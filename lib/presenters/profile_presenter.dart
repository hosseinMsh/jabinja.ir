import '../models/user.dart';
import '../services/api_service.dart';
import '../services/real_api_service.dart';

abstract class ProfileView {
  void onProfileLoaded(User user);
  void onProfileError(String message);
  void setLoading(bool loading);
}

class ProfilePresenter {
  final ProfileView _view;
  final ApiService _apiService = RealApiService();

  ProfilePresenter(this._view);

  void loadProfile() {
    _view.setLoading(true);
    _apiService.getProfile().then((response) {
      _view.setLoading(false);
      if (response.success && response.data != null) {
        _view.onProfileLoaded(response.data!);
      } else {
        _view.onProfileError(response.message ?? 'خطا در دریافت پروفایل');
      }
    }).catchError((_) {
      _view.setLoading(false);
      _view.onProfileError('خطا در ارتباط با سرور');
    });
  }
}
