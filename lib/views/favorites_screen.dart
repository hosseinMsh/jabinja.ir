import 'package:flutter/material.dart';
import '../presenters/job_presenter.dart';
import '../models/company.dart';
import '../models/job.dart';
import '../widgets/loading_widget.dart';
import '../widgets/job_card.dart';

class FavoritesScreen extends StatefulWidget {
  const FavoritesScreen({super.key});

  @override
  State<FavoritesScreen> createState() => _FavoritesScreenState();
}

class _FavoritesScreenState extends State<FavoritesScreen> implements JobView {
  late final JobPresenter _presenter;
  List<Job> _jobs = [];
  bool _isLoading = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _presenter = JobPresenter(this);
    _presenter.loadFavoriteJobs();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        title: const Text('نشان‌شده‌ها', style: TextStyle(fontFamily: 'Vazir', fontSize: 18, fontWeight: FontWeight.bold)),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0,
        foregroundColor: const Color(0xFF212529),
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
            const Icon(Icons.error_outline, size: 64, color: Color(0xFFADB5BD)),
            const SizedBox(height: 16),
            Text(_errorMessage!, style: const TextStyle(fontFamily: 'Vazir', fontSize: 14, color: Color(0xFF6C757D)), textAlign: TextAlign.center),
          ]),
        ),
      );
    }

    if (_jobs.isEmpty) {
      return Center(
        child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
          const Icon(Icons.bookmark_border, size: 64, color: Color(0xFFADB5BD)),
          const SizedBox(height: 16),
          const Text('هنوز شغلی نشان نکرده‌اید', style: TextStyle(fontFamily: 'Vazir', fontSize: 14, color: Color(0xFF6C757D))),
          const SizedBox(height: 8),
          const Text('با نشان کردن شغل‌ها، می‌توانید بعداً به راحتی آن‌ها را پیدا کنید', style: TextStyle(fontFamily: 'Vazir', fontSize: 12, color: Color(0xFFADB5BD))),
        ]),
      );
    }

    return RefreshIndicator(
      onRefresh: () async => _presenter.loadFavoriteJobs(),
      child: ListView.builder(
        padding: const EdgeInsets.only(top: 8, bottom: 16),
        itemCount: _jobs.length,
        itemBuilder: (context, index) {
          final job = _jobs[index];
          return JobCard(
            job: job,
            isFavorited: true,
            onTap: () async {
              await Navigator.pushNamed(context, '/job-detail', arguments: job.id);
              if (mounted) _presenter.loadFavoriteJobs();
            },
            onFavoriteTap: () => _presenter.toggleFavorite(job.id),
          );
        },
      ),
    );
  }

  @override
  void onFavoriteJobsLoaded(List<Job> jobs) { if (mounted) setState(() { _jobs = jobs; _errorMessage = null; }); }
  @override
  void onFavoriteToggled(String jobId, bool isFav, String msg) {
    if (mounted) {
      _presenter.loadFavoriteJobs();
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(msg, style: const TextStyle(fontFamily: 'Vazir')),
        behavior: SnackBarBehavior.floating, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ));
    }
  }
  @override
  void onJobsLoaded(List<Job> jobs) {}
  @override
  void onJobsError(String message) { if (mounted) setState(() { _errorMessage = message; _jobs = []; }); }
  @override
  void onJobDetailLoaded(Job job) {}
  @override
  void onJobDetailError(String message) {}
  @override
  void onAppliedJobsLoaded(List<Job> jobs) {}
  @override
  void onRecommendedJobsLoaded(List<Job> jobs) {}
  @override
  void onTopCompaniesLoaded(List<Company> companies) {}
  @override
  void onApplied(String message) {}
  @override
  void setLoading(bool loading) { if (mounted) setState(() => _isLoading = loading); }
}
