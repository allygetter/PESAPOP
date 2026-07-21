// lib/features/owner/presentation/screens/reports_screen.dart
// PESAPOP AI — Reports & Analytics Screen

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
  int _selectedRange = 1; // 0=Today 1=Week 2=Month 3=Year

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final stats = ref.watch(ownerStatsProvider);

    final bg = isDark ? PPColors.darkBg : PPColors.lightBg;
    final surf = isDark ? PPColors.darkSurface : PPColors.lightSurface;
    final surf2 = isDark ? PPColors.darkSurface2 : PPColors.lightSurface2;
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
              GestureDetector(
                onTap: () => context.pop(),
                child: Container(width: 38, height: 38,
                    decoration: BoxDecoration(color: surf,
                        borderRadius: BorderRadius.circular(10), border: Border.all(color: border)),
                    child: Icon(Icons.arrow_back_ios_new_rounded, size: 16, color: textPrimary)),
              ),
              const SizedBox(width: 12),
              Expanded(child: Text('Reports & Analytics',
                  style: PPTypography.headingLG.copyWith(color: textPrimary))),
              GestureDetector(
                onTap: () {},
                child: Container(width: 38, height: 38,
                    decoration: BoxDecoration(color: surf,
                        borderRadius: BorderRadius.circular(10), border: Border.all(color: border)),
                    child: Icon(Icons.download_outlined, size: 20, color: textPrimary)),
              ),
            ]),
          ),

          const SizedBox(height: 14),

          // ── Date range selector ─────────────────────
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: PPSpacing.screenH),
            child: Container(
              height: 40,
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: surf2,
                borderRadius: BorderRadius.circular(PPSpacing.radiusMD),
                border: Border.all(color: border),
              ),
              child: Row(children: ['Today', 'Week', 'Month', 'Year']
                  .asMap().entries.map((e) {
                final sel = e.key == _selectedRange;
                return Expanded(child: GestureDetector(
                  onTap: () => setState(() => _selectedRange = e.key),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 160),
                    decoration: BoxDecoration(
                      color: sel ? PPColors.brand : Colors.transparent,
                      borderRadius: BorderRadius.circular(PPSpacing.radiusSM),
                    ),
                    child: Center(child: Text(e.value,
                        style: PPTypography.labelMD.copyWith(
                          color: sel ? Colors.black : textSec,
                          fontWeight: sel ? FontWeight.w600 : FontWeight.w400,
                        ))),
                  ),
                ));
              }).toList()),
            ),
          ),

          const SizedBox(height: 14),

          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: PPSpacing.screenH),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [

                // ── Summary row ────────────────────────
                Row(children: [
                  Expanded(child: _SummaryCard(
                    label: 'Revenue', value: PPFormatter.ksh(stats.monthRevenue),
                    trend: '+18.4%', up: true, isDark: isDark, surf: surf, border: border,
                    textPrimary: textPrimary, textSec: textSec, accent: true,
                  )),
                  const SizedBox(width: 12),
                  Expanded(child: _SummaryCard(
                    label: 'Profit', value: PPFormatter.ksh(stats.monthProfit),
                    trend: '+22.4%', up: true, isDark: isDark, surf: surf, border: border,
                    textPrimary: textPrimary, textSec: textSec,
                  )),
                ]),

                const SizedBox(height: 20),

                // ── Revenue chart ──────────────────────
                PPSectionHeader(title: 'Revenue Trend'),
                const SizedBox(height: 12),
                _BarChart(points: stats.revenueChart, isDark: isDark, surf: surf,
                    border: border, textSec: textSec),

                const SizedBox(height: 22),

                // ── P&L summary ────────────────────────
                PPSectionHeader(title: 'Profit & Loss'),
                const SizedBox(height: 12),
                _PLCard(stats: stats, isDark: isDark, surf: surf, border: border,
                    textPrimary: textPrimary, textSec: textSec),

                const SizedBox(height: 22),

                // ── Export row ─────────────────────────
                PPSectionHeader(title: 'Export Reports'),
                const SizedBox(height: 12),
                _ExportRow(isDark: isDark, surf: surf, border: border,
                    textPrimary: textPrimary, textSec: textSec),

                const SizedBox(height: 100),
              ]),
            ),
          ),
        ]),
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
    );
  }
}

class _SummaryCard extends StatelessWidget {
  const _SummaryCard({
    required this.label, required this.value, required this.trend,
    required this.up, required this.isDark, required this.surf, required this.border,
    required this.textPrimary, required this.textSec, this.accent = false,
  });
  final String label, value, trend;
  final bool up, isDark, accent;
  final Color surf, border, textPrimary, textSec;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: accent ? PPColors.brand.withOpacity(isDark ? 0.1 : 0.06) : surf,
        borderRadius: BorderRadius.circular(PPSpacing.radiusLG),
        border: Border.all(color: accent ? PPColors.brand.withOpacity(0.3) : border),
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(label, style: PPTypography.labelMD.copyWith(color: textSec)),
        const SizedBox(height: 6),
        Text(value, style: PPTypography.metricSM.copyWith(
            color: accent ? PPColors.brand : textPrimary, fontSize: 16)),
        const SizedBox(height: 6),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
          decoration: BoxDecoration(
            color: (up ? PPColors.success : PPColors.error).withOpacity(0.1),
            borderRadius: BorderRadius.circular(PPSpacing.radiusFull),
          ),
          child: Row(mainAxisSize: MainAxisSize.min, children: [
            Icon(up ? Icons.arrow_upward_rounded : Icons.arrow_downward_rounded,
                size: 10, color: up ? PPColors.success : PPColors.error),
            const SizedBox(width: 2),
            Text(trend, style: PPTypography.labelXS.copyWith(
                color: up ? PPColors.success : PPColors.error)),
          ]),
        ),
      ]),
    );
  }
}

