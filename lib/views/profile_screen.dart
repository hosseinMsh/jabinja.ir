import 'package:flutter/material.dart';
import '../presenters/job_presenter.dart';
import '../presenters/profile_presenter.dart';
import '../presenters/auth_presenter.dart';
import '../models/company.dart';
import '../models/job.dart';
import '../models/user.dart';
import '../widgets/loading_widget.dart';
import '../widgets/job_card.dart';
import '../utils/constants.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> implements ProfileView, JobView, AuthView {
  late final ProfilePresenter _profilePresenter;
  late final JobPresenter _jobPresenter;
  late final AuthPresenter _authPresenter;
  User? _user;
  List<Job> _appliedJobs = [];
  List<Job> _favoriteJobs = [];
  bool _isLoading = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _profilePresenter = ProfilePresenter(this);
    _jobPresenter = JobPresenter(this);
    _authPresenter = AuthPresenter(this);
    _profilePresenter.loadProfile();
    _jobPresenter.loadAppliedJobs();
    _jobPresenter.loadFavoriteJobs();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('پروفایل'),
        centerTitle: true,
        backgroundColor: AppColors.surface,
        elevation: 0,
        foregroundColor: AppColors.textPrimary,
        actions: [
          IconButton(
            icon: const Icon(Icons.settings_outlined, color: AppColors.textSecondary),
            onPressed: () {},
          ),
        ],
      ),
      body: _isLoading
          ? const LoadingWidget(message: 'در حال بارگذاری...')
          : _errorMessage != null
              ? _buildErrorState()
              : RefreshIndicator(
                  color: AppColors.primary,
                  onRefresh: () async {
                    _profilePresenter.loadProfile();
                    _jobPresenter.loadAppliedJobs();
                    _jobPresenter.loadFavoriteJobs();
                  },
                  child: SingleChildScrollView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    child: Column(children: [
                      _buildProfileHeader(),
                      const SizedBox(height: 8),
                      _buildStatsSection(),
                      const SizedBox(height: 8),
                      _buildResumeSection(),
                      const SizedBox(height: 8),
                      _buildMenuSection(),
                      if (_appliedJobs.isNotEmpty) ...[
                        const SizedBox(height: 8),
                        _buildSection('درخواست‌های اخیر', _appliedJobs, '/applied-jobs'),
                      ],
                      if (_favoriteJobs.isNotEmpty) ...[
                        const SizedBox(height: 8),
                        _buildSection('نشان‌شده‌ها', _favoriteJobs, '/favorites'),
                      ],
                      const SizedBox(height: 32),
                    ]),
                  ),
                ),
    );
  }

  Widget _buildErrorState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
          Container(
            width: 80, height: 80,
            decoration: BoxDecoration(
              color: AppColors.error.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(20),
            ),
            child: const Icon(Icons.error_outline, size: 40, color: AppColors.error),
          ),
          const SizedBox(height: 16),
          Text(_errorMessage!, style: AppTypography.body.copyWith(color: AppColors.textSecondary), textAlign: TextAlign.center),
          const SizedBox(height: 24),
          OutlinedButton.icon(
            onPressed: () { _profilePresenter.loadProfile(); _jobPresenter.loadAppliedJobs(); _jobPresenter.loadFavoriteJobs(); },
            icon: const Icon(Icons.refresh, size: 18),
            label: const Text('تلاش مجدد', style: TextStyle(fontFamily: AppTypography.fontFamily)),
          ),
        ]),
      ),
    );
  }

  Widget _buildProfileHeader() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: const BoxDecoration(
        color: AppColors.surface,
        border: Border(
          bottom: BorderSide(color: AppColors.divider),
        ),
      ),
      child: Column(children: [
        Stack(
          children: [
            CircleAvatar(
              radius: 48,
              backgroundColor: AppColors.primaryLight,
              backgroundImage: _user?.avatarUrl != null && _user!.avatarUrl!.isNotEmpty
                  ? NetworkImage(_user!.avatarUrl!) : null,
              child: _user?.avatarUrl == null || _user!.avatarUrl!.isEmpty
                  ? Text(
                      (_user?.name ?? 'کاربر').substring(0, 1),
                      style: const TextStyle(fontSize: 36, fontWeight: FontWeight.bold, color: AppColors.primary),
                    )
                  : null,
            ),
            Positioned(
              bottom: 0,
              right: 0,
              child: Container(
                width: 28, height: 28,
                decoration: const BoxDecoration(
                  color: AppColors.primary,
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.edit, size: 14, color: Colors.white),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Text(
          _user?.name ?? 'کاربر',
          style: AppTypography.h2,
        ),
        const SizedBox(height: 4),
        Text(
          _user?.email ?? '',
          style: AppTypography.bodySmall,
        ),
        if (_user?.phone != null && _user!.phone!.isNotEmpty) ...[
          const SizedBox(height: 2),
          Text(
            _user!.phone!,
            style: AppTypography.caption,
          ),
        ],
      ]),
    );
  }

  Widget _buildStatsSection() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      color: AppColors.surface,
      child: Row(
        textDirection: TextDirection.rtl,
        children: [
          Expanded(child: _buildStatItem(Icons.send_outlined, 'درخواست‌ها', '${_user?.appliedJobsCount ?? 0}', AppColors.primary)),
          Container(width: 1, height: 40, color: AppColors.divider),
          Expanded(child: _buildStatItem(Icons.bookmark_outlined, 'نشان‌شده‌ها', '${_user?.savedJobsCount ?? 0}', AppColors.accent)),
          Container(width: 1, height: 40, color: AppColors.divider),
          Expanded(child: _buildStatItem(Icons.visibility_outlined, 'بازدید', '--', AppColors.amber)),
        ],
      ),
    );
  }

  Widget _buildStatItem(IconData icon, String label, String value, Color color) {
    return Column(children: [
      Container(
        width: 36, height: 36,
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(AppRadius.sm),
        ),
        child: Icon(icon, size: 18, color: color),
      ),
      const SizedBox(height: 6),
      Text(value, style: AppTypography.h3.copyWith(fontSize: 18)),
      Text(label, style: AppTypography.caption),
    ]);
  }

  Widget _buildResumeSection() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      color: AppColors.surface,
      child: Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
        Row(
          textDirection: TextDirection.rtl,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text('رزومه', style: AppTypography.h4),
            Container(
              width: 32, height: 32,
              decoration: BoxDecoration(
                color: AppColors.primaryLight,
                borderRadius: BorderRadius.circular(AppRadius.sm),
              ),
              child: const Icon(Icons.description_outlined, size: 18, color: AppColors.primary),
            ),
          ],
        ),
        const SizedBox(height: 16),
        if (_user?.resumeScore != null) ...[
          Row(
            textDirection: TextDirection.rtl,
            children: [
              Text(
                'امتیاز رزومه: ${_user!.resumeScore}%',
                style: AppTypography.bodySmall.copyWith(fontWeight: FontWeight.w600),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(6),
                  child: LinearProgressIndicator(
                    value: (_user!.resumeScore ?? 0) / 100,
                    backgroundColor: AppColors.border,
                    valueColor: const AlwaysStoppedAnimation<Color>(AppColors.primary),
                    minHeight: 8,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
        ],
        Row(
          textDirection: TextDirection.rtl,
          children: [
            const Icon(Icons.link, size: 14, color: AppColors.textMuted),
            const SizedBox(width: 6),
            Text(
              _user?.resumeSlug != null ? 'jobinja.ir/resume/${_user!.resumeSlug}' : 'https://jobinja.ir/resume',
              style: AppTypography.bodySmall.copyWith(color: AppColors.primary),
            ),
          ],
        ),
      ]),
    );
  }

  Widget _buildMenuSection() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 8),
      color: AppColors.surface,
      child: Column(
        children: [
          _buildMenuItem(Icons.search, 'جستجوی مشاغل', () => Navigator.pop(context)),
          _buildMenuItem(Icons.description_outlined, 'رزومه‌ساز آنلاین', () => Navigator.pushNamed(context, '/resume-builder')),
          _buildMenuItem(Icons.notifications_outlined, 'ایمیل اطلاع‌رسانی', () => Navigator.pushNamed(context, '/job-alert')),
          _buildMenuItem(Icons.headset_mic, 'تماس با جابینجا', () => Navigator.pushNamed(context, '/contact')),
          _buildMenuItem(Icons.info_outline, 'درباره جابینجا', () => Navigator.pushNamed(context, '/about')),
          _buildMenuItem(Icons.help_outline, 'راهنمای استفاده', () => Navigator.pushNamed(context, '/how-to')),
          const Divider(height: 1, color: AppColors.divider),
          _buildMenuItem(Icons.logout, 'خروج از حساب', _handleLogout, isDestructive: true),
        ],
      ),
    );
  }

  Widget _buildMenuItem(IconData icon, String title, VoidCallback onTap, {bool isDestructive = false}) {
    return ListTile(
      trailing: Icon(
        icon,
        color: isDestructive ? AppColors.error : AppColors.textSecondary,
        size: 22,
      ),
      title: Text(
        title,
        style: TextStyle(
          fontFamily: AppTypography.fontFamily,
          fontSize: 14,
          color: isDestructive ? AppColors.error : AppColors.textPrimary,
        ),
        textAlign: TextAlign.right,
      ),
      onTap: onTap,
      dense: true,
      minVerticalPadding: 8,
    );
  }

  Widget _buildSection(String title, List<Job> jobs, String route) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      color: AppColors.surface,
      child: Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
        Row(
          textDirection: TextDirection.rtl,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(title, style: AppTypography.h4),
            TextButton(
              onPressed: () => Navigator.pushNamed(context, route),
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'مشاهده همه',
                    style: TextStyle(
                      fontFamily: AppTypography.fontFamily,
                      fontSize: 12,
                      color: AppColors.primary,
                    ),
                  ),
                  SizedBox(width: 2),
                  Icon(Icons.chevron_left, size: 16, color: AppColors.primary),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        ...jobs.take(3).map((job) => Padding(
          padding: const EdgeInsets.only(bottom: 4),
          child: JobCard(
            job: job,
            isFavorited: _jobPresenter.isFavorited(job.id),
            onTap: () async {
              await Navigator.pushNamed(context, '/job-detail', arguments: job.id);
              setState(() {});
            },
            onFavoriteTap: () => _jobPresenter.toggleFavorite(job.id),
          ),
        )),
      ]),
    );
  }

  void _handleLogout() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadius.md)),
        title: const Text('خروج از حساب', style: TextStyle(fontFamily: AppTypography.fontFamily)),
        content: const Text('آیا از خروج خود مطمئن هستید؟', style: TextStyle(fontFamily: AppTypography.fontFamily)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('انصراف', style: TextStyle(fontFamily: AppTypography.fontFamily)),
          ),
          TextButton(
            onPressed: () { Navigator.pop(ctx); _authPresenter.logout(); },
            child: const Text('خروج', style: TextStyle(fontFamily: AppTypography.fontFamily, color: AppColors.error)),
          ),
        ],
      ),
    );
  }

  @override
  void onProfileLoaded(User user) { if (mounted) setState(() => _user = user); }
  @override
  void onProfileError(String message) { if (mounted) setState(() => _errorMessage = message); }
  @override
  void onAppliedJobsLoaded(List<Job> jobs) { if (mounted) setState(() => _appliedJobs = jobs); }
  @override
  void onFavoriteJobsLoaded(List<Job> jobs) { if (mounted) setState(() => _favoriteJobs = jobs); }
  @override
  void setLoading(bool loading) { if (mounted) setState(() => _isLoading = loading); }
  @override
  void onLoginSuccess(User user) {}
  @override
  void onLoginError(String message) {}
  @override
  void onSignupSuccess(User user) {}
  @override
  void onSignupError(String message) {}
  @override
  void onLogoutSuccess() { if (mounted) Navigator.pushReplacementNamed(context, '/login'); }
  @override
  void onLogoutError(String message) {
    if (mounted) ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message, style: const TextStyle(fontFamily: AppTypography.fontFamily)), backgroundColor: AppColors.error),
    );
  }
  @override
  void onJobsLoaded(List<Job> jobs) {}
  @override
  void onJobsError(String message) {}
  @override
  void onJobDetailLoaded(Job job) {}
  @override
  void onJobDetailError(String message) {}
  @override
  void onRecommendedJobsLoaded(List<Job> jobs) {}
  @override
  void onTopCompaniesLoaded(List<Company> companies) {}
  @override
  void onFavoriteToggled(String jobId, bool isFav, String msg) {
    if (mounted) {
      setState(() {});
      ScaffoldMessenger.of(context).clearSnackBars();
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Row(children: [
          Icon(isFav ? Icons.bookmark : Icons.bookmark_border, color: Colors.white, size: 18),
          const SizedBox(width: 8),
          Expanded(child: Text(msg, style: const TextStyle(fontFamily: AppTypography.fontFamily))),
        ]),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadius.sm)),
        backgroundColor: isFav ? AppColors.primary : AppColors.textMuted,
        duration: const Duration(seconds: 2),
      ));
    }
  }
  @override
  void onApplied(String message) {}
}
