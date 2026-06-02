import 'package:flutter/material.dart';
import '../presenters/job_presenter.dart';
import '../models/company.dart';
import '../models/job.dart';
import '../widgets/loading_widget.dart';
import '../widgets/custom_button.dart';

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
      if (jobId != null) _presenter.loadJobDetail(jobId);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        title: const Text('جزئیات شغل', style: TextStyle(fontFamily: 'Vazir', fontSize: 18, fontWeight: FontWeight.bold)),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0,
        foregroundColor: const Color(0xFF212529),
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
              const Icon(Icons.error_outline, size: 64, color: Color(0xFFADB5BD)),
              const SizedBox(height: 16),
              Text(_errorMessage!, style: const TextStyle(fontFamily: 'Vazir', fontSize: 14, color: Color(0xFF6C757D)), textAlign: TextAlign.center),
            ],
          ),
        ),
      );
    }

    if (_job == null) return const SizedBox.shrink();

    return SingleChildScrollView(
      child: Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
        _buildHeader(),
        const SizedBox(height: 8),
        _buildInfoSection(),
        const SizedBox(height: 8),
        if (_job!.description != null) _buildDescriptionSection(),
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
    );
  }

  Widget _buildHeader() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      color: Colors.white,
      child: Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
        if (_job!.isPremium)
          Container(
            margin: const EdgeInsets.only(bottom: 12),
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
            decoration: BoxDecoration(
              gradient: const LinearGradient(colors: [Color(0xFF4A90D9), Color(0xFF357ABD)]),
              borderRadius: BorderRadius.circular(6),
            ),
            child: const Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.star, size: 12, color: Colors.white),
                SizedBox(width: 4),
                Text('ویژه', style: TextStyle(fontFamily: 'Vazir', fontSize: 10, color: Colors.white, fontWeight: FontWeight.bold)),
              ],
            ),
          ),
        Row(
          textDirection: TextDirection.rtl,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 60, height: 60,
              decoration: BoxDecoration(color: const Color(0xFFE8F0FE), borderRadius: BorderRadius.circular(14), border: Border.all(color: const Color(0xFFDEE2E6))),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(13),
                child: Image.network(
                  _job!.company.logoUrl ?? '',
                  fit: BoxFit.contain,
                  errorBuilder: (_, __, ___) => const Center(child: Icon(Icons.business_rounded, color: Color(0xFF4A90D9), size: 36)),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
                Text(_job!.title, style: const TextStyle(fontFamily: 'Vazir', fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFF212529)), textAlign: TextAlign.right),
                const SizedBox(height: 4),
                GestureDetector(
                  onTap: () => Navigator.pushNamed(context, '/company', arguments: _job!.company.slug),
                  child: Text(_job!.company.name, style: const TextStyle(fontFamily: 'Vazir', fontSize: 14, color: Color(0xFF4A90D9), decoration: TextDecoration.underline), textAlign: TextAlign.right),
                ),
                if (_job!.relativeTime != null)
                  Text(_job!.relativeTime!, style: const TextStyle(fontFamily: 'Vazir', fontSize: 12, color: Color(0xFFADB5BD))),
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
      color: Colors.white,
      child: Wrap(spacing: 12, runSpacing: 12, textDirection: TextDirection.rtl, children: [
        _buildInfoItem(Icons.location_on_outlined, 'موقعیت', _job!.location),
        if (_job!.contractType != null) _buildInfoItem(Icons.work_outline, 'نوع قرارداد', _job!.contractType!),
        if (_job!.salaryDisplay != null) _buildInfoItem(Icons.monetization_on_outlined, 'حقوق', _job!.salaryDisplay!),
        if (_job!.experienceLevel != null) _buildInfoItem(Icons.timeline, 'سابقه مورد نیاز', _job!.experienceLevel!),
        if (_job!.publishedAt != null) _buildInfoItem(Icons.calendar_today, 'تاریخ انتشار', _job!.publishedAt!),
        _buildInfoItem(Icons.wifi, 'دورکاری', _job!.isRemote ? 'بله' : 'خیر'),
        if (_job!.category != null) _buildInfoItem(Icons.category_outlined, 'دسته‌بندی', _job!.category!),
      ]),
    );
  }

  Widget _buildInfoItem(IconData icon, String label, String value) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(color: const Color(0xFFF8F9FA), borderRadius: BorderRadius.circular(10)),
      child: Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
        Row(mainAxisSize: MainAxisSize.min, children: [
          Text(label, style: const TextStyle(fontFamily: 'Vazir', fontSize: 12, color: Color(0xFFADB5BD))),
          const SizedBox(width: 4),
          Icon(icon, size: 14, color: const Color(0xFFADB5BD)),
        ]),
        const SizedBox(height: 4),
        Text(value, style: const TextStyle(fontFamily: 'Vazir', fontSize: 14, fontWeight: FontWeight.w500, color: Color(0xFF212529))),
      ]),
    );
  }

  Widget _buildDescriptionSection() {
    return Container(
      width: double.infinity, padding: const EdgeInsets.all(20), color: Colors.white,
      child: Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
        const Text('توضیحات شغل', style: TextStyle(fontFamily: 'Vazir', fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF212529))),
        const SizedBox(height: 12),
        Text(_job!.description!, style: const TextStyle(fontFamily: 'Vazir', fontSize: 14, color: Color(0xFF495057), height: 1.8), textAlign: TextAlign.right),
      ]),
    );
  }

  Widget _buildSkillsSection() {
    return Container(
      width: double.infinity, padding: const EdgeInsets.all(20), color: Colors.white,
      child: Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
        const Text('مهارت‌های مورد نیاز', style: TextStyle(fontFamily: 'Vazir', fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF212529))),
        const SizedBox(height: 12),
        Wrap(spacing: 8, runSpacing: 8, textDirection: TextDirection.rtl,
          children: _job!.skills!.map((s) => Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(color: const Color(0xFFE8F0FE), borderRadius: BorderRadius.circular(8)),
            child: Text(s, style: const TextStyle(fontFamily: 'Vazir', fontSize: 12, color: Color(0xFF4A90D9))),
          )).toList()),
      ]),
    );
  }

  Widget _buildBenefitsSection() {
    return Container(
      width: double.infinity, padding: const EdgeInsets.all(20), color: Colors.white,
      child: Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
        const Text('مزایا', style: TextStyle(fontFamily: 'Vazir', fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF212529))),
        const SizedBox(height: 12),
        Wrap(spacing: 8, runSpacing: 8, textDirection: TextDirection.rtl,
          children: _job!.benefits!.map((b) => Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(color: const Color(0xFFE8F8E8), borderRadius: BorderRadius.circular(8)),
            child: Row(mainAxisSize: MainAxisSize.min, children: [
              Text(b, style: const TextStyle(fontFamily: 'Vazir', fontSize: 12, color: Color(0xFF27AE60))),
              const SizedBox(width: 4),
              const Icon(Icons.check_circle, size: 14, color: Color(0xFF27AE60)),
            ]),
          )).toList()),
      ]),
    );
  }

  Widget _buildCompanySection() {
    return Container(
      width: double.infinity, padding: const EdgeInsets.all(20), color: Colors.white,
      child: Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
        const Text('اطلاعات شرکت', style: TextStyle(fontFamily: 'Vazir', fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF212529))),
        const SizedBox(height: 12),
        Row(textDirection: TextDirection.rtl, children: [
          const Icon(Icons.business, size: 16, color: Color(0xFF6C757D)),
          const SizedBox(width: 6),
          Text(_job!.company.name, style: const TextStyle(fontFamily: 'Vazir', fontSize: 14, color: Color(0xFF495057))),
        ]),
        if (_job!.company.industry != null) ...[
          const SizedBox(height: 8),
          Row(textDirection: TextDirection.rtl, children: [
            const Icon(Icons.category_outlined, size: 16, color: Color(0xFF6C757D)),
            const SizedBox(width: 6),
            Text(_job!.company.industry!, style: const TextStyle(fontFamily: 'Vazir', fontSize: 14, color: Color(0xFF495057))),
          ]),
        ],
        if (_job!.company.description != null) ...[
          const SizedBox(height: 12),
          Text(_job!.company.description!, style: const TextStyle(fontFamily: 'Vazir', fontSize: 13, color: Color(0xFF6C757D), height: 1.6), textAlign: TextAlign.right),
        ],
        const SizedBox(height: 12),
        TextButton.icon(
          onPressed: () => Navigator.pushNamed(context, '/company', arguments: _job!.company.slug),
          icon: const Icon(Icons.arrow_forward, size: 16),
          label: const Text('مشاهده صفحه شرکت', style: TextStyle(fontFamily: 'Vazir', fontSize: 13)),
        ),
      ]),
    );
  }

  Widget _buildBottomBar() {
    final isApplied = _presenter.isApplied(_job!.id);
    final isFav = _presenter.isFavorited(_job!.id);
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
      decoration: const BoxDecoration(color: Colors.white, boxShadow: [BoxShadow(color: Color(0x1A000000), blurRadius: 8, offset: Offset(0, -2))]),
      child: Row(
        children: [
          Expanded(
            child: CustomButton(
              text: isApplied ? 'ارسال شد ✓' : 'ارسال رزومه',
              color: isApplied ? const Color(0xFF27AE60) : null,
              onPressed: isApplied ? null : () => _presenter.applyToJob(_job!.id),
            ),
          ),
          const SizedBox(width: 12),
          Container(
            width: 50, height: 50,
            decoration: BoxDecoration(
              border: Border.all(color: isFav ? const Color(0xFF4A90D9) : const Color(0xFFDEE2E6)),
              borderRadius: BorderRadius.circular(12),
            ),
            child: IconButton(
              icon: Icon(isFav ? Icons.bookmark : Icons.bookmark_border, color: isFav ? const Color(0xFF4A90D9) : const Color(0xFFADB5BD)),
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
        content: Text(msg, style: const TextStyle(fontFamily: 'Vazir')),
        behavior: SnackBarBehavior.floating, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ));
    }
  }
  @override
  void onApplied(String message) {
    if (mounted) {
      setState(() {});
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(message, style: const TextStyle(fontFamily: 'Vazir')),
        backgroundColor: const Color(0xFF27AE60), behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ));
    }
  }
  @override
  void setLoading(bool loading) { if (mounted) setState(() => _isLoading = loading); }
}
