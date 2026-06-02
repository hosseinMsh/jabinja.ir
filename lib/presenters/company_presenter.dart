import '../models/company.dart';
import '../models/job.dart';
import '../services/api_service.dart';
import '../services/real_api_service.dart';

abstract class CompanyView {
  void onCompanyLoaded(Company company);
  void onCompanyJobsLoaded(List<Job> jobs);
  void onCompanyError(String message);
  void setLoading(bool loading);
}

class CompanyPresenter {
  final CompanyView _view;
  final ApiService _apiService = RealApiService();

  CompanyPresenter(this._view);

  void loadCompany(String slug) {
    _view.setLoading(true);
    Future.wait([
      _apiService.getCompany(slug),
      _apiService.getCompanyJobs(slug),
    ]).then((results) {
      _view.setLoading(false);
      final companyResponse = results[0] as dynamic;
      final jobsResponse = results[1] as dynamic;

      if (companyResponse.success && companyResponse.data != null) {
        _view.onCompanyLoaded(companyResponse.data);
        if (jobsResponse.success && jobsResponse.data != null) {
          _view.onCompanyJobsLoaded(jobsResponse.data);
        }
      } else {
        _view.onCompanyError(companyResponse.message ?? 'خطا');
      }
    }).catchError((_) {
      _view.setLoading(false);
      _view.onCompanyError('خطا در ارتباط با سرور');
    });
  }
}
