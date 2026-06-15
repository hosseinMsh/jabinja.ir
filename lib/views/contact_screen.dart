import 'package:flutter/material.dart';
import '../widgets/custom_button.dart';
import '../utils/constants.dart';

class ContactScreen extends StatefulWidget {
  const ContactScreen({super.key});

  @override
  State<ContactScreen> createState() => _ContactScreenState();
}

class _ContactScreenState extends State<ContactScreen> {
  final _nameCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _messageCtrl = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    _nameCtrl.dispose();
    _emailCtrl.dispose();
    _messageCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('تماس با جابینجا'),
        centerTitle: true,
        backgroundColor: AppColors.surface,
        elevation: 0,
        foregroundColor: AppColors.textPrimary,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            _buildHeaderBanner(),
            const SizedBox(height: 16),
            _buildInfo(),
            const SizedBox(height: 16),
            _buildForm(),
          ],
        ),
      ),
    );
  }

  Widget _buildHeaderBanner() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [AppColors.primary, AppColors.primaryDark],
        ),
        borderRadius: BorderRadius.circular(AppRadius.lg),
      ),
      child: Column(
        children: [
          Container(
            width: 56, height: 56,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(AppRadius.lg),
            ),
            child: const Icon(Icons.headset_mic, color: Colors.white, size: 28),
          ),
          const SizedBox(height: 12),
          const Text(
            'ارتباط با جابینجا',
            style: TextStyle(
              fontFamily: AppTypography.fontFamily,
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'ما همیشه خوشحال می‌شویم نظرات شما را بشنویم',
            style: TextStyle(
              fontFamily: AppTypography.fontFamily,
              fontSize: 13,
              color: Colors.white70,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildInfo() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppRadius.md),
        border: Border.all(color: AppColors.border, width: 0.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          const Row(
            textDirection: TextDirection.rtl,
            children: [
              Icon(Icons.headset_mic, color: AppColors.primary, size: 24),
              SizedBox(width: 8),
              Text('اطلاعات تماس', style: AppTypography.h4),
            ],
          ),
          const SizedBox(height: 20),
          _buildInfoRow(Icons.email_outlined, 'ایمیل', 'support@jobinja.ir'),
          const SizedBox(height: 12),
          _buildInfoRow(Icons.language_outlined, 'وبلاگ', 'blog.jobinja.ir'),
          const SizedBox(height: 12),
          _buildInfoRow(Icons.camera_alt_outlined, 'اینستاگرام', '@myjobinja'),
          const SizedBox(height: 12),
          _buildInfoRow(Icons.chat_outlined, 'تلگرام', '@jobinja_ir'),
        ],
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Row(
      textDirection: TextDirection.rtl,
      children: [
        Container(
          width: 36, height: 36,
          decoration: BoxDecoration(
            color: AppColors.primaryLight,
            borderRadius: BorderRadius.circular(AppRadius.sm),
          ),
          child: Icon(icon, size: 18, color: AppColors.primary),
        ),
        const SizedBox(width: 12),
        Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(label, style: AppTypography.caption),
            Text(value, style: AppTypography.body.copyWith(fontWeight: FontWeight.w500)),
          ],
        ),
      ],
    );
  }

  Widget _buildForm() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppRadius.md),
        border: Border.all(color: AppColors.border, width: 0.5),
      ),
      child: Form(
        key: _formKey,
        child: Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
          const Text('ارسال پیام', style: AppTypography.h4),
          const SizedBox(height: 20),
          TextFormField(
            controller: _nameCtrl,
            textDirection: TextDirection.rtl,
            decoration: _input('نام و نام خانوادگی', Icons.person_outline),
            validator: (v) => (v == null || v.isEmpty) ? 'نام را وارد کنید' : null,
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: _emailCtrl,
            textDirection: TextDirection.rtl,
            decoration: _input('ایمیل', Icons.email_outlined),
            keyboardType: TextInputType.emailAddress,
            validator: (v) => (v == null || v.isEmpty || !v.contains('@')) ? 'ایمیل معتبر وارد کنید' : null,
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: _messageCtrl,
            textDirection: TextDirection.rtl,
            maxLines: 5,
            decoration: _input('پیام شما', Icons.message_outlined),
            validator: (v) => (v == null || v.isEmpty) ? 'پیام را وارد کنید' : null,
          ),
          const SizedBox(height: 24),
          CustomButton(
            text: 'ارسال پیام',
            onPressed: () {
              if (_formKey.currentState!.validate()) {
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                  content: const Text('پیام شما با موفقیت ارسال شد', style: TextStyle(fontFamily: AppTypography.fontFamily)),
                  backgroundColor: AppColors.success,
                  behavior: SnackBarBehavior.floating,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadius.sm)),
                ));
                _nameCtrl.clear();
                _emailCtrl.clear();
                _messageCtrl.clear();
              }
            },
          ),
        ]),
      ),
    );
  }

  InputDecoration _input(String label, IconData icon) {
    return InputDecoration(
      labelText: label,
      labelStyle: const TextStyle(fontFamily: AppTypography.fontFamily, color: AppColors.textSecondary),
      prefixIcon: Icon(icon, color: AppColors.textMuted),
      filled: true,
      fillColor: AppColors.background,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppRadius.md),
        borderSide: const BorderSide(color: AppColors.border),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppRadius.md),
        borderSide: const BorderSide(color: AppColors.border),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppRadius.md),
        borderSide: const BorderSide(color: AppColors.primary, width: 2),
      ),
    );
  }
}
