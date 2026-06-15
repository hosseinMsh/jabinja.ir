import 'package:flutter/material.dart';
import '../presenters/job_presenter.dart';
import '../models/company.dart';
import '../models/job.dart';
import '../widgets/loading_widget.dart';
import '../utils/constants.dart';

class TopCompaniesScreen extends StatefulWidget {
  const TopCompaniesScreen({super.key});

  @override
  State<TopCompaniesScreen> createState() => _TopCompaniesScreenState();
}

class _TopCompaniesScreenState extends State<TopCompaniesScreen> implements JobView {
  late final JobPresenter _presenter;
  List<Company> _companies = [];
  bool _isLoading = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _presenter = JobPresenter(this);
    _presenter.loadTopCompanies();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('۵۰ شرکت برتر'),
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

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _companies.length,
      itemBuilder: (context, index) {
        final company = _companies[index];
        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(AppRadius.md),
            border: Border.all(
              color: index < 3 ? AppColors.primary.withValues(alpha: 0.2) : AppColors.border,
              width: index < 3 ? 1.5 : 0.5,
            ),
          ),
          child: Material(
            color: Colors.transparent,
            borderRadius: BorderRadius.circular(AppRadius.md),
            child: InkWell(
              onTap: () => Navigator.pushNamed(context, '/company', arguments: company.slug),
              borderRadius: BorderRadius.circular(AppRadius.md),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  textDirection: TextDirection.rtl,
                  children: [
                    Container(
                      width: 56, height: 56,
                      decoration: BoxDecoration(
                        color: AppColors.primaryLight,
                        borderRadius: BorderRadius.circular(AppRadius.md),
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(AppRadius.md - 1),
                        child: Image.network(
                          company.logoUrl ?? '',
                          fit: BoxFit.contain,
                          errorBuilder: (_, __, ___) => const Center(
                            child: Icon(Icons.business_rounded, color: AppColors.primary, size: 32),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
                        Text(
                          company.name,
                          style: AppTypography.body.copyWith(fontWeight: FontWeight.bold),
                          textAlign: TextAlign.right,
                        ),
                        if (company.industry != null)
                          Padding(
                            padding: const EdgeInsets.only(top: 4),
                            child: Text(
                              company.industry!,
                              style: AppTypography.bodySmall,
                              textAlign: TextAlign.right,
                            ),
                          ),
                      ]),
                    ),
                    Container(
                      width: 36, height: 36,
                      decoration: BoxDecoration(
                        color: index < 3
                            ? AppColors.premiumLight.withValues(alpha: 0.3)
                            : AppColors.background,
                        borderRadius: BorderRadius.circular(AppRadius.sm),
                      ),
                      child: Center(
                        child: Text(
                          '${index + 1}',
                          style: TextStyle(
                            fontFamily: AppTypography.fontFamily,
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: index < 3 ? AppColors.premiumGold : AppColors.textMuted,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  @override
  void onTopCompaniesLoaded(List<Company> companies) { if (mounted) setState(() { _companies = companies; _errorMessage = null; }); }
  @override
  void onJobsLoaded(List<Job> jobs) {}
  @override
  void onJobsError(String message) { if (mounted) setState(() => _errorMessage = message); }
  @override
  void onJobDetailLoaded(Job job) {}
  @override
  void onJobDetailError(String message) {}
  @override
  void onAppliedJobsLoaded(List<Job> jobs) {}
  @override
  void onFavoriteJobsLoaded(List<Job> jobs) {}
  @override
  void onRecommendedJobsLoaded(List<Job> jobs) {}
  @override
  void onFavoriteToggled(String jobId, bool isFav, String msg) {}
  @override
  void onApplied(String message) {}
  @override
  void setLoading(bool loading) { if (mounted) setState(() => _isLoading = loading); }
}
