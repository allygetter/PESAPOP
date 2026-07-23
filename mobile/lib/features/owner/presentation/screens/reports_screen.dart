// lib/features/owner/presentation/screens/reports_screen.dart
// FIXED — working version

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/utils/formatters.dart';
import '../../../../core/widgets/pp_bottom_nav.dart';
import '../../../../core/widgets/pp_card.dart';
import '../providers/owner_provider.dart';

class ReportsScreen extends ConsumerStatefulWidget {
  const ReportsScreen({super.key});

  @override
  ConsumerState<ReportsScreen> createState() => _ReportsScreenState();
}

class _ReportsScreenState extends ConsumerState<ReportsScreen> {
  int _selectedRange = 1;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
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
        body: const Center(child: CircularProgressIndicator()),
      ),

      error: (e, _) => Scaffold(
        backgroundColor: bg,
        body: Center(
          child: Text(
            'Error: $e',
            style: TextStyle(color: textPrimary),
          ),
        ),
      ),

      data: (stats) => Scaffold(
        backgroundColor: bg,

        appBar: AppBar(
          backgroundColor: surf,
          title: const Text('Reports & Analytics'),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios_new_rounded),
            onPressed: () => context.pop(),
          ),
        ),

        body: Padding(
          padding: const EdgeInsets.all(PPSpacing.screenH),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [

              // Range selector
              SegmentedButton<int>(
                segments: const [
                  ButtonSegment(value: 0, label: Text('Today')),
                  ButtonSegment(value: 1, label: Text('Week')),
                  ButtonSegment(value: 2, label: Text('Month')),
                  ButtonSegment(value: 3, label: Text('Year')),
                ],
                selected: {_selectedRange},
                onSelectionChanged: (s) {
                  setState(() => _selectedRange = s.first);
                },
              ),

              const SizedBox(height: 20),

              // KPI cards
              Row(
                children: [
                  Expanded(
                    child: PPMetricCard(
                      label: 'Revenue',
                      value: PPFormatter.ksh(stats.monthRevenue),
                      subtitle: 'This month',
                      icon: Icons.payments_outlined,
                      iconColor: PPColors.brand,
                      trend: '+18.4%',
                      trendPositive: true,
                    ),
                  ),

                  const SizedBox(width: 12),

                  Expanded(
                    child: PPMetricCard(
                      label: 'Profit',
                      value: PPFormatter.ksh(stats.monthProfit),
                      subtitle: 'This month',
                      icon: Icons.trending_up_rounded,
                      iconColor: PPColors.success,
                      trend: '+22.4%',
                      trendPositive: true,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 24),

              Text(
                'Revenue Trend',
                style: PPTypography.headingMD.copyWith(
                  color: textPrimary,
                ),
              ),

              const SizedBox(height: 12),

              Expanded(
                child: ListView(
                  children: [
                    ...stats.revenueChart.map(
                      (p) => ListTile(
                        contentPadding: EdgeInsets.zero,
                        title: Text(
                          p.label,
                          style: TextStyle(color: textPrimary),
                        ),
                        trailing: Text(
                          PPFormatter.ksh(p.value, compact: true),
                          style: TextStyle(color: textSec),
                        ),
                      ),
                    ),

                    const SizedBox(height: 16),

                    Text(
                      'Profit & Loss',
                      style: PPTypography.headingMD.copyWith(
                        color: textPrimary,
                      ),
                    ),

                    const SizedBox(height: 12),

                    Card(
                      color: surf,
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          children: [
                            _plRow(
                              'Revenue',
                              PPFormatter.ksh(stats.monthRevenue),
                              PPColors.success,
                              textPrimary,
                            ),

                            const SizedBox(height: 8),

                            _plRow(
                              'Expenses',
                              '- ${PPFormatter.ksh(stats.monthExpenses)}',
                              PPColors.error,
                              textPrimary,
                            ),

                            const Divider(height: 24),

                            _plRow(
                              'Net Profit',
                              PPFormatter.ksh(stats.monthProfit),
                              PPColors.brand,
                              textPrimary,
                              bold: true,
                            ),

                            const SizedBox(height: 8),

                            _plRow(
                              'Profit Margin',
                              '${stats.profitMargin}%',
                              PPColors.gold,
                              textPrimary,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
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

  Widget _plRow(
    String label,
    String value,
    Color color,
    Color textColor, {
    bool bold = false,
  }) {
    return Row(
      children: [
        Text(
          label,
          style: TextStyle(
            color: textColor,
            fontWeight: bold ? FontWeight.w700 : FontWeight.w500,
          ),
        ),
        const Spacer(),
        Text(
          value,
          style: TextStyle(
            color: color,
            fontWeight: bold ? FontWeight.w700 : FontWeight.w600,
          ),
        ),
      ],
    );
  }
}
