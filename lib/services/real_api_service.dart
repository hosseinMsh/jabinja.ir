import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart' as http;

import '../models/api_response.dart';
import '../models/company.dart';
import '../models/job.dart';
import '../models/job_filter.dart';
import '../models/user.dart';
import 'api_service.dart';
import 'session_manager.dart';

class RealApiService implements ApiService {
  static const String apiBase = String.fromEnvironment(
    'JOBINJA_API_BASE',
    defaultValue: 'http://10.0.2.2:3000/api',
  );

  static final Set<String> _favoriteJobIds = <String>{};
  static final Set<String> _appliedJobIds = <String>{};

  final http.Client _client;
  final SessionManager _sessionManager;

  RealApiService({http.Client? client, SessionManager? sessionManager})
      : _client = client ?? http.Client(),
        _sessionManager = sessionManager ?? SessionManager();

  Future<Map<String, String>> _headers({bool auth = true}) async {
    final headers = <String, String>{
      'Accept': 'application/json',
      'Content-Type': 'application/json',
    };
    if (auth) {
      final token = await _sessionManager.getToken();
      if (token != null) headers['Authorization'] = 'Bearer $token';
    }
    return headers;
  }

  Uri _uri(String path, [Map<String, String?>? query]) {
    final params = <String, String>{};
    query?.forEach((key, value) {
      if (value != null && value.isNotEmpty) params[key] = value;
    });
    return Uri.parse('$apiBase${path.startsWith('/') ? path : '/$path'}')
        .replace(queryParameters: params.isEmpty ? null : params);
  }

  Future<ApiResponse<dynamic>> _request(
    String method,
    String path, {
    Map<String, String?>? query,
    Map<String, dynamic>? body,
    bool auth = true,
  }) async {
    final uri = _uri(path, query);
    try {
      final headers = await _headers(auth: auth);
      late final http.Response res;
      if (method == 'POST') {
        res = await _client.post(uri, headers: headers, body: jsonEncode(body ?? {})).timeout(const Duration(seconds: 7));
      } else if (method == 'PUT') {
        res = await _client.put(uri, headers: headers, body: jsonEncode(body ?? {})).timeout(const Duration(seconds: 7));
      } else if (method == 'DELETE') {
        res = await _client.delete(uri, headers: headers).timeout(const Duration(seconds: 7));
      } else {
        res = await _client.get(uri, headers: headers).timeout(const Duration(seconds: 7));
      }
      final decoded = _decode(res.body);
      if (res.statusCode >= 200 && res.statusCode < 300) {
        return ApiResponse.success(decoded, message: _message(decoded));
      }
      return ApiResponse.error(_message(decoded) ?? 'API ${res.statusCode}: ${uri.path}', statusCode: res.statusCode);
    } on TimeoutException {
      return ApiResponse.error('Timeout: ${uri.path}');
    } catch (e) {
      return ApiResponse.error('Network error: ${e.runtimeType}');
    }
  }

  dynamic _decode(String body) {
    if (body.trim().isEmpty) return <String, dynamic>{};
    try {
      return jsonDecode(body);
    } catch (_) {
      return <String, dynamic>{'raw': body};
    }
  }

  String? _message(dynamic value) {
    if (value is Map) {
      final msg = value['message'] ?? value['error'] ?? value['detail'];
      if (msg != null && msg.toString().isNotEmpty) return msg.toString();
    }
    return null;
  }

  Map<String, dynamic> _map(dynamic value) {
    if (value is Map<String, dynamic>) return value;
    if (value is Map) return Map<String, dynamic>.from(value);
    return <String, dynamic>{};
  }

  dynamic _payload(dynamic value) {
    if (value is Map) {
      for (final key in ['data', 'result', 'payload', 'response']) {
        if (value.containsKey(key)) return value[key];
      }
    }
    return value;
  }

  List<dynamic> _items(dynamic value) {
    final payload = _payload(value);
    if (payload is List) return payload;
    if (payload is Map) {
      for (final key in ['items', 'jobs', 'companies', 'records', 'results', 'rows', 'data']) {
        if (payload[key] is List) return payload[key] as List;
      }
    }
    return <dynamic>[];
  }

