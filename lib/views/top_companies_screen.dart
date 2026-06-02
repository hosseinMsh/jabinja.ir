import 'package:flutter/material.dart';
import '../presenters/job_presenter.dart';
import '../models/company.dart';
import '../models/job.dart';
import '../widgets/loading_widget.dart';

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
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        title: const Text('۵۰ شرکت برتر', style: TextStyle(fontFamily: 'Vazir', fontSize: 18, fontWeight: FontWeight.bold)),
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

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _companies.length,
      itemBuilder: (context, index) {
        final company = _companies[index];
        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          child: InkWell(
            onTap: () => Navigator.pushNamed(context, '/company', arguments: company.slug),
            borderRadius: BorderRadius.circular(12),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                textDirection: TextDirection.rtl,
                children: [
                  Container(
                    width: 56, height: 56,
                    decoration: BoxDecoration(color: const Color(0xFFE8F0FE), borderRadius: BorderRadius.circular(12)),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(11),
                      child: Image.network(
                        company.logoUrl ?? '',
                        fit: BoxFit.contain,
                        errorBuilder: (_, __, ___) => const Center(child: Icon(Icons.business_rounded, color: Color(0xFF4A90D9), size: 32)),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
                      Text(company.name, style: const TextStyle(fontFamily: 'Vazir', fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF212529)), textAlign: TextAlign.right),
                      if (company.industry != null)
                        Padding(
                          padding: const EdgeInsets.only(top: 4),
                          child: Text(company.industry!, style: const TextStyle(fontFamily: 'Vazir', fontSize: 13, color: Color(0xFF6C757D)), textAlign: TextAlign.right),
                        ),
                    ]),
                  ),
                  Container(
                    width: 32, height: 32,
                    decoration: BoxDecoration(
                      color: index < 3 ? const Color(0xFFFFD700).withAlpha(38) : const Color(0xFFF8F9FA),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Center(
                      child: Text('${index + 1}', style: TextStyle(
                        fontFamily: 'Vazir', fontSize: 14, fontWeight: FontWeight.bold,
                        color: index < 3 ? const Color(0xFFB8860B) : const Color(0xFFADB5BD),
                      )),
                    ),
                  ),
                ],
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
