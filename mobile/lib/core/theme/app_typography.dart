// lib/core/theme/app_typography.dart
// PESAPOP AI — Typography System
// Display: Sora (headings, titles, branding)
// Body: DM Sans (UI text, labels, paragraphs)

import 'package:flutter/material.dart';

class PPTypography {
  PPTypography._();

  // ── Display / Headings (Sora) ──────────────────────────
  static const TextStyle displayXL = TextStyle(
    fontFamily: 'Sora',
    fontSize: 40,
    fontWeight: FontWeight.w700,
    letterSpacing: -1.2,
    height: 1.1,
  );

  static const TextStyle displayLG = TextStyle(
    fontFamily: 'Sora',
    fontSize: 32,
    fontWeight: FontWeight.w700,
    letterSpacing: -0.8,
    height: 1.15,
  );

  static const TextStyle displayMD = TextStyle(
    fontFamily: 'Sora',
    fontSize: 26,
    fontWeight: FontWeight.w600,
    letterSpacing: -0.5,
    height: 1.2,
  );

  static const TextStyle displaySM = TextStyle(
    fontFamily: 'Sora',
    fontSize: 22,
    fontWeight: FontWeight.w600,
    letterSpacing: -0.3,
    height: 1.25,
  );

  // ── Headings (Sora) ─────────────────────────────────────
  static const TextStyle headingXL = TextStyle(
    fontFamily: 'Sora',
    fontSize: 20,
    fontWeight: FontWeight.w600,
    letterSpacing: -0.2,
    height: 1.3,
  );

  static const TextStyle headingLG = TextStyle(
    fontFamily: 'Sora',
    fontSize: 18,
    fontWeight: FontWeight.w600,
    letterSpacing: -0.1,
    height: 1.35,
  );

  static const TextStyle headingMD = TextStyle(
    fontFamily: 'Sora',
    fontSize: 16,
    fontWeight: FontWeight.w600,
    height: 1.4,
  );

  static const TextStyle headingSM = TextStyle(
    fontFamily: 'Sora',
    fontSize: 14,
    fontWeight: FontWeight.w600,
    height: 1.4,
  );

  // ── Body (DM Sans) ──────────────────────────────────────
  static const TextStyle bodyLG = TextStyle(
    fontFamily: 'DM Sans',
    fontSize: 16,
    fontWeight: FontWeight.w400,
    height: 1.6,
  );

  static const TextStyle bodyMD = TextStyle(
    fontFamily: 'DM Sans',
    fontSize: 14,
    fontWeight: FontWeight.w400,
    height: 1.55,
  );

  static const TextStyle bodySM = TextStyle(
    fontFamily: 'DM Sans',
    fontSize: 13,
    fontWeight: FontWeight.w400,
    height: 1.5,
  );

  static const TextStyle bodyXS = TextStyle(
    fontFamily: 'DM Sans',
    fontSize: 12,
    fontWeight: FontWeight.w400,
    height: 1.5,
  );

  // ── Labels / UI Text (DM Sans) ──────────────────────────
  static const TextStyle labelLG = TextStyle(
    fontFamily: 'DM Sans',
    fontSize: 14,
    fontWeight: FontWeight.w500,
    letterSpacing: 0.1,
    height: 1.4,
  );

  static const TextStyle labelMD = TextStyle(
    fontFamily: 'DM Sans',
    fontSize: 13,
    fontWeight: FontWeight.w500,
    letterSpacing: 0.1,
    height: 1.4,
  );

  static const TextStyle labelSM = TextStyle(
    fontFamily: 'DM Sans',
    fontSize: 11,
    fontWeight: FontWeight.w500,
    letterSpacing: 0.3,
    height: 1.4,
  );

  static const TextStyle labelXS = TextStyle(
    fontFamily: 'DM Sans',
    fontSize: 10,
    fontWeight: FontWeight.w600,
    letterSpacing: 0.5,
    height: 1.4,
  );

  // ── Numbers / Metrics (Sora — for financial data) ───────
  static const TextStyle metricXL = TextStyle(
    fontFamily: 'Sora',
    fontSize: 36,
    fontWeight: FontWeight.w700,
    letterSpacing: -1.0,
    height: 1.0,
  );

  static const TextStyle metricLG = TextStyle(
    fontFamily: 'Sora',
    fontSize: 28,
    fontWeight: FontWeight.w700,
    letterSpacing: -0.8,
    height: 1.0,
  );

  static const TextStyle metricMD = TextStyle(
    fontFamily: 'Sora',
    fontSize: 22,
    fontWeight: FontWeight.w700,
    letterSpacing: -0.5,
    height: 1.0,
  );

  static const TextStyle metricSM = TextStyle(
    fontFamily: 'Sora',
    fontSize: 18,
    fontWeight: FontWeight.w600,
    letterSpacing: -0.3,
    height: 1.0,
  );

  // ── Buttons ─────────────────────────────────────────────
  static const TextStyle buttonLG = TextStyle(
    fontFamily: 'DM Sans',
    fontSize: 16,
    fontWeight: FontWeight.w600,
    letterSpacing: 0.2,
  );

  static const TextStyle buttonMD = TextStyle(
    fontFamily: 'DM Sans',
    fontSize: 14,
    fontWeight: FontWeight.w600,
    letterSpacing: 0.2,
  );

  static const TextStyle buttonSM = TextStyle(
    fontFamily: 'DM Sans',
    fontSize: 12,
    fontWeight: FontWeight.w600,
    letterSpacing: 0.3,
  );

  // ── Monospace (for codes, IDs, transactions) ────────────
  static const TextStyle mono = TextStyle(
    fontFamily: 'Courier Prime',
    fontSize: 13,
    fontWeight: FontWeight.w400,
    letterSpacing: 0.5,
  );
}