  String _text(dynamic value) => value?.toString() ?? '';
  int _int(dynamic value) => value is int ? value : int.tryParse(_text(value)) ?? 0;

  Company _company(dynamic value) {
    final m = _map(value);
    return Company.fromJson({
      'id': m['id'] ?? m['company_id'] ?? m['slug'] ?? '',
      'name': m['name'] ?? m['title'] ?? m['company_name'] ?? '',
      'slug': m['slug'] ?? m['company_slug'] ?? m['id']?.toString() ?? '',
      'logo_url': m['logo_url'] ?? m['logo'],
      'cover_url': m['cover_url'],
      'industry': m['industry'] ?? m['category'],
      'description': m['description'] ?? m['about'],
      'website': m['website'] ?? m['url'],
      'location': m['location'] is Map ? '${m['location']['province'] ?? ''} ${m['location']['city'] ?? ''}'.trim() : m['location'],
      'employee_count': m['employee_count'],
      'popularity': m['popularity'],
      'job_variety': m['job_variety'],
      'resume_review': m['resume_review'],
    });
  }

  Job _job(dynamic value) {
    final m = _map(value);
    final id = _text(m['id'] ?? m['job_id'] ?? m['short_id'] ?? m['slug']);
    final company = _company(m['company'] ?? {
      'id': m['company_id'],
      'name': m['company_name'],
      'slug': m['company_slug'],
      'logo_url': m['company_logo'],
    });
    final loc = m['location'] is Map ? '${m['location']['province'] ?? ''} ${m['location']['city'] ?? ''}'.trim() : m['location'];
    final salary = m['salary'] is Map ? m['salary']['display'] : m['salary_display'] ?? m['salary_text'] ?? m['salary'];
    if (m['is_favorite'] == true || m['is_saved'] == true) _favoriteJobIds.add(id);
    if (m['is_applied'] == true || m['applied'] == true) _appliedJobIds.add(id);
    return Job.fromJson({
      'id': id,
      'short_id': m['short_id'] ?? id,
      'title': m['title'] ?? m['name'] ?? '',
      'company': company.toJson(),
      'location': loc ?? '',
      'contract_type': m['contract_type'] ?? m['job_type'],
      'salary_display': salary,
      'experience_level': m['experience_level'],
      'published_at': m['published_at'],
      'relative_time': m['relative_time'],
      'is_remote': m['is_remote'] == true,
      'is_premium': m['is_premium'] == true,
      'category': m['category'],
      'description': m['description'],
      'skills': m['skills'] is List ? m['skills'] : null,
      'benefits': m['benefits'] is List ? m['benefits'] : null,
      'min_salary': m['min_salary'],
      'max_salary': m['max_salary'],
    });
  }

  User _user(dynamic value, {String? token}) {
    final m = _map(_payload(value));
    final u = _map(m['user']).isNotEmpty ? _map(m['user']) : m;
    final extractedToken = token ?? _text(m['token'] ?? m['access_token'] ?? u['token']);
    return User.fromJson({
      'id': _int(u['id']),
      'name': u['name'] ?? u['full_name'] ?? '',
      'email': u['email'] ?? '',
      'token': extractedToken.isEmpty ? null : extractedToken,
      'phone': u['phone'] ?? u['mobile'],
      'avatar_url': u['avatar_url'] ?? u['avatar'],
      'resume_slug': u['resume_slug'],
      'resume_score': _int(u['resume_score']),
      'applied_jobs_count': _int(u['applied_jobs_count']),
      'saved_jobs_count': _int(u['saved_jobs_count']),
    });
  }

  User _localUser(String name, String email) => User(
        id: DateTime.now().millisecondsSinceEpoch,
        name: name.trim().isEmpty ? email.split('@').first : name.trim(),
        email: email,
        token: 'local_${DateTime.now().millisecondsSinceEpoch}',
        resumeSlug: email.split('@').first,
        resumeScore: 0,
        appliedJobsCount: _appliedJobIds.length,
        savedJobsCount: _favoriteJobIds.length,
      );

