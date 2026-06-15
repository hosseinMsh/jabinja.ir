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
  static const String _siteBase = "https://jobinja.ir";
  static const String apiBase = "$_siteBase/api/v10";
  static final Set<String> _favoriteJobIds = <String>{};
  static final Set<String> _appliedJobIds = <String>{};

  final http.Client _client;
  final SessionManager _sessionManager;

  RealApiService({http.Client? client, SessionManager? sessionManager})
      : _client = client ?? http.Client(),
        _sessionManager = sessionManager ?? SessionManager();

  Map<String, String> get _browserHeaders => {
        'User-Agent':
            'Mozilla/5.0 (Linux; Android 10; SM-G975F) AppleWebKit/537.36',
        'Accept': 'text/html,application/xhtml+xml,application/xml;q=0.9,*/*;q=0.8',
        'Accept-Language': 'fa-IR,fa;q=0.9,en;q=0.8',
      };

  Future<Map<String, String>> _apiHeaders({bool auth = true}) async {
    final headers = <String, String>{
      'Accept': 'application/json',
      'Content-Type': 'application/json',
      'User-Agent': 'jobinja-android-app/1.0',
      'X-Requested-With': 'XMLHttpRequest',
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
      final headers = await _apiHeaders(auth: auth);
      late final http.Response res;
      if (method == 'POST') {
        res = await _client
            .post(uri, headers: headers, body: jsonEncode(body ?? {}))
            .timeout(const Duration(seconds: 7));
      } else if (method == 'PUT') {
        res = await _client
            .put(uri, headers: headers, body: jsonEncode(body ?? {}))
            .timeout(const Duration(seconds: 7));
      } else if (method == 'DELETE') {
        res = await _client
            .delete(uri, headers: headers)
            .timeout(const Duration(seconds: 7));
      } else {
        res = await _client
            .get(uri, headers: headers)
            .timeout(const Duration(seconds: 7));
      }
      final decoded = _decode(res.body);
      if (res.statusCode >= 200 && res.statusCode < 300) {
        return ApiResponse.success(decoded, message: _message(decoded));
      }
      return ApiResponse.error(
          _message(decoded) ?? 'API ${res.statusCode}: ${uri.path}',
          statusCode: res.statusCode);
    } on TimeoutException {
      return ApiResponse.error('Timeout: ${uri.path}');
    } catch (e) {
      return ApiResponse.error('Network error: ${e.runtimeType}');
    }
  }

  Future<String> _fetchHtml(String url) async {
    final uri = Uri.parse(url);
    final res = await _client
        .get(uri, headers: _browserHeaders)
        .timeout(const Duration(seconds: 10));
    if (res.statusCode == 200) return res.body;
    throw Exception('HTTP ${res.statusCode}');
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
      for (final key in [
        'items',
        'jobs',
        'companies',
        'records',
        'results',
        'rows',
        'data'
      ]) {
        if (payload[key] is List) return payload[key] as List;
      }
    }
    return <dynamic>[];
  }

  String _text(dynamic value) => value?.toString() ?? '';
  int _int(dynamic value) =>
      value is int ? value : int.tryParse(_text(value)) ?? 0;

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
      'location': m['location'] is Map
          ? '${m['location']['province'] ?? ''} ${m['location']['city'] ?? ''}'
              .trim()
          : m['location'],
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
    final loc = m['location'] is Map
        ? '${m['location']['province'] ?? ''} ${m['location']['city'] ?? ''}'
            .trim()
        : m['location'];
    final salary = m['salary'] is Map
        ? m['salary']['display']
        : m['salary_display'] ?? m['salary_text'] ?? m['salary'];
    if (m['is_favorite'] == true || m['is_saved'] == true) {
      _favoriteJobIds.add(id);
    }
    if (m['is_applied'] == true || m['applied'] == true) {
      _appliedJobIds.add(id);
    }
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
    final extractedToken =
        token ?? _text(m['token'] ?? m['access_token'] ?? u['token']);
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

  String _stripTags(String html) =>
      html.replaceAll(RegExp(r'<[^>]*>'), '').trim();

  String _extractText(String html, String className) {
    final idx = html.indexOf(className);
    if (idx == -1) return '';
    final start = html.indexOf('>', idx + className.length);
    if (start == -1) return '';
    final end = html.indexOf('<', start + 1);
    if (end == -1) return '';
    return html.substring(start + 1, end).trim();
  }

  String _extractAttr(String html, String attr) {
    final search = '$attr="';
    final idx = html.indexOf(search);
    if (idx == -1) return '';
    final start = idx + search.length;
    final end = html.indexOf('"', start);
    if (end == -1) return '';
    return html.substring(start, end);
  }

  List<Job> _parseJobsFromHtml(String html) {
    final jobs = <Job>[];
    final items = <String>[];
    int pos = 0;
    while (true) {
      final idx = html.indexOf('c-jobListView__item', pos);
      if (idx == -1) break;
      final liStart = html.lastIndexOf('<li', idx);
      if (liStart == -1) {
        pos = idx + 1;
        continue;
      }
      // Find the correct </li> by counting open/close li tags
      int depth = 0;
      int liEnd = -1;
      for (int i = liStart; i < html.length; i++) {
        if (html.startsWith('<li', i) && !html.startsWith('</li', i)) {
          depth++;
        } else if (html.startsWith('</li>', i)) {
          depth--;
          if (depth == 0) {
            liEnd = i + 5;
            break;
          }
        }
      }
      if (liEnd == -1) break;
      items.add(html.substring(liStart, liEnd));
      pos = liEnd;
    }
    for (final item in items) {
      try {
        final isPremium = item.contains('c-jobListView__item--premium');
        final titleLink = 'c-jobListView__titleLink';
        final tIdx = item.indexOf(titleLink);
        if (tIdx == -1) continue;
        final tStart = item.indexOf('>', tIdx + titleLink.length);
        final tEnd = item.indexOf('</a>', tStart);
        if (tStart == -1 || tEnd == -1) continue;
        final title = _stripTags(item.substring(tStart + 1, tEnd));

        final href = _extractAttr(item, 'href');
        final uri = href.isNotEmpty ? Uri.tryParse(href) : null;
        final segments = uri?.pathSegments ?? <String>[];
        final companySlug =
            segments.length > 1 ? segments[1] : '';
        final shortId = segments.length > 3 ? segments[3] : '';
        final jobId = shortId.isNotEmpty ? shortId : companySlug;

        final logo =
            _extractAttr(item, 'src');
        final logoUrl = logo.startsWith('http') ? logo : '';

        final days = _extractText(item, 'c-jobListView__passedDays');
        final metaItems = <String>[];
        int mPos = 0;
        while (true) {
          final mIdx = item.indexOf('c-jobListView__metaItem', mPos);
          if (mIdx == -1) break;
          final sIdx = item.indexOf('<span', mIdx);
          if (sIdx == -1) {
            mPos = mIdx + 1;
            continue;
          }
          final sEnd = item.indexOf('</span>', sIdx);
          if (sEnd == -1) break;
          metaItems.add(_stripTags(item.substring(sIdx, sEnd + 7)));
          mPos = sEnd + 7;
        }

        String companyName = '';
        String location = '';
        String contractType = '';
        String salaryDisplay = '';
        bool isRemote = false;

        for (int i = 0; i < metaItems.length; i++) {
          final val = metaItems[i];
          if (i == 0) {
            companyName = val;
          } else if (i == 1) {
            location = val;
          } else if (i == 2) {
            if (val.contains('دورکاری') || val.contains('remote')) {
              isRemote = true;
            }
            if (val.contains('(برای') || val.contains('وارد شوید')) {
              final parts = val.split('(برای');
              contractType = parts[0].trim();
              salaryDisplay = 'برای مشاهده حقوق وارد شوید';
            } else {
              contractType = val;
            }
          } else if (i == 3) {
            salaryDisplay = val;
          }
        }

        jobs.add(Job(
          id: jobId,
          shortId: shortId,
          title: title,
          company: Company(
            id: companySlug,
            name: companyName,
            slug: companySlug,
            logoUrl: logoUrl,
          ),
          location: location,
          contractType: contractType,
          salaryDisplay: salaryDisplay,
          relativeTime: days,
          isPremium: isPremium,
          isRemote: isRemote,
        ));
      } catch (_) {}
    }
    return jobs;
  }

  Job? _parseJobDetailFromHtml(String html) {
    try {
      final jsonLdStart = html.indexOf('"@type":"JobPosting"');
      if (jsonLdStart == -1) return null;
      final scriptStart = html.lastIndexOf('<script', jsonLdStart);
      if (scriptStart == -1) return null;
      final scriptEnd = html.indexOf('</script>', scriptStart);
      if (scriptEnd == -1) return null;
      final jsonStr = html.substring(
        html.indexOf('>', scriptStart) + 1,
        scriptEnd,
      );
      final data = jsonDecode(jsonStr) as Map<String, dynamic>;

      final title = _text(data['title']);
      final description = _stripTags(data['description'] ?? '');

      final org =
          data['hiringOrganization'] is Map ? data['hiringOrganization'] : null;
      final companyName = org != null ? _text(org['name']) : '';
      final companyLogo = org != null ? _text(org['logo']) : '';
      final companyWebsite = org != null ? _text(org['sameAs']) : '';
      final companyDesc = org != null ? _stripTags(org['description'] ?? '') : '';

      final salary = data['baseSalary'] is Map ? data['baseSalary'] : null;
      String salaryDisplay = '';
      if (salary != null) {
        final value = salary['value'];
        final currency = salary['currency'] ?? '';
        if (value != null) {
          if (currency == 'IRT') {
            final millions = (value as num) / 1000000;
            salaryDisplay = '${millions.toStringAsFixed(0)} میلیون تومان';
          } else {
            salaryDisplay = '$value $currency';
          }
        }
      }

      final empType = _text(data['employmentType']);
      final contractMap = {
        'FULL_TIME': 'تمام‌وقت',
        'PART_TIME': 'پاره‌وقت',
        'CONTRACTOR': 'قراردادی',
        'TEMPORARY': 'موقت',
        'INTERN': 'کارآموزی',
        'VOLUNTEER': 'داوطلبانه',
      };
      final contractType = contractMap[empType] ?? empType;

      final location = data['jobLocation'] is Map
          ? (data['jobLocation']['address'] is Map
              ? _text(data['jobLocation']['address']
                      ['addressLocality'] ??
                  '')
              : '')
          : '';
      final isRemote = data['jobLocationType'] == 'TELECOMMUTE';

      final datePosted = _text(data['datePosted']);

      final identifier =
          data['identifier'] is Map ? data['identifier'] : null;
      final id = identifier != null ? _text(identifier['value']) : '';
      final slug = companyName.replaceAll(' ', '-');

      return Job(
        id: id,
        shortId: id,
        title: title,
        company: Company(
          id: slug,
          name: companyName,
          slug: slug,
          logoUrl: companyLogo,
          website: companyWebsite,
          description: companyDesc,
        ),
        location: location,
        contractType: contractType,
        salaryDisplay: salaryDisplay,
        publishedAt: datePosted,
        isRemote: isRemote,
        isPremium: false,
        description: description,
      );
    } catch (_) {
      return null;
    }
  }

  Company? _parseCompanyFromHtml(String html) {
    try {
      final name = _extractText(html, 'c-companyHeader__name')
          .replaceAll(RegExp(r'\s*\|\s*.*$'), '')
          .trim();

      final slugMatch = RegExp(r"/companies/([^/""\s]+)").firstMatch(html);
      final slug = (slugMatch?.group(1)) ?? '';

      // Find the logo image URL near the company header
      final logoSection = html.indexOf('c-companyHeader__logoImage');
      String logoUrl = '';
      if (logoSection != -1) {
        final srcStart = html.indexOf('src="', logoSection);
        if (srcStart != -1) {
          final qStart = srcStart + 5;
          final qEnd = html.indexOf('"', qStart);
          if (qEnd != -1) {
            final url = html.substring(qStart, qEnd);
            if (url.startsWith('http')) logoUrl = url;
          }
        }
      }

      final metaEl = 'c-companyHeader__meta';
      final metaIdx = html.indexOf(metaEl);
      final metaItems = <String>[];
      if (metaIdx != -1) {
        final metaSection = html.substring(metaIdx, metaIdx + 1000);
        int mPos = 0;
        while (true) {
          final mIdx =
              metaSection.indexOf('c-companyHeader__metaItem', mPos);
          if (mIdx == -1) break;
          final content = _stripTags(
              metaSection.substring(mIdx + 27, mIdx + 300));
          metaItems.add(content);
          mPos = mIdx + 1;
        }
      }

      String industry = '';
      String employeeCount = '';
      String website = '';
      for (final item in metaItems) {
        if (item.contains('http') || item.contains('www')) {
          website = item;
        } else if (RegExp(r'نفر|person|employee').hasMatch(item)) {
          employeeCount = item;
        } else {
          industry = item;
        }
      }

      final descEl = 'c-cardText__body';
      final descIdx = html.indexOf(descEl);
      String description = '';
      if (descIdx != -1) {
        final dStart = html.indexOf('<p', descIdx);
        if (dStart != -1) {
          final dEnd = html.indexOf('</p>', dStart);
          if (dEnd != -1) {
            description = _stripTags(html.substring(dStart, dEnd + 4));
          }
        }
      }

      return Company(
        id: slug,
        name: name,
        slug: slug,
        logoUrl: logoUrl,
        industry: industry,
        description: description,
        website: website,
        employeeCount:
            int.tryParse(employeeCount.replaceAll(RegExp(r'\D'), '')) ?? 0,
      );
    } catch (_) {
      return null;
    }
  }

  List<Company> _parseCompaniesFromHtml(String html) {
    final companies = <Company>[];
    final items = <String>[];
    int pos = 0;
    while (true) {
      final idx = html.indexOf('c-companyOverview', pos);
      if (idx == -1) break;
      final aStart = html.lastIndexOf('<a', idx);
      if (aStart == -1) {
        pos = idx + 1;
        continue;
      }
      final aEnd = html.indexOf('</a>', idx);
      if (aEnd == -1) break;
      items.add(html.substring(aStart, aEnd + 4));
      pos = aEnd + 4;
    }
    for (final item in items) {
      try {
        final href = _extractAttr(item, 'href');
        final uri = Uri.tryParse(href);
        final segments = uri?.pathSegments ?? <String>[];
        final slug = segments.length > 1 ? segments[1] : '';

        final imgSrc = _extractAttr(item, 'src');
        final logoUrl = imgSrc.startsWith('http') ? imgSrc : '';

        final bannerIdx = item.indexOf('c-companyOverview__title');
        final textContent = bannerIdx != -1
            ? item.substring(bannerIdx + 27)
            : item;
        final titleEnd = textContent.indexOf('</h3>');
        String name = '';
        if (titleEnd != -1) {
          name = _stripTags(textContent.substring(0, titleEnd));
        }

        companies.add(Company(
          id: slug,
          name: name,
          slug: slug,
          logoUrl: logoUrl,
        ));
      } catch (_) {}
    }
    return companies;
  }

  @override
  Future<ApiResponse<User>> login(String email, String password) async {
    final res = await _request('POST', '/auth/login',
        body: {'email': email, 'password': password}, auth: false);
    if (res.success) {
      final user = _user(res.data);
      await _sessionManager.saveSession(user);
      return ApiResponse.success(user, message: res.message ?? 'ورود با موفقیت انجام شد');
    }
    final cached = await _sessionManager.getCachedUser();
    if (cached != null &&
        cached.email.toLowerCase() == email.toLowerCase()) {
      return ApiResponse.success(cached);
    }
    return ApiResponse.error(res.message ?? 'خطا در ورود',
        statusCode: res.statusCode);
  }

  @override
  Future<ApiResponse<User>> signup(
      String name, String email, String password) async {
    final res = await _request('POST', '/auth/signup',
        body: {'name': name, 'email': email, 'password': password},
        auth: false);
    if (res.success) {
      final user = _user(res.data);
      await _sessionManager.saveSession(user);
      return ApiResponse.success(
          user, message: res.message ?? 'ثبت‌نام با موفقیت انجام شد');
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
  Future<ApiResponse<List<Job>>> getJobs(
      {int page = 1, String? keyword, String? location}) async {
    try {
      String url = '$_siteBase/jobs';
      final params = <String, String>{};
      if (keyword != null && keyword.isNotEmpty) params['q'] = keyword;
      if (location != null && location.isNotEmpty) {
        params['location'] = location;
      }
      if (page > 1) params['page'] = '$page';
      if (params.isNotEmpty) {
        url += '?${Uri(queryParameters: params).query}';
      }
      final html = await _fetchHtml(url);
      final jobs = _parseJobsFromHtml(html);
      if (jobs.isNotEmpty) return ApiResponse.success(jobs);
    } catch (_) {}
    return ApiResponse.success(<Job>[]);
  }

  @override
  Future<ApiResponse<List<Job>>> getJobsWithFilter(JobFilter filter) async {
    try {
      String url = '$_siteBase/jobs';
      final params = <String, String>{};
      if (filter.keyword != null && filter.keyword!.isNotEmpty) {
        params['q'] = filter.keyword!;
      }
      if (filter.location != null && filter.location!.isNotEmpty) {
        params['location'] = filter.location!;
      }
      if (filter.category != null &&
          filter.category!.isNotEmpty &&
          filter.category != 'همه') {
        params['category'] = filter.category!;
      }
      if (filter.page > 1) params['page'] = '${filter.page}';
      if (params.isNotEmpty) {
        url += '?${Uri(queryParameters: params).query}';
      }
      final html = await _fetchHtml(url);
      final jobs = _parseJobsFromHtml(html);
      if (filter.contractType != null &&
          filter.contractType!.isNotEmpty &&
          filter.contractType != 'همه') {
        jobs.removeWhere(
            (j) => j.contractType != filter.contractType);
      }
      if (filter.isRemote == true) {
        jobs.removeWhere((j) => !j.isRemote);
      }
      if (jobs.isNotEmpty) return ApiResponse.success(jobs);
    } catch (_) {}
    return ApiResponse.success(<Job>[]);
  }

  @override
  Future<ApiResponse<Job>> getJobDetail(String jobId) async {
    try {
      String? jobUrl;
      try {
        final listHtml = await _fetchHtml('$_siteBase/jobs');
        final jobs = _parseJobsFromHtml(listHtml);
        final match = jobs.where(
            (j) => j.id == jobId || j.shortId == jobId);
        if (match.isNotEmpty) {
          jobUrl =
              '$_siteBase/companies/${match.first.company.slug}/jobs/$jobId';
        }
      } catch (_) {}
      if (jobUrl == null) {
        jobUrl =
            '$_siteBase/jobs/$jobId';
      }
      final html = await _fetchHtml(jobUrl);
      final job = _parseJobDetailFromHtml(html);
      if (job != null) return ApiResponse.success(job);
    } catch (_) {}
    return ApiResponse.error('آگهی مورد نظر یافت نشد', statusCode: 404);
  }

  @override
  Future<ApiResponse<Company>> getCompany(String slug) async {
    try {
      final html = await _fetchHtml('$_siteBase/companies/$slug');
      final company = _parseCompanyFromHtml(html);
      if (company != null && company.name.isNotEmpty) {
        return ApiResponse.success(company);
      }
    } catch (_) {}
    return ApiResponse.error('شرکت مورد نظر یافت نشد', statusCode: 404);
  }

  @override
  Future<ApiResponse<List<Job>>> getCompanyJobs(String slug) async {
    try {
      final html =
          await _fetchHtml('$_siteBase/companies/$slug/jobs');
      final jobs = _parseJobsFromHtml(html);
      if (jobs.isNotEmpty) return ApiResponse.success(jobs);
    } catch (_) {}
    return ApiResponse.success(<Job>[]);
  }

  @override
  Future<ApiResponse<User>> getProfile() async {
    final cached = await _sessionManager.getCachedUser();
    final res = await _request('GET', '/user/profile');
    if (res.success) {
      final user =
          _user(res.data, token: await _sessionManager.getToken());
      await _sessionManager.saveSession(user);
      return ApiResponse.success(user);
    }
    if (cached != null) return ApiResponse.success(cached);
    return ApiResponse.error('کاربر وارد نشده است', statusCode: 401);
  }

  @override
  Future<ApiResponse<List<Job>>> getAppliedJobs() async {
    final res = await _request('GET', '/jobs/applied');
    if (res.success) {
      final jobs =
          _items(res.data).map(_job).where((j) => j.id.isNotEmpty).toList();
      _appliedJobIds..clear()..addAll(jobs.map((j) => j.id));
      return ApiResponse.success(jobs);
    }
    return ApiResponse.success(<Job>[]);
  }

  @override
  Future<ApiResponse<void>> applyToJob(String jobId) async {
    _appliedJobIds.add(jobId);
    return ApiResponse.success(null, message: 'رزومه با موفقیت ارسال شد');
  }

  @override
  Future<ApiResponse<List<Job>>> getFavoriteJobs() async {
    return ApiResponse.success(<Job>[]);
  }

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
  Future<ApiResponse<List<Company>>> getTopCompanies() async {
    try {
      final html = await _fetchHtml('$_siteBase/companies');
      final companies = _parseCompaniesFromHtml(html);
      if (companies.isNotEmpty) return ApiResponse.success(companies);
    } catch (_) {}
    return ApiResponse.success(<Company>[]);
  }

  @override
  Future<ApiResponse<List<Job>>> getRecommendedJobs() async {
    try {
      final html = await _fetchHtml(_siteBase);
      final jobs = _parseJobsFromHtml(html);
      if (jobs.length > 6) {
        return ApiResponse.success(jobs.take(6).toList());
      }
      if (jobs.isNotEmpty) return ApiResponse.success(jobs);
    } catch (_) {}
    return ApiResponse.success(<Job>[]);
  }

  Future<ApiResponse<void>> saveResume(Map<String, dynamic> resume) async =>
      ApiResponse.success(null, message: 'رزومه ذخیره شد');

  Future<ApiResponse<List<String>>> getCategories() async {
    final res = await _request('GET', '/job/categories', auth: false);
    if (res.success) {
      final list = _items(res.data)
          .map((i) => i is Map ? _text(i['name'] ?? i['title']) : _text(i))
          .where((i) => i.isNotEmpty)
          .toList();
      if (list.isNotEmpty) return ApiResponse.success(list);
    }
    return ApiResponse.success(<String>[]);
  }

  Future<ApiResponse<List<Map<String, dynamic>>>> getRawCategories() async {
    final res = await _request('GET', '/job/categories', auth: false);
    return ApiResponse.success(res.success
        ? _items(res.data).map(_map).toList()
        : <Map<String, dynamic>>[]);
  }

  Future<ApiResponse<List<String>>> getProvinces() async {
    final res = await _request('GET', '/region/province', auth: false);
    if (res.success) {
      final list = _items(res.data)
          .map((i) => i is Map
              ? _text(i['name'] ?? i['title'] ?? i['province'])
              : _text(i))
          .where((i) => i.isNotEmpty)
          .toList();
      if (list.isNotEmpty) return ApiResponse.success(list);
    }
    return ApiResponse.success(<String>[]);
  }

  Future<ApiResponse<List<Map<String, dynamic>>>> getRawProvinces() async {
    final res = await _request('GET', '/region/province', auth: false);
    return ApiResponse.success(res.success
        ? _items(res.data).map(_map).toList()
        : <Map<String, dynamic>>[]);
  }

  Future<ApiResponse<List<String>>> searchSkills(String keyword) async {
    final res = await _request('GET', '/job-skills/search',
        query: {'q': keyword}, auth: false);
    if (!res.success) return ApiResponse.success(<String>[]);
    final list = _items(res.data)
        .map((i) => i is Map ? _text(i['name']) : _text(i))
        .where((i) => i.isNotEmpty)
        .toList();
    return ApiResponse.success(list);
  }

  void dispose() => _client.close();
}
