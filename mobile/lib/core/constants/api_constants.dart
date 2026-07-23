// lib/core/constants/api_constants.dart
class ApiConstants {
  ApiConstants._();

  // Change to your production URL before release
  static const String baseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'http://10.0.2.2:4000/api/v1', // Android emulator → localhost
    // For iOS simulator use: 'http://127.0.0.1:4000/api/v1'
    // For production: 'https://api.pesapop.africa/api/v1'
  );

  // Auth
  static const String requestOtp = '/auth/request-otp';
  static const String verifyOtp  = '/auth/verify-otp';
  static const String register   = '/auth/register';
  static const String refresh    = '/auth/refresh';
  static const String logout     = '/auth/logout';
  static const String me         = '/auth/me';

  // Products
  static const String products      = '/products';
  static const String lowStock      = '/products/low-stock';
  static String productById(String id) => '/products/$id';
  static String productByBarcode(String code) => '/products/barcode/$code';

  // Sales
  static const String sales        = '/sales';
  static const String todaySummary = '/sales/summary/today';
  static String saleById(String id) => '/sales/$id';

  // Inventory
  static const String inventory       = '/inventory';
  static const String inventoryStats  = '/inventory/stats';
  static const String inventoryAlerts = '/inventory/low-stock';
  static const String movements       = '/inventory/movements';
  static const String stockIn         = '/inventory/stock-in';
  static const String stockAdjust     = '/inventory/adjust';
  static const String stockTransfer   = '/inventory/transfer';

  // Payments
  static const String mpesaStk = '/payments/mpesa/stk';
  static String paymentStatus(String saleId) => '/payments/$saleId/status';

  // Customers
  static const String customers = '/customers';
  static String customerById(String id) => '/customers/$id';

  // Analytics
  static const String dashboard  = '/analytics/dashboard';
  static const String profitLoss = '/analytics/profit-loss';

  // AI
  static const String aiChat = '/ai/chat';
}