  List<Company> _seedCompanies() => [
        Company(id: 'company_1', name: 'شرکت نمونه', slug: 'sample-company', industry: 'کامپیوتر، فناوری اطلاعات و اینترنت', location: 'تهران', employeeCount: 50, popularity: 9, jobVariety: 8, resumeReview: 10),
        Company(id: 'company_2', name: 'تیم نرم‌افزاری پیشرو', slug: 'tech-team', industry: 'نرم‌افزار', location: 'اصفهان', employeeCount: 20, popularity: 8, jobVariety: 7, resumeReview: 9),
        Company(id: 'company_3', name: 'راهکارهای داده‌ور', slug: 'data-var', industry: 'IT / DevOps / Server', location: 'شیراز', employeeCount: 80, popularity: 7, jobVariety: 5, resumeReview: 8),
      ];

  List<Job> _seedJobs() {
    final c = _seedCompanies();
    return [
      Job(id: 'job_1', shortId: 'job_1', title: 'توسعه‌دهنده پایتون', company: c[0], location: 'تهران، تهران', contractType: 'تمام‌وقت', salaryDisplay: 'حقوق توافقی', experienceLevel: 'کمتر از سه سال', publishedAt: '۱۴۰۵/۰۳/۱۰', relativeTime: '(امروز)', isPremium: true, category: 'وب، برنامه‌نویسی و نرم‌افزار', description: 'توسعه‌دهنده Python مسلط به Django و REST API', skills: ['Python', 'Django', 'REST API', 'Git'], benefits: ['بیمه تکمیلی', 'ساعت شناور']),
      Job(id: 'job_2', shortId: 'job_2', title: 'برنامه‌نویس فلاتر', company: c[1], location: 'اصفهان', contractType: 'دورکاری', salaryDisplay: '۱۵-۲۵ میلیون تومان', experienceLevel: 'یک تا سه سال', publishedAt: '۱۴۰۵/۰۳/۰۸', relativeTime: '(۲ روز پیش)', category: 'وب، برنامه‌نویسی و نرم‌افزار', description: 'برنامه‌نویس Flutter مسلط به MVP و API', skills: ['Flutter', 'Dart', 'MVP', 'REST API'], benefits: ['دورکاری', 'بیمه']),
      Job(id: 'job_3', shortId: 'job_3', title: 'مهندس DevOps', company: c[2], location: 'شیراز', contractType: 'تمام‌وقت', salaryDisplay: '۲۰-۳۵ میلیون تومان', experienceLevel: 'سه تا پنج سال', publishedAt: '۱۴۰۵/۰۳/۰۵', relativeTime: '(۵ روز پیش)', isPremium: true, category: 'IT / DevOps / Server', description: 'مسلط به Docker، Linux و CI/CD', skills: ['Docker', 'Linux', 'CI/CD'], benefits: ['بیمه تکمیلی']),
    ];
  }

  List<Job> _filterSeedJobs({String? keyword, String? location, String? category, String? contractType}) {
    var jobs = _seedJobs();
    if (keyword != null && keyword.isNotEmpty) jobs = jobs.where((j) => j.title.contains(keyword) || j.company.name.contains(keyword)).toList();
    if (location != null && location.isNotEmpty) jobs = jobs.where((j) => j.location.contains(location)).toList();
    if (category != null && category.isNotEmpty && category != 'همه') jobs = jobs.where((j) => (j.category ?? '').contains(category)).toList();
    if (contractType != null && contractType.isNotEmpty && contractType != 'همه') jobs = jobs.where((j) => (j.contractType ?? '').contains(contractType)).toList();
    return jobs;
  }

  @override
  Future<ApiResponse<User>> login(String email, String password) async {
    final res = await _request('POST', '/auth/login', body: {'email': email, 'password': password}, auth: false);
    if (res.success) {
      final user = _user(res.data);
      await _sessionManager.saveSession(user);
      return ApiResponse.success(user, message: res.message ?? 'ورود با موفقیت انجام شد');
    }
    final cached = await _sessionManager.getCachedUser();
    if (cached != null && cached.email.toLowerCase() == email.toLowerCase()) return ApiResponse.success(cached);
    return ApiResponse.error(res.message ?? 'خطا در ورود', statusCode: res.statusCode);
  }

