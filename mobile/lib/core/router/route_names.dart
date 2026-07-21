// lib/core/router/route_names.dart
// PESAPOP AI — Route Name Constants

class PPRoutes {
  PPRoutes._();

  // ── Auth ────────────────────────────────────────────
  static const String splash = '/';
  static const String login = '/login';
  static const String otp = '/otp';
  static const String onboarding = '/onboarding';

  // ── Cashier App ─────────────────────────────────────
  static const String cashierHome = '/cashier';
  static const String pos = '/cashier/pos';
  static const String cart = '/cashier/cart';
  static const String payment = '/cashier/payment';
  static const String receipt = '/cashier/receipt';
  static const String refund = '/cashier/refund';
  static const String cashierInventory = '/cashier/inventory';
  static const String productDetail = '/cashier/product/:id';

  // ── Owner App ────────────────────────────────────────
  static const String ownerHome = '/owner';
  static const String reports = '/owner/reports';
  static const String employees = '/owner/employees';
  static const String aiAssistant = '/owner/ai';
  static const String ownerInventory = '/owner/inventory';

  // ── Shared ──────────────────────────────────────────
  static const String settings = '/settings';
  static const String profile = '/settings/profile';
  static const String notifications = '/notifications';
}
