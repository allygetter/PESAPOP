// lib/core/theme/app_theme.dart
// PESAPOP AI — Complete Theme Configuration

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'app_colors.dart';
import 'app_typography.dart';
import 'app_spacing.dart';

class PPTheme {
  PPTheme._();

  // ─────────────────────────────────────────────────────────
  //  DARK THEME
  // ─────────────────────────────────────────────────────────
  static ThemeData get dark => ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    scaffoldBackgroundColor: PPColors.darkBg,
    primaryColor: PPColors.brand,

    colorScheme: const ColorScheme.dark(
      primary: PPColors.brand,
      onPrimary: Colors.black,
      primaryContainer: PPColors.darkSurface2,
      secondary: PPColors.accent,
      onSecondary: Colors.white,
      surface: PPColors.darkSurface,
      onSurface: PPColors.darkText,
      error: PPColors.error,
      onError: Colors.white,
      outline: PPColors.darkBorder,
    ),

    // ── AppBar ──────────────────────────────────────────
    appBarTheme: const AppBarTheme(
      backgroundColor: PPColors.darkBg,
      foregroundColor: PPColors.darkText,
      elevation: 0,
      scrolledUnderElevation: 0,
      centerTitle: false,
      systemOverlayStyle: SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.light,
        systemNavigationBarColor: PPColors.darkBg,
        systemNavigationBarIconBrightness: Brightness.light,
      ),
      titleTextStyle: TextStyle(
        fontFamily: 'Sora',
        fontSize: 18,
        fontWeight: FontWeight.w600,
        color: PPColors.darkText,
      ),
    ),

    // ── Card ────────────────────────────────────────────
    cardTheme: CardThemeData(
      color: PPColors.darkSurface,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(PPSpacing.radiusLG),
        side: const BorderSide(color: PPColors.darkBorder, width: 1),
      ),
      margin: EdgeInsets.zero,
    ),

    // ── Input Decoration ────────────────────────────────
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: PPColors.darkSurface3,
      contentPadding: const EdgeInsets.symmetric(
        horizontal: 16,
        vertical: 14,
      ),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(PPSpacing.radiusMD),
        borderSide: const BorderSide(color: PPColors.darkBorder),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(PPSpacing.radiusMD),
        borderSide: const BorderSide(color: PPColors.darkBorder),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(PPSpacing.radiusMD),
        borderSide: const BorderSide(color: PPColors.brand, width: 1.5),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(PPSpacing.radiusMD),
        borderSide: const BorderSide(color: PPColors.error),
      ),
      hintStyle: PPTypography.bodyMD.copyWith(color: PPColors.darkTextMuted),
      labelStyle: PPTypography.labelMD.copyWith(color: PPColors.darkTextSecondary),
      prefixIconColor: PPColors.darkTextSecondary,
      suffixIconColor: PPColors.darkTextSecondary,
    ),

    // ── ElevatedButton ──────────────────────────────────
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: PPColors.brand,
        foregroundColor: Colors.black,
        elevation: 0,
        minimumSize: const Size(double.infinity, PPSpacing.btnHeightMD),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(PPSpacing.radiusMD),
        ),
        textStyle: PPTypography.buttonMD,
      ),
    ),

    // ── OutlinedButton ──────────────────────────────────
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: PPColors.brand,
        side: const BorderSide(color: PPColors.brand, width: 1.5),
        minimumSize: const Size(double.infinity, PPSpacing.btnHeightMD),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(PPSpacing.radiusMD),
        ),
        textStyle: PPTypography.buttonMD,
      ),
    ),

    // ── TextButton ──────────────────────────────────────
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: PPColors.brand,
        textStyle: PPTypography.buttonMD,
      ),
    ),

    // ── Chip ────────────────────────────────────────────
    chipTheme: ChipThemeData(
      backgroundColor: PPColors.darkSurface2,
      labelStyle: PPTypography.labelSM.copyWith(color: PPColors.darkText),
      side: const BorderSide(color: PPColors.darkBorder),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(PPSpacing.radiusFull),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
    ),

    // ── Divider ─────────────────────────────────────────
    dividerTheme: const DividerThemeData(
      color: PPColors.darkBorder,
      thickness: 1,
      space: 1,
    ),

    // ── Bottom Navigation ────────────────────────────────
    navigationBarTheme: NavigationBarThemeData(
      backgroundColor: PPColors.darkSurface,
      indicatorColor: PPColors.brand.withOpacity(0.15),
      iconTheme: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.selected)) {
          return const IconThemeData(color: PPColors.brand, size: 22);
        }
        return const IconThemeData(color: PPColors.darkTextSecondary, size: 22);
      }),
      labelTextStyle: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.selected)) {
          return PPTypography.labelXS.copyWith(color: PPColors.brand);
        }
        return PPTypography.labelXS.copyWith(color: PPColors.darkTextSecondary);
      }),
      elevation: 0,
    ),

    // ── BottomSheet ─────────────────────────────────────
    bottomSheetTheme: const BottomSheetThemeData(
      backgroundColor: PPColors.darkSurface,
      modalBackgroundColor: PPColors.darkSurface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(PPSpacing.radiusXXL),
        ),
      ),
      elevation: 0,
    ),

    // ── Dialog ──────────────────────────────────────────
    dialogTheme: DialogThemeData(
      backgroundColor: PPColors.darkSurface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(PPSpacing.radiusXL),
      ),
      elevation: 0,
    ),

    // ── Snackbar ────────────────────────────────────────
    snackBarTheme: SnackBarThemeData(
      backgroundColor: PPColors.darkSurface2,
      contentTextStyle: PPTypography.bodyMD.copyWith(color: PPColors.darkText),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(PPSpacing.radiusMD),
      ),
      behavior: SnackBarBehavior.floating,
    ),

    // ── Switch ──────────────────────────────────────────
    switchTheme: SwitchThemeData(
      thumbColor: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.selected)) return PPColors.brand;
        return PPColors.darkTextMuted;
      }),
      trackColor: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.selected)) {
          return PPColors.brand.withOpacity(0.3);
        }
        return PPColors.darkSurface3;
      }),
    ),

    // ── Text ────────────────────────────────────────────
    textTheme: TextTheme(
      displayLarge: PPTypography.displayXL.copyWith(color: PPColors.darkText),
      displayMedium: PPTypography.displayLG.copyWith(color: PPColors.darkText),
      displaySmall: PPTypography.displayMD.copyWith(color: PPColors.darkText),
      headlineLarge: PPTypography.headingXL.copyWith(color: PPColors.darkText),
      headlineMedium: PPTypography.headingLG.copyWith(color: PPColors.darkText),
      headlineSmall: PPTypography.headingMD.copyWith(color: PPColors.darkText),
      titleLarge: PPTypography.headingSM.copyWith(color: PPColors.darkText),
      bodyLarge: PPTypography.bodyLG.copyWith(color: PPColors.darkText),
      bodyMedium: PPTypography.bodyMD.copyWith(color: PPColors.darkText),
      bodySmall: PPTypography.bodySM.copyWith(color: PPColors.darkTextSecondary),
      labelLarge: PPTypography.labelLG.copyWith(color: PPColors.darkText),
      labelMedium: PPTypography.labelMD.copyWith(color: PPColors.darkTextSecondary),
      labelSmall: PPTypography.labelSM.copyWith(color: PPColors.darkTextMuted),
    ),
  );

  // ─────────────────────────────────────────────────────────
  //  LIGHT THEME
  // ─────────────────────────────────────────────────────────
  static ThemeData get light => ThemeData(
    useMaterial3: true,
    brightness: Brightness.light,
    scaffoldBackgroundColor: PPColors.lightBg,
    primaryColor: PPColors.brand,

    colorScheme: const ColorScheme.light(
      primary: PPColors.brand,
      onPrimary: Colors.black,
      primaryContainer: PPColors.brandSurface,
      secondary: PPColors.accent,
      onSecondary: Colors.white,
      surface: PPColors.lightSurface,
      onSurface: PPColors.lightText,
      error: PPColors.error,
      onError: Colors.white,
      outline: PPColors.lightBorder,
    ),

    // ── AppBar ──────────────────────────────────────────
    appBarTheme: const AppBarTheme(
      backgroundColor: PPColors.lightBg,
      foregroundColor: PPColors.lightText,
      elevation: 0,
      scrolledUnderElevation: 0,
      centerTitle: false,
      systemOverlayStyle: SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.dark,
        systemNavigationBarColor: PPColors.lightBg,
        systemNavigationBarIconBrightness: Brightness.dark,
      ),
      titleTextStyle: TextStyle(
        fontFamily: 'Sora',
        fontSize: 18,
        fontWeight: FontWeight.w600,
        color: PPColors.lightText,
      ),
    ),

    // ── Card ────────────────────────────────────────────
    cardTheme: CardThemeData(
      color: PPColors.lightSurface,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(PPSpacing.radiusLG),
        side: const BorderSide(color: PPColors.lightBorder, width: 1),
      ),
      margin: EdgeInsets.zero,
      shadowColor: PPColors.brand.withOpacity(0.06),
    ),

    // ── Input Decoration ────────────────────────────────
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: PPColors.lightSurface3,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(PPSpacing.radiusMD),
        borderSide: const BorderSide(color: PPColors.lightBorder),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(PPSpacing.radiusMD),
        borderSide: const BorderSide(color: PPColors.lightBorder),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(PPSpacing.radiusMD),
        borderSide: const BorderSide(color: PPColors.brand, width: 1.5),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(PPSpacing.radiusMD),
        borderSide: const BorderSide(color: PPColors.error),
      ),
      hintStyle: PPTypography.bodyMD.copyWith(color: PPColors.lightTextMuted),
      labelStyle: PPTypography.labelMD.copyWith(color: PPColors.lightTextSecondary),
    ),

    // ── ElevatedButton ──────────────────────────────────
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: PPColors.brand,
        foregroundColor: Colors.black,
        elevation: 0,
        minimumSize: const Size(double.infinity, PPSpacing.btnHeightMD),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(PPSpacing.radiusMD),
        ),
        textStyle: PPTypography.buttonMD,
      ),
    ),

    // ── OutlinedButton ──────────────────────────────────
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: PPColors.brand,
        side: const BorderSide(color: PPColors.brand, width: 1.5),
        minimumSize: const Size(double.infinity, PPSpacing.btnHeightMD),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(PPSpacing.radiusMD),
        ),
        textStyle: PPTypography.buttonMD,
      ),
    ),

    // ── Navigation Bar ──────────────────────────────────
    navigationBarTheme: NavigationBarThemeData(
      backgroundColor: PPColors.lightSurface,
      indicatorColor: PPColors.brandSurface,
      iconTheme: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.selected)) {
          return const IconThemeData(color: PPColors.brand, size: 22);
        }
        return const IconThemeData(color: PPColors.lightTextSecondary, size: 22);
      }),
      labelTextStyle: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.selected)) {
          return PPTypography.labelXS.copyWith(color: PPColors.brand);
        }
        return PPTypography.labelXS.copyWith(
          color: PPColors.lightTextSecondary,
        );
      }),
      elevation: 0,
    ),

    // ── BottomSheet ─────────────────────────────────────
    bottomSheetTheme: const BottomSheetThemeData(
      backgroundColor: PPColors.lightSurface,
      modalBackgroundColor: PPColors.lightSurface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(PPSpacing.radiusXXL),
        ),
      ),
      elevation: 0,
    ),

    // ── Divider ─────────────────────────────────────────
    dividerTheme: const DividerThemeData(
      color: PPColors.lightBorder,
      thickness: 1,
      space: 1,
    ),

    // ── Switch ──────────────────────────────────────────
    switchTheme: SwitchThemeData(
      thumbColor: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.selected)) return PPColors.brand;
        return Colors.white;
      }),
      trackColor: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.selected)) {
          return PPColors.brand.withOpacity(0.4);
        }
        return PPColors.lightBorder;
      }),
    ),

    // ── Snackbar ────────────────────────────────────────
    snackBarTheme: SnackBarThemeData(
      backgroundColor: PPColors.lightText,
      contentTextStyle: PPTypography.bodyMD.copyWith(color: Colors.white),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(PPSpacing.radiusMD),
      ),
      behavior: SnackBarBehavior.floating,
    ),

    // ── Text ────────────────────────────────────────────
    textTheme: TextTheme(
      displayLarge: PPTypography.displayXL.copyWith(color: PPColors.lightText),
      displayMedium: PPTypography.displayLG.copyWith(color: PPColors.lightText),
      displaySmall: PPTypography.displayMD.copyWith(color: PPColors.lightText),
      headlineLarge: PPTypography.headingXL.copyWith(color: PPColors.lightText),
      headlineMedium: PPTypography.headingLG.copyWith(color: PPColors.lightText),
      headlineSmall: PPTypography.headingMD.copyWith(color: PPColors.lightText),
      titleLarge: PPTypography.headingSM.copyWith(color: PPColors.lightText),
      bodyLarge: PPTypography.bodyLG.copyWith(color: PPColors.lightText),
      bodyMedium: PPTypography.bodyMD.copyWith(color: PPColors.lightText),
      bodySmall: PPTypography.bodySM.copyWith(color: PPColors.lightTextSecondary),
      labelLarge: PPTypography.labelLG.copyWith(color: PPColors.lightText),
      labelMedium: PPTypography.labelMD.copyWith(color: PPColors.lightTextSecondary),
      labelSmall: PPTypography.labelSM.copyWith(color: PPColors.lightTextMuted),
    ),
  );
}
