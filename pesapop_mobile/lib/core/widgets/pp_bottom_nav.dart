// lib/core/widgets/pp_bottom_nav.dart
// PESAPOP AI — Shared Bottom Navigation Bar

import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_spacing.dart';
import '../theme/app_typography.dart';

class PPNavItem {
  const PPNavItem({
    required this.icon,
    required this.activeIcon,
    required this.label,
  });
  final IconData icon;
  final IconData activeIcon;
  final String label;
}

// ── Cashier nav items ────────────────────────────────────────
const cashierNavItems = [
  PPNavItem(
    icon: Icons.home_outlined,
    activeIcon: Icons.home_rounded,
    label: 'Home',
  ),
  PPNavItem(
    icon: Icons.point_of_sale_outlined,
    activeIcon: Icons.point_of_sale_rounded,
    label: 'POS',
  ),
  PPNavItem(
    icon: Icons.inventory_2_outlined,
    activeIcon: Icons.inventory_2_rounded,
    label: 'Stock',
  ),
  PPNavItem(
    icon: Icons.receipt_long_outlined,
    activeIcon: Icons.receipt_long_rounded,
    label: 'Sales',
  ),
];

// ── Owner nav items ───────────────────────────────────────────
const ownerNavItems = [
  PPNavItem(
    icon: Icons.home_outlined,
    activeIcon: Icons.home_rounded,
    label: 'Home',
  ),
  PPNavItem(
    icon: Icons.bar_chart_outlined,
    activeIcon: Icons.bar_chart_rounded,
    label: 'Reports',
  ),
  PPNavItem(
    icon: Icons.inventory_2_outlined,
    activeIcon: Icons.inventory_2_rounded,
    label: 'Stock',
  ),
  PPNavItem(
    icon: Icons.auto_awesome_outlined,
    activeIcon: Icons.auto_awesome_rounded,
    label: 'PESA AI',
  ),
  PPNavItem(
    icon: Icons.settings_outlined,
    activeIcon: Icons.settings_rounded,
    label: 'Settings',
  ),
];

class PPBottomNav extends StatelessWidget {
  const PPBottomNav({
    super.key,
    required this.items,
    required this.currentIndex,
    required this.onTap,
  });

  final List<PPNavItem> items;
  final int currentIndex;
  final ValueChanged<int> onTap;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      height: PPSpacing.bottomNavHeight + MediaQuery.of(context).padding.bottom,
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).padding.bottom,
      ),
      decoration: BoxDecoration(
        color: isDark ? PPColors.darkSurface : PPColors.lightSurface,
        border: Border(
          top: BorderSide(
            color: isDark ? PPColors.darkBorder : PPColors.lightBorder,
            width: 1,
          ),
        ),
      ),
      child: Row(
        children: items.asMap().entries.map((entry) {
          final i = entry.key;
          final item = entry.value;
          final isActive = i == currentIndex;

          return Expanded(
            child: GestureDetector(
              onTap: () => onTap(i),
              behavior: HitTestBehavior.opaque,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                curve: Curves.easeOut,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12, vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: isActive
                            ? PPColors.brand.withOpacity(0.12)
                            : Colors.transparent,
                        borderRadius: BorderRadius.circular(
                          PPSpacing.radiusFull,
                        ),
                      ),
                      child: Icon(
                        isActive ? item.activeIcon : item.icon,
                        color: isActive
                            ? PPColors.brand
                            : (isDark
                                ? PPColors.darkTextSecondary
                                : PPColors.lightTextSecondary),
                        size: PPSpacing.bottomNavIconSize,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      item.label,
                      style: PPTypography.labelXS.copyWith(
                        color: isActive
                            ? PPColors.brand
                            : (isDark
                                ? PPColors.darkTextSecondary
                                : PPColors.lightTextSecondary),
                        fontWeight: isActive
                            ? FontWeight.w600
                            : FontWeight.w400,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}
