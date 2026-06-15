import 'package:flutter/material.dart';
import '../widgets/custom_button.dart';
import '../utils/constants.dart';

class JobAlertScreen extends StatefulWidget {
  const JobAlertScreen({super.key});

  @override
  State<JobAlertScreen> createState() => _JobAlertScreenState();
}

class _JobAlertScreenState extends State<JobAlertScreen> {
  final _keywordController = TextEditingController();
  String? _selectedCategory;
  String? _selectedLocation;
  String? _selectedFrequency;

  final List<String> frequencies = ['روزانه', 'هفتگی', 'فوری'];

  @override
  void dispose() {
    _keywordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('ایمیل اطلاع‌رسانی'),
        centerTitle: true,
        backgroundColor: AppColors.surface,
        elevation: 0,
        foregroundColor: AppColors.textPrimary,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            _buildHeader(),
            const SizedBox(height: 16),
            _buildForm(),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [AppColors.primary, AppColors.primaryDark],
          begin: Alignment.topRight,
          end: Alignment.bottomLeft,
        ),
        borderRadius: BorderRadius.circular(AppRadius.md),
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
        const Row(
          textDirection: TextDirection.rtl,
          children: [
            Icon(Icons.notifications_active, color: Colors.white, size: 28),
            SizedBox(width: 8),
            Text(
              'از آگهی‌های جدید باخبر شو!',
              style: TextStyle(
                fontFamily: AppTypography.fontFamily,
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        const Text(
          'با تنظیم هشدار شغلی، به محض انتشار آگهی‌های جدید متناسب با علاقه‌مندی‌هایتان، ایمیل دریافت کنید.',
          style: TextStyle(
            fontFamily: AppTypography.fontFamily,
            fontSize: 13,
            color: Colors.white70,
            height: 1.6,
          ),
          textAlign: TextAlign.right,
        ),
      ]),
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
      child: Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
        const Text('تنظیمات هشدار', style: AppTypography.h4),
        const SizedBox(height: 20),
        Text('کلمه کلیدی', style: AppTypography.bodySmall.copyWith(fontWeight: FontWeight.w600)),
        const SizedBox(height: 8),
        TextField(
          controller: _keywordController,
          textDirection: TextDirection.rtl,
          decoration: InputDecoration(
            hintText: 'مثال: برنامه‌نویس، پایتون، حسابداری',
            hintStyle: const TextStyle(fontFamily: AppTypography.fontFamily, color: AppColors.textMuted),
            prefixIcon: const Icon(Icons.search, color: AppColors.textMuted),
            filled: true, fillColor: AppColors.background,
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(AppRadius.md), borderSide: const BorderSide(color: AppColors.border)),
            enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(AppRadius.md), borderSide: const BorderSide(color: AppColors.border)),
            focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(AppRadius.md), borderSide: const BorderSide(color: AppColors.primary, width: 2)),
          ),
        ),
        const SizedBox(height: 20),
        Text('دسته‌بندی شغلی', style: AppTypography.bodySmall.copyWith(fontWeight: FontWeight.w600)),
        const SizedBox(height: 8),
        _buildDropdown('همه دسته‌بندی‌ها', _selectedCategory, ['وب, برنامه‌نویسی و نرم‌افزار', 'فروش و بازاریابی', 'مالی و حسابداری', 'طراحی', 'IT / DevOps / Server'], (v) {
          setState(() => _selectedCategory = v);
        }),
        const SizedBox(height: 20),
        Text('موقعیت مکانی', style: AppTypography.bodySmall.copyWith(fontWeight: FontWeight.w600)),
        const SizedBox(height: 8),
        _buildDropdown('همه استان‌ها', _selectedLocation, ['تهران', 'اصفهان', 'خراسان رضوی', 'البرز', 'مازندران', 'فارس', 'گیلان', 'آذربایجان شرقی'], (v) {
          setState(() => _selectedLocation = v);
        }),
        const SizedBox(height: 20),
        Text('فرکانس ارسال', style: AppTypography.bodySmall.copyWith(fontWeight: FontWeight.w600)),
        const SizedBox(height: 8),
        _buildDropdown('روزانه', _selectedFrequency, frequencies, (v) {
          setState(() => _selectedFrequency = v);
        }),
        const SizedBox(height: 32),
        CustomButton(
          text: 'ثبت هشدار شغلی',
          onPressed: () {
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(
              content: const Text('هشدار شغلی با موفقیت ثبت شد', style: TextStyle(fontFamily: AppTypography.fontFamily)),
              backgroundColor: AppColors.success,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadius.sm)),
            ));
          },
        ),
      ]),
    );
  }

  Widget _buildDropdown(String hint, String? value, List<String> items, ValueChanged<String?> onChanged) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(AppRadius.md),
        border: Border.all(color: AppColors.border),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: items.contains(value) ? value : null,
          isExpanded: true,
          hint: Text(hint, style: const TextStyle(fontFamily: AppTypography.fontFamily, color: AppColors.textMuted)),
          icon: const Icon(Icons.arrow_drop_down, size: 24, color: AppColors.textSecondary),
          style: const TextStyle(fontFamily: AppTypography.fontFamily, fontSize: 14, color: AppColors.textPrimary),
          items: items.map((e) => DropdownMenuItem(value: e, child: Text(e, textDirection: TextDirection.rtl))).toList(),
          onChanged: onChanged,
        ),
      ),
    );
  }
}
