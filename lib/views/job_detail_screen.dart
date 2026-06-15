import 'package:flutter/material.dart';
import '../presenters/job_presenter.dart';
import '../models/company.dart';
import '../models/job.dart';
import '../widgets/loading_widget.dart';
import '../widgets/custom_button.dart';
import '../utils/constants.dart';

class JobDetailScreen extends StatefulWidget {
  const JobDetailScreen({super.key});

  @override
  State<JobDetailScreen> createState() => _JobDetailScreenState();
}

class _JobDetailScreenState extends State<JobDetailScreen> implements JobView {
  late final JobPresenter _presenter;
  Job? _job;
  bool _isLoading = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _presenter = JobPresenter(this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final jobId = ModalRoute.of(context)?.settings.arguments as String?;
      if (jobId != null) {
        _presenter.loadJobDetail(jobId);
      } else if (mounted) {
        setState(() => _errorMessage = 'شناسه شغل نامعتبر است');
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('جزئیات شغل'),
        centerTitle: true,
        backgroundColor: AppColors.surface,
        elevation: 0,
        foregroundColor: AppColors.textPrimary,
      ),
      body: _buildBody(),
      bottomNavigationBar: _job != null ? _buildBottomBar() : null,
    );
  }

  Widget _buildBody() {
    if (_isLoading) return const LoadingWidget(message: 'در حال بارگذاری...');

    if (_errorMessage != null) {
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
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Icon(Icons.error_outline, size: 40, color: AppColors.error),
              ),
              const SizedBox(height: 16),
              Text(
                _errorMessage!,
                style: AppTypography.body.copyWith(color: AppColors.textSecondary),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      );
    }

    if (_job == null) return const SizedBox.shrink();

    return RefreshIndicator(
      color: AppColors.primary,
      onRefresh: () async {
        final jobId = ModalRoute.of(context)?.settings.arguments as String?;
        if (jobId != null) _presenter.loadJobDetail(jobId);
      },
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        child: Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
          _buildHeader(),
          const SizedBox(height: 8),
          _buildInfoSection(),
          const SizedBox(height: 8),
          if (_job!.description != null && _job!.description!.isNotEmpty) _buildDescriptionSection(),
          if (_job!.skills != null && _job!.skills!.isNotEmpty) ...[
            const SizedBox(height: 8),
            _buildSkillsSection(),
          ],
          if (_job!.benefits != null && _job!.benefits!.isNotEmpty) ...[
            const SizedBox(height: 8),
            _buildBenefitsSection(),
          ],
          const SizedBox(height: 8),
          _buildCompanySection(),
          const SizedBox(height: 24),
        ]),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      color: AppColors.surface,
      child: Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
        if (_job!.isPremium)
          Container(
            margin: const EdgeInsets.only(bottom: 12),
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              gradient: const LinearGradient(colors: [AppColors.primary, AppColors.primaryDark]),
              borderRadius: BorderRadius.circular(6),
            ),
            child: const Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.star, size: 14, color: Colors.white),
                SizedBox(width: 4),
                Text(
                  'ویژه',
                  style: TextStyle(
                    fontFamily: AppTypography.fontFamily,
                    fontSize: 11,
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        Row(
          textDirection: TextDirection.rtl,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 64, height: 64,
              decoration: BoxDecoration(
                color: AppColors.primaryLight,
                borderRadius: BorderRadius.circular(AppRadius.lg),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(AppRadius.lg - 1),
                child: Image.network(
                  _job!.company.logoUrl ?? '',
                  fit: BoxFit.contain,
                  errorBuilder: (_, __, ___) => const Center(
                    child: Icon(Icons.business_rounded, color: AppColors.primary, size: 36),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
                Text(
                  _job!.title,
                  style: AppTypography.h2.copyWith(fontSize: 20),
                  textAlign: TextAlign.right,
                ),
                const SizedBox(height: 4),
                GestureDetector(
                  onTap: () => Navigator.pushNamed(context, '/company', arguments: _job!.company.slug),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.chevron_left, size: 16, color: AppColors.primary),
                      const SizedBox(width: 4),
                      Text(
                        _job!.company.name,
                        style: const TextStyle(
                          fontFamily: AppTypography.fontFamily,
                          fontSize: 14,
                          color: AppColors.primary,
                          fontWeight: FontWeight.w500,
                        ),
                        textAlign: TextAlign.right,
                      ),
                    ],
                  ),
                ),
                if (_job!.relativeTime != null)
                  Padding(
                    padding: const EdgeInsets.only(top: 2),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          _job!.relativeTime!,
                          style: AppTypography.caption,
                        ),
                        const SizedBox(width: 4),
                        const Icon(Icons.access_time, size: 13, color: AppColors.textMuted),
                      ],
                    ),
                  ),
              ]),
            ),
          ],
        ),
      ]),
    );
  }

  Widget _buildInfoSection() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      color: AppColors.surface,
      child: Wrap(
        spacing: 10, runSpacing: 10,
        textDirection: TextDirection.rtl,
        children: [
          _buildInfoChip(Icons.location_on_outlined, 'موقعیت', _job!.location),
          if (_job!.contractType != null)
            _buildInfoChip(Icons.work_outline, 'نوع قرارداد', _job!.contractType!),
          if (_job!.salaryDisplay != null)
            _buildInfoChip(Icons.monetization_on_outlined, 'حقوق', _job!.salaryDisplay!),
          if (_job!.experienceLevel != null)
            _buildInfoChip(Icons.timeline, 'سابقه', _job!.experienceLevel!),
          if (_job!.publishedAt != null)
            _buildInfoChip(Icons.calendar_today, 'تاریخ انتشار', _job!.publishedAt!),
          _buildInfoChip(Icons.wifi, 'دورکاری', _job!.isRemote ? 'بله' : 'خیر'),
          if (_job!.category != null)
            _buildInfoChip(Icons.category_outlined, 'دسته‌بندی', _job!.category!),
        ],
      ),
    );
  }

  Widget _buildInfoChip(IconData icon, String label, String value) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(AppRadius.sm),
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
        Row(mainAxisSize: MainAxisSize.min, children: [
          Text(label, style: AppTypography.caption),
          const SizedBox(width: 4),
          Icon(icon, size: 14, color: AppColors.textMuted),
        ]),
        const SizedBox(height: 4),
        Text(
          value,
          style: AppTypography.bodySmall.copyWith(
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
      ]),
    );
  }

  Widget _buildDescriptionSection() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      color: AppColors.surface,
      child: Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
        const Text('توضیحات شغل', style: AppTypography.h4),
        const SizedBox(height: 12),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.background,
            borderRadius: BorderRadius.circular(AppRadius.md),
          ),
          child: Text(
            _job!.description!,
            style: AppTypography.body.copyWith(
              color: AppColors.textSecondary,
              height: 1.8,
            ),
            textAlign: TextAlign.right,
          ),
        ),
      ]),
    );
  }

  Widget _buildSkillsSection() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      color: AppColors.surface,
      child: Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
        const Text('مهارت‌های مورد نیاز', style: AppTypography.h4),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8, runSpacing: 8,
          textDirection: TextDirection.rtl,
          children: _job!.skills!.map((s) => Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
            decoration: BoxDecoration(
              color: AppColors.primaryLight,
              borderRadius: BorderRadius.circular(AppRadius.full),
            ),
            child: Text(
              s,
              style: const TextStyle(
                fontFamily: AppTypography.fontFamily,
                fontSize: 12,
                color: AppColors.primary,
                fontWeight: FontWeight.w500,
              ),
            ),
          )).toList(),
        ),
      ]),
    );
  }

  Widget _buildBenefitsSection() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      color: AppColors.surface,
      child: Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
        const Text('مزایا', style: AppTypography.h4),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8, runSpacing: 8,
          textDirection: TextDirection.rtl,
          children: _job!.benefits!.map((b) => Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
            decoration: BoxDecoration(
              color: AppColors.success.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(AppRadius.full),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  b,
                  style: const TextStyle(
                    fontFamily: AppTypography.fontFamily,
                    fontSize: 12,
                    color: AppColors.success,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(width: 6),
                const Icon(Icons.check_circle, size: 14, color: AppColors.success),
              ],
            ),
          )).toList(),
        ),
      ]),
    );
  }

  Widget _buildCompanySection() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      color: AppColors.surface,
      child: Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
        const Text('اطلاعات شرکت', style: AppTypography.h4),
        const SizedBox(height: 16),
        Row(
          textDirection: TextDirection.rtl,
          children: [
            Container(
              width: 48, height: 48,
              decoration: BoxDecoration(
                color: AppColors.primaryLight,
                borderRadius: BorderRadius.circular(AppRadius.md),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(AppRadius.md - 1),
                child: Image.network(
                  _job!.company.logoUrl ?? '',
                  fit: BoxFit.contain,
                  errorBuilder: (_, __, ___) => const Icon(Icons.business, color: AppColors.primary, size: 28),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
                Text(_job!.company.name, style: AppTypography.body.copyWith(fontWeight: FontWeight.w600)),
                if (_job!.company.industry != null)
                  Text(_job!.company.industry!, style: AppTypography.caption),
              ]),
            ),
          ],
        ),
        if (_job!.company.description != null && _job!.company.description!.isNotEmpty) ...[
          const SizedBox(height: 12),
          Text(
            _job!.company.description!,
            style: AppTypography.bodySmall.copyWith(height: 1.6),
            textAlign: TextAlign.right,
            maxLines: 3,
            overflow: TextOverflow.ellipsis,
          ),
        ],
        const SizedBox(height: 12),
        Align(
          alignment: Alignment.centerLeft,
          child: TextButton.icon(
            onPressed: () => Navigator.pushNamed(context, '/company', arguments: _job!.company.slug),
            icon: const Icon(Icons.arrow_forward, size: 16),
            label: const Text(
              'مشاهده صفحه شرکت',
              style: TextStyle(fontFamily: AppTypography.fontFamily, fontSize: 13),
            ),
            style: TextButton.styleFrom(foregroundColor: AppColors.primary),
          ),
        ),
      ]),
    );
  }

  Widget _buildBottomBar() {
    final isApplied = _presenter.isApplied(_job!.id);
    final isFav = _presenter.isFavorited(_job!.id);
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 12,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: CustomButton(
              text: isApplied ? 'ارسال شد ✓' : 'ارسال رزومه',
              color: isApplied ? AppColors.success : null,
              onPressed: isApplied ? null : () => _presenter.applyToJob(_job!.id),
            ),
          ),
          const SizedBox(width: 12),
          Container(
            width: 52, height: 52,
            decoration: BoxDecoration(
              border: Border.all(
                color: isFav ? AppColors.primary : AppColors.border,
                width: isFav ? 2 : 1,
              ),
              borderRadius: BorderRadius.circular(AppRadius.md),
              color: isFav ? AppColors.primaryLight : AppColors.surface,
            ),
            child: IconButton(
              icon: Icon(
                isFav ? Icons.bookmark : Icons.bookmark_border,
                color: isFav ? AppColors.primary : AppColors.textMuted,
              ),
              onPressed: () => _presenter.toggleFavorite(_job!.id),
            ),
          ),
        ],
      ),
    );
  }

  @override
  void onJobDetailLoaded(Job job) { if (mounted) setState(() { _job = job; _errorMessage = null; }); }
  @override
  void onJobDetailError(String message) { if (mounted) setState(() { _errorMessage = message; _job = null; }); }
  @override
  void onJobsLoaded(List<Job> jobs) {}
  @override
  void onJobsError(String message) {}
  @override
  void onAppliedJobsLoaded(List<Job> jobs) {}
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
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(msg, style: const TextStyle(fontFamily: AppTypography.fontFamily)),
        behavior: SnackBarBehavior.floating, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadius.sm)),
      ));
    }
  }
  @override
  void onApplied(String message) {
    if (mounted) {
      setState(() {});
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(message, style: const TextStyle(fontFamily: AppTypography.fontFamily)),
        backgroundColor: AppColors.success, behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadius.sm)),
      ));
    }
  }
  @override
  void setLoading(bool loading) { if (mounted) setState(() => _isLoading = loading); }
}
