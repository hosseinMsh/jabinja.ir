import 'package:flutter/material.dart';
import '../models/job.dart';
import '../utils/constants.dart';

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
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 5),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppRadius.md),
        border: Border.all(
          color: job.isPremium ? AppColors.primary.withValues(alpha: 0.15) : AppColors.border,
          width: job.isPremium ? 1.5 : 0.5,
        ),
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(AppRadius.md),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(AppRadius.md),
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
                              fontFamily: AppTypography.fontFamily,
                              fontSize: 15,
                              fontWeight: job.isPremium ? FontWeight.bold : FontWeight.w600,
                              color: AppColors.textPrimary,
                            ),
                            textAlign: TextAlign.right,
                          ),
                          const SizedBox(height: 4),
                          Text(
                            job.company.name,
                            style: AppTypography.bodySmall,
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
                            color: isFavorited ? AppColors.primary : AppColors.textMuted,
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
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [AppColors.primary, AppColors.primaryDark],
              ),
              borderRadius: BorderRadius.circular(20),
            ),
            child: const Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.star, size: 12, color: Colors.white),
                SizedBox(width: 4),
                Text(
                  'ویژه',
                  style: TextStyle(
                    fontFamily: AppTypography.fontFamily,
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
        color: AppColors.primaryLight,
        borderRadius: BorderRadius.circular(AppRadius.md),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(AppRadius.md - 1),
        child: Image.network(
          job.company.logoUrl ?? '',
          fit: BoxFit.contain,
          errorBuilder: (context, error, stackTrace) {
            return const Center(
              child: Icon(Icons.business_rounded, color: AppColors.primary, size: 28),
            );
          },
          loadingBuilder: (context, child, loadingProgress) {
            if (loadingProgress == null) return child;
            return const Center(
              child: SizedBox(
                width: 20, height: 20,
                child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.primary),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildInfoChip(IconData icon, String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(AppRadius.full),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            text,
            style: AppTypography.bodySmall.copyWith(
              color: AppColors.textPrimary,
              fontSize: 11,
            ),
          ),
          const SizedBox(width: 4),
          Icon(icon, size: 13, color: AppColors.textMuted),
        ],
      ),
    );
  }
}
