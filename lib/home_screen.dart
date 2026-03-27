import 'package:flutter/material.dart';
import '../models/project.dart';
import '../services/api_service.dart';
import '../utils/app_theme.dart';
import '../widgets/summary_card.dart';
import '../widgets/project_list_item.dart';
import 'project_detail_screen.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';

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
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _future = ApiService.fetchProjects();
    _headerAnim = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _headerOpacity = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _headerAnim, curve: Curves.easeOut),
    );
    _headerSlide = Tween<Offset>(
      begin: const Offset(0, -0.1),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _headerAnim, curve: Curves.easeOutCubic));
    _headerAnim.forward();
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    _headerAnim.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _refresh() {
    setState(() {
      _future = ApiService.fetchProjects();
    });
  }

  void _onSummaryCardTapped(String paymentFilter, String statusFilter) {
    _searchCtrl.clear();
    setState(() {
      _searchQuery = '';
      _paymentFilter = paymentFilter;
      _statusFilter = statusFilter;
    });

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 500),
          curve: Curves.easeOutCubic,
        );
      }
    });
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

  double _parseAmount(String val) {
    if (val.isEmpty) return 0.0;
    val = val.replaceAll('₹', '').replaceAll('/-', '').trim();
    double total = 0.0;
    final parts = val.split(RegExp(r'[+&]'));
    for (final part in parts) {
      final cleaned = part.replaceAll(RegExp(r'[^0-9.]'), '');
      if (cleaned.isNotEmpty) {
        total += double.tryParse(cleaned) ?? 0.0;
      }
    }
    return total;
  }

  String _fmt(double v) => v.toStringAsFixed(2);

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
        gradient: AppColors.primaryGradient,
      ),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(
              width: 40,
              height: 40,
              child: CircularProgressIndicator(
                strokeWidth: 3,
                valueColor: AlwaysStoppedAnimation<Color>(AppColors.gold),
              ),
            ),
            const SizedBox(height: 20),
            Text(
              'Fetching your data...',
              style: TextStyle(
                color: Colors.white.withOpacity(0.7),
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildError(String error) {
    final isNetworkError = error.toLowerCase().contains('network') ||
        error.toLowerCase().contains('timeout');

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
                gradient: AppColors.warningGradient,
                shape: BoxShape.circle,
              ),
              child: Icon(
                isNetworkError
                    ? Icons.cloud_off_rounded
                    : Icons.error_outline_rounded,
                color: Colors.white,
                size: 36,
              ),
            ),
            const SizedBox(height: 20),
            Text(
              isNetworkError ? 'Connection Failed' : 'Data Error',
              style: AppTextStyles.displayMedium,
            ),
            const SizedBox(height: 8),
            Text(
              isNetworkError
                  ? 'Unable to reach the server.\nPlease check your connection.'
                  : 'Something went wrong while loading your data.',
              textAlign: TextAlign.center,
              style: AppTextStyles.bodyMedium,
            ),
            const SizedBox(height: 28),
            ElevatedButton.icon(
              onPressed: _refresh,
              icon: const Icon(Icons.refresh_rounded),
              label: const Text('Try Again'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.navy,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
                elevation: 2,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContent(List<Project> all, List<Project> filtered) {
    final totalFee = all.fold<double>(0, (s, p) => s + _parseAmount(p.feeAmount));
    final paidFee = all
        .where((p) => p.isPaid)
        .fold<double>(0, (s, p) => s + _parseAmount(p.feeAmount));
    final unpaidFee = totalFee - paidFee;
    final paidCount = all.where((p) => p.isPaid).length;
    final unpaidCount = all.where((p) => !p.isPaid).length;

    return CustomScrollView(
      controller: _scrollController,
      slivers: [
        // Premium App Bar
        SliverAppBar(
          expandedHeight: 220,
          pinned: true,
          backgroundColor: AppColors.navy,
          flexibleSpace: FlexibleSpaceBar(
            background: _buildPremiumAppBar(all, totalFee, paidFee),
          ),
          title: AnimatedBuilder(
            animation: _headerAnim,
            builder: (_, __) => FadeTransition(
              opacity: _headerOpacity,
              child: SlideTransition(
                position: _headerSlide,
                child: const Text(
                  'Operation TRACKER',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w900,
                    fontSize: 18,
                    letterSpacing: 2,
                  ),
                ),
              ),
            ),
          ),
          actions: [
            const SizedBox(width: 8),
            IconButton(
              icon: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(Icons.refresh_rounded, color: Colors.white, size: 20),
              ),
              onPressed: _refresh,
              tooltip: 'Refresh',
            ),
            const SizedBox(width: 12),
          ],
        ),

        // Summary Cards Section
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 20, 16, 0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Financial Overview',
                  style: AppTextStyles.titleLarge.copyWith(
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: _TappableCard(
                        isActive: _paymentFilter == 'All' && _statusFilter == 'All',
                        onTap: () => _onSummaryCardTapped('All', 'All'),
                        child: SummaryCard(
                          label: 'Total Portfolio',
                          value: '₹${_fmt(totalFee)}',
                          icon: Icons.account_balance_wallet_rounded,
                          color: AppColors.navy,
                          textColor: Colors.white,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _TappableCard(
                        isActive: _paymentFilter == 'Paid',
                        onTap: () => _onSummaryCardTapped('Paid', 'All'),
                        child: SummaryCard(
                          label: 'Collected',
                          value: '₹${_fmt(paidFee)}',
                          icon: Icons.check_circle_outline_rounded,
                          color: AppColors.success,
                          textColor: Colors.white,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: _TappableCard(
                        isActive: _paymentFilter == 'Unpaid',
                        onTap: () => _onSummaryCardTapped('Unpaid', 'All'),
                        child: SummaryCard(
                          label: 'Pending Collection',
                          value: '₹${_fmt(unpaidFee)}',
                          icon: Icons.pending_actions_rounded,
                          color: AppColors.warning,
                          textColor: Colors.white,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _TappableCard(
                        isActive: false,
                        onTap: () {},
                        child: SummaryCard(
                          label: 'Collection Rate',
                          value: totalFee > 0
                              ? '${((paidFee / totalFee) * 100).toStringAsFixed(1)}%'
                              : '0%',
                          icon: Icons.trending_up_rounded,
                          color: AppColors.info,
                          textColor: Colors.white,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: _TappableCard(
                        isActive: _paymentFilter == 'Unpaid',
                        onTap: () => _onSummaryCardTapped('Unpaid', 'All'),
                        child: SummaryCard(
                          label: 'Pending Clients',
                          value: '$unpaidCount',
                          icon: Icons.people_outline_rounded,
                          color: AppColors.warningBg,
                          textColor: AppColors.warning,
                          borderColor: AppColors.warning.withOpacity(0.3),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _TappableCard(
                        isActive: _paymentFilter == 'Paid',
                        onTap: () => _onSummaryCardTapped('Paid', 'All'),
                        child: SummaryCard(
                          label: 'Completed Clients',
                          value: '$paidCount',
                          icon: Icons.verified_rounded,
                          color: AppColors.successBg,
                          textColor: AppColors.success,
                          borderColor: AppColors.success.withOpacity(0.3),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),

        // Search & Filters
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 24, 16, 0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (_paymentFilter != 'All' || _statusFilter != 'All')
                  Container(
                    margin: const EdgeInsets.only(bottom: 16),
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    decoration: BoxDecoration(
                      color: AppColors.navy.withOpacity(0.05),
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: AppColors.navy.withOpacity(0.1)),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.filter_alt_rounded, size: 18, color: AppColors.navy),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            'Active Filter: ${_paymentFilter != 'All' ? _paymentFilter : ''}'
                            '${_statusFilter != 'All' ? ' · $_statusFilter' : ''}'
                            '  (${filtered.length} results)',
                            style: const TextStyle(
                              fontSize: 13,
                              color: AppColors.navy,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                        GestureDetector(
                          onTap: () {
                            setState(() {
                              _paymentFilter = 'All';
                              _statusFilter = 'All';
                            });
                          },
                          child: Container(
                            padding: const EdgeInsets.all(4),
                            decoration: BoxDecoration(
                              color: AppColors.navy.withOpacity(0.1),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(Icons.close_rounded, size: 14, color: AppColors.navy),
                          ),
                        ),
                      ],
                    ),
                  ),

                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('All Projects', style: AppTextStyles.titleLarge.copyWith(fontWeight: FontWeight.w800)),
                    Text(
                      '${filtered.length} items',
                      style: AppTextStyles.labelLarge,
                    ),
                  ],
                ),
                const SizedBox(height: 14),

                // Premium Search Bar
                Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(18),
                    boxShadow: AppShadows.soft,
                  ),
                  child: TextField(
                    controller: _searchCtrl,
                    onChanged: (v) => setState(() => _searchQuery = v),
                    decoration: InputDecoration(
                      hintText: 'Search by name, ID, or invoice...',
                      hintStyle: AppTextStyles.bodyMedium,
                      prefixIcon: const Icon(
                        Icons.search_rounded,
                        color: AppColors.textMuted,
                        size: 20,
                      ),
                      suffixIcon: _searchQuery.isNotEmpty
                          ? IconButton(
                              icon: const Icon(Icons.close_rounded, color: AppColors.textMuted, size: 18),
                              onPressed: () {
                                _searchCtrl.clear();
                                setState(() => _searchQuery = '');
                              },
                            )
                          : null,
                      border: InputBorder.none,
                      contentPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // Filter Chips
                // Status filter row
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      _buildFilterLabel('Status:'),
                      _buildChip('All', _statusFilter == 'All',
                          () => setState(() => _statusFilter = 'All')),
                      _buildChip('On Going', _statusFilter == 'On Going',
                          () => setState(() => _statusFilter = 'On Going')),
                      _buildChip('Completed', _statusFilter == 'Completed',
                          () => setState(() => _statusFilter = 'Completed')),
                    ],
                  ),
                ),
                const SizedBox(height: 8),
                // Payment filter row
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      _buildFilterLabel('Payment:'),
                      _buildChip('All', _paymentFilter == 'All',
                          () => setState(() => _paymentFilter = 'All')),
                      _buildChip('Paid', _paymentFilter == 'Paid',
                          () => setState(() => _paymentFilter = 'Paid')),
                      _buildChip('Unpaid', _paymentFilter == 'Unpaid',
                          () => setState(() => _paymentFilter = 'Unpaid')),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
                const Divider(color: AppColors.divider),
                const SizedBox(height: 8),
              ],
            ),
          ),
        ),

        // Animated Project List
        filtered.isEmpty
            ? SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(60),
                  child: Column(
                    children: [
                      Icon(Icons.search_off_rounded, size: 64, color: AppColors.textMuted),
                      const SizedBox(height: 16),
                      Text(
                        'No projects found',
                        style: AppTextStyles.titleMedium.copyWith(color: AppColors.textMuted),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Try adjusting your search or filters',
                        style: AppTextStyles.bodyMedium,
                      ),
                    ],
                  ),
                ),
              )
            : SliverPadding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                sliver: AnimationLimiter(
                  child: SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (ctx, i) {
                        final p = filtered[i];
                        return AnimationConfiguration.staggeredList(
                          position: i,
                          duration: const Duration(milliseconds: 400),
                          child: SlideAnimation(
                            verticalOffset: 50,
                            child: FadeInAnimation(
                              child: ProjectListItem(
                                project: p,
                                index: i,
                                onTap: () => Navigator.push(
                                  ctx,
                                  MaterialPageRoute(
                                    builder: (_) => ProjectDetailScreen(project: p),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        );
                      },
                      childCount: filtered.length,
                    ),
                  ),
                ),
              ),
        const SliverToBoxAdapter(child: SizedBox(height: 30)),
      ],
    );
  }

  Widget _buildPremiumAppBar(List<Project> all, double totalFee, double paidFee) {
    final pct = totalFee > 0 ? (paidFee / totalFee).clamp(0.0, 1.0) : 0.0;

    return Container(
      decoration: const BoxDecoration(
        gradient: AppColors.primaryGradient,
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 48, 20, 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Row(
                children: [
                  Container(
                    width: 52,
                    height: 52,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: AppColors.goldGradient,
                      boxShadow: AppShadows.soft,
                    ),
                    child: const Icon(Icons.person_rounded, color: Colors.white, size: 26),
                  ),
                  const SizedBox(width: 14),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Welcome back,',
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.7),
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const Text(
                        'Taruneshwar V',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 22,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ],
                  ),
                  const Spacer(),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(30),
                      border: Border.all(color: Colors.white.withOpacity(0.2)),
                    ),
                    child: const Row(
                      children: [
                        Icon(Icons.shield_rounded, color: AppColors.gold, size: 14),
                        SizedBox(width: 6),
                        Text(
                            'Operation Head',
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
              const SizedBox(height: 20),
              if (all.isNotEmpty) ...[
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Collection Rate',
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.7),
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    Text(
                      '${(pct * 100).toStringAsFixed(1)}%',
                      style: const TextStyle(
                        color: AppColors.gold,
                        fontSize: 13,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                ClipRRect(
                  borderRadius: BorderRadius.circular(6),
                  child: LinearProgressIndicator(
                    value: pct,
                    backgroundColor: Colors.white.withOpacity(0.2),
                    valueColor: const AlwaysStoppedAnimation<Color>(AppColors.gold),
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
      padding: const EdgeInsets.only(right: 8),
      child: Text(text, style: AppTextStyles.labelLarge),
    );
  }

  Widget _buildChip(String label, bool selected, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        margin: const EdgeInsets.only(right: 8),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: selected ? AppColors.navy : Colors.white,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: selected ? AppColors.navy : AppColors.border,
            width: 1,
          ),
          boxShadow: selected ? AppShadows.soft : null,
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
}

class _TappableCard extends StatefulWidget {
  final Widget child;
  final VoidCallback onTap;
  final bool isActive;

  const _TappableCard({
    required this.child,
    required this.onTap,
    required this.isActive,
  });

  @override
  State<_TappableCard> createState() => _TappableCardState();
}

class _TappableCardState extends State<_TappableCard> {
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: widget.onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        transform: widget.isActive ? Matrix4.identity() : null,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          boxShadow: widget.isActive
              ? [
                  BoxShadow(
                    color: AppColors.gold.withOpacity(0.4),
                    blurRadius: 16,
                    spreadRadius: 1,
                    offset: const Offset(0, 4),
                  )
                ]
              : null,
        ),
        child: widget.child,
      ),
    );
  }
}