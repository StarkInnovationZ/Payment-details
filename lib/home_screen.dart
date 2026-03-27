import 'package:flutter/material.dart';
import '../models/project.dart';
import '../services/api_service.dart';
import '../utils/app_theme.dart';
import '../widgets/summary_card.dart';
import '../widgets/project_list_item.dart';
import 'project_detail_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen>
    with SingleTickerProviderStateMixin {
  late Future<List<Project>> _future;
  final TextEditingController _searchCtrl = TextEditingController();
  String _searchQuery = '';
  String _statusFilter = 'All';
  String _paymentFilter = 'All';
  late AnimationController _headerAnim;
  late Animation<double> _headerOpacity;
  late Animation<Offset> _headerSlide;

  @override
  void initState() {
    super.initState();
    _future = ApiService.fetchProjects();
    _headerAnim = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _headerOpacity = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _headerAnim, curve: Curves.easeIn),
    );
    _headerSlide = Tween<Offset>(
      begin: const Offset(0, -0.2),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _headerAnim, curve: Curves.easeOut));
    _headerAnim.forward();
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    _headerAnim.dispose();
    super.dispose();
  }

  void _refresh() {
    setState(() => _future = ApiService.fetchProjects());
  }

  List<Project> _filter(List<Project> all) {
    return all.where((p) {
      final q = _searchQuery.toLowerCase();
      final matchQ = q.isEmpty ||
          p.fullName.toLowerCase().contains(q) ||
          p.customerId.toLowerCase().contains(q) ||
          p.projectTitle.toLowerCase().contains(q) ||
          p.invoiceNo.toLowerCase().contains(q);

      final matchS = _statusFilter == 'All' ||
          p.status.toLowerCase().contains(_statusFilter.toLowerCase());

      final matchP = _paymentFilter == 'All' ||
          (_paymentFilter == 'Paid' && p.isPaid) ||
          (_paymentFilter == 'Unpaid' && !p.isPaid);

      return matchQ && matchS && matchP;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: FutureBuilder<List<Project>>(
        future: _future,
        builder: (ctx, snap) {
          if (snap.connectionState == ConnectionState.waiting) {
            return _buildLoading();
          }
          if (snap.hasError) {
            return _buildError(snap.error.toString());
          }
          final projects = snap.data ?? [];
          final filtered = _filter(projects);
          return _buildContent(projects, filtered);
        },
      ),
    );
  }

  Widget _buildLoading() {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF0A2540), Color(0xFF1A3A5C)],
        ),
      ),
      child: const Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircularProgressIndicator(
              color: AppColors.gold,
              strokeWidth: 3,
            ),
            SizedBox(height: 20),
            Text(
              'Fetching data from server…',
              style: TextStyle(color: Colors.white60, fontSize: 14),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildError(String error) {
    return Container(
      color: AppColors.background,
      padding: const EdgeInsets.all(32),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: AppColors.dangerBg,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.cloud_off_rounded,
                color: AppColors.danger,
                size: 36,
              ),
            ),
            const SizedBox(height: 20),
            const Text('Connection Failed', style: AppTextStyles.displayMedium),
            const SizedBox(height: 8),
            Text(
              'Could not reach the server.\nCheck your internet connection.',
              textAlign: TextAlign.center,
              style: AppTextStyles.bodyMedium,
            ),
            const SizedBox(height: 6),
            Text(
              error,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 11,
                color: AppColors.textMuted,
              ),
            ),
            const SizedBox(height: 28),
            ElevatedButton.icon(
              onPressed: _refresh,
              icon: const Icon(Icons.refresh_rounded),
              label: const Text('Retry'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.navy,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                    horizontal: 28, vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContent(List<Project> all, List<Project> filtered) {
    final totalFee = all.fold<double>(0, (s, p) => s + p.feeDouble);
    final paidFee = all
        .where((p) => p.isPaid)
        .fold<double>(0, (s, p) => s + p.feeDouble);
    final paidCount = all.where((p) => p.isPaid).length;
    final unpaidCount = all.where((p) => !p.isPaid).length;
    final completedCount = all.where((p) => p.isCompleted).length;
    final pendingCount = all.where((p) => p.isPending).length;

    return CustomScrollView(
      slivers: [
        // ── App Bar ─────────────────────────────────────────────────
        SliverAppBar(
          expandedHeight: 200,
          pinned: true,
          backgroundColor: AppColors.navy,
          flexibleSpace: FlexibleSpaceBar(
            background: _buildAppBarBg(all),
          ),
          title: AnimatedBuilder(
            animation: _headerAnim,
            builder: (_, __) => FadeTransition(
              opacity: _headerOpacity,
              child: const Text(
                'CFO TRACKER',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w900,
                  fontSize: 18,
                  letterSpacing: 2,
                ),
              ),
            ),
          ),
          actions: [
            IconButton(
              icon: const Icon(Icons.refresh_rounded, color: Colors.white),
              onPressed: _refresh,
              tooltip: 'Refresh',
            ),
            const SizedBox(width: 4),
          ],
        ),

        // ── Summary Cards ────────────────────────────────────────────
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Financial Overview',
                    style: AppTextStyles.titleLarge),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: SummaryCard(
                        label: 'Total Revenue',
                        value: '₹${_fmt(totalFee)}',
                        icon: Icons.currency_rupee_rounded,
                        color: AppColors.navy,
                        textColor: Colors.white,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: SummaryCard(
                        label: 'Collected',
                        value: '₹${_fmt(paidFee)}',
                        icon: Icons.check_circle_outline_rounded,
                        color: AppColors.success,
                        textColor: Colors.white,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    Expanded(
                      child: SummaryCard(
                        label: 'Paid',
                        value: '$paidCount clients',
                        icon: Icons.verified_rounded,
                        color: AppColors.infoBg,
                        textColor: AppColors.info,
                        borderColor: AppColors.info.withOpacity(0.3),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: SummaryCard(
                        label: 'Pending',
                        value: '$unpaidCount clients',
                        icon: Icons.pending_actions_rounded,
                        color: AppColors.warningBg,
                        textColor: AppColors.warning,
                        borderColor: AppColors.warning.withOpacity(0.3),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: SummaryCard(
                        label: 'Done',
                        value: '$completedCount',
                        icon: Icons.task_alt_rounded,
                        color: AppColors.successBg,
                        textColor: AppColors.success,
                        borderColor: AppColors.success.withOpacity(0.3),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),

        // ── Search + Filters ─────────────────────────────────────────
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 20, 16, 0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('All Projects', style: AppTextStyles.titleLarge),
                const SizedBox(height: 12),

                // Search bar
                Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(14),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.06),
                        blurRadius: 10,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                  child: TextField(
                    controller: _searchCtrl,
                    onChanged: (v) => setState(() => _searchQuery = v),
                    decoration: InputDecoration(
                      hintText: 'Search by name, ID, invoice…',
                      hintStyle: const TextStyle(
                        color: AppColors.textMuted,
                        fontSize: 14,
                      ),
                      prefixIcon: const Icon(
                        Icons.search_rounded,
                        color: AppColors.textMuted,
                      ),
                      suffixIcon: _searchQuery.isNotEmpty
                          ? IconButton(
                              icon: const Icon(Icons.close_rounded,
                                  color: AppColors.textMuted),
                              onPressed: () {
                                _searchCtrl.clear();
                                setState(() => _searchQuery = '');
                              },
                            )
                          : null,
                      border: InputBorder.none,
                      contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 14),
                    ),
                  ),
                ),
                const SizedBox(height: 12),

                // Filter chips row
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      _buildFilterLabel('Status:'),
                      _buildChip('All', _statusFilter == 'All',
                          () => setState(() => _statusFilter = 'All')),
                      _buildChip(
                          'In Progress',
                          _statusFilter == 'In Progress',
                          () => setState(() => _statusFilter = 'In Progress')),
                      _buildChip(
                          'Completed',
                          _statusFilter == 'Completed',
                          () => setState(() => _statusFilter = 'Completed')),
                      _buildChip(
                          'Pending',
                          _statusFilter == 'Pending',
                          () => setState(() => _statusFilter = 'Pending')),
                      const SizedBox(width: 8),
                      _buildFilterLabel('Pay:'),
                      _buildChip('All', _paymentFilter == 'All',
                          () => setState(() => _paymentFilter = 'All')),
                      _buildChip('Paid', _paymentFilter == 'Paid',
                          () => setState(() => _paymentFilter = 'Paid')),
                      _buildChip('Unpaid', _paymentFilter == 'Unpaid',
                          () => setState(() => _paymentFilter = 'Unpaid')),
                    ],
                  ),
                ),
                const SizedBox(height: 10),

                Text(
                  '${filtered.length} of ${all.length} records',
                  style: AppTextStyles.labelSmall,
                ),
                const SizedBox(height: 8),
              ],
            ),
          ),
        ),

        // ── Project List ─────────────────────────────────────────────
        filtered.isEmpty
            ? SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(40),
                  child: Column(
                    children: [
                      Icon(Icons.search_off_rounded,
                          size: 56, color: AppColors.textMuted),
                      const SizedBox(height: 12),
                      Text('No projects found',
                          style: AppTextStyles.bodyMedium),
                    ],
                  ),
                ),
              )
            : SliverList(
                delegate: SliverChildBuilderDelegate(
                  (ctx, i) {
                    final p = filtered[i];
                    return ProjectListItem(
                      project: p,
                      index: i,
                      onTap: () => Navigator.push(
                        ctx,
                        MaterialPageRoute(
                          builder: (_) => ProjectDetailScreen(project: p),
                        ),
                      ),
                    );
                  },
                  childCount: filtered.length,
                ),
              ),

        const SliverToBoxAdapter(child: SizedBox(height: 30)),
      ],
    );
  }

  Widget _buildAppBarBg(List<Project> all) {
    final totalFee = all.fold<double>(0, (s, p) => s + p.feeDouble);
    final paidFee =
        all.where((p) => p.isPaid).fold<double>(0, (s, p) => s + p.feeDouble);
    final pct = totalFee > 0 ? (paidFee / totalFee).clamp(0, 1) : 0.0;

    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF0A2540), Color(0xFF1A3A5C), Color(0xFF0D3060)],
        ),
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 56, 20, 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Row(
                children: [
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: AppColors.gold.withOpacity(0.2),
                      border: Border.all(color: AppColors.gold, width: 1.5),
                    ),
                    child: const Icon(Icons.person_rounded,
                        color: AppColors.gold, size: 22),
                  ),
                  const SizedBox(width: 12),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Welcome back,',
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.6),
                          fontSize: 13,
                        ),
                      ),
                      const Text(
                        'Tarun',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ],
                  ),
                  const Spacer(),
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 10, vertical: 5),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                          color: Colors.white.withOpacity(0.2)),
                    ),
                    child: const Row(
                      children: [
                        Icon(Icons.shield_rounded,
                            color: AppColors.gold, size: 14),
                        SizedBox(width: 4),
                        Text(
                          'CFO',
                          style: TextStyle(
                            color: AppColors.gold,
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),

              // Collection progress
              if (all.isNotEmpty) ...[
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Collection Rate',
                      style: TextStyle(
                          color: Colors.white.withOpacity(0.6), fontSize: 12),
                    ),
                    Text(
                      '${(pct * 100).toStringAsFixed(1)}%',
                      style: const TextStyle(
                        color: AppColors.gold,
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: LinearProgressIndicator(
                    value: pct.toDouble(),
                    backgroundColor: Colors.white.withOpacity(0.15),
                    valueColor:
                        const AlwaysStoppedAnimation<Color>(AppColors.gold),
                    minHeight: 6,
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFilterLabel(String text) {
    return Padding(
      padding: const EdgeInsets.only(right: 6, left: 2),
      child: Text(text, style: AppTextStyles.labelSmall),
    );
  }

  Widget _buildChip(String label, bool selected, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        margin: const EdgeInsets.only(right: 6),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: selected ? AppColors.navy : Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: selected ? AppColors.navy : AppColors.divider,
          ),
          boxShadow: selected
              ? [
                  BoxShadow(
                    color: AppColors.navy.withOpacity(0.2),
                    blurRadius: 6,
                    offset: const Offset(0, 2),
                  )
                ]
              : [],
        ),
        child: Text(
          label,
          style: TextStyle(
            color: selected ? Colors.white : AppColors.textSecondary,
            fontSize: 12,
            fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
          ),
        ),
      ),
    );
  }

  String _fmt(double v) {
    if (v >= 100000) {
      return '${(v / 100000).toStringAsFixed(1)}L';
    } else if (v >= 1000) {
      return '${(v / 1000).toStringAsFixed(1)}K';
    }
    return v.toStringAsFixed(0);
  }
}
