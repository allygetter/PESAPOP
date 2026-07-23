// lib/features/owner/presentation/screens/owner_home_screen.dart
// PESAPOP AI — Owner Home Dashboard

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
    final stats = ref.watch(ownerStatsProvider('default'));

    final bg = isDark ? PPColors.darkBg : PPColors.lightBg;
    final surf = isDark ? PPColors.darkSurface : PPColors.lightSurface;
    final border = isDark ? PPColors.darkBorder : PPColors.lightBorder;
    final textPrimary = isDark ? PPColors.darkText : PPColors.lightText;
    final textSec = isDark ? PPColors.darkTextSecondary : PPColors.lightTextSecondary;

    return Scaffold(
      backgroundColor: bg,
      body: SafeArea(
        bottom: false,
        child: Column(children: [

          // ── Header ─────────────────────────────────
          Padding(
            padding: const EdgeInsets.fromLTRB(PPSpacing.screenH, 16, PPSpacing.screenH, 0),
            child: Row(children: [
              Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(_greeting(), style: PPTypography.bodySM.copyWith(color: textSec)),
                const SizedBox(height: 2),
                Text(user?.name ?? 'Owner', style: PPTypography.headingLG.copyWith(color: textPrimary)),
              ])),
              GestureDetector(
                onTap: () => context.push('/owner/ai'),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(colors: [Color(0xFF6C47FF), Color(0xFF00C896)]),
                    borderRadius: BorderRadius.circular(PPSpacing.radiusMD),
                  ),
                  child: Row(mainAxisSize: MainAxisSize.min, children: [
                    const Icon(Icons.auto_awesome_rounded, color: Colors.white, size: 16),
                    const SizedBox(width: 6),
                    Text('Ask PESA AI', style: PPTypography.labelMD.copyWith(color: Colors.white)),
                  ]),
                ),
              ),
            ]),
          ),

          const SizedBox(height: 18),

          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: PPSpacing.screenH),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [

                // ── Revenue hero ───────────────────────
                _RevenueHero(stats: stats, isDark: isDark),
                const SizedBox(height: 14),

                // ── KPI grid ───────────────────────────
                GridView.count(
                  crossAxisCount: 2,
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  crossAxisSpacing: 12, mainAxisSpacing: 12,
                  childAspectRatio: 1.6,
                  children: [
                    PPMetricCard(label: 'Net Profit', value: PPFormatter.ksh(stats.monthProfit, compact: true),
                        subtitle: 'This month', icon: Icons.trending_up_rounded, iconColor: PPColors.success,
                        trend: '+22.4%', trendPositive: true),
                    PPMetricCard(label: 'Expenses', value: PPFormatter.ksh(stats.monthExpenses, compact: true),
                        subtitle: 'This month', icon: Icons.receipt_outlined, iconColor: PPColors.error,
                        trend: '+4.1%', trendPositive: false),
                    PPMetricCard(label: 'Customers', value: stats.totalCustomers.toString(),
                        subtitle: '+${stats.newCustomers} new', icon: Icons.people_outline_rounded,
                        iconColor: const Color(0xFF2196F3), trend: '+64', trendPositive: true),
                    PPMetricCard(label: 'Profit Margin', value: '${stats.profitMargin}%',
                        subtitle: 'Net margin', icon: Icons.pie_chart_outline_rounded,
                        iconColor: PPColors.gold, accent: true),
                  ],
                ),

                const SizedBox(height: 22),

                // ── Revenue mini-chart ─────────────────
                PPSectionHeader(title: 'Revenue — Last 7 Days', action: 'Full report', onAction: () => context.push('/owner/reports')),
                const SizedBox(height: 12),
                _MiniBarChart(points: stats.revenueChart, isDark: isDark, surf: surf, border: border, textSec: textSec),

                const SizedBox(height: 22),

                // ── Top products ───────────────────────
                PPSectionHeader(title: 'Top Products', action: 'See all', onAction: () {}),
                const SizedBox(height: 12),
                ...stats.topProducts.asMap().entries.map((e) => Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: _TopProductRow(rank: e.key + 1, product: e.value,
                      isDark: isDark, surf: surf, border: border,
                      textPrimary: textPrimary, textSec: textSec),
                )),

                const SizedBox(height: 22),

                // ── Payment breakdown ──────────────────
                PPSectionHeader(title: 'Payment Breakdown'),
                const SizedBox(height: 12),
                _PaymentBreakdown(data: stats.paymentBreakdown,
                    isDark: isDark, surf: surf, border: border,
                    textPrimary: textPrimary, textSec: textSec),

                const SizedBox(height: 100),
              ]),
            ),
          ),
        ]),
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
    );
  }

  String _greeting() {
    final h = DateTime.now().hour;
    if (h < 12) return 'Good morning 👋';
    if (h < 17) return 'Good afternoon 👋';
    return 'Good evening 👋';
  }
}

