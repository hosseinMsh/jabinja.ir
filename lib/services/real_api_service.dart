import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/api_response.dart';
import '../models/company.dart';
import '../models/job.dart';
import '../models/job_filter.dart';
import '../models/user.dart';
import 'api_service.dart';
import 'mock_api_service.dart';

class RealApiService implements ApiService {
  static const String baseUrl = 'https://jobinja.ir';
  static const String apiBase = '$baseUrl/api/v10';

  final http.Client _client = http.Client();
  final MockApiService _mockFallback;

  RealApiService() : _mockFallback = MockApiService();

  Future<ApiResponse<List<dynamic>>> _get(String url) async {
    try {
      final response = await _client.get(
        Uri.parse(url),
        headers: {'Content-Type': 'application/json'},
      ).timeout(const Duration(seconds: 10));
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return ApiResponse.success(data);
      }
      return ApiResponse.error('خطا در دریافت اطلاعات', statusCode: response.statusCode);
    } catch (e) {
      return ApiResponse.error('خطا در ارتباط با سرور');
    }
  }

  Future<ApiResponse<List<String>>> getCategories() async {
    final result = await _get('$apiBase/job/categories');
    if (result.success && result.data != null) {
      final categories = (result.data as List).map((e) => e['name'] as String).toList();
      return ApiResponse.success(categories);
    }
    return ApiResponse.error('خطا در دریافت دسته‌بندی‌ها');
  }

  Future<ApiResponse<List<Map<String, dynamic>>>> getRawCategories() async {
    final result = await _get('$apiBase/job/categories');
    if (result.success && result.data != null) {
      return ApiResponse.success((result.data as List).cast<Map<String, dynamic>>());
    }
    return ApiResponse.error('خطا در دریافت دسته‌بندی‌ها');
  }

  Future<ApiResponse<List<String>>> getProvinces() async {
    final result = await _get('$apiBase/region/province');
    if (result.success && result.data != null) {
      final data = result.data as Map<String, dynamic>;
      final provinces = (data['data'] as List).map((e) => (e as Map<String, dynamic>)['name'] as String).toList();
      return ApiResponse.success(provinces);
    }
    return ApiResponse.error('خطا در دریافت استان‌ها');
  }

  Future<ApiResponse<List<Map<String, dynamic>>>> getRawProvinces() async {
    final result = await _get('$apiBase/region/province');
    if (result.success && result.data != null) {
      final data = result.data as Map<String, dynamic>;
      return ApiResponse.success((data['data'] as List).cast<Map<String, dynamic>>());
    }
    return ApiResponse.error('خطا در دریافت استان‌ها');
  }

  @override
  Future<ApiResponse<User>> login(String email, String password) async {
    return _mockFallback.login(email, password);
  }

  @override
  Future<ApiResponse<User>> signup(String name, String email, String password) async {
    return _mockFallback.signup(name, email, password);
  }

  @override
  Future<ApiResponse<void>> logout() async {
    return _mockFallback.logout();
  }

  @override
  Future<ApiResponse<List<Job>>> getJobs({int page = 1, String? keyword, String? location}) async {
    return _mockFallback.getJobs(page: page, keyword: keyword, location: location);
  }

  @override
  Future<ApiResponse<List<Job>>> getJobsWithFilter(JobFilter filter) async {
    return _mockFallback.getJobsWithFilter(filter);
  }

  @override
  Future<ApiResponse<Job>> getJobDetail(String jobId) async {
    return _mockFallback.getJobDetail(jobId);
  }

  @override
  Future<ApiResponse<Company>> getCompany(String slug) async {
    return _mockFallback.getCompany(slug);
  }

  @override
  Future<ApiResponse<List<Job>>> getCompanyJobs(String slug) async {
    return _mockFallback.getCompanyJobs(slug);
  }

  @override
  Future<ApiResponse<User>> getProfile() async {
    return _mockFallback.getProfile();
  }

  @override
  Future<ApiResponse<List<Job>>> getAppliedJobs() async {
    return _mockFallback.getAppliedJobs();
  }

  @override
  Future<ApiResponse<void>> applyToJob(String jobId) async {
    return _mockFallback.applyToJob(jobId);
  }

  @override
  Future<ApiResponse<List<Job>>> getFavoriteJobs() async {
    return _mockFallback.getFavoriteJobs();
  }

  @override
  Future<ApiResponse<void>> toggleFavorite(String jobId) async {
    return _mockFallback.toggleFavorite(jobId);
  }

  @override
  bool isFavorited(String jobId) => _mockFallback.isFavorited(jobId);
  @override
  bool isApplied(String jobId) => _mockFallback.isApplied(jobId);

  @override
  Future<ApiResponse<List<Company>>> getTopCompanies() async {
    return _mockFallback.getTopCompanies();
  }

  @override
  Future<ApiResponse<List<Job>>> getRecommendedJobs() async {
    return _mockFallback.getRecommendedJobs();
  }

  void dispose() {
    _client.close();
  }
}
