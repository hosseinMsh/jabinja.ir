import '../models/company.dart';
import '../models/job.dart';
import '../models/job_filter.dart';
import '../services/api_service.dart';
import '../services/real_api_service.dart';

abstract class JobView {
  void onJobsLoaded(List<Job> jobs);
  void onJobsError(String message);
  void onJobDetailLoaded(Job job);
  void onJobDetailError(String message);
  void onAppliedJobsLoaded(List<Job> jobs);
  void onFavoriteJobsLoaded(List<Job> jobs);
  void onFavoriteToggled(String jobId, bool isFavorited, String message);
  void onApplied(String message);
  void onRecommendedJobsLoaded(List<Job> jobs);
  void onTopCompaniesLoaded(List<Company> companies);
  void setLoading(bool loading);
}

class JobPresenter {
  final JobView _view;
  final ApiService _apiService = RealApiService();

  JobPresenter(this._view);

  void loadJobs({int page = 1, String? keyword, String? location}) {
    _view.setLoading(true);
    _apiService.getJobs(page: page, keyword: keyword, location: location).then((response) {
      _view.setLoading(false);
      if (response.success && response.data != null) {
        _view.onJobsLoaded(response.data!);
      } else {
        _view.onJobsError(response.message ?? 'خطا در دریافت لیست شغل‌ها');
      }
    }).catchError((_) {
      _view.setLoading(false);
      _view.onJobsError('خطا در ارتباط با سرور');
    });
  }

  void loadJobsWithFilter(JobFilter filter) {
    _view.setLoading(true);
    (_apiService as dynamic).getJobsWithFilter(filter).then((response) {
      _view.setLoading(false);
      if (response.success && response.data != null) {
        _view.onJobsLoaded(response.data);
      } else {
        _view.onJobsError(response.message ?? 'نتیجه‌ای یافت نشد');
      }
    }).catchError((_) {
      _view.setLoading(false);
      _view.onJobsError('خطا در ارتباط با سرور');
    });
  }

  void loadJobDetail(String jobId) {
    _view.setLoading(true);
    _apiService.getJobDetail(jobId).then((response) {
      _view.setLoading(false);
      if (response.success && response.data != null) {
        _view.onJobDetailLoaded(response.data!);
      } else {
        _view.onJobDetailError(response.message ?? 'خطا در دریافت جزئیات');
      }
    }).catchError((_) {
      _view.setLoading(false);
      _view.onJobDetailError('خطا در ارتباط با سرور');
    });
  }

  void loadAppliedJobs() {
    _view.setLoading(true);
    _apiService.getAppliedJobs().then((response) {
      _view.setLoading(false);
      if (response.success && response.data != null) {
        _view.onAppliedJobsLoaded(response.data!);
      } else {
        _view.onJobsError(response.message ?? 'خطا');
      }
    }).catchError((_) {
      _view.setLoading(false);
      _view.onJobsError('خطا در ارتباط با سرور');
    });
  }

  void loadFavoriteJobs() {
    _view.setLoading(true);
    _apiService.getFavoriteJobs().then((response) {
      _view.setLoading(false);
      if (response.success && response.data != null) {
        _view.onFavoriteJobsLoaded(response.data!);
      } else {
        _view.onJobsError(response.message ?? 'خطا');
      }
    }).catchError((_) {
      _view.setLoading(false);
      _view.onJobsError('خطا در ارتباط با سرور');
    });
  }

  void toggleFavorite(String jobId) {
    _apiService.toggleFavorite(jobId).then((response) {
      final isFav = _apiService.isFavorited(jobId);
      _view.onFavoriteToggled(jobId, isFav, response.message ?? '');
    }).catchError((_) {});
  }

  bool isFavorited(String jobId) => _apiService.isFavorited(jobId);
  bool isApplied(String jobId) => _apiService.isApplied(jobId);

  void applyToJob(String jobId) {
    _apiService.applyToJob(jobId).then((response) {
      if (response.success) {
        _view.onApplied(response.message ?? 'رزومه با موفقیت ارسال شد');
      }
    }).catchError((_) {});
  }

  void loadRecommendedJobs() {
    _apiService.getRecommendedJobs().then((response) {
      if (response.success && response.data != null) {
        _view.onRecommendedJobsLoaded(response.data!);
      }
    }).catchError((_) {});
  }

  void loadTopCompanies() {
    _apiService.getTopCompanies().then((response) {
      if (response.success && response.data != null) {
        _view.onTopCompaniesLoaded(response.data!);
      }
    }).catchError((_) {});
  }
}
