import 'package:flutter/material.dart';
import '../presenters/job_presenter.dart';
import '../models/company.dart';
import '../models/job.dart';
import '../models/job_filter.dart';
import '../widgets/job_card.dart';
import '../widgets/loading_widget.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> implements JobView {
  late final JobPresenter _presenter;
  final _searchController = TextEditingController();
  List<Job> _jobs = [];
  List<Job> _recommendedJobs = [];
  List<Company> _topCompanies = [];

  bool _isLoading = false;
  String? _errorMessage;
  String? _selectedCategory;
  String? _selectedLocation;
  String? _selectedContractType;
  bool _showFilters = false;

  static const List<Map<String, String>> categories = [
    {'name': 'همه', 'id': ''},
    {'name': 'وب، برنامه‌نویسی و نرم‌افزار', 'id': 'وب، برنامه‌نویسی و نرم‌افزار'},
    {'name': 'IT / DevOps / Server', 'id': 'IT / DevOps / Server'},
    {'name': 'طراحی', 'id': 'طراحی'},
    {'name': 'فروش و بازاریابی', 'id': 'فروش و بازاریابی'},
    {'name': 'مدیر محصول', 'id': 'مدیر محصول'},
    {'name': 'مالی و حسابداری', 'id': 'مالی و حسابداری'},
    {'name': 'دیجیتال مارکتینگ', 'id': 'دیجیتال مارکتینگ'},
    {'name': 'منابع انسانی', 'id': 'منابع انسانی و کارگزینی'},
  ];

  static const List<Map<String, String>> locations = [
    {'name': 'همه استان‌ها', 'id': ''},
    {'name': 'تهران', 'id': 'تهران'},
    {'name': 'اصفهان', 'id': 'اصفهان'},
    {'name': 'مشهد', 'id': 'مشهد'},
    {'name': 'شیراز', 'id': 'شیراز'},
    {'name': 'تبریز', 'id': 'تبریز'},
    {'name': 'دورکاری', 'id': 'دورکاری'},
  ];

  static const List<Map<String, String>> contractTypes = [
    {'name': 'همه', 'id': ''},
    {'name': 'تمام‌وقت', 'id': 'تمام‌وقت'},
    {'name': 'دورکاری', 'id': 'دورکاری'},
    {'name': 'پروژه‌ای', 'id': 'پروژه‌ای'},
    {'name': 'پاره‌وقت', 'id': 'پاره‌وقت'},
  ];

  static const List<String> popularSearches = [
    'دورکاری', 'پایتون', 'فلاتر', 'فرانت اند', 'هوش مصنوعی',
    'حسابدار', 'ادمین', 'منشی', 'فروشنده', 'سئو',
    'گرافیست', 'برنامه نویس', 'کارآموز', 'پشتیبان', 'React',
    'جاوا', 'مدیر محصول', 'دواپس', 'پشتیبانی', 'حسابداری',
  ];

  @override
  void initState() {
    super.initState();
    _presenter = JobPresenter(this);
    _presenter.loadJobs();
    _presenter.loadRecommendedJobs();
    _presenter.loadTopCompanies();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        title: const Text(
          'جابینجا',
          style: TextStyle(fontFamily: 'Vazir', fontSize: 20, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0,
        foregroundColor: const Color(0xFF212529),
        actions: [
          IconButton(
            icon: const Icon(Icons.tune),
            onPressed: () => setState(() => _showFilters = !_showFilters),
          ),
          IconButton(
            icon: const Icon(Icons.person_outline),
            onPressed: () => Navigator.pushNamed(context, '/profile'),
          ),
          Builder(
            builder: (ctx) => IconButton(
              icon: const Icon(Icons.menu),
              onPressed: () => Scaffold.of(ctx).openDrawer(),
            ),
          ),
        ],
      ),
      drawer: _buildDrawer(),
      body: Column(
        children: [
          _buildSearchBar(),
          if (_showFilters) _buildFilterBar(),
          _buildTabBar(),
          Expanded(child: _buildBody()),
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
      color: Colors.white,
      child: TextField(
        controller: _searchController,
        textDirection: TextDirection.rtl,
        decoration: InputDecoration(
          hintText: 'عنوان شغلی، مهارت یا شرکت...',
          hintStyle: const TextStyle(fontFamily: 'Vazir', color: Color(0xFFADB5BD)),
          prefixIcon: const Icon(Icons.search, color: Color(0xFFADB5BD)),
          suffixIcon: _searchController.text.isNotEmpty
              ? IconButton(
                  icon: const Icon(Icons.clear, color: Color(0xFFADB5BD)),
                  onPressed: () {
                    _searchController.clear();
                    _applyFilters();
                  },
                )
              : null,
          filled: true,
          fillColor: const Color(0xFFF8F9FA),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        ),
        style: const TextStyle(fontFamily: 'Vazir', fontSize: 14),
        onSubmitted: (value) => _applyFilters(),
        onChanged: (value) {
          if (value.isEmpty) _applyFilters();
        },
      ),
    );
  }

  Widget _buildFilterBar() {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
      color: Colors.white,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Row(
            children: [
              Expanded(
                child: _buildDropdown('دسته‌بندی', _selectedCategory ?? 'همه', categories, (v) {
                  setState(() => _selectedCategory = v == 'همه' ? '' : v);
                  _applyFilters();
                }),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _buildDropdown('موقعیت', _selectedLocation ?? 'همه استان‌ها', locations, (v) {
                  setState(() => _selectedLocation = v == 'همه استان‌ها' ? '' : v);
                  _applyFilters();
                }),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _buildDropdown('نوع همکاری', _selectedContractType ?? 'همه', contractTypes, (v) {
                  setState(() => _selectedContractType = v == 'همه' ? '' : v);
                  _applyFilters();
                }),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDropdown(String label, String value, List<Map<String, String>> items, ValueChanged<String> onChanged) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8),
      decoration: BoxDecoration(
        color: const Color(0xFFF8F9FA),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0xFFDEE2E6)),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: items.any((e) => e['name'] == value) ? value : items.first['name'],
          isExpanded: true,
          icon: const Icon(Icons.arrow_drop_down, size: 20),
          style: const TextStyle(fontFamily: 'Vazir', fontSize: 12, color: Color(0xFF495057)),
          items: items.map((e) => DropdownMenuItem(
            value: e['name'],
            child: Text(e['name']!, textDirection: TextDirection.rtl),
          )).toList(),
          onChanged: (v) { if (v != null) onChanged(v); },
        ),
      ),
    );
  }

  Widget _buildTabBar() {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          textDirection: TextDirection.rtl,
          children: [
            const SizedBox(width: 16),
            _buildTab('جستجو', true, () {}),
            _buildTab('درخواست‌های من', false, () => Navigator.pushNamed(context, '/applied-jobs')),
            _buildTab('نشان‌شده‌ها', false, () => Navigator.pushNamed(context, '/favorites')),
            _buildTab('۵۰ شرکت برتر', false, () => Navigator.pushNamed(context, '/top-companies')),
            const SizedBox(width: 16),
          ],
        ),
      ),
    );
  }

  Widget _buildTab(String text, bool isActive, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(left: 8),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isActive ? const Color(0xFF4A90D9) : const Color(0xFFF8F9FA),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          text,
          style: TextStyle(
            fontFamily: 'Vazir',
            fontSize: 13,
            color: isActive ? Colors.white : const Color(0xFF495057),
            fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
          ),
        ),
      ),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const LoadingWidget(message: 'در حال جستجو...');
    }

    if (_errorMessage != null) {
      return _buildErrorState();
    }

    return RefreshIndicator(
      onRefresh: () async => _presenter.loadJobs(),
      child: ListView(
        padding: const EdgeInsets.only(bottom: 16),
        children: [
          _buildStatsBanner(),
          if (_recommendedJobs.isNotEmpty) _buildRecommendedSection(),
          if (_topCompanies.isNotEmpty) _buildTopCompaniesCarousel(),
          _buildPopularSearches(),
          _buildHowToStart(),
          _buildSectionHeader('آخرین آگهی‌ها'),
          if (_jobs.isEmpty)
            _buildEmptyState()
          else
            ..._jobs.map((job) => JobCard(
              job: job,
              isFavorited: _presenter.isFavorited(job.id),
              onTap: () async {
                await Navigator.pushNamed(context, '/job-detail', arguments: job.id);
                if (mounted) setState(() {});
              },
              onFavoriteTap: () => _presenter.toggleFavorite(job.id),
            )),
        ],
      ),
    );
  }

  Widget _buildStatsBanner() {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 12, 16, 4),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(colors: [Color(0xFF4A90D9), Color(0xFF357ABD)]),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        textDirection: TextDirection.rtl,
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _buildStatColumn('۲۰', 'آگهی فعال', Icons.work_outline),
          Container(width: 1, height: 40, color: Colors.white.withValues(alpha: 0.3)),
          _buildStatColumn('۱۲', 'شرکت برتر', Icons.business),
          Container(width: 1, height: 40, color: Colors.white.withValues(alpha: 0.3)),
          _buildStatColumn('۱۰۰%', 'رضایت', Icons.thumb_up_outlined),
        ],
      ),
    );
  }

  Widget _buildStatColumn(String value, String label, IconData icon) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, color: Colors.white, size: 22),
        const SizedBox(height: 6),
        Text(value, style: const TextStyle(fontFamily: 'Vazir', fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white)),
        Text(label, style: const TextStyle(fontFamily: 'Vazir', fontSize: 11, color: Colors.white70)),
      ],
    );
  }

  Widget _buildRecommendedSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 4),
          child: Row(
            textDirection: TextDirection.rtl,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('شغل‌های پیشنهادی', style: TextStyle(fontFamily: 'Vazir', fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF212529))),
              TextButton(
                onPressed: () {},
                child: const Text('مشاهده همه', style: TextStyle(fontFamily: 'Vazir', fontSize: 12)),
              ),
            ],
          ),
        ),
        SizedBox(
          height: 180,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 12),
            itemCount: _recommendedJobs.length,
            itemBuilder: (context, index) {
              final job = _recommendedJobs[index];
              return SizedBox(
                width: 240,
                child: Card(
                  margin: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  child: InkWell(
                    onTap: () async {
                      await Navigator.pushNamed(context, '/job-detail', arguments: job.id);
                      if (mounted) setState(() {});
                    },
                    borderRadius: BorderRadius.circular(12),
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Row(
                            textDirection: TextDirection.rtl,
                            children: [
                              Container(
                                width: 40, height: 40,
                                decoration: BoxDecoration(color: const Color(0xFFE8F0FE), borderRadius: BorderRadius.circular(10)),
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(9),
                                  child: Image.network(
                                    job.company.logoUrl ?? '',
                                    fit: BoxFit.contain,
                                    errorBuilder: (_, __, ___) => const Icon(Icons.business, color: Color(0xFF4A90D9), size: 24),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
                                  Text(job.title, style: const TextStyle(fontFamily: 'Vazir', fontSize: 13, fontWeight: FontWeight.bold, color: Color(0xFF212529)), maxLines: 2, overflow: TextOverflow.ellipsis, textAlign: TextAlign.right),
                                  Text(job.company.name, style: const TextStyle(fontFamily: 'Vazir', fontSize: 11, color: Color(0xFF6C757D)), textAlign: TextAlign.right),
                                ]),
                              ),
                            ],
                          ),
                          const Spacer(),
                          Row(
                            textDirection: TextDirection.rtl,
                            children: [
                              Icon(Icons.location_on_outlined, size: 12, color: const Color(0xFFADB5BD)),
                              const SizedBox(width: 4),
                              Expanded(
                                child: Text(job.location, style: const TextStyle(fontFamily: 'Vazir', fontSize: 11, color: Color(0xFFADB5BD)), overflow: TextOverflow.ellipsis),
                              ),
                            ],
                          ),
                          const SizedBox(height: 4),
                          Row(
                            textDirection: TextDirection.rtl,
                            children: [
                              Icon(Icons.monetization_on_outlined, size: 12, color: const Color(0xFF27AE60)),
                              const SizedBox(width: 4),
                              Text(job.salaryDisplay ?? 'حقوق توافقی', style: const TextStyle(fontFamily: 'Vazir', fontSize: 11, color: Color(0xFF27AE60), fontWeight: FontWeight.bold)),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildTopCompaniesCarousel() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 4),
          child: Row(
            textDirection: TextDirection.rtl,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('شرکت‌های برتر', style: TextStyle(fontFamily: 'Vazir', fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF212529))),
              TextButton(
                onPressed: () => Navigator.pushNamed(context, '/top-companies'),
                child: const Text('مشاهده همه', style: TextStyle(fontFamily: 'Vazir', fontSize: 12)),
              ),
            ],
          ),
        ),
        SizedBox(
          height: 110,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 12),
            itemCount: _topCompanies.length,
            itemBuilder: (context, index) {
              final company = _topCompanies[index];
              return Container(
                width: 100,
                margin: const EdgeInsets.symmetric(horizontal: 4),
                child: GestureDetector(
                  onTap: () => Navigator.pushNamed(context, '/company', arguments: company.slug),
                  child: Card(
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    child: Padding(
                      padding: const EdgeInsets.all(12),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            width: 44, height: 44,
                            decoration: BoxDecoration(color: const Color(0xFFE8F0FE), borderRadius: BorderRadius.circular(10)),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(9),
                              child: Image.network(
                                company.logoUrl ?? '',
                                fit: BoxFit.contain,
                                errorBuilder: (_, __, ___) => const Icon(Icons.business, color: Color(0xFF4A90D9), size: 26),
                              ),
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(company.name, style: const TextStyle(fontFamily: 'Vazir', fontSize: 11, fontWeight: FontWeight.w500, color: Color(0xFF212529)), maxLines: 2, overflow: TextOverflow.ellipsis, textAlign: TextAlign.center),
                        ],
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildPopularSearches() {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 8, 16, 4),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          const Row(
            textDirection: TextDirection.rtl,
            children: [
              Icon(Icons.trending_up, size: 18, color: Color(0xFF4A90D9)),
              SizedBox(width: 6),
              Text('جستجوهای پرطرفدار', style: TextStyle(fontFamily: 'Vazir', fontSize: 14, fontWeight: FontWeight.bold, color: Color(0xFF212529))),
            ],
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8, runSpacing: 8,
            textDirection: TextDirection.rtl,
            children: popularSearches.map((tag) => GestureDetector(
              onTap: () {
                _searchController.text = tag;
                _applyFilters();
              },
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: const Color(0xFFF8F9FA),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: const Color(0xFFDEE2E6)),
                ),
                child: Text(tag, style: const TextStyle(fontFamily: 'Vazir', fontSize: 12, color: Color(0xFF495057))),
              ),
            )).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildHowToStart() {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 8, 16, 4),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          const Text('از کجا شروع کنم؟', style: TextStyle(fontFamily: 'Vazir', fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF212529))),
          const SizedBox(height: 16),
          _buildStepItem(Icons.person_add_outlined, 'ثبت نام در جابینجا', 'با گوگل، لینکدین یا ایمیل ثبت نام کنید'),
          const Divider(height: 24),
          _buildStepItem(Icons.description_outlined, 'ساخت یا آپلود رزومه', 'با رزومه‌ساز استاندارد رزومه خود را بسازید'),
          const Divider(height: 24),
          _buildStepItem(Icons.search_outlined, 'جستجوی مشاغل', 'عنوان شغلی یا شرکت مورد نظر را جستجو کنید'),
          const Divider(height: 24),
          _buildStepItem(Icons.send_outlined, 'ارسال درخواست شغلی', 'برای شغل‌های مورد علاقه رزومه بفرستید'),
        ],
      ),
    );
  }

  Widget _buildStepItem(IconData icon, String title, String subtitle) {
    return Row(
      textDirection: TextDirection.rtl,
      children: [
        Container(
          width: 44, height: 44,
          decoration: BoxDecoration(color: const Color(0xFFE8F0FE), borderRadius: BorderRadius.circular(12)),
          child: Icon(icon, color: const Color(0xFF4A90D9), size: 24),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
            Text(title, style: const TextStyle(fontFamily: 'Vazir', fontSize: 14, fontWeight: FontWeight.w600, color: Color(0xFF212529))),
            Text(subtitle, style: const TextStyle(fontFamily: 'Vazir', fontSize: 12, color: Color(0xFF6C757D))),
          ]),
        ),
      ],
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
      child: Row(
        textDirection: TextDirection.rtl,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(title, style: const TextStyle(fontFamily: 'Vazir', fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF212529))),
          TextButton(
            onPressed: () {},
            child: const Text('مشاهده همه', style: TextStyle(fontFamily: 'Vazir', fontSize: 12)),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.cloud_off, size: 64, color: Color(0xFFADB5BD)),
            const SizedBox(height: 16),
            Text(
              _errorMessage!,
              style: const TextStyle(fontFamily: 'Vazir', fontSize: 14, color: Color(0xFF6C757D)),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            OutlinedButton.icon(
              onPressed: () => _presenter.loadJobs(),
              icon: const Icon(Icons.refresh),
              label: const Text('تلاش مجدد', style: TextStyle(fontFamily: 'Vazir')),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.search_off, size: 64, color: Color(0xFFADB5BD)),
            const SizedBox(height: 16),
            const Text(
              'نتیجه‌ای یافت نشد',
              style: TextStyle(fontFamily: 'Vazir', fontSize: 14, color: Color(0xFF6C757D)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDrawer() {
    return Drawer(
      child: Container(
        color: Colors.white,
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            DrawerHeader(
              decoration: const BoxDecoration(
                gradient: LinearGradient(colors: [Color(0xFF4A90D9), Color(0xFF357ABD)]),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Container(
                    width: 56, height: 56,
                    decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.2), borderRadius: BorderRadius.circular(14)),
                    child: const Icon(Icons.work_rounded, color: Colors.white, size: 32),
                  ),
                  const SizedBox(height: 12),
                  const Text('جابینجا', style: TextStyle(fontFamily: 'Vazir', fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white)),
                  const Text('سامانه کاریابی آنلاین', style: TextStyle(fontFamily: 'Vazir', fontSize: 12, color: Colors.white70)),
                ],
              ),
            ),
            _buildDrawerItem(Icons.search, 'جستجوی مشاغل', () => Navigator.pop(context)),
            _buildDrawerItem(Icons.description_outlined, 'رزومه‌ساز آنلاین', () {
              Navigator.pop(context);
              Navigator.pushNamed(context, '/resume-builder');
            }),
            _buildDrawerItem(Icons.notifications_outlined, 'ایمیل اطلاع‌رسانی', () {
              Navigator.pop(context);
              Navigator.pushNamed(context, '/job-alert');
            }),
            _buildDrawerItem(Icons.bookmark_outline, 'نشان‌شده‌ها', () {
              Navigator.pop(context);
              Navigator.pushNamed(context, '/favorites');
            }),
            _buildDrawerItem(Icons.send_outlined, 'درخواست‌های من', () {
              Navigator.pop(context);
              Navigator.pushNamed(context, '/applied-jobs');
            }),
            _buildDrawerItem(Icons.business, '۵۰ شرکت برتر', () {
              Navigator.pop(context);
              Navigator.pushNamed(context, '/top-companies');
            }),
            _buildDrawerItem(Icons.help_outline, 'راهنمای استفاده', () {
              Navigator.pop(context);
              Navigator.pushNamed(context, '/how-to');
            }),
            _buildDrawerItem(Icons.headset_mic, 'تماس با جابینجا', () {
              Navigator.pop(context);
              Navigator.pushNamed(context, '/contact');
            }),
            _buildDrawerItem(Icons.person_outline, 'پروفایل', () {
              Navigator.pop(context);
              Navigator.pushNamed(context, '/profile');
            }),
          ],
        ),
      ),
    );
  }

  Widget _buildDrawerItem(IconData icon, String title, VoidCallback onTap) {
    return ListTile(
      trailing: Icon(icon, color: const Color(0xFF6C757D), size: 22),
      title: Text(title, style: const TextStyle(fontFamily: 'Vazir', fontSize: 14, color: Color(0xFF212529)), textAlign: TextAlign.right),
      onTap: onTap,
      dense: true,
    );
  }

  void _applyFilters() {
    final filter = JobFilter(
      keyword: _searchController.text.trim().isEmpty ? null : _searchController.text.trim(),
      category: (_selectedCategory != null && _selectedCategory!.isNotEmpty) ? _selectedCategory : null,
      location: (_selectedLocation != null && _selectedLocation!.isNotEmpty) ? _selectedLocation : null,
      contractType: (_selectedContractType != null && _selectedContractType!.isNotEmpty) ? _selectedContractType : null,
    );
    _presenter.loadJobsWithFilter(filter);
  }

  @override
  void onJobsLoaded(List<Job> jobs) {
    if (mounted) setState(() { _jobs = jobs; _errorMessage = null; });
  }

  @override
  void onJobsError(String message) {
    if (mounted) setState(() { _errorMessage = message; _jobs = []; });
  }

  @override
  void onJobDetailLoaded(Job job) {}

  @override
  void onJobDetailError(String message) {}

  @override
  void onAppliedJobsLoaded(List<Job> jobs) {}

  @override
  void onFavoriteJobsLoaded(List<Job> jobs) {}

  @override
  void onRecommendedJobsLoaded(List<Job> jobs) {
    if (mounted) setState(() => _recommendedJobs = jobs);
  }

  @override
  void onTopCompaniesLoaded(List<Company> companies) {
    if (mounted) setState(() => _topCompanies = companies);
  }

  @override
  void onFavoriteToggled(String jobId, bool isFavorited, String message) {
    if (mounted) {
      setState(() {});
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message, style: const TextStyle(fontFamily: 'Vazir')),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          duration: const Duration(seconds: 2),
        ),
      );
    }
  }

  @override
  void onApplied(String message) {}

  @override
  void setLoading(bool loading) {
    if (mounted) setState(() => _isLoading = loading);
  }
}
