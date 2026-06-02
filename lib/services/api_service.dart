import '../models/api_response.dart';
import '../models/company.dart';
import '../models/job.dart';
import '../models/job_filter.dart';
import '../models/user.dart';

abstract class ApiService {
  Future<ApiResponse<User>> login(String email, String password);
  Future<ApiResponse<User>> signup(String name, String email, String password);
  Future<ApiResponse<void>> logout();

  Future<ApiResponse<List<Job>>> getJobs({int page = 1, String? keyword, String? location});
  Future<ApiResponse<List<Job>>> getJobsWithFilter(JobFilter filter);
  Future<ApiResponse<Job>> getJobDetail(String jobId);

  Future<ApiResponse<Company>> getCompany(String slug);
  Future<ApiResponse<List<Job>>> getCompanyJobs(String slug);

  Future<ApiResponse<User>> getProfile();
  Future<ApiResponse<List<Job>>> getAppliedJobs();

  Future<ApiResponse<void>> applyToJob(String jobId);
  Future<ApiResponse<List<Job>>> getFavoriteJobs();
  Future<ApiResponse<void>> toggleFavorite(String jobId);
  bool isFavorited(String jobId);
  bool isApplied(String jobId);

  Future<ApiResponse<List<Company>>> getTopCompanies();
  Future<ApiResponse<List<Job>>> getRecommendedJobs();
}
