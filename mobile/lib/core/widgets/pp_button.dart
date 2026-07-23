// lib/core/widgets/pp_button.dart
// PESAPOP AI — Reusable Button Component

import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_spacing.dart';
import '../theme/app_typography.dart';

enum PPButtonVariant { primary, secondary, outline, ghost, danger }
enum PPButtonSize { lg, md, sm, xs }

class PPButton extends StatelessWidget {
  const PPButton({
    super.key,
    required this.label,
    required this.onTap,
    this.variant = PPButtonVariant.primary,
    this.size = PPButtonSize.md,
    this.icon,
    this.trailing,
    this.isLoading = false,
    this.isDisabled = false,
    this.width,
    this.borderRadius,
  });

  final String label;
  final VoidCallback? onTap;
  final PPButtonVariant variant;
  final PPButtonSize size;
  final Widget? icon;
  final Widget? trailing;
  final bool isLoading;
  final bool isDisabled;
  final double? width;
  final double? borderRadius;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final height = _height;
    final textStyle = _textStyle;
    final bg = _backgroundColor(isDark);
    final fg = _foregroundColor(isDark);
    final border = _border(isDark);

    return SizedBox(
      width: width ?? double.infinity,
      height: height,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: (isLoading || isDisabled) ? null : onTap,
          borderRadius: BorderRadius.circular(
            borderRadius ?? PPSpacing.radiusMD,
          ),
          child: Ink(
            decoration: BoxDecoration(
              color: (isDisabled || isLoading)
                  ? bg.withOpacity(0.4)
                  : bg,
              borderRadius: BorderRadius.circular(
                borderRadius ?? PPSpacing.radiusMD,
              ),
              border: border,
            ),
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: _horizontalPad),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                mainAxisSize: MainAxisSize.max,
                children: [
                  if (isLoading) ...[
                    SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation(fg),
                      ),
                    ),
                    const SizedBox(width: 10),
                  ] else if (icon != null) ...[
                    IconTheme(
                      data: IconThemeData(color: fg, size: _iconSize),
                      child: icon!,
                    ),
                    const SizedBox(width: 8),
                  ],
                  Text(
                    label,
                    style: textStyle.copyWith(color: fg),
                  ),
                  if (trailing != null) ...[
                    const SizedBox(width: 8),
                    IconTheme(
                      data: IconThemeData(color: fg, size: _iconSize),
                      child: trailing!,
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  double get _height {
    switch (size) {
      case PPButtonSize.lg: return PPSpacing.btnHeightLG;
      case PPButtonSize.md: return PPSpacing.btnHeightMD;
      case PPButtonSize.sm: return PPSpacing.btnHeightSM;
      case PPButtonSize.xs: return PPSpacing.btnHeightXS;
    }
  }

  double get _horizontalPad {
    switch (size) {
      case PPButtonSize.lg: return 24;
      case PPButtonSize.md: return 20;
      case PPButtonSize.sm: return 16;
      case PPButtonSize.xs: return 12;
    }
  }

  double get _iconSize {
    switch (size) {
      case PPButtonSize.lg: return 20;
      case PPButtonSize.md: return 18;
      case PPButtonSize.sm: return 16;
      case PPButtonSize.xs: return 14;
    }
  }

  TextStyle get _textStyle {
    switch (size) {
      case PPButtonSize.lg: return PPTypography.buttonLG;
      case PPButtonSize.md: return PPTypography.buttonMD;
      case PPButtonSize.sm: return PPTypography.buttonSM;
      case PPButtonSize.xs: return PPTypography.buttonSM;
    }
  }

  Color _backgroundColor(bool isDark) {
    switch (variant) {
      case PPButtonVariant.primary:
        return PPColors.brand;
      case PPButtonVariant.secondary:
        return isDark ? PPColors.darkSurface2 : PPColors.lightSurface2;
      case PPButtonVariant.outline:
        return Colors.transparent;
      case PPButtonVariant.ghost:
        return Colors.transparent;
      case PPButtonVariant.danger:
        return PPColors.error;
    }
  }

  Color _foregroundColor(bool isDark) {
    switch (variant) {
      case PPButtonVariant.primary:
        return Colors.black;
      case PPButtonVariant.secondary:
        return isDark ? PPColors.darkText : PPColors.lightText;
      case PPButtonVariant.outline:
        return PPColors.brand;
      case PPButtonVariant.ghost:
        return isDark ? PPColors.darkTextSecondary : PPColors.lightTextSecondary;
      case PPButtonVariant.danger:
        return Colors.white;
    }
  }

  Border? _border(bool isDark) {
    switch (variant) {
      case PPButtonVariant.outline:
        return Border.all(color: PPColors.brand, width: 1.5);
      case PPButtonVariant.secondary:
        return Border.all(
          color: isDark ? PPColors.darkBorder : PPColors.lightBorder,
          width: 1,
        );
      default:
        return null;
    }
  }
}
