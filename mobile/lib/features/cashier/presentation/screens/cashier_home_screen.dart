// lib/features/cashier/presentation/screens/cashier_home_screen.dart
// Simplified working version

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/utils/formatters.dart';

import '../../../auth/presentation/providers/auth_provider.dart';
import '../../domain/pos_models.dart';
import '../providers/cart_provider.dart';
import '../providers/pos_provider.dart';

class CashierHomeScreen extends ConsumerWidget {
  const CashierHomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(authProvider).user;
    final statsAsync = ref.watch(cashierStatsProvider);
    final cartState = ref.watch(cartProvider);

    return statsAsync.when(
      data: (stats) => Scaffold(
        backgroundColor: PPColors.darkBg,
        appBar: AppBar(
          backgroundColor: PPColors.darkSurface,
          title: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Welcome',
                style: PPTypography.bodySM.copyWith(
                  color: PPColors.darkTextSecondary,
                ),
              ),
              Text(
                user?.name ?? 'Cashier',
                style: PPTypography.headingMD.copyWith(
                  color: PPColors.darkText,
                ),
              ),
            ],
          ),
          actions: [
            IconButton(
              onPressed: () => context.push('/settings'),
              icon: const Icon(Icons.settings_outlined),
            ),
          ],
        ),
        body: Padding(
          padding: const EdgeInsets.all(PPSpacing.screenH),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Sales card
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: PPColors.brand,
                  borderRadius: BorderRadius.circular(PPSpacing.radiusXL),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Today\'s Sales',
                      style: PPTypography.bodySM.copyWith(
                        color: Colors.white70,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      PPFormatter.ksh(stats.todaySales),
                      style: PPTypography.metricXL.copyWith(
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        _MiniStat(
                          label: 'Profit',
                          value: PPFormatter.ksh(
                            stats.todayProfit,
                            compact: true,
                          ),
                        ),
                        _MiniStat(
                          label: 'Transactions',
                          value: stats.todayTransactions.toString(),
                        ),
                        _MiniStat(
                          label: 'Avg Order',
                          value: PPFormatter.ksh(
                            stats.avgOrderValue,
                            compact: true,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              // Open POS button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () => context.push('/cashier/pos'),
                  icon: const Icon(Icons.point_of_sale_rounded),
                  label: Text(
                    cartState.itemCount > 0
                        ? 'Open POS (${cartState.itemCount} items)'
                        : 'Open POS',
                  ),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    backgroundColor: PPColors.accent,
                    foregroundColor: Colors.white,
                  ),
                ),
              ),

              const SizedBox(height: 20),

              Text(
                'Quick Actions',
                style: PPTypography.headingMD.copyWith(
                  color: PPColors.darkText,
                ),
              ),

              const SizedBox(height: 12),

              Row(
                children: [
                  Expanded(
                    child: _ActionCard(
                      icon: Icons.qr_code_scanner_rounded,
                      label: 'Scan',
                      onTap: () {},
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _ActionCard(
                      icon: Icons.history_rounded,
                      label: 'History',
                      onTap: () {},
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 12),

              Row(
                children: [
                  Expanded(
                    child: _ActionCard(
                      icon: Icons.replay_rounded,
                      label: 'Refund',
                      onTap: () {},
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _ActionCard(
                      icon: Icons.people_outline_rounded,
                      label: 'Customers',
                      onTap: () {},
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),

      loading: () => const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      ),

      error: (e, _) => Scaffold(
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Text(
              'Failed to load cashier dashboard\\n$e',
              textAlign: TextAlign.center,
            ),
          ),
        ),
      ),
    );
  }
}

class _MiniStat extends StatelessWidget {
  const _MiniStat({
    required this.label,
    required this.value,
  });

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          label,
          style: PPTypography.labelXS.copyWith(
            color: Colors.white70,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: PPTypography.labelLG.copyWith(
            color: Colors.white,
          ),
        ),
      ],
    );
  }
}

class _ActionCard extends StatelessWidget {
  const _ActionCard({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(PPSpacing.radiusMD),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 18),
        decoration: BoxDecoration(
          color: PPColors.darkSurface,
          borderRadius: BorderRadius.circular(PPSpacing.radiusMD),
          border: Border.all(color: PPColors.darkBorder),
        ),
        child: Column(
          children: [
            Icon(icon, color: PPColors.brand, size: 28),
            const SizedBox(height: 8),
            Text(
              label,
              style: PPTypography.labelLG.copyWith(
                color: PPColors.darkText,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
