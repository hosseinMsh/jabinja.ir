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
  static const String baseUrl = 'https://jobinja.ir';
  static const String apiBase = '$baseUrl/api/v10';

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
      'X-Requested-With': 'XMLHttpRequest',
    };
    if (auth) {
      final token = await _sessionManager.getToken();
      if (token != null) headers['Authorization'] = 'Bearer $token';
    }
    return headers;
  }

  Uri _uri(String path, [Map<String, String?>? query]) {
    final normalized = path.startsWith('/') ? path : '/$path';
    final params = <String, String>{};
    query?.forEach((key, value) {
      if (value != null && value.isNotEmpty) params[key] = value;
    });
    return Uri.parse('$apiBase$normalized').replace(queryParameters: params.isEmpty ? null : params);
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
      late final http.Response response;
      switch (method) {
        case 'POST':
          response = await _client.post(uri, headers: headers, body: jsonEncode(body ?? {})).timeout(const Duration(seconds: 15));
          break;
        case 'PUT':
          response = await _client.put(uri, headers: headers, body: jsonEncode(body ?? {})).timeout(const Duration(seconds: 15));
          break;
        case 'DELETE':
          response = await _client.delete(uri, headers: headers, body: body == null ? null : jsonEncode(body)).timeout(const Duration(seconds: 15));
          break;
        default:
          response = await _client.get(uri, headers: headers).timeout(const Duration(seconds: 15));
      }
      final decoded = _decode(response.body);
      if (response.statusCode >= 200 && response.statusCode < 300) {
        return ApiResponse.success(decoded, message: _message(decoded));
      }
      return ApiResponse.error(
        _message(decoded) ?? 'API ${response.statusCode}: $method ${uri.path}',
        statusCode: response.statusCode,
      );
    } on TimeoutException {
      return ApiResponse.error('Timeout: $method ${uri.path}');
    } catch (error) {
      return ApiResponse.error('Network error: ${error.runtimeType} در ${uri.path}');
    }
  }

  Future<ApiResponse<dynamic>> _first(List<Future<ApiResponse<dynamic>> Function()> calls) async {
    ApiResponse<dynamic>? last;
    for (final call in calls) {
      final response = await call();
      if (response.success) return response;
      last = response;
      if (response.statusCode != 404 && response.statusCode != 405) break;
    }
    return last ?? ApiResponse.error('پاسخی از API دریافت نشد');
  }

  dynamic _decode(String body) {
    if (body.trim().isEmpty) return <String, dynamic>{};
    try {
      return jsonDecode(body);
    } catch (_) {
      return {'raw': body};
    }
  }

  String? _message(dynamic value) {
    if (value is Map) {
      for (final key in ['message', 'error', 'detail', 'title']) {
        final item = value[key];
        if (item != null && item.toString().trim().isNotEmpty) return item.toString();
      }
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

  int _int(dynamic value) {
    if (value is int) return value;
    return int.tryParse(_text(value)) ?? 0;
  }

  Company _company(dynamic value) {
    final map = _map(value);
    return Company.fromJson({
      'id': map['id'] ?? map['company_id'] ?? map['slug'] ?? '',
      'name': map['name'] ?? map['title'] ?? map['company_name'] ?? '',
      'slug': map['slug'] ?? map['company_slug'] ?? map['id']?.toString() ?? '',
      'logo_url': map['logo_url'] ?? map['logo'] ?? map['avatar_url'],
      'cover_url': map['cover_url'] ?? map['cover'],
      'industry': map['industry'] ?? map['category'],
      'description': map['description'] ?? map['about'],
      'website': map['website'] ?? map['url'],
      'location': map['location'] ?? map['city'] ?? map['province'],
      'employee_count': map['employee_count'] ?? map['employees_count'],
      'popularity': map['popularity'],
      'job_variety': map['job_variety'],
      'resume_review': map['resume_review'],
    });
  }

  Job _job(dynamic value) {
    final map = _map(value);
    final id = _text(map['id'] ?? map['job_id'] ?? map['short_id'] ?? map['slug']);
    final company = _company(map['company'] ?? map['organization'] ?? map['employer'] ?? {
      'id': map['company_id'],
      'name': map['company_name'],
      'slug': map['company_slug'],
      'logo_url': map['company_logo'],
    });
    if (map['is_favorite'] == true || map['is_saved'] == true || map['saved'] == true) _favoriteJobIds.add(id);
    if (map['is_applied'] == true || map['applied'] == true || map['has_applied'] == true) _appliedJobIds.add(id);
    return Job.fromJson({
      'id': id,
      'short_id': map['short_id'] ?? map['code'] ?? id,
      'title': map['title'] ?? map['name'] ?? map['position_title'] ?? '',
      'company': company.toJson(),
      'location': map['location'] ?? map['city'] ?? map['province'] ?? map['region'] ?? '',
      'contract_type': map['contract_type'] ?? map['employment_type'] ?? map['type'],
      'salary_display': map['salary_display'] ?? map['salary'] ?? map['salary_text'],
      'experience_level': map['experience_level'] ?? map['experience'],
      'published_at': map['published_at'] ?? map['created_at'] ?? map['date'],
      'relative_time': map['relative_time'] ?? map['published_ago'],
      'is_remote': map['is_remote'] == true || _text(map['contract_type']).contains('دورکاری'),
      'is_premium': map['is_premium'] == true || map['premium'] == true,
      'category': map['category'] ?? map['job_category'],
      'description': map['description'] ?? map['body'] ?? map['requirements'],
      'skills': map['skills'] is List ? map['skills'] : null,
      'benefits': map['benefits'] is List ? map['benefits'] : null,
      'min_salary': map['min_salary'],
      'max_salary': map['max_salary'],
    });
  }

  User _user(dynamic value, {String? token}) {
    final map = _map(_payload(value));
    final userMap = _map(map['user']).isNotEmpty ? _map(map['user']) : map;
    final resume = _map(userMap['resume']);
    final extractedToken = token ?? _text(map['token'] ?? map['access_token'] ?? userMap['token']);
    return User.fromJson({
      'id': _int(userMap['id']),
      'name': userMap['name'] ?? userMap['full_name'] ?? userMap['display_name'] ?? '',
      'email': userMap['email'] ?? '',
      'token': extractedToken.isEmpty ? null : extractedToken,
      'phone': userMap['phone'] ?? userMap['mobile'],
      'avatar_url': userMap['avatar_url'] ?? userMap['avatar'],
      'resume_slug': userMap['resume_slug'] ?? resume['slug'],
      'resume_score': _int(userMap['resume_score'] ?? resume['score']),
      'applied_jobs_count': _int(userMap['applied_jobs_count'] ?? userMap['applications_count']),
      'saved_jobs_count': _int(userMap['saved_jobs_count'] ?? userMap['favorites_count'] ?? userMap['saved_count']),
    });
  }

  User _localUser(String name, String email, {String? token}) {
    return User(
      id: DateTime.now().millisecondsSinceEpoch,
      name: name,
      email: email,
      token: token ?? 'local_${DateTime.now().millisecondsSinceEpoch}',
      resumeSlug: email.split('@').first.replaceAll(RegExp(r'[^a-zA-Z0-9_-]'), '-'),
      resumeScore: 0,
      appliedJobsCount: _appliedJobIds.length,
      savedJobsCount: _favoriteJobIds.length,
    );
  }

  @override
  Future<ApiResponse<User>> login(String email, String password) async {
    final response = await _first([
      () => _request('POST', '/auth/login', body: {'email': email, 'password': password}, auth: false),
      () => _request('POST', '/login', body: {'email': email, 'password': password}, auth: false),
      () => _request('POST', '/user/login', body: {'email': email, 'password': password}, auth: false),
    ]);
    if (response.success) {
      final user = _user(response.data);
      await _sessionManager.saveSession(user);
      return ApiResponse.success(user, message: response.message ?? 'ورود با موفقیت انجام شد');
    }
    final cached = await _sessionManager.getCachedUser();
    if (cached != null && cached.email == email) {
      return ApiResponse.success(cached, message: 'ورود با session ذخیره‌شده انجام شد');
    }
    return ApiResponse.error(response.message ?? 'خطا در ورود', statusCode: response.statusCode);
  }

  @override
  Future<ApiResponse<User>> signup(String name, String email, String password) async {
    final body = {'name': name, 'email': email, 'password': password, 'password_confirmation': password};
    final response = await _first([
      () => _request('POST', '/auth/register', body: body, auth: false),
      () => _request('POST', '/register', body: body, auth: false),
      () => _request('POST', '/signup', body: body, auth: false),
    ]);
    if (response.success) {
      final user = _user(response.data);
      await _sessionManager.saveSession(user);
      return ApiResponse.success(user, message: response.message ?? 'ثبت‌نام با موفقیت انجام شد');
    }

    // Jobinja does not expose a public registration endpoint for this student clone.
    // Keep the app usable by creating a persistent local session, while all job/profile
    // data requests still go through RealApiService and the remote API.
    final user = _localUser(name, email);
    await _sessionManager.saveSession(user);
    return ApiResponse.success(user, message: 'حساب محلی ساخته شد؛ API ثبت‌نام عمومی پاسخ نداد: ${response.message}');
  }

  @override
  Future<ApiResponse<void>> logout() async {
    await _first([() => _request('POST', '/auth/logout'), () => _request('POST', '/logout')]);
    await _sessionManager.clearSession();
    _favoriteJobIds.clear();
    _appliedJobIds.clear();
    return ApiResponse.success(null, message: 'با موفقیت خارج شدید');
  }

  @override
  Future<ApiResponse<List<Job>>> getJobs({int page = 1, String? keyword, String? location}) async {
    final query = {'page': '$page', 'q': keyword, 'keyword': keyword, 'location': location};
    final response = await _first([
      () => _request('GET', '/jobs', query: query, auth: false),
      () => _request('GET', '/job', query: query, auth: false),
      () => _request('GET', '/job/search', query: query, auth: false),
    ]);
    if (!response.success) return ApiResponse.error(response.message ?? 'خطا در دریافت آگهی‌ها', statusCode: response.statusCode);
    return ApiResponse.success(_items(response.data).map(_job).toList());
  }

  @override
  Future<ApiResponse<List<Job>>> getJobsWithFilter(JobFilter filter) async {
    final query = {
      'page': '${filter.page}',
      'q': filter.keyword,
      'keyword': filter.keyword,
      'location': filter.location,
      'category': filter.category,
      'contract_type': filter.contractType,
      'remote': filter.isRemote == true ? '1' : null,
    };
    final response = await _first([
      () => _request('GET', '/jobs', query: query, auth: false),
      () => _request('GET', '/job', query: query, auth: false),
      () => _request('GET', '/job/search', query: query, auth: false),
    ]);
    if (!response.success) return ApiResponse.error(response.message ?? 'نتیجه‌ای یافت نشد', statusCode: response.statusCode);
    return ApiResponse.success(_items(response.data).map(_job).toList());
  }

  @override
  Future<ApiResponse<Job>> getJobDetail(String jobId) async {
    final response = await _first([
      () => _request('GET', '/jobs/$jobId', auth: false),
      () => _request('GET', '/job/$jobId', auth: false),
      () => _request('GET', '/job/detail/$jobId', auth: false),
    ]);
    if (!response.success) return ApiResponse.error(response.message ?? 'آگهی مورد نظر یافت نشد', statusCode: response.statusCode);
    return ApiResponse.success(_job(_payload(response.data)));
  }

  @override
  Future<ApiResponse<Company>> getCompany(String slug) async {
    final response = await _first([
      () => _request('GET', '/companies/$slug', auth: false),
      () => _request('GET', '/company/$slug', auth: false),
    ]);
    if (!response.success) return ApiResponse.error(response.message ?? 'شرکت مورد نظر یافت نشد', statusCode: response.statusCode);
    return ApiResponse.success(_company(_payload(response.data)));
  }

  @override
  Future<ApiResponse<List<Job>>> getCompanyJobs(String slug) async {
    final response = await _first([
      () => _request('GET', '/companies/$slug/jobs', auth: false),
      () => _request('GET', '/company/$slug/jobs', auth: false),
    ]);
    if (!response.success) return ApiResponse.error(response.message ?? 'خطا در دریافت آگهی‌های شرکت', statusCode: response.statusCode);
    return ApiResponse.success(_items(response.data).map(_job).toList());
  }

  @override
  Future<ApiResponse<User>> getProfile() async {
    final cached = await _sessionManager.getCachedUser();
    final response = await _first([
      () => _request('GET', '/profile'),
      () => _request('GET', '/me'),
      () => _request('GET', '/user/profile'),
    ]);
    if (response.success) {
      final user = _user(response.data, token: await _sessionManager.getToken());
      await _sessionManager.saveSession(user);
      return ApiResponse.success(user);
    }
    if (cached != null) return ApiResponse.success(cached);
    return ApiResponse.error(response.message ?? 'کاربر وارد نشده است', statusCode: response.statusCode);
  }

  @override
  Future<ApiResponse<List<Job>>> getAppliedJobs() async {
    final response = await _first([
      () => _request('GET', '/applications'),
      () => _request('GET', '/applied-jobs'),
      () => _request('GET', '/user/applications'),
    ]);
    if (!response.success) return ApiResponse.success(<Job>[]);
    final jobs = _items(response.data).map(_job).toList();
    _appliedJobIds..clear()..addAll(jobs.map((job) => job.id));
    return ApiResponse.success(jobs);
  }

  @override
  Future<ApiResponse<void>> applyToJob(String jobId) async {
    final response = await _first([
      () => _request('POST', '/jobs/$jobId/apply'),
      () => _request('POST', '/job/$jobId/apply'),
      () => _request('POST', '/applications', body: {'job_id': jobId}),
    ]);
    if (!response.success) return ApiResponse.error(response.message ?? 'خطا در ارسال درخواست', statusCode: response.statusCode);
    _appliedJobIds.add(jobId);
    return ApiResponse.success(null, message: response.message ?? 'رزومه با موفقیت ارسال شد');
  }

  @override
  Future<ApiResponse<List<Job>>> getFavoriteJobs() async {
    final response = await _first([
      () => _request('GET', '/favorites'),
      () => _request('GET', '/saved-jobs'),
      () => _request('GET', '/user/favorites'),
    ]);
    if (!response.success) return ApiResponse.success(<Job>[]);
    final jobs = _items(response.data).map(_job).toList();
    _favoriteJobIds..clear()..addAll(jobs.map((job) => job.id));
    return ApiResponse.success(jobs);
  }

  @override
  Future<ApiResponse<void>> toggleFavorite(String jobId) async {
    final exists = _favoriteJobIds.contains(jobId);
    final response = exists
        ? await _first([() => _request('DELETE', '/favorites/$jobId'), () => _request('DELETE', '/saved-jobs/$jobId'), () => _request('DELETE', '/jobs/$jobId/favorite')])
        : await _first([() => _request('POST', '/favorites', body: {'job_id': jobId}), () => _request('POST', '/saved-jobs', body: {'job_id': jobId}), () => _request('POST', '/jobs/$jobId/favorite')]);
    if (!response.success) return ApiResponse.error(response.message ?? 'خطا در تغییر وضعیت نشان‌شده', statusCode: response.statusCode);
    if (exists) {
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
  Future<ApiResponse<List<Company>>> getTopCompanies() async {
    final response = await _first([
      () => _request('GET', '/companies/top', auth: false),
      () => _request('GET', '/companies', auth: false),
      () => _request('GET', '/company/top', auth: false),
    ]);
    if (!response.success) return ApiResponse.error(response.message ?? 'خطا در دریافت شرکت‌ها', statusCode: response.statusCode);
    return ApiResponse.success(_items(response.data).map(_company).toList());
  }

  @override
  Future<ApiResponse<List<Job>>> getRecommendedJobs() async {
    final response = await _first([() => _request('GET', '/jobs/recommended'), () => _request('GET', '/job/recommended')]);
    if (response.success) return ApiResponse.success(_items(response.data).map(_job).toList());
    return getJobs(page: 1);
  }

  Future<ApiResponse<void>> saveResume(Map<String, dynamic> resume) async {
    final response = await _first([
      () => _request('POST', '/resume', body: resume),
      () => _request('PUT', '/resume', body: resume),
      () => _request('POST', '/user/resume', body: resume),
    ]);
    if (!response.success) return ApiResponse.error(response.message ?? 'خطا در ذخیره رزومه', statusCode: response.statusCode);
    return ApiResponse.success(null, message: response.message ?? 'رزومه با موفقیت ذخیره شد');
  }

  Future<ApiResponse<List<String>>> getCategories() async {
    final response = await _first([() => _request('GET', '/job/categories', auth: false), () => _request('GET', '/categories', auth: false)]);
    if (!response.success) return ApiResponse.error('خطا در دریافت دسته‌بندی‌ها');
    final list = _items(response.data).map((item) => item is Map ? _text(item['name'] ?? item['title']) : _text(item)).where((item) => item.isNotEmpty).toList();
    return ApiResponse.success(list);
  }

  Future<ApiResponse<List<Map<String, dynamic>>>> getRawCategories() async {
    final response = await _request('GET', '/job/categories', auth: false);
    if (!response.success) return ApiResponse.error('خطا در دریافت دسته‌بندی‌ها');
    return ApiResponse.success(_items(response.data).map(_map).toList());
  }

  Future<ApiResponse<List<String>>> getProvinces() async {
    final response = await _request('GET', '/region/province', auth: false);
    if (!response.success) return ApiResponse.error('خطا در دریافت استان‌ها');
    final list = _items(response.data).map((item) => item is Map ? _text(item['name'] ?? item['title']) : _text(item)).where((item) => item.isNotEmpty).toList();
    return ApiResponse.success(list);
  }

  Future<ApiResponse<List<Map<String, dynamic>>>> getRawProvinces() async {
    final response = await _request('GET', '/region/province', auth: false);
    if (!response.success) return ApiResponse.error('خطا در دریافت استان‌ها');
    return ApiResponse.success(_items(response.data).map(_map).toList());
  }

  void dispose() => _client.close();
}
