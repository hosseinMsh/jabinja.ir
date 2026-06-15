import 'package:flutter/material.dart';
import '../utils/constants.dart';

class ResumeBuilderScreen extends StatefulWidget {
  const ResumeBuilderScreen({super.key});

  @override
  State<ResumeBuilderScreen> createState() => _ResumeBuilderScreenState();
}

class _ResumeBuilderScreenState extends State<ResumeBuilderScreen> {
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _bioController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  final List<Map<String, dynamic>> _educations = [];
  final List<Map<String, dynamic>> _experiences = [];
  final List<String> _skills = [];

  int _currentStep = 0;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _bioController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('رزومه‌ساز'),
        centerTitle: true,
        backgroundColor: AppColors.surface,
        elevation: 0,
        foregroundColor: AppColors.textPrimary,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            _buildProgressBar(),
            Form(
              key: _formKey,
              child: _buildCurrentStep(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProgressBar() {
    return Container(
      padding: const EdgeInsets.all(20),
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppRadius.md),
        border: Border.all(color: AppColors.border, width: 0.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          const Text('تکمیل رزومه', style: AppTypography.h4),
          const SizedBox(height: 16),
          Row(
            textDirection: TextDirection.rtl,
            children: [
              _buildStepDot(0, 'اطلاعات', Icons.person_outline),
              _buildStepLine(0),
              _buildStepDot(1, 'تحصیلات', Icons.school_outlined),
              _buildStepLine(1),
              _buildStepDot(2, 'سوابق', Icons.work_outline),
              _buildStepLine(2),
              _buildStepDot(3, 'مهارت‌ها', Icons.psychology_outlined),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStepDot(int index, String label, IconData icon) {
    final isActive = index <= _currentStep;
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 36, height: 36,
          decoration: BoxDecoration(
            color: isActive ? AppColors.primary : AppColors.border,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, size: 18, color: isActive ? Colors.white : AppColors.textMuted),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            fontFamily: AppTypography.fontFamily,
            fontSize: 10,
            color: isActive ? AppColors.primary : AppColors.textMuted,
          ),
        ),
      ],
    );
  }

  Widget _buildStepLine(int index) {
    return Expanded(
      child: Container(
        height: 2,
        margin: const EdgeInsets.only(bottom: 20),
        color: index < _currentStep ? AppColors.primary : AppColors.border,
      ),
    );
  }

  Widget _buildCurrentStep() {
    switch (_currentStep) {
      case 0: return _buildPersonalInfo();
      case 1: return _buildEducation();
      case 2: return _buildExperience();
      case 3: return _buildSkills();
      default: return const SizedBox.shrink();
    }
  }

  Widget _buildPersonalInfo() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppRadius.md),
        border: Border.all(color: AppColors.border, width: 0.5),
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
        const Text('اطلاعات شخصی', style: AppTypography.h4),
        const SizedBox(height: 20),
        TextFormField(
          controller: _nameController,
          textDirection: TextDirection.rtl,
          decoration: _inputDecoration('نام و نام خانوادگی', Icons.person_outline),
          validator: (v) => (v == null || v.isEmpty) ? 'نام را وارد کنید' : null,
        ),
        const SizedBox(height: 16),
        TextFormField(
          controller: _emailController,
          textDirection: TextDirection.rtl,
          decoration: _inputDecoration('ایمیل', Icons.email_outlined),
          keyboardType: TextInputType.emailAddress,
          validator: (v) => (v == null || v.isEmpty) ? 'ایمیل را وارد کنید' : null,
        ),
        const SizedBox(height: 16),
        TextFormField(
          controller: _phoneController,
          textDirection: TextDirection.rtl,
          decoration: _inputDecoration('شماره تماس', Icons.phone_outlined),
          keyboardType: TextInputType.phone,
        ),
        const SizedBox(height: 16),
        TextFormField(
          controller: _bioController,
          textDirection: TextDirection.rtl,
          maxLines: 4,
          decoration: _inputDecoration('درباره من (خلاصه)', Icons.info_outline),
        ),
        const SizedBox(height: 24),
        _buildPrimaryButton('مرحله بعد', () {
          if (_formKey.currentState!.validate()) {
            setState(() => _currentStep++);
          }
        }),
      ]),
    );
  }

  Widget _buildEducation() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppRadius.md),
        border: Border.all(color: AppColors.border, width: 0.5),
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
        Row(textDirection: TextDirection.rtl, mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          const Text('تحصیلات', style: AppTypography.h4),
          TextButton.icon(
            onPressed: _addEducation,
            icon: const Icon(Icons.add, size: 18),
            label: const Text('افزودن', style: TextStyle(fontFamily: AppTypography.fontFamily, fontSize: 13)),
          ),
        ]),
        const SizedBox(height: 12),
        if (_educations.isEmpty)
          Center(child: Padding(
            padding: const EdgeInsets.all(24),
            child: Text('تحصیلی ثبت نشده', style: AppTypography.body.copyWith(color: AppColors.textMuted)),
          )),
        ..._educations.asMap().entries.map((e) => _buildEducationCard(e.key, e.value)),
        const SizedBox(height: 16),
        Row(textDirection: TextDirection.rtl, mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          TextButton(onPressed: () => setState(() => _currentStep--), child: const Text('مرحله قبل', style: TextStyle(fontFamily: AppTypography.fontFamily))),
          _buildPrimaryButton('مرحله بعد', () => setState(() => _currentStep++)),
        ]),
      ]),
    );
  }

  void _addEducation() {
    showDialog(
      context: context,
      builder: (ctx) {
        final degreeCtrl = TextEditingController();
        final fieldCtrl = TextEditingController();
        final uniCtrl = TextEditingController();
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadius.md)),
          title: const Text('افزودن تحصیلات', style: TextStyle(fontFamily: AppTypography.fontFamily)),
          content: Column(mainAxisSize: MainAxisSize.min, children: [
            TextField(controller: degreeCtrl, textDirection: TextDirection.rtl, decoration: _inputDecoration('مقطع تحصیلی', null)),
            const SizedBox(height: 12),
            TextField(controller: fieldCtrl, textDirection: TextDirection.rtl, decoration: _inputDecoration('رشته تحصیلی', null)),
            const SizedBox(height: 12),
            TextField(controller: uniCtrl, textDirection: TextDirection.rtl, decoration: _inputDecoration('دانشگاه', null)),
          ]),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('انصراف', style: TextStyle(fontFamily: AppTypography.fontFamily))),
            ElevatedButton(onPressed: () {
              setState(() => _educations.add({'degree': degreeCtrl.text, 'field': fieldCtrl.text, 'university': uniCtrl.text}));
              Navigator.pop(ctx);
            }, child: const Text('ذخیره', style: TextStyle(fontFamily: AppTypography.fontFamily))),
          ],
        );
      },
    );
  }

  Widget _buildEducationCard(int index, Map<String, dynamic> edu) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 8),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(AppRadius.sm),
      ),
      child: Row(
        textDirection: TextDirection.rtl,
        children: [
          Expanded(
            child: Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
              Text(
                '${edu['degree']} - ${edu['field']}',
                style: AppTypography.bodySmall.copyWith(fontWeight: FontWeight.w600),
                textAlign: TextAlign.right,
              ),
              Text(edu['university'] ?? '', style: AppTypography.caption, textAlign: TextAlign.right),
            ]),
          ),
          IconButton(
            icon: const Icon(Icons.delete_outline, color: AppColors.error, size: 20),
            onPressed: () => setState(() => _educations.removeAt(index)),
          ),
        ],
      ),
    );
  }

  Widget _buildExperience() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppRadius.md),
        border: Border.all(color: AppColors.border, width: 0.5),
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
        Row(textDirection: TextDirection.rtl, mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          const Text('سوابق شغلی', style: AppTypography.h4),
          TextButton.icon(
            onPressed: _addExperience,
            icon: const Icon(Icons.add, size: 18),
            label: const Text('افزودن', style: TextStyle(fontFamily: AppTypography.fontFamily, fontSize: 13)),
          ),
        ]),
        const SizedBox(height: 12),
        if (_experiences.isEmpty)
          Center(child: Padding(
            padding: const EdgeInsets.all(24),
            child: Text('سابقه شغلی ثبت نشده', style: AppTypography.body.copyWith(color: AppColors.textMuted)),
          )),
        ..._experiences.asMap().entries.map((e) => _buildExperienceCard(e.key, e.value)),
        const SizedBox(height: 16),
        Row(textDirection: TextDirection.rtl, mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          TextButton(onPressed: () => setState(() => _currentStep--), child: const Text('مرحله قبل', style: TextStyle(fontFamily: AppTypography.fontFamily))),
          _buildPrimaryButton('مرحله بعد', () => setState(() => _currentStep++)),
        ]),
      ]),
    );
  }

  void _addExperience() {
    showDialog(
      context: context,
      builder: (ctx) {
        final companyCtrl = TextEditingController();
        final positionCtrl = TextEditingController();
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadius.md)),
          title: const Text('افزودن سابقه شغلی', style: TextStyle(fontFamily: AppTypography.fontFamily)),
          content: Column(mainAxisSize: MainAxisSize.min, children: [
            TextField(controller: companyCtrl, textDirection: TextDirection.rtl, decoration: _inputDecoration('نام شرکت', null)),
            const SizedBox(height: 12),
            TextField(controller: positionCtrl, textDirection: TextDirection.rtl, decoration: _inputDecoration('سمت', null)),
          ]),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('انصراف', style: TextStyle(fontFamily: AppTypography.fontFamily))),
            ElevatedButton(onPressed: () {
              setState(() => _experiences.add({'company': companyCtrl.text, 'position': positionCtrl.text}));
              Navigator.pop(ctx);
            }, child: const Text('ذخیره', style: TextStyle(fontFamily: AppTypography.fontFamily))),
          ],
        );
      },
    );
  }

  Widget _buildExperienceCard(int index, Map<String, dynamic> exp) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 8),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(AppRadius.sm),
      ),
      child: Row(
        textDirection: TextDirection.rtl,
        children: [
          Expanded(
            child: Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
              Text(exp['position'] ?? '', style: AppTypography.bodySmall.copyWith(fontWeight: FontWeight.w600), textAlign: TextAlign.right),
              Text(exp['company'] ?? '', style: AppTypography.caption, textAlign: TextAlign.right),
            ]),
          ),
          IconButton(
            icon: const Icon(Icons.delete_outline, color: AppColors.error, size: 20),
            onPressed: () => setState(() => _experiences.removeAt(index)),
          ),
        ],
      ),
    );
  }

  Widget _buildSkills() {
    final skillCtrl = TextEditingController();
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppRadius.md),
        border: Border.all(color: AppColors.border, width: 0.5),
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
        const Text('مهارت‌ها', style: AppTypography.h4),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: TextField(
                controller: skillCtrl,
                textDirection: TextDirection.rtl,
                decoration: _inputDecoration('مهارت جدید', Icons.psychology_outlined),
                onSubmitted: (v) {
                  if (v.isNotEmpty) {
                    setState(() => _skills.add(v));
                    skillCtrl.clear();
                  }
                },
              ),
            ),
            const SizedBox(width: 8),
            Container(
              width: 46, height: 46,
              decoration: BoxDecoration(
                color: AppColors.primary,
                borderRadius: BorderRadius.circular(AppRadius.md),
              ),
              child: IconButton(
                icon: const Icon(Icons.add, color: Colors.white),
                onPressed: () {
                  if (skillCtrl.text.isNotEmpty) {
                    setState(() => _skills.add(skillCtrl.text));
                    skillCtrl.clear();
                  }
                },
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Wrap(
          spacing: 8, runSpacing: 8,
          textDirection: TextDirection.rtl,
          children: _skills.map((s) => Chip(
            label: Text(s, style: const TextStyle(fontFamily: AppTypography.fontFamily, fontSize: 12)),
            deleteIcon: const Icon(Icons.close, size: 16),
            onDeleted: () => setState(() => _skills.remove(s)),
            backgroundColor: AppColors.primaryLight,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadius.sm)),
          )).toList(),
        ),
        if (_skills.isEmpty)
          Center(child: Padding(
            padding: const EdgeInsets.all(24),
            child: Text('مهارتی ثبت نشده', style: AppTypography.body.copyWith(color: AppColors.textMuted)),
          )),
        const SizedBox(height: 24),
        Row(
          textDirection: TextDirection.rtl,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            TextButton(onPressed: () => setState(() => _currentStep--), child: const Text('مرحله قبل', style: TextStyle(fontFamily: AppTypography.fontFamily))),
            ElevatedButton(
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                  content: const Text('رزومه با موفقیت ساخته شد', style: TextStyle(fontFamily: AppTypography.fontFamily)),
                  backgroundColor: AppColors.success,
                  behavior: SnackBarBehavior.floating,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadius.sm)),
                ));
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.success,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadius.md)),
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
              ),
              child: const Text('ذخیره رزومه', style: TextStyle(fontFamily: AppTypography.fontFamily, fontWeight: FontWeight.bold)),
            ),
          ],
        ),
      ]),
    );
  }

  Widget _buildPrimaryButton(String text, VoidCallback onPressed) {
    return SizedBox(
      width: double.infinity,
      height: 50,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadius.md)),
          elevation: 0,
        ),
        child: Text(text, style: const TextStyle(fontFamily: AppTypography.fontFamily, fontSize: 16, fontWeight: FontWeight.bold)),
      ),
    );
  }

  InputDecoration _inputDecoration(String label, IconData? icon) {
    return InputDecoration(
      labelText: label,
      labelStyle: const TextStyle(fontFamily: AppTypography.fontFamily, color: AppColors.textSecondary),
      filled: true,
      fillColor: AppColors.background,
      prefixIcon: icon != null ? Icon(icon, color: AppColors.textMuted) : null,
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
