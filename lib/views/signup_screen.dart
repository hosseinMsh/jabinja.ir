import 'package:flutter/material.dart';
import '../presenters/auth_presenter.dart';
import '../models/user.dart';
import '../widgets/custom_text_field.dart';
import '../widgets/custom_button.dart';
import '../utils/validators.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> implements AuthView {
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _passwordConfirmController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  late final AuthPresenter _presenter;
  bool _isLoading = false;
  bool _obscurePassword = true;
  bool _obscureConfirm = true;

  @override
  void initState() {
    super.initState();
    _presenter = AuthPresenter(this);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _passwordConfirmController.dispose();
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
                      Icons.person_add_rounded,
                      size: 40,
                      color: Color(0xFF4A90D9),
                    ),
                  ),
                  const SizedBox(height: 24),
                  const Text(
                    'ثبت‌نام در جابینجا',
                    style: TextStyle(
                      fontFamily: 'Vazir',
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF212529),
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'ایجاد حساب کاربری جدید',
                    style: TextStyle(
                      fontFamily: 'Vazir',
                      fontSize: 14,
                      color: Color(0xFF6C757D),
                    ),
                  ),
                  const SizedBox(height: 40),
                  CustomTextField(
                    controller: _nameController,
                    labelText: 'نام و نام خانوادگی',
                    hintText: 'نام خود را وارد کنید',
                    validator: Validators.validateName,
                    prefixIcon: const Icon(Icons.person_outline, color: Color(0xFFADB5BD)),
                  ),
                  const SizedBox(height: 16),
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
                  CustomTextField(
                    controller: _passwordConfirmController,
                    labelText: 'تکرار رمز عبور',
                    hintText: 'رمز عبور را مجدد وارد کنید',
                    obscureText: _obscureConfirm,
                    validator: (value) => Validators.validatePasswordConfirmation(
                      value, _passwordController.text,
                    ),
                    prefixIcon: const Icon(Icons.lock_outlined, color: Color(0xFFADB5BD)),
                    suffixIcon: IconButton(
                      icon: Icon(
                        _obscureConfirm ? Icons.visibility_outlined : Icons.visibility_off_outlined,
                        color: const Color(0xFFADB5BD),
                      ),
                      onPressed: () => setState(() => _obscureConfirm = !_obscureConfirm),
                    ),
                  ),
                  const SizedBox(height: 32),
                  CustomButton(
                    text: 'ثبت‌نام',
                    isLoading: _isLoading,
                    onPressed: _handleSignup,
                  ),
                  const SizedBox(height: 16),
                  TextButton(
                    onPressed: () => Navigator.pushReplacementNamed(context, '/login'),
                    child: const Text(
                      'قبلاً ثبت‌نام کرده‌اید؟ ورود',
                      style: TextStyle(
                        fontFamily: 'Vazir',
                        fontSize: 14,
                        color: Color(0xFF4A90D9),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _handleSignup() {
    if (_formKey.currentState!.validate()) {
      _presenter.signup(
        _nameController.text.trim(),
        _emailController.text.trim(),
        _passwordController.text,
      );
    }
  }

  @override
  void onSignupSuccess(User user) {
    if (mounted) {
      Navigator.pushReplacementNamed(context, '/home');
    }
  }

  @override
  void onSignupError(String message) {
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
  void onLoginSuccess(User user) {}

  @override
  void onLoginError(String message) {}

  @override
  void onLogoutSuccess() {}

  @override
  void onLogoutError(String message) {}

  @override
  void setLoading(bool loading) {
    if (mounted) setState(() => _isLoading = loading);
  }
}
