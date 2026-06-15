import 'package:flutter/material.dart';
import '../presenters/company_presenter.dart';
import '../models/company.dart';
import '../models/job.dart';
import '../widgets/loading_widget.dart';
import '../widgets/job_card.dart';
import '../utils/constants.dart';

class CompanyScreen extends StatefulWidget {
  const CompanyScreen({super.key});

  @override
  State<CompanyScreen> createState() => _CompanyScreenState();
}

class _CompanyScreenState extends State<CompanyScreen> implements CompanyView {
  late final CompanyPresenter _presenter;
  Company? _company;
  List<Job> _jobs = [];
  bool _isLoading = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _presenter = CompanyPresenter(this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final slug = ModalRoute.of(context)?.settings.arguments as String?;
      if (slug != null) _presenter.loadCompany(slug);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('اطلاعات شرکت'),
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
              width: 80, height: 80,
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

    if (_company == null) return const SizedBox.shrink();

    return RefreshIndicator(
      color: AppColors.primary,
      onRefresh: () async {
        final slug = ModalRoute.of(context)?.settings.arguments as String?;
        if (slug != null) _presenter.loadCompany(slug);
      },
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        child: Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
          _buildCompanyHeader(),
          if (_company!.industry != null || _company!.location != null || _company!.employeeCount != null)
            _buildCompanyInfo(),
          if (_company!.description != null && _company!.description!.isNotEmpty)
            _buildCompanyDescription(),
          if (_jobs.isNotEmpty) _buildJobsSection(),
          const SizedBox(height: 24),
        ]),
      ),
    );
  }

  Widget _buildCompanyHeader() {
    return Container(
      width: double.infinity,
      color: AppColors.surface,
      child: Column(children: [
        if (_company!.coverUrl != null && _company!.coverUrl!.isNotEmpty)
          Container(
            width: double.infinity, height: 140,
            decoration: BoxDecoration(
              color: AppColors.primaryLight,
              image: DecorationImage(
                image: NetworkImage(_company!.coverUrl!),
                fit: BoxFit.cover,
                onError: (_, __) {},
              ),
            ),
          )
        else
          Container(
            width: double.infinity, height: 80,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [AppColors.primary, AppColors.primaryDark],
              ),
            ),
          ),
        Padding(
          padding: EdgeInsets.fromLTRB(24, _company!.coverUrl != null ? 0 : 0, 24, 24),
          child: Transform.translate(
            offset: const Offset(0, -36),
            child: Column(children: [
              Container(
                width: 88, height: 88,
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(AppRadius.xl),
                  border: Border.all(color: AppColors.surface, width: 3),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.08),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(AppRadius.xl - 2),
                  child: Image.network(
                    _company!.logoUrl ?? '',
                    fit: BoxFit.contain,
                    errorBuilder: (_, __, ___) => const Center(child: Icon(Icons.business_rounded, color: AppColors.primary, size: 48)),
                  ),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                _company!.name,
                style: AppTypography.h2,
                textAlign: TextAlign.center,
              ),
              if (_company!.website != null && _company!.website!.isNotEmpty) ...[
                const SizedBox(height: 4),
                Text(
                  _company!.website!,
                  style: AppTypography.bodySmall.copyWith(color: AppColors.primary),
                ),
              ],
              if (_company!.popularity != null) ...[
                const SizedBox(height: 16),
                _buildRatingRow(),
              ],
            ]),
          ),
        ),
      ]),
    );
  }

  Widget _buildRatingRow() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(AppRadius.md),
      ),
      child: Row(
        textDirection: TextDirection.rtl,
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _buildRatingItem('محبوبیت', _company!.popularity ?? 0),
          Container(width: 1, height: 30, color: AppColors.divider),
          _buildRatingItem('تنوع شغل', _company!.jobVariety ?? 0),
          Container(width: 1, height: 30, color: AppColors.divider),
          _buildRatingItem('بررسی رزومه', _company!.resumeReview ?? 0),
        ],
      ),
    );
  }

  Widget _buildRatingItem(String label, int score) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          children: List.generate(5, (i) => Icon(
            i < (score / 2).ceil() ? Icons.star : Icons.star_border,
            size: 14,
            color: AppColors.star,
          )),
        ),
        const SizedBox(height: 4),
        Text(label, style: AppTypography.caption),
      ],
    );
  }

  Widget _buildCompanyInfo() {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(top: 8),
      padding: const EdgeInsets.all(20),
      color: AppColors.surface,
      child: Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
        const Text('اطلاعات کلی', style: AppTypography.h4),
        const SizedBox(height: 16),
        if (_company!.industry != null) _buildInfoRow(Icons.category_outlined, 'صنعت', _company!.industry!),
        if (_company!.location != null) _buildInfoRow(Icons.location_on_outlined, 'موقعیت', _company!.location!),
        if (_company!.employeeCount != null) _buildInfoRow(Icons.people_outline, 'تعداد کارکنان', '${_company!.employeeCount} نفر'),
      ]),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(textDirection: TextDirection.rtl, children: [
        Container(
          width: 32, height: 32,
          decoration: BoxDecoration(
            color: AppColors.primaryLight,
            borderRadius: BorderRadius.circular(AppRadius.sm),
          ),
          child: Icon(icon, size: 16, color: AppColors.primary),
        ),
        const SizedBox(width: 10),
        Text('$label: ', style: AppTypography.bodySmall),
        Text(value, style: AppTypography.body.copyWith(fontWeight: FontWeight.w500)),
      ]),
    );
  }

  Widget _buildCompanyDescription() {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(top: 8),
      padding: const EdgeInsets.all(20),
      color: AppColors.surface,
      child: Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
        const Text('درباره شرکت', style: AppTypography.h4),
        const SizedBox(height: 12),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.background,
            borderRadius: BorderRadius.circular(AppRadius.md),
          ),
          child: Text(
            _company!.description!,
            style: AppTypography.bodySmall.copyWith(height: 1.8, color: AppColors.textSecondary),
            textAlign: TextAlign.right,
          ),
        ),
      ]),
    );
  }

  Widget _buildJobsSection() {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(top: 8),
      padding: const EdgeInsets.all(16),
      color: AppColors.surface,
      child: Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
        Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: Text('شغل‌های این شرکت', style: AppTypography.h4),
        ),
        ..._jobs.map((job) => Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: JobCard(
            job: job,
            onTap: () => Navigator.pushNamed(context, '/job-detail', arguments: job.id),
          ),
        )),
      ]),
    );
  }

  @override
  void onCompanyLoaded(Company company) { if (mounted) setState(() { _company = company; _errorMessage = null; }); }
  @override
  void onCompanyJobsLoaded(List<Job> jobs) { if (mounted) setState(() => _jobs = jobs); }
  @override
  void onCompanyError(String message) { if (mounted) setState(() { _errorMessage = message; _company = null; }); }
  @override
  void setLoading(bool loading) { if (mounted) setState(() => _isLoading = loading); }
}
