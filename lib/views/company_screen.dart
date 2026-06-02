import 'package:flutter/material.dart';
import '../presenters/company_presenter.dart';
import '../models/company.dart';
import '../models/job.dart';
import '../widgets/loading_widget.dart';
import '../widgets/job_card.dart';

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
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        title: const Text('اطلاعات شرکت', style: TextStyle(fontFamily: 'Vazir', fontSize: 18, fontWeight: FontWeight.bold)),
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

    if (_company == null) return const SizedBox.shrink();

    return SingleChildScrollView(
      child: Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
        _buildCompanyHeader(),
        if (_company!.industry != null || _company!.location != null || _company!.employeeCount != null)
          _buildCompanyInfo(),
        if (_company!.description != null) _buildCompanyDescription(),
        if (_jobs.isNotEmpty) _buildJobsSection(),
        const SizedBox(height: 24),
      ]),
    );
  }

  Widget _buildCompanyHeader() {
    return Container(
      width: double.infinity,
      color: Colors.white,
      child: Column(children: [
        if (_company!.coverUrl != null)
          Container(
            width: double.infinity, height: 140,
            decoration: BoxDecoration(
              color: const Color(0xFFE8F0FE),
              image: DecorationImage(
                image: NetworkImage(_company!.coverUrl!),
                fit: BoxFit.cover,
                onError: (_, __) {},
              ),
            ),
          ),
        Padding(
          padding: EdgeInsets.fromLTRB(24, _company!.coverUrl != null ? 0 : 24, 24, 24),
          child: Transform.translate(
            offset: _company!.coverUrl != null ? const Offset(0, -32) : Offset.zero,
            child: Column(children: [
              Container(
                width: 84, height: 84,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(color: const Color(0xFFDEE2E6), width: 2),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(16),
                  child: Image.network(
                    _company!.logoUrl ?? '',
                    fit: BoxFit.contain,
                    errorBuilder: (_, __, ___) => const Center(child: Icon(Icons.business_rounded, color: Color(0xFF4A90D9), size: 48)),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              Text(_company!.name, style: const TextStyle(fontFamily: 'Vazir', fontSize: 22, fontWeight: FontWeight.bold, color: Color(0xFF212529)), textAlign: TextAlign.center),
              if (_company!.website != null) ...[
                const SizedBox(height: 6),
                Text(_company!.website!, style: const TextStyle(fontFamily: 'Vazir', fontSize: 13, color: Color(0xFF4A90D9))),
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
        color: const Color(0xFFF8F9FA),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        textDirection: TextDirection.rtl,
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _buildRatingItem('محبوبیت', _company!.popularity ?? 0),
          Container(width: 1, height: 30, color: const Color(0xFFDEE2E6)),
          _buildRatingItem('تنوع شغل', _company!.jobVariety ?? 0),
          Container(width: 1, height: 30, color: const Color(0xFFDEE2E6)),
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
            color: const Color(0xFFF5A623),
          )),
        ),
        const SizedBox(height: 4),
        Text(label, style: const TextStyle(fontFamily: 'Vazir', fontSize: 11, color: Color(0xFF6C757D))),
      ],
    );
  }

  Widget _buildCompanyInfo() {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(top: 8),
      padding: const EdgeInsets.all(20),
      color: Colors.white,
      child: Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
        const Text('اطلاعات کلی', style: TextStyle(fontFamily: 'Vazir', fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF212529))),
        const SizedBox(height: 12),
        if (_company!.industry != null) _buildInfoRow(Icons.category_outlined, 'صنعت', _company!.industry!),
        if (_company!.location != null) _buildInfoRow(Icons.location_on_outlined, 'موقعیت', _company!.location!),
        if (_company!.employeeCount != null) _buildInfoRow(Icons.people_outline, 'تعداد کارکنان', '${_company!.employeeCount} نفر'),
      ]),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(textDirection: TextDirection.rtl, children: [
        Icon(icon, size: 18, color: const Color(0xFF6C757D)),
        const SizedBox(width: 8),
        Text('$label: ', style: const TextStyle(fontFamily: 'Vazir', fontSize: 13, color: Color(0xFFADB5BD))),
        Text(value, style: const TextStyle(fontFamily: 'Vazir', fontSize: 14, color: Color(0xFF495057))),
      ]),
    );
  }

  Widget _buildCompanyDescription() {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(top: 8),
      padding: const EdgeInsets.all(20),
      color: Colors.white,
      child: Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
        const Text('درباره شرکت', style: TextStyle(fontFamily: 'Vazir', fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF212529))),
        const SizedBox(height: 12),
        Text(_company!.description!, style: const TextStyle(fontFamily: 'Vazir', fontSize: 14, color: Color(0xFF495057), height: 1.8), textAlign: TextAlign.right),
      ]),
    );
  }

  Widget _buildJobsSection() {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(top: 8),
      padding: const EdgeInsets.all(20),
      color: Colors.white,
      child: Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
        const Text('شغل‌های این شرکت', style: TextStyle(fontFamily: 'Vazir', fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF212529))),
        const SizedBox(height: 12),
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