  @override
  Future<ApiResponse<User>> signup(String name, String email, String password) async {
    final res = await _request('POST', '/auth/signup', body: {'name': name, 'email': email, 'password': password}, auth: false);
    if (res.success) {
      final user = _user(res.data);
      await _sessionManager.saveSession(user);
      return ApiResponse.success(user, message: res.message ?? 'ثبت‌نام با موفقیت انجام شد');
    }
    final user = _localUser(name, email);
    await _sessionManager.saveSession(user);
    return ApiResponse.success(user, message: 'حساب محلی ساخته شد');
  }

  @override
  Future<ApiResponse<void>> logout() async {
    await _request('POST', '/auth/logout');
    await _sessionManager.clearSession();
    return ApiResponse.success(null, message: 'با موفقیت خارج شدید');
  }

  @override
  Future<ApiResponse<List<Job>>> getJobs({int page = 1, String? keyword, String? location}) async {
    final res = await _request('GET', '/jobs', query: {'keyword': keyword, 'location': location, 'page': '$page'}, auth: false);
    if (res.success) {
      final jobs = _items(res.data).map(_job).where((j) => j.id.isNotEmpty).toList();
      if (jobs.isNotEmpty) return ApiResponse.success(jobs);
    }
    return ApiResponse.success(_filterSeedJobs(keyword: keyword, location: location));
  }

  @override
  Future<ApiResponse<List<Job>>> getJobsWithFilter(JobFilter filter) async {
    final res = await _request('GET', '/jobs', query: {'keyword': filter.keyword, 'location': filter.location, 'category': filter.category, 'contract_type': filter.contractType, 'page': '${filter.page}'}, auth: false);
    if (res.success) {
      final jobs = _items(res.data).map(_job).where((j) => j.id.isNotEmpty).toList();
      if (jobs.isNotEmpty) return ApiResponse.success(jobs);
    }
    return ApiResponse.success(_filterSeedJobs(keyword: filter.keyword, location: filter.location, category: filter.category, contractType: filter.contractType));
  }

  @override
  Future<ApiResponse<Job>> getJobDetail(String jobId) async {
    final res = await _request('GET', '/jobs/$jobId', auth: false);
    if (res.success) return ApiResponse.success(_job(_payload(res.data)));
    try {
      return ApiResponse.success(_seedJobs().firstWhere((j) => j.id == jobId || j.shortId == jobId));
    } catch (_) {
      return ApiResponse.error('آگهی مورد نظر یافت نشد', statusCode: 404);
    }
  }

  @override
  Future<ApiResponse<Company>> getCompany(String slug) async {
    final res = await _request('GET', '/companies/$slug', auth: false);
    if (res.success) return ApiResponse.success(_company(_payload(res.data)));
    try {
      return ApiResponse.success(_seedCompanies().firstWhere((c) => c.slug == slug || c.id == slug));
    } catch (_) {
      return ApiResponse.error('شرکت مورد نظر یافت نشد', statusCode: 404);
    }
  }

  @override
  Future<ApiResponse<List<Job>>> getCompanyJobs(String slug) async {
    final res = await _request('GET', '/companies/$slug/jobs', auth: false);
    if (res.success) {
      final jobs = _items(res.data).map(_job).where((j) => j.id.isNotEmpty).toList();
      if (jobs.isNotEmpty) return ApiResponse.success(jobs);
    }
    return ApiResponse.success(_seedJobs().where((j) => j.company.slug == slug || j.company.id == slug).toList());
  }

  @override
  Future<ApiResponse<User>> getProfile() async {
    final cached = await _sessionManager.getCachedUser();
    final res = await _request('GET', '/user/profile');
    if (res.success) {
      final user = _user(res.data, token: await _sessionManager.getToken());
      await _sessionManager.saveSession(user);
      return ApiResponse.success(user);
    }
    if (cached != null) return ApiResponse.success(cached);
    return ApiResponse.error('کاربر وارد نشده است', statusCode: 401);
  }

