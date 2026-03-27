import 'package:flutter/material.dart';
import '../../models/project.dart';
import '../../utils/app_theme.dart';

class ProjectListItem extends StatelessWidget {
  final Project project;
  final int index;
  final VoidCallback onTap;

  const ProjectListItem({
    super.key,
    required this.project,
    required this.index,
    required this.onTap,
  });

  Color _statusColor() {
    final s = project.status.toLowerCase();
    if (s.contains('complet') || s.contains('done')) return AppColors.success;
    if (s.contains('progress') || s.contains('active')) return AppColors.info;
    if (s.contains('pend') || s.contains('hold')) return AppColors.warning;
    if (s.contains('cancel') || s.contains('reject')) return AppColors.danger;
    return AppColors.textMuted;
  }

  @override
  Widget build(BuildContext context) {
    final sc = _statusColor();

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 10),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 10,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: IntrinsicHeight(
            child: Row(
              children: [
                // Color bar
                Container(
                  width: 4,
                  decoration: BoxDecoration(
                    color: sc,
                    borderRadius: const BorderRadius.horizontal(
                      left: Radius.circular(16),
                    ),
                  ),
                ),

                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(14),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Row 1: Name + Pay badge
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              child: Text(
                                project.fullName.isNotEmpty
                                    ? project.fullName
                                    : 'Unknown',
                                style: AppTextStyles.titleMedium,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            const SizedBox(width: 8),
                            _PayBadge(isPaid: project.isPaid),
                          ],
                        ),
                        const SizedBox(height: 3),

                        // Project title
                        if (project.projectTitle.isNotEmpty)
                          Text(
                            project.projectTitle,
                            style: AppTextStyles.bodyMedium,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),

                        const SizedBox(height: 8),

                        // Row 3: ID + Status + Amount
                        Row(
                          children: [
                            // Customer ID
                            if (project.customerId.isNotEmpty)
                              _MiniChip(
                                icon: Icons.badge_rounded,
                                label: project.customerId,
                                color: AppColors.infoBg,
                                textColor: AppColors.info,
                              ),
                            if (project.customerId.isNotEmpty)
                              const SizedBox(width: 6),

                            // Status
                            _MiniChip(
                              icon: Icons.circle,
                              label: project.status.isNotEmpty
                                  ? project.status
                                  : 'N/A',
                              color: sc.withOpacity(0.12),
                              textColor: sc,
                              iconSize: 8,
                            ),

                            const Spacer(),

                            // Amount
                            if (project.feeAmount.isNotEmpty)
                              Text(
                                '₹${project.feeAmount}',
                                style: const TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w800,
                                  color: AppColors.textPrimary,
                                ),
                              ),

                            const SizedBox(width: 6),
                            const Icon(
                              Icons.chevron_right_rounded,
                              color: AppColors.textMuted,
                              size: 18,
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _PayBadge extends StatelessWidget {
  final bool isPaid;
  const _PayBadge({required this.isPaid});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: isPaid ? AppColors.successBg : AppColors.warningBg,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isPaid
              ? AppColors.success.withOpacity(0.4)
              : AppColors.warning.withOpacity(0.4),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            isPaid ? Icons.check_circle_rounded : Icons.schedule_rounded,
            size: 11,
            color: isPaid ? AppColors.success : AppColors.warning,
          ),
          const SizedBox(width: 3),
          Text(
            isPaid ? 'Paid' : 'Unpaid',
            style: TextStyle(
              color: isPaid ? AppColors.success : AppColors.warning,
              fontSize: 11,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

class _MiniChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final Color textColor;
  final double iconSize;

  const _MiniChip({
    required this.icon,
    required this.label,
    required this.color,
    required this.textColor,
    this.iconSize = 12,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: iconSize, color: textColor),
          const SizedBox(width: 3),
          Text(
            label,
            style: TextStyle(
              color: textColor,
              fontSize: 11,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
