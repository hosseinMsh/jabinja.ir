import '../models/user.dart';
import '../services/api_service.dart';
import '../services/real_api_service.dart';

abstract class AuthView {
  void onLoginSuccess(User user);
  void onLoginError(String message);
  void onSignupSuccess(User user);
  void onSignupError(String message);
  void onLogoutSuccess();
  void onLogoutError(String message);
  void setLoading(bool loading);
}

class AuthPresenter {
  final AuthView _view;
  final ApiService _apiService = RealApiService();

  AuthPresenter(this._view);

  void login(String email, String password) {
    _view.setLoading(true);
    _apiService.login(email, password).then((response) {
      _view.setLoading(false);
      if (response.success && response.data != null) {
        _view.onLoginSuccess(response.data!);
      } else {
        _view.onLoginError(response.message ?? 'خطا در ورود');
      }
    }).catchError((_) {
      _view.setLoading(false);
      _view.onLoginError('خطا در ارتباط با سرور');
    });
  }

  void signup(String name, String email, String password) {
    _view.setLoading(true);
    _apiService.signup(name, email, password).then((response) {
      _view.setLoading(false);
      if (response.success && response.data != null) {
        _view.onSignupSuccess(response.data!);
      } else {
        _view.onSignupError(response.message ?? 'خطا در ثبت‌نام');
      }
    }).catchError((_) {
      _view.setLoading(false);
      _view.onSignupError('خطا در ارتباط با سرور');
    });
  }

  void logout() {
    _view.setLoading(true);
    _apiService.logout().then((response) {
      _view.setLoading(false);
      if (response.success) {
        _view.onLogoutSuccess();
      } else {
        _view.onLogoutError(response.message ?? 'خطا در خروج');
      }
    }).catchError((_) {
      _view.setLoading(false);
      _view.onLogoutError('خطا در ارتباط با سرور');
    });
  }
}