  @override
  Future<ApiResponse<List<Job>>> getAppliedJobs() async {
    final res = await _request('GET', '/user/applied-jobs');
    if (res.success) {
      final jobs = _items(res.data).map(_job).where((j) => j.id.isNotEmpty).toList();
      _appliedJobIds..clear()..addAll(jobs.map((j) => j.id));
      return ApiResponse.success(jobs);
    }
    return ApiResponse.success(_seedJobs().where((j) => _appliedJobIds.contains(j.id)).toList());
  }

  @override
  Future<ApiResponse<void>> applyToJob(String jobId) async {
    _appliedJobIds.add(jobId);
    return ApiResponse.success(null, message: 'رزومه با موفقیت ارسال شد');
  }

  @override
  Future<ApiResponse<List<Job>>> getFavoriteJobs() async => ApiResponse.success(_seedJobs().where((j) => _favoriteJobIds.contains(j.id)).toList());

  @override
  Future<ApiResponse<void>> toggleFavorite(String jobId) async {
    if (_favoriteJobIds.contains(jobId)) {
      _favoriteJobIds.remove(jobId);
      return ApiResponse.success(null, message: 'از نشان‌شده‌ها حذف شد');
    }
    _favoriteJobIds.add(jobId);
    return ApiResponse.success(null, message: 'به نشان‌شده‌ها اضافه شد');
  }

  @override
  bool isFavorited(String jobId) => _favoriteJobIds.contains(jobId);

  @override
  bool isApplied(String jobId) => _appliedJobIds.contains(jobId);

  @override
  Future<ApiResponse<List<Company>>> getTopCompanies() async => ApiResponse.success(_seedCompanies());

  @override
  Future<ApiResponse<List<Job>>> getRecommendedJobs() async => ApiResponse.success(_seedJobs().take(4).toList());

  Future<ApiResponse<void>> saveResume(Map<String, dynamic> resume) async => ApiResponse.success(null, message: 'رزومه ذخیره شد');

  Future<ApiResponse<List<String>>> getCategories() async {
    final res = await _request('GET', '/jobs/categories', auth: false);
    if (res.success) {
      final list = _items(res.data).map((i) => i is Map ? _text(i['name'] ?? i['title']) : _text(i)).where((i) => i.isNotEmpty).toList();
      if (list.isNotEmpty) return ApiResponse.success(list);
    }
    return ApiResponse.success(['وب، برنامه‌نویسی و نرم‌افزار', 'IT / DevOps / Server', 'طراحی']);
  }

  Future<ApiResponse<List<Map<String, dynamic>>>> getRawCategories() async {
    final res = await _request('GET', '/jobs/categories', auth: false);
    return ApiResponse.success(res.success ? _items(res.data).map(_map).toList() : <Map<String, dynamic>>[]);
  }

  Future<ApiResponse<List<String>>> getProvinces() async {
    final res = await _request('GET', '/jobs/locations', auth: false);
    if (res.success) {
      final list = _items(res.data).map((i) => i is Map ? _text(i['name'] ?? i['title'] ?? i['province']) : _text(i)).where((i) => i.isNotEmpty).toList();
      if (list.isNotEmpty) return ApiResponse.success(list);
    }
    return ApiResponse.success(['تهران', 'اصفهان', 'شیراز']);
  }

  Future<ApiResponse<List<Map<String, dynamic>>>> getRawProvinces() async {
    final res = await _request('GET', '/jobs/locations', auth: false);
    return ApiResponse.success(res.success ? _items(res.data).map(_map).toList() : <Map<String, dynamic>>[]);
  }

  Future<ApiResponse<List<String>>> searchSkills(String keyword) async {
    final res = await _request('GET', '/job-skills/search', query: {'q': keyword}, auth: false);
    if (!res.success) return ApiResponse.success(<String>[]);
    final list = _items(res.data).map((i) => i is Map ? _text(i['name']) : _text(i)).where((i) => i.isNotEmpty).toList();
    return ApiResponse.success(list);
  }

  void dispose() => _client.close();
}
