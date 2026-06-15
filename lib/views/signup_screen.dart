import 'package:flutter/material.dart';
import '../presenters/auth_presenter.dart';
import '../models/user.dart';
import '../widgets/custom_text_field.dart';
import '../widgets/custom_button.dart';
import '../widgets/jobinja_logo.dart';
import '../utils/constants.dart';
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
  bool _agreeTerms = false;

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
      backgroundColor: AppColors.surface,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(AppSpacing.xxl),
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const JobinjaLogo(size: 56, showText: true),
                  const SizedBox(height: 28),
                  Text(
                    'ایجاد حساب کاربری',
                    style: AppTypography.h1.copyWith(color: AppColors.textPrimary),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'با ثبت‌نام، به هزاران فرصت شغلی دسترسی پیدا کنید',
                    style: AppTypography.body.copyWith(color: AppColors.textSecondary),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 32),
                  CustomTextField(
                    controller: _nameController,
                    labelText: 'نام و نام خانوادگی',
                    hintText: 'نام خود را وارد کنید',
                    validator: Validators.validateName,
                    prefixIcon: const Icon(Icons.person_outline, color: AppColors.textMuted),
                  ),
                  const SizedBox(height: 16),
                  CustomTextField(
                    controller: _emailController,
                    labelText: 'ایمیل',
                    hintText: 'example@email.com',
                    keyboardType: TextInputType.emailAddress,
                    validator: Validators.validateEmail,
                    prefixIcon: const Icon(Icons.email_outlined, color: AppColors.textMuted),
                  ),
                  const SizedBox(height: 16),
                  CustomTextField(
                    controller: _passwordController,
                    labelText: 'رمز عبور',
                    hintText: 'حداقل ۶ کاراکتر',
                    obscureText: _obscurePassword,
                    validator: Validators.validatePassword,
                    prefixIcon: const Icon(Icons.lock_outlined, color: AppColors.textMuted),
                    suffixIcon: IconButton(
                      icon: Icon(
                        _obscurePassword ? Icons.visibility_outlined : Icons.visibility_off_outlined,
                        color: AppColors.textMuted,
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
                    prefixIcon: const Icon(Icons.lock_outlined, color: AppColors.textMuted),
                    suffixIcon: IconButton(
                      icon: Icon(
                        _obscureConfirm ? Icons.visibility_outlined : Icons.visibility_off_outlined,
                        color: AppColors.textMuted,
                      ),
                      onPressed: () => setState(() => _obscureConfirm = !_obscureConfirm),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    textDirection: TextDirection.rtl,
                    children: [
                      SizedBox(
                        height: 24,
                        width: 24,
                        child: Checkbox(
                          value: _agreeTerms,
                          onChanged: (v) => setState(() => _agreeTerms = v ?? false),
                          activeColor: AppColors.primary,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(4),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'با قوانین و مقررات جابینجا موافقم',
                          style: AppTypography.bodySmall.copyWith(color: AppColors.textSecondary),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  CustomButton(
                    text: 'ثبت‌نام',
                    isLoading: _isLoading,
                    onPressed: _handleSignup,
                  ),
                  const SizedBox(height: 24),
                  Row(
                    textDirection: TextDirection.rtl,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'قبلاً ثبت‌نام کرده‌اید؟',
                        style: AppTypography.body.copyWith(color: AppColors.textSecondary),
                      ),
                      const SizedBox(width: 4),
                      GestureDetector(
                        onTap: () => Navigator.pushReplacementNamed(context, '/login'),
                        child: Text(
                          'ورود',
                          style: AppTypography.link,
                        ),
                      ),
                    ],
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
    if (!_agreeTerms) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('لطفاً قوانین را بپذیرید', style: TextStyle(fontFamily: AppTypography.fontFamily)),
          backgroundColor: AppColors.warning,
        ),
      );
      return;
    }
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
    if (mounted) Navigator.pushReplacementNamed(context, '/home');
  }

  @override
  void onSignupError(String message) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message, style: const TextStyle(fontFamily: AppTypography.fontFamily)),
          backgroundColor: AppColors.error,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadius.sm)),
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
