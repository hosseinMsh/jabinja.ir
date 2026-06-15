import 'package:flutter/material.dart';
import '../utils/constants.dart';

class HowToScreen extends StatelessWidget {
  const HowToScreen({super.key});

  static const List<Map<String, dynamic>> steps = [
    {
      'icon': Icons.person_add_rounded,
      'title': 'ثبت نام در جابینجا',
      'description': 'وارد جابینجا شوید. اگر حساب کاربری ندارید، می‌توانید به سادگی با گوگل، لینکدین یا ایمیل ثبت نام کنید.',
    },
    {
      'icon': Icons.description_rounded,
      'title': 'رزومه خود را بسازید',
      'description': 'با رزومه‌ساز استاندارد جابینجا در کمترین زمان رزومه‌تان را بسازید یا اگر فایل رزومه آماده دارید آپلود کنید.',
    },
    {
      'icon': Icons.search_rounded,
      'title': 'شغل مورد نظر را پیدا کنید',
      'description': 'می‌توانید عنوان شغلی یا نام شرکتی که می‌خواهید را در قسمت جستجو وارد کنید و آگهی‌ها را ببینید.',
    },
    {
      'icon': Icons.send_rounded,
      'title': 'رزومه خود را ارسال کنید',
      'description': 'جزئیات آگهی را با دقت بخوانید و اگر شرایطش با سابقه شغلیتان هماهنگ بود، رزومه‌تان را برایشان ارسال کنید.',
    },
    {
      'icon': Icons.notifications_active_rounded,
      'title': 'از آگهی‌های جدید باخبر شوید',
      'description': 'با فعال کردن هشدار شغلی، به محض انتشار آگهی‌های جدید مرتبط با زمینه شغلی شما، ایمیل دریافت می‌کنید.',
    },
    {
      'icon': Icons.trending_up_rounded,
      'title': 'ردیابی درخواست‌ها',
      'description': 'از بخش "درخواست‌های من" می‌توانید وضعیت درخواست‌های ارسال شده خود را پیگیری کنید.',
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('راهنمای استفاده'),
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
            ...steps.asMap().entries.map((e) => _buildStep(e.key, e.value)),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [AppColors.primary, AppColors.primaryDark],
          begin: Alignment.topRight,
          end: Alignment.bottomLeft,
        ),
        borderRadius: BorderRadius.circular(AppRadius.lg),
      ),
      child: Column(children: [
        Container(
          width: 64, height: 64,
          decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.2), borderRadius: BorderRadius.circular(AppRadius.lg)),
          child: const Icon(Icons.help_outline, color: Colors.white, size: 36),
        ),
        const SizedBox(height: 16),
        const Text(
          'جابینجا چطور به استخدام شدن من کمک می‌کند؟',
          style: TextStyle(fontFamily: AppTypography.fontFamily, fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 8),
        const Text(
          'با جابینجا در ۶ قدم ساده شغل دلخواه خود را پیدا کنید',
          style: TextStyle(fontFamily: AppTypography.fontFamily, fontSize: 13, color: Colors.white70),
          textAlign: TextAlign.center,
        ),
      ]),
    );
  }

  Widget _buildStep(int index, Map<String, dynamic> step) {
    final colors = [AppColors.primary, AppColors.accent, AppColors.amber, AppColors.purple, AppColors.lightBlue, AppColors.success];
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppRadius.md),
        border: Border.all(color: AppColors.border, width: 0.5),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        textDirection: TextDirection.rtl,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 44, height: 44,
            decoration: BoxDecoration(
              color: colors[index].withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(AppRadius.md),
            ),
            child: Center(
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(step['icon'] as IconData, size: 16, color: colors[index]),
                  const SizedBox(width: 4),
                  Text(
                    '${index + 1}',
                    style: TextStyle(
                      fontFamily: AppTypography.fontFamily,
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: colors[index],
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
              Text(
                step['title'] as String,
                style: AppTypography.body.copyWith(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Text(
                step['description'] as String,
                style: AppTypography.bodySmall.copyWith(height: 1.6),
                textAlign: TextAlign.right,
              ),
            ]),
          ),
        ],
      ),
    );
  }
}
