// lib/core/theme/app_colors.dart
// PESAPOP AI — Design System Color Tokens

import 'package:flutter/material.dart';

/// ─────────────────────────────────────────────
///  PESAPOP Brand Colors
/// ─────────────────────────────────────────────
class PPColors {
  PPColors._();

  // ── Brand Primary ──────────────────────────
  static const Color brand = Color(0xFF00C896);       // PESAPOP Green
  static const Color brandDark = Color(0xFF00A87E);   // Pressed state
  static const Color brandLight = Color(0xFF00E5AB);  // Hover / highlight
  static const Color brandSurface = Color(0xFFE6FBF5);// Light brand bg

  // ── Accent ─────────────────────────────────
  static const Color accent = Color(0xFFFF6B35);      // Orange — alerts, CTAs
  static const Color accentDark = Color(0xFFE55A26);
  static const Color accentLight = Color(0xFFFF8F63);
  static const Color accentSurface = Color(0xFFFFF0EB);

  // ── Gold / Premium ──────────────────────────
  static const Color gold = Color(0xFFFFB800);
  static const Color goldSurface = Color(0xFFFFF8E1);

  // ──────────────────────────────────────────
  //  DARK THEME
  // ──────────────────────────────────────────

  static const Color darkBg = Color(0xFF0A0F0D);       // Deepest bg
  static const Color darkSurface = Color(0xFF111916);  // Card bg
  static const Color darkSurface2 = Color(0xFF1A2420); // Elevated card
  static const Color darkSurface3 = Color(0xFF233029); // Input bg
  static const Color darkBorder = Color(0xFF2C3E35);   // Dividers
  static const Color darkBorderBright = Color(0xFF3D5A4E); // Focused borders

  static const Color darkText = Color(0xFFF0FAF6);     // Primary text
  static const Color darkTextSecondary = Color(0xFF8BA89C); // Body / labels
  static const Color darkTextMuted = Color(0xFF4D6B5E); // Placeholder

  // ──────────────────────────────────────────
  //  LIGHT THEME
  // ──────────────────────────────────────────

  static const Color lightBg = Color(0xFFF5FAF8);      // App background
  static const Color lightSurface = Color(0xFFFFFFFF); // Card bg
  static const Color lightSurface2 = Color(0xFFF0F7F4);// Elevated sections
  static const Color lightSurface3 = Color(0xFFE8F5F0);// Input bg
  static const Color lightBorder = Color(0xFFD8EDE6);  // Dividers
  static const Color lightBorderBright = Color(0xFF8AC8B5); // Focused borders

  static const Color lightText = Color(0xFF0D2218);    // Primary text
  static const Color lightTextSecondary = Color(0xFF4D7A66); // Body
  static const Color lightTextMuted = Color(0xFF8CB5A5); // Placeholder

  // ──────────────────────────────────────────
  //  SEMANTIC COLORS
  // ──────────────────────────────────────────

  static const Color success = Color(0xFF00C896);
  static const Color successSurface = Color(0xFFE6FBF5);

  static const Color warning = Color(0xFFFFB800);
  static const Color warningSurface = Color(0xFFFFF8E1);

  static const Color error = Color(0xFFFF3B5C);
  static const Color errorSurface = Color(0xFFFFECEF);

  static const Color info = Color(0xFF2196F3);
  static const Color infoSurface = Color(0xFFE3F2FD);

  // ──────────────────────────────────────────
  //  PAYMENT METHOD COLORS
  // ──────────────────────────────────────────

  static const Color mpesa = Color(0xFF00A651);
  static const Color airtelMoney = Color(0xFFE40000);
  static const Color mtnMoney = Color(0xFFFFCC00);
  static const Color visa = Color(0xFF1A1F71);
  static const Color mastercard = Color(0xFFEB001B);
  static const Color paypal = Color(0xFF003087);
  static const Color stripe = Color(0xFF635BFF);
  static const Color flutterwave = Color(0xFFF5A623);

  // ──────────────────────────────────────────
  //  CHART PALETTE
  // ──────────────────────────────────────────

  static const List<Color> chartColors = [
    Color(0xFF00C896),  // Brand green
    Color(0xFFFF6B35),  // Orange
    Color(0xFFFFB800),  // Gold
    Color(0xFF2196F3),  // Blue
    Color(0xFFAB47BC),  // Purple
    Color(0xFF26C6DA),  // Cyan
    Color(0xFFEF5350),  // Red
    Color(0xFF66BB6A),  // Light green
  ];
}
