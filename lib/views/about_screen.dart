import 'package:flutter/material.dart';
import '../utils/constants.dart';
import '../widgets/jobinja_logo.dart';

class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('درباره جابینجا'),
        centerTitle: true,
        backgroundColor: AppColors.surface,
        elevation: 0,
        foregroundColor: AppColors.textPrimary,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            _buildHeroSection(),
            const SizedBox(height: 8),
            _buildStorySection(),
            const SizedBox(height: 8),
            _buildStatsSection(),
            const SizedBox(height: 8),
            _buildValuesSection(),
            const SizedBox(height: 8),
            _buildTeamSection(context),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Widget _buildHeroSection() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 24),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [AppColors.primary, AppColors.primaryDark],
          begin: Alignment.topRight,
          end: Alignment.bottomLeft,
        ),
      ),
      child: Column(
        children: [
          const JobinjaLogo(size: 56, showText: false, iconColor: Colors.white),
          const SizedBox(height: 16),
          const Text(
            'جابینجا',
            style: TextStyle(
              fontFamily: AppTypography.fontFamily,
              fontSize: 32,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'سامانه کاریابی آنلاین',
            style: TextStyle(
              fontFamily: AppTypography.fontFamily,
              fontSize: 16,
              color: Colors.white.withValues(alpha: 0.9),
            ),
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(AppRadius.full),
            ),
            child: const Text(
              'بزرگترین سایت کاریابی ایران',
              style: TextStyle(
                fontFamily: AppTypography.fontFamily,
                fontSize: 12,
                color: Colors.white,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStorySection() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      color: AppColors.surface,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          const Text('داستان جابینجا', style: AppTypography.h2),
          const SizedBox(height: 16),
          Text(
            'جابینجا در سال ۱۳۹۲ با هدف ایجاد بستری مطمئن و حرفه‌ای برای ارتباط بین کارجویان و کارفرمایان در ایران تأسیس شد. '
            'ما معتقدیم هر فرد مستعدی شایسته شغلی است که به آن علاقه دارد و هر شرکتی لایق نیروهای متخصصی است که به رشد آن کمک کنند.',
            style: AppTypography.body.copyWith(
              color: AppColors.textSecondary,
              height: 1.8,
            ),
            textAlign: TextAlign.right,
          ),
          const SizedBox(height: 12),
          Text(
            'امروز جابینجا با هزاران آگهی شغلی فعال از معتبرترین شرکت‌های ایرانی، به بزرگترین سامانه کاریابی آنلاین کشور تبدیل شده است. '
            'ما به ایجاد محیطی شفاف و حرفه‌ای برای استخدام در ایران افتخار می‌کنیم.',
            style: AppTypography.body.copyWith(
              color: AppColors.textSecondary,
              height: 1.8,
            ),
            textAlign: TextAlign.right,
          ),
        ],
      ),
    );
  }

  Widget _buildStatsSection() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      color: AppColors.surface,
      child: Row(
        textDirection: TextDirection.rtl,
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _buildStatCard('+۵,۰۰۰', 'شرکت فعال', Icons.business, AppColors.primary),
          _buildStatCard('+۱۰,۰۰۰', 'آگهی شغلی', Icons.work_outline, AppColors.accent),
          _buildStatCard('+۱,۰۰۰,۰۰۰', 'کارجو', Icons.people_outline, AppColors.amber),
          _buildStatCard('۹ سال', 'تجربه', Icons.auto_awesome, AppColors.purple),
        ],
      ),
    );
  }

  Widget _buildStatCard(String value, String label, IconData icon, Color color) {
    return Column(
      children: [
        Container(
          width: 48, height: 48,
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(AppRadius.md),
          ),
          child: Icon(icon, color: color, size: 24),
        ),
        const SizedBox(height: 8),
        Text(
          value,
          style: AppTypography.h3.copyWith(color: color),
        ),
        Text(
          label,
          style: AppTypography.caption,
        ),
      ],
    );
  }

  Widget _buildValuesSection() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      color: AppColors.surface,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          const Text('ارزش‌های ما', style: AppTypography.h2),
          const SizedBox(height: 20),
          _buildValueItem(
            Icons.verified_outlined,
            'شفافیت',
            'ما به شفافیت در فرآیند استخدام اعتقاد داریم و اطلاعات دقیق شغلی را در اختیار کاربران قرار می‌دهیم.',
            AppColors.primary,
          ),
          const SizedBox(height: 16),
          _buildValueItem(
            Icons.psychology_outlined,
            'حرفه‌ای‌گرایی',
            'با ارائه ابزارهای حرفه‌ای رزومه‌سازی و جستجوی پیشرفته، به کاربران در یافتن شغل مناسب کمک می‌کنیم.',
            AppColors.accent,
          ),
          const SizedBox(height: 16),
          _buildValueItem(
            Icons.people_outline,
            'اعتماد',
            'اعتماد مهمترین سرمایه ماست. تمامی شرکت‌های فعال در جابینجا توسط تیم ما تأیید شده‌اند.',
            AppColors.amber,
          ),
          const SizedBox(height: 16),
          _buildValueItem(
            Icons.trending_up_outlined,
            'نوآوری',
            'ما همواره در حال بهبود و نوآوری هستیم تا بهترین تجربه را برای کاربران خود فراهم کنیم.',
            AppColors.purple,
          ),
        ],
      ),
    );
  }

  Widget _buildValueItem(IconData icon, String title, String description, Color color) {
    return Row(
      textDirection: TextDirection.rtl,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 44, height: 44,
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(AppRadius.md),
          ),
          child: Icon(icon, color: color, size: 24),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
            Text(title, style: AppTypography.h4),
            const SizedBox(height: 4),
            Text(
              description,
              style: AppTypography.bodySmall.copyWith(height: 1.6),
              textAlign: TextAlign.right,
            ),
          ]),
        ),
      ],
    );
  }

  Widget _buildTeamSection(BuildContext context) {
    final nav = Navigator.of(context);
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      color: AppColors.surface,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          const Text('تیم ما', style: AppTypography.h2),
          const SizedBox(height: 12),
          Text(
            'تیم جابینجا متشکل از افراد متخصص و پرانرژی است که هر روز با عشق برای بهبود تجربه کاربران تلاش می‌کنند. '
            'ما به نیروی انسانی به عنوان مهمترین دارایی خود اعتقاد داریم.',
            style: AppTypography.body.copyWith(
              color: AppColors.textSecondary,
              height: 1.8,
            ),
            textAlign: TextAlign.right,
          ),
          const SizedBox(height: 20),
          Center(
            child: SizedBox(
              width: 200,
              child: OutlinedButton.icon(
                onPressed: () => nav.pushNamed('/contact'),
                icon: const Icon(Icons.headset_mic, size: 18),
                label: const Text(
                  'ارتباط با تیم',
                  style: TextStyle(fontFamily: AppTypography.fontFamily),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
