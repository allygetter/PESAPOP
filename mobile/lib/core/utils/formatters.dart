// lib/core/utils/formatters.dart
// PESAPOP AI — Formatting Utilities

import 'package:intl/intl.dart';

class PPFormatter {
  PPFormatter._();

  // ── Currency Formatters ─────────────────────────────────
  static String currency(
    double amount, {
    String symbol = 'KES',
    bool compact = false,
  }) {
    if (compact) {
      return '$symbol ${_compact(amount)}';
    }
    final formatter = NumberFormat('#,##0.00', 'en_KE');
    return '$symbol ${formatter.format(amount)}';
  }

  static String ksh(double amount, {bool compact = false}) =>
      currency(amount, symbol: 'KES', compact: compact);

  static String usd(double amount, {bool compact = false}) =>
      currency(amount, symbol: '\$', compact: compact);

  static String _compact(double amount) {
    if (amount >= 1000000000) {
      return '${(amount / 1000000000).toStringAsFixed(1)}B';
    } else if (amount >= 1000000) {
      return '${(amount / 1000000).toStringAsFixed(1)}M';
    } else if (amount >= 1000) {
      return '${(amount / 1000).toStringAsFixed(1)}K';
    }
    return amount.toStringAsFixed(0);
  }

  // ── Number Formatters ───────────────────────────────────
  static String number(double n) {
    return NumberFormat('#,##0', 'en_KE').format(n);
  }

  static String percentage(double n, {int decimals = 1}) {
    return '${n.toStringAsFixed(decimals)}%';
  }

  static String compactNumber(double n) => _compact(n);

  // ── Date/Time Formatters ────────────────────────────────
  static String date(DateTime dt) {
    return DateFormat('dd MMM yyyy').format(dt);
  }

  static String dateShort(DateTime dt) {
    return DateFormat('dd MMM').format(dt);
  }

  static String dateTime(DateTime dt) {
    return DateFormat('dd MMM yyyy, hh:mm a').format(dt);
  }

  static String time(DateTime dt) {
    return DateFormat('hh:mm a').format(dt);
  }

  static String timeAgo(DateTime dt) {
    final now = DateTime.now();
    final diff = now.difference(dt);
    if (diff.inSeconds < 60) return 'Just now';
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    if (diff.inDays < 7) return '${diff.inDays}d ago';
    return date(dt);
  }

  // ── Phone Formatter ─────────────────────────────────────
  static String phone(String phone) {
    // Format Kenyan numbers: +254 7XX XXX XXX
    final cleaned = phone.replaceAll(RegExp(r'\D'), '');
    if (cleaned.length == 12 && cleaned.startsWith('254')) {
      return '+${cleaned.substring(0, 3)} ${cleaned.substring(3, 6)} ${cleaned.substring(6, 9)} ${cleaned.substring(9)}';
    }
    return phone;
  }

  // ── Transaction ID ──────────────────────────────────────
  static String transactionId() {
    final now = DateTime.now();
    return 'TXN${DateFormat('yyyyMMdd').format(now)}${now.millisecond.toString().padLeft(3, '0')}';
  }

  // ── Receipt Number ──────────────────────────────────────
  static String receiptNumber(int seq) {
    return 'RCP${seq.toString().padLeft(6, '0')}';
  }
}
