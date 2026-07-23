class _ReportsScreenState extends ConsumerState<ReportsScreen> {
  int _selectedRange = 1; // 0=Today 1=Week 2=Month 3=Year

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    // AsyncValue<OwnerStats>
    final statsAsync = ref.watch(ownerStatsProvider('default'));

    final bg = isDark ? PPColors.darkBg : PPColors.lightBg;
    final surf = isDark ? PPColors.darkSurface : PPColors.lightSurface;
    final surf2 = isDark ? PPColors.darkSurface2 : PPColors.lightSurface2;
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
              'Failed to load reports\\n$e',
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
                    GestureDetector(
                      onTap: () => context.pop(),
                      child: Container(
                        width: 38,
                        height: 38,
                        decoration: BoxDecoration(
                          color: surf,
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: border),
                        ),
                        child: Icon(
                          Icons.arrow_back_ios_new_rounded,
                          size: 16,
                          color: textPrimary,
                        ),
                      ),
                    ),

                    const SizedBox(width: 12),

                    Expanded(
                      child: Text(
                        'Reports & Analytics',
                        style: PPTypography.headingLG.copyWith(
                          color: textPrimary,
                        ),
                      ),
                    ),

                    GestureDetector(
                      onTap: () {},
                      child: Container(
                        width: 38,
                        height: 38,
                        decoration: BoxDecoration(
                          color: surf,
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: border),
                        ),
                        child: Icon(
                          Icons.download_outlined,
                          size: 20,
                          color: textPrimary,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 14),

              // ── Date range selector ─────────────────────
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: PPSpacing.screenH,
                ),
                child: Container(
                  height: 40,
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: surf2,
                    borderRadius: BorderRadius.circular(
                      PPSpacing.radiusMD,
                    ),
                    border: Border.all(color: border),
                  ),
                  child: Row(
                    children: ['Today', 'Week', 'Month', 'Year']
                        .asMap()
                        .entries
                        .map((e) {
                      final sel = e.key == _selectedRange;

                      return Expanded(
                        child: GestureDetector(
                          onTap: () => setState(
                            () => _selectedRange = e.key,
                          ),
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 160),
                            decoration: BoxDecoration(
                              color: sel
                                  ? PPColors.brand
                                  : Colors.transparent,
                              borderRadius: BorderRadius.circular(
                                PPSpacing.radiusSM,
                              ),
                            ),
                            child: Center(
                              child: Text(
                                e.value,
                                style: PPTypography.labelMD.copyWith(
                                  color: sel
                                      ? Colors.black
                                      : textSec,
                                  fontWeight: sel
                                      ? FontWeight.w600
                                      : FontWeight.w400,
                                ),
                              ),
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ),
              ),

              const SizedBox(height: 14),

              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(
                    horizontal: PPSpacing.screenH,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [

                      // ── Summary row ────────────────────────
                      Row(
                        children: [
                          Expanded(
                            child: _SummaryCard(
                              label: 'Revenue',
                              value: PPFormatter.ksh(
                                stats.monthRevenue,
                              ),
                              trend: '+18.4%',
                              up: true,
                              isDark: isDark,
                              surf: surf,
                              border: border,
                              textPrimary: textPrimary,
                              textSec: textSec,
                              accent: true,
                            ),
                          ),

                          const SizedBox(width: 12),

                          Expanded(
                            child: _SummaryCard(
                              label: 'Profit',
                              value: PPFormatter.ksh(
                                stats.monthProfit,
                              ),
                              trend: '+22.4%',
                              up: true,
                              isDark: isDark,
                              surf: surf,
                              border: border,
                              textPrimary: textPrimary,
                              textSec: textSec,
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 20),

                      // ── Revenue chart ──────────────────────
                      PPSectionHeader(title: 'Revenue Trend'),

                      const SizedBox(height: 12),

                      _BarChart(
                        points: stats.revenueChart,
                        isDark: isDark,
                        surf: surf,
                        border: border,
                        textSec: textSec,
                      ),

                      const SizedBox(height: 22),

                      // ── P&L summary ────────────────────────
                      PPSectionHeader(title: 'Profit & Loss'),

                      const SizedBox(height: 12),

                      _PLCard(
                        stats: stats,
                        isDark: isDark,
                        surf: surf,
                        border: border,
                        textPrimary: textPrimary,
                        textSec: textSec,
                      ),

                      const SizedBox(height: 22),

                      // ── Export row ─────────────────────────
                      PPSectionHeader(title: 'Export Reports'),

                      const SizedBox(height: 12),

                      _ExportRow(
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
          currentIndex: 1,
          onTap: (i) {
            if (i == 0) context.go('/owner');
            if (i == 3) context.push('/owner/ai');
            if (i == 4) context.push('/settings');
          },
        ),
      ),
    );
  }
}
