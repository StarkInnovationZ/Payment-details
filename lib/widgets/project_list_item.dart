import 'package:flutter/material.dart';
import '../../models/project.dart';
import '../../utils/app_theme.dart';

class ProjectListItem extends StatefulWidget {
  final Project project;
  final int index;
  final VoidCallback onTap;

  const ProjectListItem({
    super.key,
    required this.project,
    required this.index,
    required this.onTap,
  });

  @override
  State<ProjectListItem> createState() => _ProjectListItemState();
}

class _ProjectListItemState extends State<ProjectListItem> {
  Color _statusColor() {
    final s = widget.project.status.toLowerCase();
    if (s.contains('complet') || s.contains('done')) return AppColors.success;
    if (s.contains('progress') || s.contains('active')) return AppColors.info;
    if (s.contains('pend') || s.contains('hold')) return AppColors.warning;
    if (s.contains('cancel') || s.contains('reject')) return AppColors.danger;
    return AppColors.textMuted;
  }

  @override
  Widget build(BuildContext context) {
    final sc = _statusColor();
    final displayNo = widget.project.sNo.isNotEmpty ? widget.project.sNo : '${widget.index + 1}';

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: widget.onTap,
          borderRadius: BorderRadius.circular(20),
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              boxShadow: AppShadows.soft,
            ),
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      // Premium S.No Badge
                      Container(
                        width: 36,
                        height: 36,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              AppColors.navy.withOpacity(0.1),
                              AppColors.navy.withOpacity(0.05),
                            ],
                          ),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Center(
                          child: Text(
                            displayNo,
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w800,
                              color: AppColors.navy,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 14),
                      
                      // Content
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Expanded(
                                  child: Text(
                                    widget.project.fullName.isNotEmpty
                                        ? widget.project.fullName
                                        : 'Unknown',
                                    style: AppTextStyles.titleMedium,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                                _PayBadge(isPaid: widget.project.isPaid),
                              ],
                            ),
                            const SizedBox(height: 4),
                            if (widget.project.projectTitle.isNotEmpty)
                              Text(
                                widget.project.projectTitle,
                                style: AppTextStyles.bodyMedium,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            const SizedBox(height: 10),
                            Row(
                              children: [
                                if (widget.project.customerId.isNotEmpty)
                                  _MiniChip(
                                    icon: Icons.badge_rounded,
                                    label: widget.project.customerId,
                                    color: AppColors.infoBg,
                                    textColor: AppColors.info,
                                  ),
                                if (widget.project.customerId.isNotEmpty)
                                  const SizedBox(width: 8),
                                _MiniChip(
                                  icon: Icons.circle,
                                  label: widget.project.status.isNotEmpty
                                      ? widget.project.status
                                      : 'N/A',
                                  color: sc.withOpacity(0.12),
                                  textColor: sc,
                                  iconSize: 8,
                                ),
                                const Spacer(),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 10,
                                    vertical: 4,
                                  ),
                                  decoration: BoxDecoration(
                                    color: AppColors.backgroundAlt,
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Text(
                                    '₹${widget.project.feeAmount}',
                                    style: const TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w800,
                                      color: AppColors.textPrimary,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 8),
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
                    ],
                  ),
                ),
                // Status Bar Indicator
                Container(
                  height: 3,
                  decoration: BoxDecoration(
                    color: sc.withOpacity(0.3),
                    borderRadius: const BorderRadius.only(
                      bottomLeft: Radius.circular(20),
                      bottomRight: Radius.circular(20),
                    ),
                  ),
                  child: FractionallySizedBox(
                    widthFactor: 0.7,
                    child: Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [sc, sc.withOpacity(0.5)],
                        ),
                        borderRadius: const BorderRadius.only(
                          bottomLeft: Radius.circular(20),
                          bottomRight: Radius.circular(20),
                        ),
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
  }
}

class _PayBadge extends StatefulWidget {
  final bool isPaid;
  const _PayBadge({required this.isPaid});

  @override
  State<_PayBadge> createState() => _PayBadgeState();
}

class _PayBadgeState extends State<_PayBadge> {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        gradient: widget.isPaid ? AppColors.successGradient : AppColors.warningGradient,
        borderRadius: BorderRadius.circular(20),
        boxShadow: AppShadows.soft,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            widget.isPaid ? Icons.check_circle_rounded : Icons.schedule_rounded,
            size: 12,
            color: Colors.white,
          ),
          const SizedBox(width: 4),
          Text(
            widget.isPaid ? 'Paid' : 'Unpaid',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 11,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

class _MiniChip extends StatefulWidget {
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
  State<_MiniChip> createState() => _MiniChipState();
}

class _MiniChipState extends State<_MiniChip> {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: widget.color,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(widget.icon, size: widget.iconSize, color: widget.textColor),
          const SizedBox(width: 4),
          Text(
            widget.label,
            style: TextStyle(
              color: widget.textColor,
              fontSize: 11,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}