import 'package:flutter/material.dart';
import '../presenters/job_presenter.dart';
import '../models/company.dart';
import '../models/job.dart';
import '../models/job_filter.dart';
import '../widgets/job_card.dart';
import '../widgets/loading_widget.dart';
import '../widgets/jobinja_logo.dart';
import '../utils/constants.dart';

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

  int _currentNavIndex = 0;

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
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const JobinjaIcon(size: 28),
        centerTitle: true,
        backgroundColor: AppColors.surface,
        elevation: 0,
        foregroundColor: AppColors.textPrimary,
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_outlined, color: AppColors.textSecondary),
            onPressed: () {},
          ),
          IconButton(
            icon: const Icon(Icons.person_outline, color: AppColors.textSecondary),
            onPressed: () => Navigator.pushNamed(context, '/profile'),
          ),
        ],
      ),
      body: Column(
        children: [
          _buildSearchSection(),
          Expanded(child: _buildBody()),
        ],
      ),
      bottomNavigationBar: _buildBottomNav(),
    );
  }

  Widget _buildBottomNav() {
    return NavigationBar(
      selectedIndex: _currentNavIndex,
      onDestinationSelected: (index) {
        setState(() => _currentNavIndex = index);
        switch (index) {
          case 1:
            Navigator.pushNamed(context, '/favorites');
            break;
          case 2:
            Navigator.pushNamed(context, '/top-companies');
            break;
          case 3:
            Navigator.pushNamed(context, '/profile');
            break;
        }
      },
      destinations: const [
        NavigationDestination(icon: Icon(Icons.home_outlined), selectedIcon: Icon(Icons.home, color: AppColors.primary), label: 'خانه'),
        NavigationDestination(icon: Icon(Icons.bookmark_outline), selectedIcon: Icon(Icons.bookmark, color: AppColors.primary), label: 'نشان‌شده'),
        NavigationDestination(icon: Icon(Icons.business_outlined), selectedIcon: Icon(Icons.business, color: AppColors.primary), label: 'شرکت‌ها'),
        NavigationDestination(icon: Icon(Icons.person_outline), selectedIcon: Icon(Icons.person, color: AppColors.primary), label: 'پروفایل'),
      ],
    );
  }

  Widget _buildSearchSection() {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
      color: AppColors.surface,
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: Container(
                  height: 46,
                  decoration: BoxDecoration(
                    color: AppColors.background,
                    borderRadius: BorderRadius.circular(AppRadius.md),
                  ),
                  child: TextField(
                    controller: _searchController,
                    textDirection: TextDirection.rtl,
                    decoration: InputDecoration(
                      hintText: 'جستجوی عنوان شغلی، مهارت یا شرکت...',
                      hintStyle: const TextStyle(fontFamily: AppTypography.fontFamily, fontSize: 13, color: AppColors.textMuted),
                      prefixIcon: const Icon(Icons.search, color: AppColors.textMuted, size: 22),
                      suffixIcon: _searchController.text.isNotEmpty
                          ? IconButton(
                              icon: const Icon(Icons.clear, color: AppColors.textMuted, size: 18),
                              onPressed: () {
                                _searchController.clear();
                                FocusScope.of(context).unfocus();
                                _applyFilters();
                              },
                            )
                          : null,
                      border: InputBorder.none,
                      contentPadding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                    style: const TextStyle(fontFamily: AppTypography.fontFamily, fontSize: 14),
                    onSubmitted: (value) => _applyFilters(),
                    onChanged: (value) {
                      setState(() {});
                      if (value.isEmpty) _applyFilters();
                    },
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Container(
                width: 46,
                height: 46,
                decoration: BoxDecoration(
                  color: _showFilters ? AppColors.primary : AppColors.background,
                  borderRadius: BorderRadius.circular(AppRadius.md),
                ),
                child: IconButton(
                  icon: Icon(
                    Icons.tune,
                    color: _showFilters ? AppColors.surface : AppColors.textSecondary,
                    size: 22,
                  ),
                  onPressed: () => setState(() => _showFilters = !_showFilters),
                ),
              ),
            ],
          ),
          if (_showFilters) ...[
            const SizedBox(height: 10),
            _buildFilterBar(),
          ],
        ],
      ),
    );
  }

  Widget _buildFilterBar() {
    return Column(
      children: [
        Row(
          children: [
            Expanded(child: _buildDropdown('دسته‌بندی', _selectedCategory ?? 'همه', categories, (v) {
              setState(() => _selectedCategory = v == 'همه' ? '' : v);
              _applyFilters();
            })),
            const SizedBox(width: 8),
            Expanded(child: _buildDropdown('موقعیت', _selectedLocation ?? 'همه استان‌ها', locations, (v) {
              setState(() => _selectedLocation = v == 'همه استان‌ها' ? '' : v);
              _applyFilters();
            })),
          ],
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(child: _buildDropdown('نوع همکاری', _selectedContractType ?? 'همه', contractTypes, (v) {
              setState(() => _selectedContractType = v == 'همه' ? '' : v);
              _applyFilters();
            })),
            const SizedBox(width: 8),
            Expanded(
              child: GestureDetector(
                onTap: () {
                  setState(() {
                    _selectedCategory = null;
                    _selectedLocation = null;
                    _selectedContractType = null;
                  });
                  _applyFilters();
                },
                child: Container(
                  height: 42,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(AppRadius.sm),
                    border: Border.all(color: AppColors.error.withValues(alpha: 0.3)),
                  ),
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.close, size: 16, color: AppColors.error),
                      SizedBox(width: 4),
                      Text(
                        'پاک کردن فیلتر',
                        style: TextStyle(
                          fontFamily: AppTypography.fontFamily,
                          fontSize: 12,
                          color: AppColors.error,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildDropdown(String label, String value, List<Map<String, String>> items, ValueChanged<String> onChanged) {
    return Container(
      height: 42,
      padding: const EdgeInsets.symmetric(horizontal: 8),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(AppRadius.sm),
        border: Border.all(color: AppColors.border),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: items.any((e) => e['name'] == value) ? value : items.first['name'],
          isExpanded: true,
          icon: const Icon(Icons.arrow_drop_down, size: 20, color: AppColors.textSecondary),
          style: const TextStyle(fontFamily: AppTypography.fontFamily, fontSize: 12, color: AppColors.textPrimary),
          items: items.map((e) => DropdownMenuItem(
            value: e['name'],
            child: Text(e['name']!, textDirection: TextDirection.rtl, style: const TextStyle(fontSize: 12)),
          )).toList(),
          onChanged: (v) { if (v != null) onChanged(v); },
        ),
      ),
    );
  }

  Widget _buildBody() {
    if (_isLoading && _jobs.isEmpty) {
      return const LoadingWidget(message: 'در حال جستجو...');
    }

    if (_errorMessage != null && _jobs.isEmpty) {
      return _buildErrorState();
    }

    return RefreshIndicator(
      onRefresh: () async => _presenter.loadJobs(),
      color: AppColors.primary,
      child: ListView(
        padding: const EdgeInsets.only(bottom: 16),
        children: [
          _buildStatsBanner(),
          if (_recommendedJobs.isNotEmpty) _buildRecommendedSection(),
          if (_topCompanies.isNotEmpty) _buildTopCompaniesCarousel(),
          _buildPopularSearches(),
          _buildHowToStart(),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 4),
            child: Row(
              textDirection: TextDirection.rtl,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('آخرین آگهی‌ها', style: AppTypography.h4),
                GestureDetector(
                  onTap: () {},
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'مشاهده همه',
                        style: TextStyle(
                          fontFamily: AppTypography.fontFamily,
                          fontSize: 12,
                          color: AppColors.primary,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      SizedBox(width: 2),
                      Icon(Icons.chevron_left, size: 16, color: AppColors.primary),
                    ],
                  ),
                ),
              ],
            ),
          ),
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
        gradient: const LinearGradient(
          colors: [AppColors.primary, AppColors.primaryDark],
          begin: Alignment.topRight,
          end: Alignment.bottomLeft,
        ),
        borderRadius: BorderRadius.circular(AppRadius.lg),
      ),
      child: Row(
        textDirection: TextDirection.rtl,
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _buildStatColumn('۲۰', 'آگهی فعال', Icons.work_outline),
          Container(width: 1, height: 40, color: Colors.white.withValues(alpha: 0.2)),
          _buildStatColumn('۱۲', 'شرکت برتر', Icons.business),
          Container(width: 1, height: 40, color: Colors.white.withValues(alpha: 0.2)),
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
        Text(value, style: const TextStyle(fontFamily: AppTypography.fontFamily, fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white)),
        Text(label, style: const TextStyle(fontFamily: AppTypography.fontFamily, fontSize: 11, color: Colors.white70)),
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
              Text('شغل‌های پیشنهادی', style: AppTypography.h4),
              GestureDetector(
                onTap: () {},
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'مشاهده همه',
                      style: TextStyle(
                        fontFamily: AppTypography.fontFamily,
                        fontSize: 12,
                        color: AppColors.primary,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    SizedBox(width: 2),
                    Icon(Icons.chevron_left, size: 16, color: AppColors.primary),
                  ],
                ),
              ),
            ],
          ),
        ),
        SizedBox(
          height: 190,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 12),
            itemCount: _recommendedJobs.length,
            itemBuilder: (context, index) {
              final job = _recommendedJobs[index];
              return Container(
                width: 260,
                margin: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
                child: Card(
                  margin: EdgeInsets.zero,
                  child: InkWell(
                    onTap: () async {
                      await Navigator.pushNamed(context, '/job-detail', arguments: job.id);
                      if (mounted) setState(() {});
                    },
                    borderRadius: BorderRadius.circular(AppRadius.md),
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Row(
                            textDirection: TextDirection.rtl,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Container(
                                width: 44, height: 44,
                                decoration: BoxDecoration(
                                  color: AppColors.primaryLight,
                                  borderRadius: BorderRadius.circular(AppRadius.sm),
                                ),
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(AppRadius.sm - 1),
                                  child: Image.network(
                                    job.company.logoUrl ?? '',
                                    fit: BoxFit.contain,
                                    errorBuilder: (_, __, ___) => const Icon(Icons.business, color: AppColors.primary, size: 24),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  children: [
                                    Text(
                                      job.title,
                                      style: AppTypography.body.copyWith(fontWeight: FontWeight.bold),
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                      textAlign: TextAlign.right,
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      job.company.name,
                                      style: AppTypography.bodySmall,
                                      textAlign: TextAlign.right,
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          const Spacer(),
                          Row(
                            textDirection: TextDirection.rtl,
                            children: [
                              const Icon(Icons.location_on_outlined, size: 14, color: AppColors.textMuted),
                              const SizedBox(width: 4),
                              Expanded(
                                child: Text(
                                  job.location,
                                  style: AppTypography.caption,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 6),
                          Row(
                            textDirection: TextDirection.rtl,
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const Icon(Icons.monetization_on_outlined, size: 14, color: AppColors.success),
                                  const SizedBox(width: 4),
                                  Text(
                                    job.salaryDisplay ?? 'حقوق توافقی',
                                    style: const TextStyle(
                                      fontFamily: AppTypography.fontFamily,
                                      fontSize: 11,
                                      color: AppColors.success,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                              if (job.isRemote)
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                  decoration: BoxDecoration(
                                    color: AppColors.primaryLight,
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                  child: const Text(
                                    'دورکاری',
                                    style: TextStyle(
                                      fontFamily: AppTypography.fontFamily,
                                      fontSize: 10,
                                      color: AppColors.primary,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ),
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
              Text('شرکت‌های برتر', style: AppTypography.h4),
              GestureDetector(
                onTap: () => Navigator.pushNamed(context, '/top-companies'),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'مشاهده همه',
                      style: TextStyle(
                        fontFamily: AppTypography.fontFamily,
                        fontSize: 12,
                        color: AppColors.primary,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    SizedBox(width: 2),
                    Icon(Icons.chevron_left, size: 16, color: AppColors.primary),
                  ],
                ),
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
                    margin: EdgeInsets.zero,
                    child: Container(
                      padding: const EdgeInsets.all(12),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            width: 48, height: 48,
                            decoration: BoxDecoration(
                              color: AppColors.primaryLight,
                              borderRadius: BorderRadius.circular(AppRadius.sm),
                            ),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(AppRadius.sm - 1),
                              child: Image.network(
                                company.logoUrl ?? '',
                                fit: BoxFit.contain,
                                errorBuilder: (_, __, ___) => const Icon(Icons.business, color: AppColors.primary, size: 26),
                              ),
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            company.name,
                            style: AppTypography.caption.copyWith(fontWeight: FontWeight.w500, color: AppColors.textPrimary),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            textAlign: TextAlign.center,
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

  Widget _buildPopularSearches() {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 8, 16, 4),
      padding: const EdgeInsets.all(16),
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
              Icon(Icons.trending_up, size: 18, color: AppColors.primary),
              SizedBox(width: 6),
              Text('جستجوهای پرطرفدار', style: AppTypography.h4),
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
                  color: AppColors.background,
                  borderRadius: BorderRadius.circular(AppRadius.full),
                  border: Border.all(color: AppColors.border),
                ),
                child: Text(tag, style: AppTypography.bodySmall.copyWith(color: AppColors.textPrimary)),
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
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppRadius.md),
        border: Border.all(color: AppColors.border, width: 0.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          const Text('از کجا شروع کنم؟', style: AppTypography.h4),
          const SizedBox(height: 16),
          _buildStepItem(
            Icons.person_add_outlined,
            'ثبت نام در جابینجا',
            'با گوگل، لینکدین یا ایمیل ثبت نام کنید',
            AppColors.primary,
          ),
          const Divider(height: 24, color: AppColors.divider),
          _buildStepItem(
            Icons.description_outlined,
            'ساخت یا آپلود رزومه',
            'با رزومه‌ساز استاندارد رزومه خود را بسازید',
            AppColors.accent,
          ),
          const Divider(height: 24, color: AppColors.divider),
          _buildStepItem(
            Icons.search_outlined,
            'جستجوی مشاغل',
            'عنوان شغلی یا شرکت مورد نظر را جستجو کنید',
            AppColors.amber,
          ),
          const Divider(height: 24, color: AppColors.divider),
          _buildStepItem(
            Icons.send_outlined,
            'ارسال درخواست شغلی',
            'برای شغل‌های مورد علاقه رزومه بفرستید',
            AppColors.purple,
          ),
        ],
      ),
    );
  }

  Widget _buildStepItem(IconData icon, String title, String subtitle, Color iconColor) {
    return Row(
      textDirection: TextDirection.rtl,
      children: [
        Container(
          width: 44, height: 44,
          decoration: BoxDecoration(
            color: iconColor.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(AppRadius.md),
          ),
          child: Icon(icon, color: iconColor, size: 24),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
            Text(title, style: AppTypography.body.copyWith(fontWeight: FontWeight.w600)),
            const SizedBox(height: 2),
            Text(subtitle, style: AppTypography.bodySmall),
          ]),
        ),
      ],
    );
  }

  Widget _buildErrorState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 80, height: 80,
              decoration: BoxDecoration(
                color: AppColors.error.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(AppRadius.xl),
              ),
              child: const Icon(Icons.cloud_off, size: 40, color: AppColors.error),
            ),
            const SizedBox(height: 16),
            Text(
              _errorMessage!,
              style: AppTypography.body.copyWith(color: AppColors.textSecondary),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            OutlinedButton.icon(
              onPressed: () => _presenter.loadJobs(),
              icon: const Icon(Icons.refresh, size: 18),
              label: const Text('تلاش مجدد', style: TextStyle(fontFamily: AppTypography.fontFamily)),
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
            Container(
              width: 80, height: 80,
              decoration: BoxDecoration(
                color: AppColors.primaryLight,
                borderRadius: BorderRadius.circular(AppRadius.xl),
              ),
              child: const Icon(Icons.search_off, size: 40, color: AppColors.textMuted),
            ),
            const SizedBox(height: 16),
            Text(
              'نتیجه‌ای یافت نشد',
              style: AppTypography.body.copyWith(color: AppColors.textSecondary),
            ),
          ],
        ),
      ),
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
          content: Row(children: [
            Icon(isFavorited ? Icons.bookmark : Icons.bookmark_border, color: Colors.white, size: 18),
            const SizedBox(width: 8),
            Expanded(child: Text(message, style: const TextStyle(fontFamily: AppTypography.fontFamily))),
          ]),
          backgroundColor: isFavorited ? AppColors.primary : AppColors.textMuted,
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
