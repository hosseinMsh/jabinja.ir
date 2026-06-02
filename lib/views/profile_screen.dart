import 'package:flutter/material.dart';
import '../presenters/job_presenter.dart';
import '../presenters/profile_presenter.dart';
import '../presenters/auth_presenter.dart';
import '../models/company.dart';
import '../models/job.dart';
import '../models/user.dart';
import '../widgets/loading_widget.dart';
import '../widgets/job_card.dart';

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
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        title: const Text('پروفایل', style: TextStyle(fontFamily: 'Vazir', fontSize: 20, fontWeight: FontWeight.bold)),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0,
        foregroundColor: const Color(0xFF212529),
      ),
      body: _isLoading
          ? const LoadingWidget(message: 'در حال بارگذاری...')
          : _errorMessage != null
              ? _buildErrorState()
              : SingleChildScrollView(
                  child: Column(children: [
                    _buildProfileHeader(),
                    const SizedBox(height: 8),
                    _buildResumeSection(),
                    const SizedBox(height: 8),
                    _buildStatsRow(),
                    const SizedBox(height: 8),
                    if (_appliedJobs.isNotEmpty) _buildSection('شغل‌های اقدام شده', _appliedJobs),
                    if (_favoriteJobs.isNotEmpty) _buildSection('نشان‌شده‌ها', _favoriteJobs),
                    const SizedBox(height: 24),
                  ]),
                ),
    );
  }

  Widget _buildErrorState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
          const Icon(Icons.error_outline, size: 64, color: Color(0xFFADB5BD)),
          const SizedBox(height: 16),
          Text(_errorMessage!, style: const TextStyle(fontFamily: 'Vazir', fontSize: 14, color: Color(0xFF6C757D)), textAlign: TextAlign.center),
          const SizedBox(height: 24),
          OutlinedButton.icon(
            onPressed: () { _profilePresenter.loadProfile(); _jobPresenter.loadAppliedJobs(); _jobPresenter.loadFavoriteJobs(); },
            icon: const Icon(Icons.refresh),
            label: const Text('تلاش مجدد', style: TextStyle(fontFamily: 'Vazir')),
          ),
        ]),
      ),
    );
  }

  Widget _buildProfileHeader() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      color: Colors.white,
      child: Column(children: [
        CircleAvatar(
          radius: 44,
          backgroundColor: const Color(0xFFE8F0FE),
          backgroundImage: _user?.avatarUrl != null && _user!.avatarUrl!.isNotEmpty
              ? NetworkImage(_user!.avatarUrl!) : null,
          child: _user?.avatarUrl == null || _user!.avatarUrl!.isEmpty
              ? const Icon(Icons.person, size: 44, color: Color(0xFF4A90D9)) : null,
        ),
        const SizedBox(height: 12),
        Text(_user?.name ?? 'کاربر', style: const TextStyle(fontFamily: 'Vazir', fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFF212529))),
        const SizedBox(height: 4),
        Text(_user?.email ?? '', style: const TextStyle(fontFamily: 'Vazir', fontSize: 14, color: Color(0xFF6C757D))),
        if (_user?.phone != null && _user!.phone!.isNotEmpty) ...[
          const SizedBox(height: 4),
          Text(_user!.phone!, style: const TextStyle(fontFamily: 'Vazir', fontSize: 13, color: Color(0xFFADB5BD))),
        ],
        const SizedBox(height: 20),
        SizedBox(
          width: double.infinity,
          child: OutlinedButton.icon(
            onPressed: _handleLogout,
            style: OutlinedButton.styleFrom(
              foregroundColor: const Color(0xFFE74C3C),
              side: const BorderSide(color: Color(0xFFE74C3C)),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              padding: const EdgeInsets.symmetric(vertical: 12),
            ),
            icon: const Icon(Icons.logout),
            label: const Text('خروج از حساب', style: TextStyle(fontFamily: 'Vazir', fontSize: 14)),
          ),
        ),
      ]),
    );
  }

  Widget _buildResumeSection() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      color: Colors.white,
      child: Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
        Row(textDirection: TextDirection.rtl, mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          const Text('رزومه', style: TextStyle(fontFamily: 'Vazir', fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF212529))),
          Icon(Icons.description_outlined, color: const Color(0xFF4A90D9)),
        ]),
        const SizedBox(height: 16),
        if (_user?.resumeScore != null) ...[
          Row(textDirection: TextDirection.rtl, children: [
            Text('امتیاز رزومه: ${_user!.resumeScore}%', style: const TextStyle(fontFamily: 'Vazir', fontSize: 14, color: Color(0xFF495057))),
            const SizedBox(width: 12),
            Expanded(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(6),
                child: LinearProgressIndicator(
                  value: (_user!.resumeScore ?? 0) / 100,
                  backgroundColor: const Color(0xFFE9ECEF),
                  valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFF4A90D9)),
                  minHeight: 8,
                ),
              ),
            ),
          ]),
          const SizedBox(height: 12),
        ],
        if (_user?.resumeSlug != null)
          Row(textDirection: TextDirection.rtl, children: [
            const Icon(Icons.link, size: 14, color: Color(0xFF6C757D)),
            const SizedBox(width: 6),
            Text('jobinja.ir/resume/${_user!.resumeSlug}', style: const TextStyle(fontFamily: 'Vazir', fontSize: 12, color: Color(0xFF4A90D9))),
          ]),
      ]),
    );
  }

  Widget _buildStatsRow() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      color: Colors.white,
      child: Row(
        textDirection: TextDirection.rtl,
        children: [
          Expanded(child: _buildStatItem(Icons.send_outlined, 'درخواست‌ها', '${_user?.appliedJobsCount ?? 0}')),
          Container(width: 1, height: 40, color: const Color(0xFFDEE2E6)),
          Expanded(child: _buildStatItem(Icons.bookmark_outlined, 'نشان‌شده‌ها', '${_user?.savedJobsCount ?? 0}')),
          Container(width: 1, height: 40, color: const Color(0xFFDEE2E6)),
          Expanded(child: _buildStatItem(Icons.visibility_outlined, 'بازدید پروفایل', '--')),
        ],
      ),
    );
  }

  Widget _buildStatItem(IconData icon, String label, String value) {
    return Column(children: [
      Icon(icon, size: 22, color: const Color(0xFF4A90D9)),
      const SizedBox(height: 6),
      Text(value, style: const TextStyle(fontFamily: 'Vazir', fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF212529))),
      Text(label, style: const TextStyle(fontFamily: 'Vazir', fontSize: 11, color: Color(0xFFADB5BD))),
    ]);
  }

  Widget _buildSection(String title, List<Job> jobs) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      color: Colors.white,
      child: Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
        Row(textDirection: TextDirection.rtl, mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          Text(title, style: const TextStyle(fontFamily: 'Vazir', fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF212529))),
          TextButton(
            onPressed: () => Navigator.pushNamed(context, title == 'نشان‌شده‌ها' ? '/favorites' : '/applied-jobs'),
            child: const Text('مشاهده همه', style: TextStyle(fontFamily: 'Vazir', fontSize: 12)),
          ),
        ]),
        const SizedBox(height: 8),
        ...jobs.take(3).map((job) => JobCard(
          job: job,
          isFavorited: _jobPresenter.isFavorited(job.id),
          onTap: () async {
            await Navigator.pushNamed(context, '/job-detail', arguments: job.id);
            setState(() {});
          },
          onFavoriteTap: () => _jobPresenter.toggleFavorite(job.id),
        )),
      ]),
    );
  }

  void _handleLogout() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('خروج از حساب', style: TextStyle(fontFamily: 'Vazir')),
        content: const Text('آیا از خروج خود مطمئن هستید؟', style: TextStyle(fontFamily: 'Vazir')),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('انصراف', style: TextStyle(fontFamily: 'Vazir'))),
          TextButton(onPressed: () { Navigator.pop(ctx); _authPresenter.logout(); }, child: const Text('خروج', style: TextStyle(fontFamily: 'Vazir', color: Color(0xFFE74C3C)))),
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
    if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message), backgroundColor: const Color(0xFFE74C3C)));
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
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(msg, style: const TextStyle(fontFamily: 'Vazir')),
        behavior: SnackBarBehavior.floating, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ));
    }
  }
  @override
  void onApplied(String message) {}
}
