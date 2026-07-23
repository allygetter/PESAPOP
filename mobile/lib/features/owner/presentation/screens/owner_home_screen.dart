// lib/features/owner/presentation/screens/owner_home_screen.dart
// FIXED — handles AsyncValue<OwnerStats> correctly

class OwnerHomeScreen extends ConsumerWidget {
  const OwnerHomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final user = ref.watch(authProvider).user;

    // AsyncValue<OwnerStats>
    final statsAsync = ref.watch(ownerStatsProvider('default'));

    final bg = isDark ? PPColors.darkBg : PPColors.lightBg;
    final surf = isDark ? PPColors.darkSurface : PPColors.lightSurface;
    final border = isDark ? PPColors.darkBorder : PPColors.lightBorder;
    final textPrimary = isDark ? PPColors.darkText : PPColors.lightText;
    final textSec =
        isDark ? PPColors.darkTextSecondary : PPColors.lightTextSecondary;

    return statsAsync.when(
      loading: () => Scaffold(
        backgroundColor: bg,
        body: const Center(
          child: CircularProgressIndicator(),
        ),
      ),

      error: (e, _) => Scaffold(
        backgroundColor: bg,
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Text(
              'Failed to load dashboard\\n$e',
              textAlign: TextAlign.center,
              style: TextStyle(color: textPrimary),
            ),
          ),
        ),
      ),

      data: (stats) => Scaffold(
        backgroundColor: bg,

        body: SafeArea(
          bottom: false,
          child: Column(
            children: [

              // ── Header ─────────────────────────────────
              Padding(
                padding: const EdgeInsets.fromLTRB(
                  PPSpacing.screenH, 16, PPSpacing.screenH, 0,
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            _greeting(),
                            style: PPTypography.bodySM.copyWith(color: textSec),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            user?.name ?? 'Owner',
                            style: PPTypography.headingLG.copyWith(
                              color: textPrimary,
                            ),
                          ),
                        ],
                      ),
                    ),

                    GestureDetector(
                      onTap: () => context.push('/owner/ai'),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 8,
                        ),
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [
                              Color(0xFF6C47FF),
                              Color(0xFF00C896),
                            ],
                          ),
                          borderRadius: BorderRadius.circular(
                            PPSpacing.radiusMD,
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(
                              Icons.auto_awesome_rounded,
                              color: Colors.white,
                              size: 16,
                            ),
                            const SizedBox(width: 6),
                            Text(
                              'Ask PESA AI',
                              style: PPTypography.labelMD.copyWith(
                                color: Colors.white,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 18),

              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(
                    horizontal: PPSpacing.screenH,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [

                      // ── Revenue hero ───────────────────────
                      _RevenueHero(stats: stats, isDark: isDark),

                      const SizedBox(height: 14),

                      // ── KPI grid ───────────────────────────
                      GridView.count(
                        crossAxisCount: 2,
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        crossAxisSpacing: 12,
                        mainAxisSpacing: 12,
                        childAspectRatio: 1.6,
                        children: [
                          PPMetricCard(
                            label: 'Net Profit',
                            value: PPFormatter.ksh(
                              stats.monthProfit,
                              compact: true,
                            ),
                            subtitle: 'This month',
                            icon: Icons.trending_up_rounded,
                            iconColor: PPColors.success,
                            trend: '+22.4%',
                            trendPositive: true,
                          ),

                          PPMetricCard(
                            label: 'Expenses',
                            value: PPFormatter.ksh(
                              stats.monthExpenses,
                              compact: true,
                            ),
                            subtitle: 'This month',
                            icon: Icons.receipt_outlined,
                            iconColor: PPColors.error,
                            trend: '+4.1%',
                            trendPositive: false,
                          ),

                          PPMetricCard(
                            label: 'Customers',
                            value: stats.totalCustomers.toString(),
                            subtitle: '+${stats.newCustomers} new',
                            icon: Icons.people_outline_rounded,
                            iconColor: const Color(0xFF2196F3),
                            trend: '+64',
                            trendPositive: true,
                          ),

                          PPMetricCard(
                            label: 'Profit Margin',
                            value: '${stats.profitMargin}%',
                            subtitle: 'Net margin',
                            icon: Icons.pie_chart_outline_rounded,
                            iconColor: PPColors.gold,
                            accent: true,
                          ),
                        ],
                      ),

                      const SizedBox(height: 22),

                      // ── Revenue mini-chart ─────────────────
                      PPSectionHeader(
                        title: 'Revenue — Last 7 Days',
                        action: 'Full report',
                        onAction: () => context.push('/owner/reports'),
                      ),

                      const SizedBox(height: 12),

                      _MiniBarChart(
                        points: stats.revenueChart,
                        isDark: isDark,
                        surf: surf,
                        border: border,
                        textSec: textSec,
                      ),

                      const SizedBox(height: 22),

                      // ── Top products ───────────────────────
                      PPSectionHeader(
                        title: 'Top Products',
                        action: 'See all',
                        onAction: () {},
                      ),

                      const SizedBox(height: 12),

                      ...stats.topProducts.asMap().entries.map(
                        (e) => Padding(
                          padding: const EdgeInsets.only(bottom: 10),
                          child: _TopProductRow(
                            rank: e.key + 1,
                            product: e.value,
                            isDark: isDark,
                            surf: surf,
                            border: border,
                            textPrimary: textPrimary,
                            textSec: textSec,
                          ),
                        ),
                      ),

                      const SizedBox(height: 22),

                      // ── Payment breakdown ──────────────────
                      PPSectionHeader(title: 'Payment Breakdown'),

                      const SizedBox(height: 12),

                      _PaymentBreakdown(
                        data: stats.paymentBreakdown,
                        isDark: isDark,
                        surf: surf,
                        border: border,
                        textPrimary: textPrimary,
                        textSec: textSec,
                      ),

                      const SizedBox(height: 100),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),

        bottomNavigationBar: PPBottomNav(
          items: ownerNavItems,
          currentIndex: 0,
          onTap: (i) {
            if (i == 1) context.push('/owner/reports');
            if (i == 2) context.push('/owner/inventory');
            if (i == 3) context.push('/owner/ai');
            if (i == 4) context.push('/settings');
          },
        ),
      ),
    );
  }

  String _greeting() {
    final h = DateTime.now().hour;
    if (h < 12) return 'Good morning 👋';
    if (h < 17) return 'Good afternoon 👋';
    return 'Good evening 👋';
  }
}
