// lib/core/widgets/pp_card.dart
// PESAPOP AI — Reusable Card Components

import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_spacing.dart';
import '../theme/app_typography.dart';

// ─────────────────────────────────────────────────────────────
//  PPCard — Base container card
// ─────────────────────────────────────────────────────────────
class PPCard extends StatelessWidget {
  const PPCard({
    super.key,
    this.child,
    this.padding,
    this.onTap,
    this.color,
    this.borderColor,
    this.borderRadius,
  });

  final Widget? child;
  final EdgeInsetsGeometry? padding;
  final VoidCallback? onTap;
  final Color? color;
  final Color? borderColor;
  final double? borderRadius;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bg = color ?? (isDark ? PPColors.darkSurface : PPColors.lightSurface);
    final border = borderColor ?? (isDark ? PPColors.darkBorder : PPColors.lightBorder);
    final radius = borderRadius ?? PPSpacing.radiusLG;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(radius),
        child: Ink(
          decoration: BoxDecoration(
            color: bg,
            borderRadius: BorderRadius.circular(radius),
            border: Border.all(color: border, width: 1),
          ),
          child: Padding(
            padding: padding ?? const EdgeInsets.all(PPSpacing.cardPad),
            child: child,
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────
//  PPMetricCard — KPI / Dashboard metric display
// ─────────────────────────────────────────────────────────────
class PPMetricCard extends StatelessWidget {
  const PPMetricCard({
    super.key,
    required this.label,
    required this.value,
    this.subtitle,
    this.icon,
    this.iconColor,
    this.trend,
    this.trendPositive,
    this.onTap,
    this.accent = false,
  });

  final String label;
  final String value;
  final String? subtitle;
  final IconData? icon;
  final Color? iconColor;
  final String? trend;         // e.g. "+12.5%"
  final bool? trendPositive;   // true = green, false = red
  final VoidCallback? onTap;
  final bool accent;           // Highlighted card with brand color

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final iColor = iconColor ?? PPColors.brand;

    final cardBg = accent
        ? (isDark ? PPColors.darkSurface2 : PPColors.brandSurface)
        : (isDark ? PPColors.darkSurface : PPColors.lightSurface);

    final borderCol = accent
        ? PPColors.brand.withOpacity(0.3)
        : (isDark ? PPColors.darkBorder : PPColors.lightBorder);

    return PPCard(
      color: cardBg,
      borderColor: borderCol,
      onTap: onTap,
      padding: const EdgeInsets.all(PPSpacing.cardPad),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Icon + Trend row ───────────────────────
          Row(
            children: [
              if (icon != null) ...[
                Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: iColor.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(PPSpacing.radiusSM),
                  ),
                  child: Icon(icon, color: iColor, size: 18),
                ),
                const SizedBox(width: 8),
              ],
              Expanded(
                child: Text(
                  label,
                  style: PPTypography.labelMD.copyWith(
                    color: isDark
                        ? PPColors.darkTextSecondary
                        : PPColors.lightTextSecondary,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              if (trend != null) ...[
                _TrendBadge(
                  label: trend!,
                  isPositive: trendPositive ?? true,
                ),
              ],
            ],
          ),

          const SizedBox(height: 12),

          // ── Main Value ──────────────────────────────
          Text(
            value,
            style: PPTypography.metricMD.copyWith(
              color: accent
                  ? PPColors.brand
                  : (isDark ? PPColors.darkText : PPColors.lightText),
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),

          // ── Subtitle ────────────────────────────────
          if (subtitle != null) ...[
            const SizedBox(height: 4),
            Text(
              subtitle!,
              style: PPTypography.bodyXS.copyWith(
                color: isDark
                    ? PPColors.darkTextMuted
                    : PPColors.lightTextMuted,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────
//  _TrendBadge — internal trend indicator
// ─────────────────────────────────────────────────────────────
class _TrendBadge extends StatelessWidget {
  const _TrendBadge({required this.label, required this.isPositive});

  final String label;
  final bool isPositive;

  @override
  Widget build(BuildContext context) {
    final color = isPositive ? PPColors.success : PPColors.error;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
      decoration: BoxDecoration(
        color: color.withOpacity(0.12),
        borderRadius: BorderRadius.circular(PPSpacing.radiusFull),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            isPositive ? Icons.arrow_upward_rounded : Icons.arrow_downward_rounded,
            size: 10,
            color: color,
          ),
          const SizedBox(width: 2),
          Text(
            label,
            style: PPTypography.labelXS.copyWith(color: color),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────
//  PPSectionHeader — Section title with optional action
// ─────────────────────────────────────────────────────────────
class PPSectionHeader extends StatelessWidget {
  const PPSectionHeader({
    super.key,
    required this.title,
    this.action,
    this.onAction,
  });

  final String title;
  final String? action;
  final VoidCallback? onAction;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Row(
      children: [
        Expanded(
          child: Text(
            title,
            style: PPTypography.headingMD.copyWith(
              color: isDark ? PPColors.darkText : PPColors.lightText,
            ),
          ),
        ),
        if (action != null)
          GestureDetector(
            onTap: onAction,
            child: Text(
              action!,
              style: PPTypography.labelMD.copyWith(
                color: PPColors.brand,
              ),
            ),
          ),
      ],
    );
  }
}