// ── Revenue hero card ─────────────────────────────────────────
class _RevenueHero extends StatelessWidget {
  const _RevenueHero({required this.stats, required this.isDark});
  final OwnerStats stats;
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft, end: Alignment.bottomRight,
          colors: [Color(0xFF0A1628), Color(0xFF0D2218), Color(0xFF0A1628)],
        ),
        borderRadius: BorderRadius.circular(PPSpacing.radiusXL),
        border: Border.all(color: PPColors.brand.withOpacity(0.2)),
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: PPColors.brand.withOpacity(0.15),
              borderRadius: BorderRadius.circular(PPSpacing.radiusFull),
              border: Border.all(color: PPColors.brand.withOpacity(0.3)),
            ),
            child: Text('June 2026', style: PPTypography.labelSM.copyWith(color: PPColors.brand)),
          ),
          const Spacer(),
          Icon(Icons.trending_up_rounded, color: PPColors.brand, size: 18),
        ]),
        const SizedBox(height: 10),
        Text('Monthly Revenue', style: PPTypography.bodySM.copyWith(color: PPColors.darkTextSecondary)),
        const SizedBox(height: 4),
        Text(PPFormatter.ksh(stats.monthRevenue),
            style: PPTypography.metricXL.copyWith(color: PPColors.darkText, fontSize: 30)),
        const SizedBox(height: 6),
        Row(children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
            decoration: BoxDecoration(
              color: PPColors.success.withOpacity(0.15),
              borderRadius: BorderRadius.circular(PPSpacing.radiusFull),
            ),
            child: Row(mainAxisSize: MainAxisSize.min, children: [
              const Icon(Icons.arrow_upward_rounded, size: 11, color: PPColors.success),
              const SizedBox(width: 3),
              Text('+18.4% vs last month', style: PPTypography.labelXS.copyWith(color: PPColors.success)),
            ]),
          ),
        ]),
      ]),
    );
  }
}

// ── Mini bar chart ────────────────────────────────────────────
class _MiniBarChart extends StatelessWidget {
  const _MiniBarChart({required this.points, required this.isDark,
      required this.surf, required this.border, required this.textSec});
  final List<RevenuePoint> points;
  final bool isDark;
  final Color surf, border, textSec;

  @override
  Widget build(BuildContext context) {
    final maxVal = points.map((p) => p.value).reduce((a, b) => a > b ? a : b);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: surf,
        borderRadius: BorderRadius.circular(PPSpacing.radiusLG),
        border: Border.all(color: border),
      ),
      child: Column(children: [
        Row(crossAxisAlignment: CrossAxisAlignment.end, children: points.map((p) {
          final pct = (p.value / maxVal);
          final isMax = p.value == maxVal;
          return Expanded(child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 3),
            child: Column(children: [
              if (isMax) Padding(
                padding: const EdgeInsets.only(bottom: 3),
                child: Text(PPFormatter.ksh(p.value, compact: true),
                    style: PPTypography.labelXS.copyWith(color: PPColors.brand), textAlign: TextAlign.center),
              ),
              AnimatedContainer(
                duration: const Duration(milliseconds: 600),
                height: 80 * pct,
                decoration: BoxDecoration(
                  color: isMax ? PPColors.brand : PPColors.brand.withOpacity(0.25),
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
              const SizedBox(height: 6),
              Text(p.label, style: PPTypography.labelXS.copyWith(color: textSec)),
            ]),
          ));
        }).toList()),
      ]),
    );
  }
}

