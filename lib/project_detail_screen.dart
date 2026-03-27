import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../models/project.dart';
import '../utils/app_theme.dart';

class ProjectDetailScreen extends StatefulWidget {
  final Project project;
  const ProjectDetailScreen({super.key, required this.project});

  @override
  State<ProjectDetailScreen> createState() => _ProjectDetailScreenState();
}

class _ProjectDetailScreenState extends State<ProjectDetailScreen> {
  Color _statusColor() {
    final s = widget.project.status.toLowerCase();
    if (s.contains('complet') || s.contains('done')) return AppColors.success;
    if (s.contains('progress') || s.contains('active')) return AppColors.info;
    if (s.contains('pend') || s.contains('hold')) return AppColors.warning;
    if (s.contains('cancel') || s.contains('reject')) return AppColors.danger;
    return AppColors.textSecondary;
  }

  Color _payColor() {
    return widget.project.isPaid ? AppColors.success : AppColors.warning;
  }

  @override
  Widget build(BuildContext context) {
    final sc = _statusColor();
    final pc = _payColor();

    return Scaffold(
      backgroundColor: AppColors.background,
      body: CustomScrollView(
        slivers: [
          // Hero AppBar
          SliverAppBar(
            expandedHeight: 280,
            pinned: true,
            backgroundColor: AppColors.navy,
            foregroundColor: Colors.white,
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [AppColors.navy, sc.withOpacity(0.7)],
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
                              label: widget.project.status.isNotEmpty
                                  ? widget.project.status
                                  : 'Unknown',
                              color: sc,
                            ),
                            const SizedBox(width: 10),
                            _StatusPill(
                              label: widget.project.paymentStatus.isNotEmpty
                                  ? widget.project.paymentStatus
                                  : 'N/A',
                              color: pc,
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Text(
                          widget.project.projectTitle.isNotEmpty
                              ? widget.project.projectTitle
                              : 'Untitled Project',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 26,
                            fontWeight: FontWeight.w800,
                            height: 1.2,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 6),
                        Text(
                          widget.project.fullName.isNotEmpty
                              ? widget.project.fullName
                              : '—',
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.85),
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Invoice: ${widget.project.invoiceNo}',
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.6),
                            fontSize: 13,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            title: const Text(
              'Project Details',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
            ),
          ),

          // Body
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  // Fee Highlight Card
                  if (widget.project.feeAmount.isNotEmpty)
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(20),
                      margin: const EdgeInsets.only(bottom: 20),
                      decoration: BoxDecoration(
                        gradient: widget.project.isPaid
                            ? AppColors.successGradient
                            : AppColors.warningGradient,
                        borderRadius: BorderRadius.circular(24),
                        boxShadow: [
                          BoxShadow(
                            color: (widget.project.isPaid
                                    ? AppColors.success
                                    : AppColors.warning)
                                .withOpacity(0.3),
                            blurRadius: 20,
                            offset: const Offset(0, 8),
                          ),
                        ],
                      ),
                      child: Row(
                        children: [
                          Container(
                            width: 56,
                            height: 56,
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.2),
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              widget.project.isPaid
                                  ? Icons.check_circle_rounded
                                  : Icons.pending_rounded,
                              color: Colors.white,
                              size: 28,
                            ),
                          ),
                          const SizedBox(width: 18),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Fee Amount',
                                style: TextStyle(
                                  color: Colors.white70,
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              Text(
                                '₹ ${widget.project.feeAmount}',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 32,
                                  fontWeight: FontWeight.w900,
                                ),
                              ),
                            ],
                          ),
                          const Spacer(),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 6,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.white.withOpacity(0.2),
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: Text(
                                  widget.project.isPaid ? 'PAID' : 'PENDING',
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 12,
                                    fontWeight: FontWeight.w800,
                                    letterSpacing: 1,
                                  ),
                                ),
                              ),
                              if (widget.project.paymentMethod.isNotEmpty)
                                Padding(
                                  padding: const EdgeInsets.only(top: 6),
                                  child: Text(
                                    widget.project.paymentMethod,
                                    style: const TextStyle(
                                      color: Colors.white70,
                                      fontSize: 12,
                                    ),
                                  ),
                                ),
                            ],
                          ),
                        ],
                      ),
                    ),

                  // Customer Info
                  _InfoCard(
                    title: 'Customer Information',
                    icon: Icons.person_rounded,
                    rows: [
                      _InfoRow('Full Name', widget.project.fullName),
                      _InfoRow('Customer ID', widget.project.customerId),
                      _InfoRow('Roll / Role', widget.project.roll),
                      _InfoRow('Email', widget.project.email),
                      _InfoRow('Phone', widget.project.phone),
                    ],
                  ),
                  const SizedBox(height: 14),

                  // Project Info
                  _InfoCard(
                    title: 'Project Information',
                    icon: Icons.folder_rounded,
                    rows: [
                      _InfoRow('Invoice No', widget.project.invoiceNo),
                      _InfoRow('Project Title', widget.project.projectTitle),
                      _InfoRow('Service', widget.project.service),
                      _InfoRow('Project Status', widget.project.status),
                    ],
                  ),
                  const SizedBox(height: 14),

                  // Payment Info
                  _InfoCard(
                    title: 'Payment Information',
                    icon: Icons.payments_rounded,
                    rows: [
                      _InfoRow('Fee Amount', widget.project.feeAmount),
                      _InfoRow('Payment Status', widget.project.paymentStatus),
                      _InfoRow('Payment Method', widget.project.paymentMethod),
                      _InfoRow('Transaction ID', widget.project.transactionId,
                          copyable: true),
                      _InfoRow('Payment Date', widget.project.paymentDate),
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

class _StatusPill extends StatefulWidget {
  final String label;
  final Color color;
  const _StatusPill({required this.label, required this.color});

  @override
  State<_StatusPill> createState() => _StatusPillState();
}

class _StatusPillState extends State<_StatusPill> {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: widget.color.withOpacity(0.2),
        borderRadius: BorderRadius.circular(30),
        border: Border.all(color: widget.color.withOpacity(0.5)),
      ),
      child: Text(
        widget.label,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 12,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

class _InfoCard extends StatefulWidget {
  final String title;
  final IconData icon;
  final List<_InfoRow> rows;

  const _InfoCard({
    required this.title,
    required this.icon,
    required this.rows,
  });

  @override
  State<_InfoCard> createState() => _InfoCardState();
}

class _InfoCardState extends State<_InfoCard> {
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: AppShadows.soft,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(18, 16, 18, 12),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        AppColors.navy.withOpacity(0.1),
                        AppColors.navy.withOpacity(0.05),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(widget.icon, color: AppColors.navy, size: 18),
                ),
                const SizedBox(width: 12),
                Text(
                  widget.title,
                  style: AppTextStyles.titleMedium.copyWith(
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ],
            ),
          ),
          const Divider(height: 1, color: AppColors.divider),
          ...widget.rows.map((r) => r.build(context)).toList(),
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
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 130,
            child: Text(
              label,
              style: AppTextStyles.bodyMedium.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value.isNotEmpty ? value : '—',
              style: AppTextStyles.bodyLarge,
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
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                );
              },
              child: Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: AppColors.backgroundAlt,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(Icons.copy_rounded,
                    size: 16, color: AppColors.textMuted),
              ),
            ),
        ],
      ),
    );
  }
}