class _BarChart extends StatelessWidget {
  const _BarChart({required this.points, required this.isDark,
      required this.surf, required this.border, required this.textSec});
  final List<RevenuePoint> points;
  final bool isDark;
  final Color surf, border, textSec;

  @override
  Widget build(BuildContext context) {
    final maxVal = points.map((p) => p.value).reduce((a, b) => a > b ? a : b);
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
      decoration: BoxDecoration(
        color: surf,
        borderRadius: BorderRadius.circular(PPSpacing.radiusLG),
        border: Border.all(color: border),
      ),
      child: Column(children: [
        SizedBox(
          height: 120,
          child: Row(crossAxisAlignment: CrossAxisAlignment.end,
              children: points.map((p) {
            final pct = p.value / maxVal;
            final isMax = p.value == maxVal;
            return Expanded(child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4),
              child: Column(mainAxisAlignment: MainAxisAlignment.end, children: [
                if (isMax) Text(PPFormatter.ksh(p.value, compact: true),
                    style: PPTypography.labelXS.copyWith(color: PPColors.brand),
                    textAlign: TextAlign.center),
                const SizedBox(height: 3),
                Container(
                  height: 100 * pct,
                  decoration: BoxDecoration(
                    color: isMax ? PPColors.brand : PPColors.brand.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              ]),
            ));
          }).toList()),
        ),
        const SizedBox(height: 10),
        Row(children: points.map((p) => Expanded(
          child: Text(p.label, style: PPTypography.labelXS.copyWith(color: textSec),
              textAlign: TextAlign.center),
        )).toList()),
      ]),
    );
  }
}

class _PLCard extends StatelessWidget {
  const _PLCard({required this.stats, required this.isDark, required this.surf,
      required this.border, required this.textPrimary, required this.textSec});
  final OwnerStats stats;
  final bool isDark;
  final Color surf, border, textPrimary, textSec;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: surf,
        borderRadius: BorderRadius.circular(PPSpacing.radiusLG),
        border: Border.all(color: border),
      ),
      child: Column(children: [
        _PLRow('Gross Revenue', PPFormatter.ksh(stats.monthRevenue),
            PPColors.success, textPrimary, textSec),
        const SizedBox(height: 8),
        _PLRow('Total Expenses', '- ${PPFormatter.ksh(stats.monthExpenses)}',
            PPColors.error, textPrimary, textSec),
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 10),
          child: Divider(color: border, thickness: 1),
        ),
        _PLRow('Net Profit', PPFormatter.ksh(stats.monthProfit),
            PPColors.brand, textPrimary, textSec, isBold: true),
        const SizedBox(height: 8),
        _PLRow('Profit Margin', '${stats.profitMargin}%',
            PPColors.gold, textPrimary, textSec),
      ]),
    );
  }
}

class _PLRow extends StatelessWidget {
  const _PLRow(this.label, this.value, this.valueColor, this.textPrimary, this.textSec, {this.isBold = false});
  final String label, value;
  final Color valueColor, textPrimary, textSec;
  final bool isBold;

  @override
  Widget build(BuildContext context) {
    return Row(children: [
      Text(label, style: (isBold ? PPTypography.headingSM : PPTypography.bodyMD)
          .copyWith(color: isBold ? textPrimary : textSec)),
      const Spacer(),
      Text(value, style: (isBold ? PPTypography.metricSM : PPTypography.labelLG)
          .copyWith(color: valueColor, fontFamily: 'Sora', fontSize: isBold ? 17 : 14)),
    ]);
  }
}

class _ExportRow extends StatelessWidget {
  const _ExportRow({required this.isDark, required this.surf, required this.border,
      required this.textPrimary, required this.textSec});
  final bool isDark;
  final Color surf, border, textPrimary, textSec;

  @override
  Widget build(BuildContext context) {
    final exports = [
      _Export(Icons.picture_as_pdf_outlined, 'PDF Report', 'Full financial report'),
      _Export(Icons.table_chart_outlined, 'Excel Sheet', 'Raw data export'),
      _Export(Icons.insert_drive_file_outlined, 'CSV Export', 'Transaction log'),
    ];
    return Column(children: exports.map((e) => Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: GestureDetector(
        onTap: () {},
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          decoration: BoxDecoration(
            color: surf,
            borderRadius: BorderRadius.circular(PPSpacing.radiusMD),
            border: Border.all(color: border),
          ),
          child: Row(children: [
            Container(
              width: 36, height: 36,
              decoration: BoxDecoration(
                color: PPColors.brand.withOpacity(0.1),
                borderRadius: BorderRadius.circular(9),
              ),
              child: Icon(e.icon, color: PPColors.brand, size: 18),
            ),
            const SizedBox(width: 12),
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(e.label, style: PPTypography.labelLG.copyWith(color: textPrimary)),
              Text(e.sub, style: PPTypography.bodySM.copyWith(color: textSec)),
            ])),
            Icon(Icons.download_outlined, color: textSec, size: 18),
          ]),
        ),
      ),
    )).toList());
  }
}

class _Export {
  const _Export(this.icon, this.label, this.sub);
  final IconData icon;
  final String label, sub;
}
