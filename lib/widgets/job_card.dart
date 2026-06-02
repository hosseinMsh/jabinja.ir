import 'package:flutter/material.dart';
import '../models/job.dart';

class JobCard extends StatelessWidget {
  final Job job;
  final VoidCallback? onTap;
  final VoidCallback? onFavoriteTap;
  final bool isFavorited;

  const JobCard({
    super.key,
    required this.job,
    this.onTap,
    this.onFavoriteTap,
    this.isFavorited = false,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      elevation: 1,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: job.isPremium ? const Color(0xFF4A90D9).withValues(alpha: 0.2) : const Color(0xFFE9ECEF),
        ),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              if (job.isPremium) _buildPremiumBadge(),
              Row(
                textDirection: TextDirection.rtl,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildCompanyLogo(),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          job.title,
                          style: TextStyle(
                            fontFamily: 'Vazir',
                            fontSize: 15,
                            fontWeight: job.isPremium ? FontWeight.bold : FontWeight.w600,
                            color: const Color(0xFF212529),
                          ),
                          textAlign: TextAlign.right,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          job.company.name,
                          style: const TextStyle(
                            fontFamily: 'Vazir',
                            fontSize: 13,
                            color: Color(0xFF6C757D),
                          ),
                          textAlign: TextAlign.right,
                        ),
                      ],
                    ),
                  ),
                  if (onFavoriteTap != null)
                    GestureDetector(
                      onTap: onFavoriteTap,
                      child: Container(
                        padding: const EdgeInsets.all(4),
                        child: Icon(
                          isFavorited ? Icons.bookmark : Icons.bookmark_border,
                          size: 22,
                          color: isFavorited ? const Color(0xFF4A90D9) : const Color(0xFFADB5BD),
                        ),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 12),
              Wrap(
                spacing: 8,
                runSpacing: 4,
                textDirection: TextDirection.rtl,
                children: [
                  _buildInfoChip(Icons.location_on_outlined, job.location),
                  if (job.contractType != null)
                    _buildInfoChip(Icons.work_outline, job.contractType!),
                  if (job.salaryDisplay != null)
                    _buildInfoChip(Icons.monetization_on_outlined, job.salaryDisplay!),
                  if (job.isRemote)
                    _buildInfoChip(Icons.wifi, 'دورکاری'),
                  if (job.relativeTime != null)
                    _buildInfoChip(Icons.access_time, job.relativeTime!),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPremiumBadge() {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      child: Row(
        textDirection: TextDirection.rtl,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF4A90D9), Color(0xFF357ABD)],
              ),
              borderRadius: BorderRadius.circular(6),
            ),
            child: const Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.star, size: 12, color: Colors.white),
                SizedBox(width: 4),
                Text(
                  'ویژه',
                  style: TextStyle(
                    fontFamily: 'Vazir',
                    fontSize: 10,
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCompanyLogo() {
    return Container(
      width: 48,
      height: 48,
      decoration: BoxDecoration(
        color: const Color(0xFFE8F0FE),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: const Color(0xFFDEE2E6)),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(9),
        child: Image.network(
          job.company.logoUrl ?? '',
          fit: BoxFit.contain,
          errorBuilder: (context, error, stackTrace) {
            return const Center(
              child: Icon(Icons.business_rounded, color: Color(0xFF4A90D9), size: 28),
            );
          },
          loadingBuilder: (context, child, loadingProgress) {
            if (loadingProgress == null) return child;
            return const Center(
              child: SizedBox(
                width: 20, height: 20,
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildInfoChip(IconData icon, String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: const Color(0xFFF8F9FA),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            text,
            style: const TextStyle(
              fontFamily: 'Vazir',
              fontSize: 12,
              color: Color(0xFF495057),
            ),
          ),
          const SizedBox(width: 4),
          Icon(icon, size: 14, color: const Color(0xFF6C757D)),
        ],
      ),
    );
  }
}