// ── Top product row ───────────────────────────────────────────
class _TopProductRow extends StatelessWidget {
  const _TopProductRow({required this.rank, required this.product,
      required this.isDark, required this.surf, required this.border,
      required this.textPrimary, required this.textSec});
  final int rank;
  final TopProduct product;
  final bool isDark;
  final Color surf, border, textPrimary, textSec;

  @override
  Widget build(BuildContext context) {
    final rankColor = rank == 1 ? PPColors.gold : rank == 2 ? PPColors.darkTextSecondary : PPColors.accent;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: surf,
        borderRadius: BorderRadius.circular(PPSpacing.radiusMD),
        border: Border.all(color: border),
      ),
      child: Row(children: [
        Container(
          width: 28, height: 28,
          decoration: BoxDecoration(
            color: rankColor.withOpacity(0.12),
            shape: BoxShape.circle,
          ),
          child: Center(child: Text('#$rank',
              style: PPTypography.labelSM.copyWith(color: rankColor, fontFamily: 'Sora'))),
        ),
        const SizedBox(width: 12),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(product.name, style: PPTypography.labelLG.copyWith(color: textPrimary),
              maxLines: 1, overflow: TextOverflow.ellipsis),
          Text('${product.units} units sold',
              style: PPTypography.bodySM.copyWith(color: textSec)),
        ])),
        const SizedBox(width: 10),
        Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
          Text(PPFormatter.ksh(product.revenue, compact: true),
              style: PPTypography.labelLG.copyWith(color: textPrimary, fontFamily: 'Sora')),
          Text('${product.pct}% of revenue',
              style: PPTypography.bodyXS.copyWith(color: textSec)),
        ]),
      ]),
    );
  }
}

// ── Payment breakdown ─────────────────────────────────────────
class _PaymentBreakdown extends StatelessWidget {
  const _PaymentBreakdown({required this.data, required this.isDark,
      required this.surf, required this.border, required this.textPrimary, required this.textSec});
  final Map<String, double> data;
  final bool isDark;
  final Color surf, border, textPrimary, textSec;

  @override
  Widget build(BuildContext context) {
    final colors = [PPColors.mpesa, PPColors.brand, const Color(0xFF1A1F71), PPColors.airtelMoney];
    final entries = data.entries.toList();

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: surf,
        borderRadius: BorderRadius.circular(PPSpacing.radiusLG),
        border: Border.all(color: border),
      ),
      child: Column(children: [
        // Bar
        ClipRRect(
          borderRadius: BorderRadius.circular(PPSpacing.radiusFull),
          child: SizedBox(
            height: 10,
            child: Row(children: entries.asMap().entries.map((e) => Expanded(
              flex: (e.value.value * 10).round(),
              child: Container(color: colors[e.key % colors.length]),
            )).toList()),
          ),
        ),
        const SizedBox(height: 16),
        // Legend
        ...entries.asMap().entries.map((e) => Padding(
          padding: const EdgeInsets.only(bottom: 10),
          child: Row(children: [
            Container(width: 10, height: 10,
                decoration: BoxDecoration(color: colors[e.key % colors.length], shape: BoxShape.circle)),
            const SizedBox(width: 10),
            Expanded(child: Text(e.value.key, style: PPTypography.bodyMD.copyWith(color: textPrimary))),
            Text('${e.value.value}%',
                style: PPTypography.labelLG.copyWith(color: textPrimary, fontFamily: 'Sora')),
          ]),
        )),
      ]),
    );
  }
}
