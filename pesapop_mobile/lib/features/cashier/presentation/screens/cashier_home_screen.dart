// lib/features/cashier/presentation/screens/cashier_home_screen.dart
// PESAPOP AI — Cashier Home Dashboard

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/widgets/pp_bottom_nav.dart';
import '../../../../core/widgets/pp_button.dart';
import '../../../../core/widgets/pp_card.dart';
import '../../../../core/utils/formatters.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../providers/cart_provider.dart';
import '../providers/pos_provider.dart';

class CashierHomeScreen extends ConsumerWidget {
  const CashierHomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final user = ref.watch(authProvider).user;
    final stats = ref.watch(cashierStatsProvider);
    final cartState = ref.watch(cartProvider);

    final bg = isDark ? PPColors.darkBg : PPColors.lightBg;
    final surf = isDark ? PPColors.darkSurface : PPColors.lightSurface;
    final textPrimary = isDark ? PPColors.darkText : PPColors.lightText;
    final textSec = isDark ? PPColors.darkTextSecondary : PPColors.lightTextSecondary;
    final border = isDark ? PPColors.darkBorder : PPColors.lightBorder;

    return Scaffold(
      backgroundColor: bg,
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            // ── App bar ─────────────────────────────────
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
                          user?.name ?? 'Cashier',
                          style: PPTypography.headingLG.copyWith(color: textPrimary),
                        ),
                      ],
                    ),
                  ),
                  // Notification bell
                  _IconBtn(
                    icon: Icons.notifications_outlined,
                    isDark: isDark,
                    badge: '3',
                    onTap: () {},
                  ),
                  const SizedBox(width: 8),
                  // Avatar
                  GestureDetector(
                    onTap: () => context.push('/settings'),
                    child: Container(
                      width: 40, height: 40,
                      decoration: BoxDecoration(
                        color: PPColors.brand.withOpacity(0.15),
                        shape: BoxShape.circle,
                        border: Border.all(color: PPColors.brand.withOpacity(0.4)),
                      ),
                      child: Center(
                        child: Text(
                          (user?.name ?? 'C')[0].toUpperCase(),
                          style: PPTypography.headingSM.copyWith(
                            color: PPColors.brand,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(
                  horizontal: PPSpacing.screenH,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // ── Hero sale card ───────────────────
                    _HeroCard(stats: stats, isDark: isDark),
                    const SizedBox(height: 16),

                    // ── Quick stat row ────────────────────
                    Row(
                      children: [
                        Expanded(
                          child: PPMetricCard(
                            label: 'Transactions',
                            value: stats.todayTransactions.toString(),
                            subtitle: 'Today',
                            icon: Icons.receipt_long_outlined,
                            iconColor: PPColors.accent,
                            trend: '+5',
                            trendPositive: true,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: PPMetricCard(
                            label: 'Avg Order',
                            value: PPFormatter.ksh(stats.avgOrderValue, compact: true),
                            subtitle: 'Per sale',
                            icon: Icons.trending_up_rounded,
                            iconColor: PPColors.gold,
                            trend: '+8.2%',
                            trendPositive: true,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),

                    // ── Big POS button ────────────────────
                    _POSLaunchButton(
                      cartCount: cartState.itemCount,
                      onTap: () => context.push('/cashier/pos'),
                    ),
                    const SizedBox(height: 20),

                    // ── Quick actions ─────────────────────
                    PPSectionHeader(title: 'Quick Actions'),
                    const SizedBox(height: 12),
                    _QuickActions(isDark: isDark),
                    const SizedBox(height: 20),

                    // ── Recent sales ──────────────────────
                    PPSectionHeader(
                      title: 'Recent Sales',
                      action: 'See all',
                      onAction: () {},
                    ),
                    const SizedBox(height: 12),
                    _RecentSalesList(isDark: isDark, surf: surf, border: border, textPrimary: textPrimary, textSec: textSec),
                    const SizedBox(height: 100),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: PPBottomNav(
        items: cashierNavItems,
        currentIndex: 0,
        onTap: (i) {
          if (i == 1) context.push('/cashier/pos');
          if (i == 2) context.push('/cashier/inventory');
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

// ── Hero sales card ──────────────────────────────────────────
class _HeroCard extends StatelessWidget {
  const _HeroCard({required this.stats, required this.isDark});
  final CashierStats stats;
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            PPColors.brand,
            PPColors.brandDark,
            const Color(0xFF008F65),
          ],
        ),
        borderRadius: BorderRadius.circular(PPSpacing.radiusXL),
        boxShadow: [
          BoxShadow(
            color: PPColors.brand.withOpacity(0.3),
            blurRadius: 24,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Stack(
        children: [
          // Decorative circles
          Positioned(
            right: -20, top: -20,
            child: Container(
              width: 100, height: 100,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withOpacity(0.07),
              ),
            ),
          ),
          Positioned(
            right: 20, bottom: -30,
            child: Container(
              width: 80, height: 80,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withOpacity(0.05),
              ),
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(PPSpacing.radiusFull),
                    ),
                    child: Text(
                      'Today\'s Sales',
                      style: PPTypography.labelSM.copyWith(color: Colors.white70),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Text(
                PPFormatter.ksh(stats.todaySales),
                style: PPTypography.metricXL.copyWith(color: Colors.white),
              ),
              const SizedBox(height: 6),
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(PPSpacing.radiusFull),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.arrow_upward_rounded,
                            size: 11, color: Colors.white),
                        const SizedBox(width: 3),
                        Text('12.5% vs yesterday',
                            style: PPTypography.labelXS.copyWith(
                              color: Colors.white,
                            )),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),
              Divider(color: Colors.white.withOpacity(0.2), thickness: 1),
              const SizedBox(height: 10),
              Row(
                children: [
                  _HeroStat(
                    label: 'Net Profit',
                    value: PPFormatter.ksh(stats.todayProfit, compact: true),
                  ),
                  Container(
                    width: 1, height: 28,
                    color: Colors.white.withOpacity(0.2),
                    margin: const EdgeInsets.symmetric(horizontal: 16),
                  ),
                  _HeroStat(
                    label: 'Transactions',
                    value: stats.todayTransactions.toString(),
                  ),
                  Container(
                    width: 1, height: 28,
                    color: Colors.white.withOpacity(0.2),
                    margin: const EdgeInsets.symmetric(horizontal: 16),
                  ),
                  _HeroStat(
                    label: 'Avg Order',
                    value: PPFormatter.ksh(stats.avgOrderValue, compact: true),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _HeroStat extends StatelessWidget {
  const _HeroStat({required this.label, required this.value});
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label,
            style: PPTypography.labelXS.copyWith(color: Colors.white60)),
        const SizedBox(height: 3),
        Text(value,
            style: PPTypography.metricSM.copyWith(color: Colors.white)),
      ],
    );
  }
}

// ── Big POS launch button ─────────────────────────────────────
class _POSLaunchButton extends StatelessWidget {
  const _POSLaunchButton({required this.cartCount, required this.onTap});
  final int cartCount;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: PPColors.darkSurface,
          borderRadius: BorderRadius.circular(PPSpacing.radiusXL),
          border: Border.all(color: PPColors.darkBorder),
        ),
        child: Row(
          children: [
            Container(
              width: 52, height: 52,
              decoration: BoxDecoration(
                color: PPColors.brand,
                borderRadius: BorderRadius.circular(14),
              ),
              child: const Icon(Icons.point_of_sale_rounded,
                  color: Colors.black, size: 28),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Open POS',
                      style: PPTypography.headingMD.copyWith(
                        color: PPColors.darkText,
                      )),
                  Text(
                    cartCount > 0
                        ? '$cartCount items in cart'
                        : 'Scan products & process sales',
                    style: PPTypography.bodySM.copyWith(
                      color: PPColors.darkTextSecondary,
                    ),
                  ),
                ],
              ),
            ),
            if (cartCount > 0)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  color: PPColors.accent,
                  borderRadius: BorderRadius.circular(PPSpacing.radiusFull),
                ),
                child: Text('$cartCount',
                    style: PPTypography.labelSM.copyWith(color: Colors.white)),
              )
            else
              const Icon(Icons.arrow_forward_ios_rounded,
                  color: PPColors.darkTextSecondary, size: 16),
          ],
        ),
      ),
    );
  }
}

// ── Quick actions grid ────────────────────────────────────────
class _QuickActions extends StatelessWidget {
  const _QuickActions({required this.isDark});
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    final actions = [
      _QuickAction(icon: Icons.qr_code_scanner_rounded, label: 'Scan', color: PPColors.brand, onTap: () {}),
      _QuickAction(icon: Icons.history_rounded, label: 'History', color: PPColors.accent, onTap: () {}),
      _QuickAction(icon: Icons.replay_rounded, label: 'Refund', color: PPColors.gold, onTap: () {}),
      _QuickAction(icon: Icons.people_outline_rounded, label: 'Customers', color: const Color(0xFF2196F3), onTap: () {}),
    ];
    return Row(
      children: actions
          .map((a) => Expanded(
                child: Padding(
                  padding: EdgeInsets.only(
                    right: actions.indexOf(a) < actions.length - 1 ? 10 : 0,
                  ),
                  child: _QuickActionBtn(action: a, isDark: isDark),
                ),
              ))
          .toList(),
    );
  }
}

class _QuickAction {
  const _QuickAction({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;
}

class _QuickActionBtn extends StatelessWidget {
  const _QuickActionBtn({required this.action, required this.isDark});
  final _QuickAction action;
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: action.onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          color: isDark ? PPColors.darkSurface : PPColors.lightSurface,
          borderRadius: BorderRadius.circular(PPSpacing.radiusMD),
          border: Border.all(
            color: isDark ? PPColors.darkBorder : PPColors.lightBorder,
          ),
        ),
        child: Column(
          children: [
            Container(
              width: 36, height: 36,
              decoration: BoxDecoration(
                color: action.color.withOpacity(0.12),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(action.icon, color: action.color, size: 18),
            ),
            const SizedBox(height: 6),
            Text(action.label,
                style: PPTypography.labelSM.copyWith(
                  color: isDark ? PPColors.darkTextSecondary : PPColors.lightTextSecondary,
                )),
          ],
        ),
      ),
    );
  }
}

// ── Recent sales list ─────────────────────────────────────────
class _RecentSalesList extends StatelessWidget {
  const _RecentSalesList({
    required this.isDark,
    required this.surf,
    required this.border,
    required this.textPrimary,
    required this.textSec,
  });
  final bool isDark;
  final Color surf;
  final Color border;
  final Color textPrimary;
  final Color textSec;

  @override
  Widget build(BuildContext context) {
    // Mock recent sales rows
    final sales = [
      _RecentSale('Mary Wanjiku', 'M-Pesa', 1250.0, '2 mins ago', true),
      _RecentSale('Walk-in Customer', 'Cash', 780.0, '8 mins ago', true),
      _RecentSale('Peter Otieno', 'Visa', 3200.0, '15 mins ago', true),
      _RecentSale('Grace Kamau', 'M-Pesa', 450.0, '31 mins ago', true),
    ];

    return Column(
      children: sales
          .map((s) => Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: _RecentSaleRow(sale: s, isDark: isDark, surf: surf, border: border, textPrimary: textPrimary, textSec: textSec),
              ))
          .toList(),
    );
  }
}

