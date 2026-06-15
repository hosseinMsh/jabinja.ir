import 'package:flutter/material.dart';
import '../presenters/job_presenter.dart';
import '../models/company.dart';
import '../models/job.dart';
import '../widgets/loading_widget.dart';
import '../widgets/job_card.dart';
import '../utils/constants.dart';

class AppliedJobsScreen extends StatefulWidget {
  const AppliedJobsScreen({super.key});

  @override
  State<AppliedJobsScreen> createState() => _AppliedJobsScreenState();
}

class _AppliedJobsScreenState extends State<AppliedJobsScreen> implements JobView {
  late final JobPresenter _presenter;
  List<Job> _jobs = [];
  bool _isLoading = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _presenter = JobPresenter(this);
    _presenter.loadAppliedJobs();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('درخواست‌های من'),
        centerTitle: true,
        backgroundColor: AppColors.surface,
        elevation: 0,
        foregroundColor: AppColors.textPrimary,
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_isLoading) return const LoadingWidget(message: 'در حال بارگذاری...');

    if (_errorMessage != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
            Container(
              width: 72, height: 72,
              decoration: BoxDecoration(
                color: AppColors.error.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Icon(Icons.error_outline, size: 40, color: AppColors.error),
            ),
            const SizedBox(height: 16),
            Text(_errorMessage!, style: AppTypography.body.copyWith(color: AppColors.textSecondary), textAlign: TextAlign.center),
          ]),
        ),
      );
    }

    if (_jobs.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
            Container(
              width: 80, height: 80,
              decoration: BoxDecoration(
                color: AppColors.primaryLight,
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Icon(Icons.send_outlined, size: 40, color: AppColors.primary),
            ),
            const SizedBox(height: 16),
            Text(
              'هنوز به شغلی رزومه نفرستاده‌اید',
              style: AppTypography.body.copyWith(color: AppColors.textSecondary),
            ),
            const SizedBox(height: 8),
            const Text(
              'با ارسال رزومه برای شغل‌ها، وضعیت آن‌ها را اینجا پیگیری کنید',
              style: AppTypography.bodySmall,
              textAlign: TextAlign.center,
            ),
          ]),
        ),
      );
    }

    return RefreshIndicator(
      color: AppColors.primary,
      onRefresh: () async => _presenter.loadAppliedJobs(),
      child: ListView.builder(
        padding: const EdgeInsets.only(top: 8, bottom: 16),
        itemCount: _jobs.length,
        itemBuilder: (context, index) => JobCard(
          job: _jobs[index],
          isFavorited: _presenter.isFavorited(_jobs[index].id),
          onTap: () async {
            await Navigator.pushNamed(context, '/job-detail', arguments: _jobs[index].id);
            if (mounted) setState(() {});
          },
          onFavoriteTap: () => _presenter.toggleFavorite(_jobs[index].id),
        ),
      ),
    );
  }

  @override
  void onAppliedJobsLoaded(List<Job> jobs) { if (mounted) setState(() { _jobs = jobs; _errorMessage = null; }); }
  @override
  void onJobsLoaded(List<Job> jobs) {}
  @override
  void onJobsError(String message) { if (mounted) setState(() { _errorMessage = message; _jobs = []; }); }
  @override
  void onJobDetailLoaded(Job job) {}
  @override
  void onJobDetailError(String message) {}
  @override
  void onFavoriteJobsLoaded(List<Job> jobs) {}
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
  @override
  void setLoading(bool loading) { if (mounted) setState(() => _isLoading = loading); }
}
