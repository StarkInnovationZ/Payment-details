import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../models/project.dart';
import '../utils/app_theme.dart';

class ProjectDetailScreen extends StatelessWidget {
  final Project project;
  const ProjectDetailScreen({super.key, required this.project});

  Color _statusColor() {
    final s = project.status.toLowerCase();
    if (s.contains('complet') || s.contains('done')) return AppColors.success;
    if (s.contains('progress') || s.contains('active')) return AppColors.info;
    if (s.contains('pend') || s.contains('hold')) return AppColors.warning;
    if (s.contains('cancel') || s.contains('reject')) return AppColors.danger;
    return AppColors.textSecondary;
  }

  Color _payColor() {
    return project.isPaid ? AppColors.success : AppColors.warning;
  }

  @override
  Widget build(BuildContext context) {
    final sc = _statusColor();
    final pc = _payColor();

    return Scaffold(
      backgroundColor: AppColors.background,
      body: CustomScrollView(
        slivers: [
          // ── Hero AppBar ──────────────────────────────────────────
          SliverAppBar(
            expandedHeight: 220,
            pinned: true,
            backgroundColor: AppColors.navy,
            foregroundColor: Colors.white,
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [AppColors.navy, sc.withOpacity(0.8)],
                  ),
                ),
                child: SafeArea(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(20, 56, 20, 20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Row(
                          children: [
                            _StatusPill(
                              label: project.status.isNotEmpty
                                  ? project.status
                                  : 'Unknown',
                              color: sc,
                            ),
                            const SizedBox(width: 8),
                            _StatusPill(
                              label: project.paymentStatus.isNotEmpty
                                  ? project.paymentStatus
                                  : 'N/A',
                              color: pc,
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),
                        Text(
                          project.projectTitle.isNotEmpty
                              ? project.projectTitle
                              : 'Untitled Project',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 22,
                            fontWeight: FontWeight.w800,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          project.fullName.isNotEmpty
                              ? project.fullName
                              : '—',
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.7),
                            fontSize: 15,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            title: Text(
              project.invoiceNo.isNotEmpty
                  ? 'INV: ${project.invoiceNo}'
                  : 'Project Detail',
              style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
            ),
          ),

          // ── Body ────────────────────────────────────────────────
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  // ── Fee highlight ──────────────────────────────
                  if (project.feeAmount.isNotEmpty)
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(20),
                      margin: const EdgeInsets.only(bottom: 16),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            project.isPaid
                                ? AppColors.success
                                : AppColors.warning,
                            project.isPaid
                                ? AppColors.success.withOpacity(0.7)
                                : AppColors.warning.withOpacity(0.7),
                          ],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: (project.isPaid
                                    ? AppColors.success
                                    : AppColors.warning)
                                .withOpacity(0.3),
                            blurRadius: 16,
                            offset: const Offset(0, 6),
                          ),
                        ],
                      ),
                      child: Row(
                        children: [
                          Container(
                            width: 48,
                            height: 48,
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.2),
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              project.isPaid
                                  ? Icons.check_circle_rounded
                                  : Icons.pending_rounded,
                              color: Colors.white,
                              size: 26,
                            ),
                          ),
                          const SizedBox(width: 16),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Fee Amount',
                                style: TextStyle(
                                  color: Colors.white70,
                                  fontSize: 12,
                                ),
                              ),
                              Text(
                                '₹ ${project.feeAmount}',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 26,
                                  fontWeight: FontWeight.w900,
                                ),
                              ),
                            ],
                          ),
                          const Spacer(),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Text(
                                project.isPaid ? '✓ PAID' : '⏳ PENDING',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w800,
                                  letterSpacing: 1,
                                ),
                              ),
                              if (project.paymentMethod.isNotEmpty)
                                Text(
                                  project.paymentMethod,
                                  style: const TextStyle(
                                    color: Colors.white70,
                                    fontSize: 12,
                                  ),
                                ),
                            ],
                          ),
                        ],
                      ),
                    ),

                  // ── Customer Info ──────────────────────────────
                  _InfoCard(
                    title: 'Customer Information',
                    icon: Icons.person_rounded,
                    rows: [
                      _InfoRow('Full Name', project.fullName),
                      _InfoRow('Customer ID', project.customerId),
                      _InfoRow('Roll / Role', project.roll),
                      _InfoRow('Email', project.email),
                      _InfoRow('Phone', project.phone),
                    ],
                  ),
                  const SizedBox(height: 12),

                  // ── Project Info ───────────────────────────────
                  _InfoCard(
                    title: 'Project Information',
                    icon: Icons.folder_rounded,
                    rows: [
                      _InfoRow('Invoice No', project.invoiceNo),
                      _InfoRow('Project Title', project.projectTitle),
                      _InfoRow('Service', project.service),
                      _InfoRow('Project Status', project.status),
                    ],
                  ),
                  const SizedBox(height: 12),

                  // ── Payment Info ───────────────────────────────
                  _InfoCard(
                    title: 'Payment Information',
                    icon: Icons.payments_rounded,
                    rows: [
                      _InfoRow('Fee Amount', project.feeAmount),
                      _InfoRow('Payment Status', project.paymentStatus),
                      _InfoRow('Payment Method', project.paymentMethod),
                      _InfoRow('Transaction ID', project.transactionId,
                          copyable: true),
                      _InfoRow('Payment Date', project.paymentDate),
                    ],
                  ),

                  const SizedBox(height: 30),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _StatusPill extends StatelessWidget {
  final String label;
  final Color color;
  const _StatusPill({required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.2),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withOpacity(0.5)),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: Colors.white,
          fontSize: 11,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

class _InfoCard extends StatelessWidget {
  final String title;
  final IconData icon;
  final List<_InfoRow> rows;

  const _InfoCard({
    required this.title,
    required this.icon,
    required this.rows,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 14, 16, 10),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(7),
                  decoration: BoxDecoration(
                    color: AppColors.navy.withOpacity(0.08),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(icon, color: AppColors.navy, size: 16),
                ),
                const SizedBox(width: 10),
                Text(title,
                    style: AppTextStyles.titleMedium
                        .copyWith(color: AppColors.navy)),
              ],
            ),
          ),
          Divider(height: 1, color: AppColors.divider),
          ...rows.map((r) => r.build(context)).toList(),
        ],
      ),
    );
  }
}

class _InfoRow {
  final String label;
  final String value;
  final bool copyable;

  const _InfoRow(this.label, this.value, {this.copyable = false});

  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 11),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 130,
            child: Text(
              label,
              style: AppTextStyles.bodyMedium,
            ),
          ),
          Expanded(
            child: Text(
              value.isNotEmpty ? value : '—',
              style: AppTextStyles.titleMedium,
            ),
          ),
          if (copyable && value.isNotEmpty)
            GestureDetector(
              onTap: () {
                Clipboard.setData(ClipboardData(text: value));
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Copied: $value'),
                    duration: const Duration(seconds: 2),
                    backgroundColor: AppColors.navy,
                    behavior: SnackBarBehavior.floating,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                );
              },
              child: const Icon(Icons.copy_rounded,
                  size: 16, color: AppColors.textMuted),
            ),
        ],
      ),
    );
  }
}
