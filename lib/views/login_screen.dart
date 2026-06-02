import 'package:flutter/material.dart';
import '../presenters/auth_presenter.dart';
import '../models/user.dart';
import '../widgets/custom_text_field.dart';
import '../widgets/custom_button.dart';
import '../utils/validators.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> implements AuthView {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  late final AuthPresenter _presenter;
  bool _isLoading = false;
  bool _obscurePassword = true;

  @override
  void initState() {
    super.initState();
    _presenter = AuthPresenter(this);
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      color: const Color(0xFFE8F0FE),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Icon(
                      Icons.work_rounded,
                      size: 40,
                      color: Color(0xFF4A90D9),
                    ),
                  ),
                  const SizedBox(height: 24),
                  const Text(
                    'ورود به جابینجا',
                    style: TextStyle(
                      fontFamily: 'Vazir',
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF212529),
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'به جمع کارجویان بپیوندید',
                    style: TextStyle(
                      fontFamily: 'Vazir',
                      fontSize: 14,
                      color: Color(0xFF6C757D),
                    ),
                  ),
                  const SizedBox(height: 40),
                  CustomTextField(
                    controller: _emailController,
                    labelText: 'ایمیل',
                    hintText: 'example@email.com',
                    keyboardType: TextInputType.emailAddress,
                    validator: Validators.validateEmail,
                    prefixIcon: const Icon(Icons.email_outlined, color: Color(0xFFADB5BD)),
                  ),
                  const SizedBox(height: 16),
                  CustomTextField(
                    controller: _passwordController,
                    labelText: 'رمز عبور',
                    hintText: 'حداقل ۶ کاراکتر',
                    obscureText: _obscurePassword,
                    validator: Validators.validatePassword,
                    prefixIcon: const Icon(Icons.lock_outlined, color: Color(0xFFADB5BD)),
                    suffixIcon: IconButton(
                      icon: Icon(
                        _obscurePassword ? Icons.visibility_outlined : Icons.visibility_off_outlined,
                        color: const Color(0xFFADB5BD),
                      ),
                      onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Row(
                    textDirection: TextDirection.rtl,
                    children: [
                      Expanded(child: Divider()),
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: 16),
                        child: Text('ورود سریع', style: TextStyle(fontFamily: 'Vazir', fontSize: 12, color: Color(0xFFADB5BD))),
                      ),
                      Expanded(child: Divider()),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: () {},
                          style: OutlinedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            side: const BorderSide(color: Color(0xFFDEE2E6)),
                          ),
                          icon: const Icon(Icons.g_mobiledata, color: Color(0xFFDB4437), size: 28),
                          label: const Text('گوگل', style: TextStyle(fontFamily: 'Vazir', fontSize: 13, color: Color(0xFF495057))),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: () {},
                          style: OutlinedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            side: const BorderSide(color: Color(0xFFDEE2E6)),
                          ),
                          icon: const Icon(Icons.link, color: Color(0xFF0077B5), size: 28),
                          label: const Text('لینکدین', style: TextStyle(fontFamily: 'Vazir', fontSize: 13, color: Color(0xFF495057))),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  CustomButton(
                    text: 'ورود',
                    isLoading: _isLoading,
                    onPressed: _handleLogin,
                  ),
                  const SizedBox(height: 16),
                  TextButton(
                    onPressed: () => Navigator.pushReplacementNamed(context, '/signup'),
                    child: const Text(
                      'حساب کاربری ندارید؟ ثبت‌نام کنید',
                      style: TextStyle(fontFamily: 'Vazir', fontSize: 14, color: Color(0xFF4A90D9)),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'test@test.com / 123456',
                    style: const TextStyle(fontFamily: 'Vazir', fontSize: 11, color: Color(0xFFADB5BD)),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _handleLogin() {
    if (_formKey.currentState!.validate()) {
      _presenter.login(
        _emailController.text.trim(),
        _passwordController.text,
      );
    }
  }

  @override
  void onLoginSuccess(User user) {
    if (mounted) {
      Navigator.pushReplacementNamed(context, '/home');
    }
  }

  @override
  void onLoginError(String message) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: const Color(0xFFE74C3C),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
      );
    }
  }

  @override
  void onSignupSuccess(User user) {}

  @override
  void onSignupError(String message) {}

  @override
  void onLogoutSuccess() {}

  @override
  void onLogoutError(String message) {}

  @override
  void setLoading(bool loading) {
    if (mounted) setState(() => _isLoading = loading);
  }
}