class _RecentSale {
  const _RecentSale(this.customer, this.method, this.amount, this.time, this.completed);
  final String customer;
  final String method;
  final double amount;
  final String time;
  final bool completed;
}

class _RecentSaleRow extends StatelessWidget {
  const _RecentSaleRow({
    required this.sale,
    required this.isDark,
    required this.surf,
    required this.border,
    required this.textPrimary,
    required this.textSec,
  });
  final _RecentSale sale;
  final bool isDark;
  final Color surf;
  final Color border;
  final Color textPrimary;
  final Color textSec;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: surf,
        borderRadius: BorderRadius.circular(PPSpacing.radiusMD),
        border: Border.all(color: border),
      ),
      child: Row(
        children: [
          Container(
            width: 38, height: 38,
            decoration: BoxDecoration(
              color: PPColors.brand.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.receipt_long_rounded,
                color: PPColors.brand, size: 18),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(sale.customer,
                    style: PPTypography.labelLG.copyWith(color: textPrimary)),
                Text('${sale.method} · ${sale.time}',
                    style: PPTypography.bodySM.copyWith(color: textSec)),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(PPFormatter.ksh(sale.amount),
                  style: PPTypography.labelLG.copyWith(
                    color: textPrimary,
                    fontFamily: 'Sora',
                  )),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                decoration: BoxDecoration(
                  color: PPColors.success.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(PPSpacing.radiusFull),
                ),
                child: Text('Paid',
                    style: PPTypography.labelXS.copyWith(
                      color: PPColors.success,
                    )),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ── Small icon button ─────────────────────────────────────────
class _IconBtn extends StatelessWidget {
  const _IconBtn({required this.icon, required this.isDark, this.badge, this.onTap});
  final IconData icon;
  final bool isDark;
  final String? badge;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Container(
            width: 40, height: 40,
            decoration: BoxDecoration(
              color: isDark ? PPColors.darkSurface : PPColors.lightSurface,
              borderRadius: BorderRadius.circular(PPSpacing.radiusMD),
              border: Border.all(
                color: isDark ? PPColors.darkBorder : PPColors.lightBorder,
              ),
            ),
            child: Icon(icon,
                color: isDark ? PPColors.darkText : PPColors.lightText, size: 20),
          ),
          if (badge != null)
            Positioned(
              top: -4, right: -4,
              child: Container(
                width: 18, height: 18,
                decoration: const BoxDecoration(
                  color: PPColors.accent,
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Text(badge!,
                      style: PPTypography.labelXS.copyWith(
                          color: Colors.white, fontSize: 9)),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
