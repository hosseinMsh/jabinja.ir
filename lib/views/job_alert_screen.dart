import 'package:flutter/material.dart';

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
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        title: const Text('ایمیل اطلاع‌رسانی', style: TextStyle(fontFamily: 'Vazir', fontSize: 18, fontWeight: FontWeight.bold)),
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
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: const BorderDirectional(
          start: BorderSide(color: Color(0xFF4A90D9), width: 4),
        ),
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
        const Row(
          textDirection: TextDirection.rtl,
          children: [
            Icon(Icons.notifications_active, color: Color(0xFF4A90D9), size: 28),
            SizedBox(width: 8),
            Text('از آگهی‌های جدید باخبر شو!', style: TextStyle(fontFamily: 'Vazir', fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF212529))),
          ],
        ),
        const SizedBox(height: 12),
        const Text(
          'با تنظیم هشدار شغلی، به محض انتشار آگهی‌های جدید متناسب با علاقه‌مندی‌هایتان، ایمیل دریافت کنید.',
          style: TextStyle(fontFamily: 'Vazir', fontSize: 13, color: Color(0xFF6C757D), height: 1.6),
          textAlign: TextAlign.right,
        ),
      ]),
    );
  }

  Widget _buildForm() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12)),
      child: Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
        const Text('تنظیمات هشدار', style: TextStyle(fontFamily: 'Vazir', fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF212529))),
        const SizedBox(height: 20),
        const Text('کلمه کلیدی', style: TextStyle(fontFamily: 'Vazir', fontSize: 13, color: Color(0xFF495057))),
        const SizedBox(height: 8),
        TextField(
          controller: _keywordController,
          textDirection: TextDirection.rtl,
          decoration: InputDecoration(
            hintText: 'مثال: برنامه‌نویس، پایتون، حسابداری',
            hintStyle: const TextStyle(fontFamily: 'Vazir', color: Color(0xFFADB5BD)),
            prefixIcon: const Icon(Icons.search, color: Color(0xFFADB5BD)),
            filled: true, fillColor: const Color(0xFFF8F9FA),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFFDEE2E6))),
            enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFFDEE2E6))),
            focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFF4A90D9), width: 2)),
          ),
        ),
        const SizedBox(height: 20),
        const Text('دسته‌بندی شغلی', style: TextStyle(fontFamily: 'Vazir', fontSize: 13, color: Color(0xFF495057))),
        const SizedBox(height: 8),
        _buildDropdown('همه دسته‌بندی‌ها', _selectedCategory, ['وب، برنامه‌نویسی و نرم‌افزار', 'فروش و بازاریابی', 'مالی و حسابداری', 'طراحی', 'IT / DevOps / Server'], (v) {
          setState(() => _selectedCategory = v);
        }),
        const SizedBox(height: 20),
        const Text('موقعیت مکانی', style: TextStyle(fontFamily: 'Vazir', fontSize: 13, color: Color(0xFF495057))),
        const SizedBox(height: 8),
        _buildDropdown('همه استان‌ها', _selectedLocation, ['تهران', 'اصفهان', 'خراسان رضوی', 'البرز', 'مازندران', 'فارس', 'گیلان', 'آذربایجان شرقی'], (v) {
          setState(() => _selectedLocation = v);
        }),
        const SizedBox(height: 20),
        const Text('فرکانس ارسال', style: TextStyle(fontFamily: 'Vazir', fontSize: 13, color: Color(0xFF495057))),
        const SizedBox(height: 8),
        _buildDropdown('روزانه', _selectedFrequency, frequencies, (v) {
          setState(() => _selectedFrequency = v);
        }),
        const SizedBox(height: 32),
        ElevatedButton(
          onPressed: () {
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(
              content: const Text('هشدار شغلی با موفقیت ثبت شد', style: TextStyle(fontFamily: 'Vazir')),
              backgroundColor: const Color(0xFF27AE60),
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ));
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF4A90D9),
            foregroundColor: Colors.white,
            minimumSize: const Size(double.infinity, 50),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
          child: const Text('ثبت هشدار شغلی', style: TextStyle(fontFamily: 'Vazir', fontSize: 16, fontWeight: FontWeight.bold)),
        ),
      ]),
    );
  }

  Widget _buildDropdown(String hint, String? value, List<String> items, ValueChanged<String?> onChanged) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: const Color(0xFFF8F9FA),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFDEE2E6)),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: items.contains(value) ? value : null,
          isExpanded: true,
          hint: Text(hint, style: const TextStyle(fontFamily: 'Vazir', color: Color(0xFFADB5BD))),
          icon: const Icon(Icons.arrow_drop_down, size: 24),
          style: const TextStyle(fontFamily: 'Vazir', fontSize: 14, color: Color(0xFF212529)),
          items: items.map((e) => DropdownMenuItem(value: e, child: Text(e, textDirection: TextDirection.rtl))).toList(),
          onChanged: onChanged,
        ),
      ),
    );
  }
}
