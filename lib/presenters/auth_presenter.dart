import '../models/user.dart';
import '../services/api_service.dart';
import '../services/real_api_service.dart';
import '../services/session_manager.dart';

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
  final SessionManager _sessionManager = SessionManager();

  AuthPresenter(this._view);

  void login(String email, String password) {
    _view.setLoading(true);
    _apiService.login(email, password).then((response) async {
      if (response.success && response.data != null) {
        await _sessionManager.saveSession(response.data!);
        _view.setLoading(false);
        _view.onLoginSuccess(response.data!);
        return;
      }

      final localUser = await _sessionManager.findLocalAccount(email, password);
      _view.setLoading(false);
      if (localUser != null) {
        await _sessionManager.saveSession(localUser);
        _view.onLoginSuccess(localUser);
      } else {
        _view.onLoginError(response.message ?? 'ایمیل یا رمز عبور اشتباه است');
      }
    }).catchError((_) async {
      final localUser = await _sessionManager.findLocalAccount(email, password);
      _view.setLoading(false);
      if (localUser != null) {
        await _sessionManager.saveSession(localUser);
        _view.onLoginSuccess(localUser);
      } else {
        _view.onLoginError('خطا در ارتباط با سرور');
      }
    });
  }

  void signup(String name, String email, String password) {
    _view.setLoading(true);
    _apiService.signup(name, email, password).then((response) async {
      _view.setLoading(false);
      if (response.success && response.data != null) {
        await _sessionManager.saveSession(response.data!);
        await _sessionManager.saveLocalAccount(response.data!, password);
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
