// lib/features/owner/presentation/screens/owner_home_screen.dart
// FIXED — clean working version

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/utils/formatters.dart';
import '../../../../core/widgets/pp_bottom_nav.dart';
import '../../../../core/widgets/pp_card.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../providers/owner_provider.dart';

class OwnerHomeScreen extends ConsumerWidget {
  const OwnerHomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final user = ref.watch(authProvider).user;
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

        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(PPSpacing.screenH),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [

                // Header
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            _greeting(),
                            style: PPTypography.bodySM.copyWith(color: textSec),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            user?.name ?? 'Owner',
                            style: PPTypography.headingLG.copyWith(
                              color: textPrimary,
                            ),
                          ),
                        ],
                      ),
                    ),

                    ElevatedButton.icon(
                      onPressed: () => context.push('/owner/ai'),
                      icon: const Icon(Icons.auto_awesome_rounded, size: 18),
                      label: const Text('Ask PESA AI'),
                    ),
                  ],
                ),

                const SizedBox(height: 24),

                // Revenue hero
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: surf,
                    borderRadius: BorderRadius.circular(PPSpacing.radiusXL),
                    border: Border.all(color: border),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Monthly Revenue',
                        style: PPTypography.bodySM.copyWith(color: textSec),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        PPFormatter.ksh(stats.monthRevenue),
                        style: PPTypography.metricXL.copyWith(
                          color: textPrimary,
                          fontSize: 30,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          const Icon(
                            Icons.arrow_upward_rounded,
                            size: 16,
                            color: PPColors.success,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            '+18.4% vs last month',
                            style: PPTypography.labelSM.copyWith(
                              color: PPColors.success,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 20),

                // KPI grid
                Expanded(
                  child: GridView.count(
                    crossAxisCount: 2,
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 12,
                    childAspectRatio: 1.5,
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
                ),
              ],
            ),
          ),
        ),

        bottomNavigationBar: PPBottomNav(
          items: ownerNavItems,
          currentIndex: 0,
          onTap: (i) {
            if (i == 1) context.go('/owner/reports');
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
