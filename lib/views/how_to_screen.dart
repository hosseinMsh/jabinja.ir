import 'package:flutter/material.dart';

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
      'description': 'می‌توانید عنوان شغلی یا نام شرکتی که می‌خواهید را در قسمت جستجو وارد کنید و آگهی‌ها را ببینید. همچنین می‌توانید بر اساس استان، دسته‌بندی و نوع همکاری فیلتر کنید.',
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
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        title: const Text('راهنمای استفاده', style: TextStyle(fontFamily: 'Vazir', fontSize: 18, fontWeight: FontWeight.bold)),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0,
        foregroundColor: const Color(0xFF212529),
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
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: const LinearGradient(colors: [Color(0xFF4A90D9), Color(0xFF357ABD)]),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(children: [
        Container(
          width: 64, height: 64,
          decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.2), borderRadius: BorderRadius.circular(16)),
          child: const Icon(Icons.help_outline, color: Colors.white, size: 36),
        ),
        const SizedBox(height: 16),
        const Text('جابینجا چطور به استخدام شدن من کمک می‌کند؟', style: TextStyle(fontFamily: 'Vazir', fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white), textAlign: TextAlign.center),
        const SizedBox(height: 8),
        const Text('با جابینجا در ۶ قدم ساده شغل دلخواه خود را پیدا کنید', style: TextStyle(fontFamily: 'Vazir', fontSize: 13, color: Colors.white70), textAlign: TextAlign.center),
      ]),
    );
  }

  Widget _buildStep(int index, Map<String, dynamic> step) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        textDirection: TextDirection.rtl,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 44, height: 44,
            decoration: BoxDecoration(
              color: const Color(0xFFE8F0FE),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Center(
              child: Text(
                '${index + 1}',
                style: const TextStyle(fontFamily: 'Vazir', fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF4A90D9)),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
              Row(
                textDirection: TextDirection.rtl,
                children: [
                  Icon(step['icon'] as IconData, size: 20, color: const Color(0xFF4A90D9)),
                  const SizedBox(width: 6),
                  Text(step['title'] as String, style: const TextStyle(fontFamily: 'Vazir', fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF212529))),
                ],
              ),
              const SizedBox(height: 8),
              Text(step['description'] as String, style: const TextStyle(fontFamily: 'Vazir', fontSize: 13, color: Color(0xFF6C757D), height: 1.6), textAlign: TextAlign.right),
            ]),
          ),
        ],
      ),
    );
  }
}
