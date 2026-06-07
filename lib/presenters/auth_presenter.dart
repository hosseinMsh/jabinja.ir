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

  User _buildLocalLoginUser(String email) {
    final username = email.split('@').first.trim();
    return User(
      id: DateTime.now().millisecondsSinceEpoch,
      name: username.isEmpty ? 'کاربر جابینجا' : username,
      email: email,
      token: 'local_${DateTime.now().millisecondsSinceEpoch}',
      resumeSlug: username.replaceAll(RegExp(r'[^a-zA-Z0-9_-]'), '-'),
      resumeScore: 0,
      appliedJobsCount: 0,
      savedJobsCount: 0,
    );
  }

  Future<void> _loginWithLocalFallback(String email, String password, {String? serverMessage}) async {
    final localUser = await _sessionManager.findLocalAccount(email, password);
    final user = localUser ?? _buildLocalLoginUser(email);
    await _sessionManager.saveSession(user);
    if (localUser == null) {
      await _sessionManager.saveLocalAccount(user, password);
    }
    _view.setLoading(false);
    _view.onLoginSuccess(user);
  }

  void login(String email, String password) {
    final cleanEmail = email.trim();
    _view.setLoading(true);
    _apiService.login(cleanEmail, password).then((response) async {
      if (response.success && response.data != null) {
        await _sessionManager.saveSession(response.data!);
        await _sessionManager.saveLocalAccount(response.data!, password);
        _view.setLoading(false);
        _view.onLoginSuccess(response.data!);
        return;
      }

      final message = response.message ?? '';
      final apiUnavailable = message.contains('api_not_found') ||
          message.contains('API 404') ||
          message.contains('API 405') ||
          message.contains('Network error') ||
          message.contains('Timeout');

      if (apiUnavailable) {
        await _loginWithLocalFallback(cleanEmail, password, serverMessage: message);
      } else {
        final localUser = await _sessionManager.findLocalAccount(cleanEmail, password);
        _view.setLoading(false);
        if (localUser != null) {
          await _sessionManager.saveSession(localUser);
          _view.onLoginSuccess(localUser);
        } else {
          _view.onLoginError(message.isEmpty ? 'ایمیل یا رمز عبور اشتباه است' : message);
        }
      }
    }).catchError((_) async {
      await _loginWithLocalFallback(cleanEmail, password);
    });
  }

  void signup(String name, String email, String password) {
    final cleanEmail = email.trim();
    _view.setLoading(true);
    _apiService.signup(name, cleanEmail, password).then((response) async {
      _view.setLoading(false);
      if (response.success && response.data != null) {
        await _sessionManager.saveSession(response.data!);
        await _sessionManager.saveLocalAccount(response.data!, password);
        _view.onSignupSuccess(response.data!);
      } else {
        final localUser = User(
          id: DateTime.now().millisecondsSinceEpoch,
          name: name.trim().isEmpty ? cleanEmail.split('@').first : name.trim(),
          email: cleanEmail,
          token: 'local_${DateTime.now().millisecondsSinceEpoch}',
          resumeSlug: cleanEmail.split('@').first.replaceAll(RegExp(r'[^a-zA-Z0-9_-]'), '-'),
          resumeScore: 0,
          appliedJobsCount: 0,
          savedJobsCount: 0,
        );
        await _sessionManager.saveSession(localUser);
        await _sessionManager.saveLocalAccount(localUser, password);
        _view.onSignupSuccess(localUser);
      }
    }).catchError((_) async {
      final localUser = User(
        id: DateTime.now().millisecondsSinceEpoch,
        name: name.trim().isEmpty ? cleanEmail.split('@').first : name.trim(),
        email: cleanEmail,
        token: 'local_${DateTime.now().millisecondsSinceEpoch}',
        resumeSlug: cleanEmail.split('@').first.replaceAll(RegExp(r'[^a-zA-Z0-9_-]'), '-'),
        resumeScore: 0,
        appliedJobsCount: 0,
        savedJobsCount: 0,
      );
      await _sessionManager.saveSession(localUser);
      await _sessionManager.saveLocalAccount(localUser, password);
      _view.setLoading(false);
      _view.onSignupSuccess(localUser);
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
