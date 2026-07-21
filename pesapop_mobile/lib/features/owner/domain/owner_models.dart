// lib/features/owner/domain/owner_models.dart — updated with fromJson

class RevenuePoint {
  const RevenuePoint({required this.label, required this.value});
  final String label;
  final double value;

  factory RevenuePoint.fromJson(Map<String, dynamic> j) =>
      RevenuePoint(label: j['label'] as String, value: (j['value'] as num).toDouble());
}

class TopProduct {
  const TopProduct({required this.name, required this.revenue, required this.units, required this.pct});
  final String name;
  final double revenue;
  final int units;
  final double pct;

  factory TopProduct.fromJson(Map<String, dynamic> j) => TopProduct(
    name: j['name'] as String,
    revenue: (j['revenue'] as num).toDouble(),
    units: j['units'] as int? ?? 0,
    pct: (j['pct'] as num?)?.toDouble() ?? 0,
  );
}

class OwnerStats {
  const OwnerStats({
    required this.monthRevenue, required this.monthProfit, required this.monthExpenses,
    required this.profitMargin, required this.totalCustomers, required this.newCustomers,
    required this.revenueChart, required this.topProducts, required this.paymentBreakdown,
    this.transactionCount = 0, this.avgOrderValue = 0, this.revenueTrend = 0,
  });

  final double monthRevenue;
  final double monthProfit;
  final double monthExpenses;
  final double profitMargin;
  final int totalCustomers;
  final int newCustomers;
  final List<RevenuePoint> revenueChart;
  final List<TopProduct> topProducts;
  final Map<String, double> paymentBreakdown;
  final int transactionCount;
  final double avgOrderValue;
  final double revenueTrend;

  factory OwnerStats.fromJson(Map<String, dynamic> j) => OwnerStats(
    monthRevenue: (j['revenue'] as num?)?.toDouble() ?? 0,
    monthProfit: (j['profit'] as num?)?.toDouble() ?? 0,
    monthExpenses: (j['expenses'] as num?)?.toDouble() ?? 0,
    profitMargin: (j['profitMargin'] as num?)?.toDouble() ?? 0,
    totalCustomers: j['customers'] as int? ?? 0,
    newCustomers: j['newCustomers'] as int? ?? 0,
    transactionCount: j['transactionCount'] as int? ?? 0,
    avgOrderValue: (j['avgOrderValue'] as num?)?.toDouble() ?? 0,
    revenueTrend: (j['revenueTrend'] as num?)?.toDouble() ?? 0,
    revenueChart: (j['revenueChart'] as List<dynamic>? ?? [])
        .map((e) => RevenuePoint.fromJson(e as Map<String, dynamic>))
        .toList(),
    topProducts: (j['topProducts'] as List<dynamic>? ?? [])
        .map((e) => TopProduct.fromJson(e as Map<String, dynamic>))
        .toList(),
    paymentBreakdown: (j['paymentBreakdown'] as Map<String, dynamic>? ?? {})
        .map((k, v) => MapEntry(k, (v as num).toDouble())),
  );

  // Fallback while loading
  static OwnerStats get empty => OwnerStats(
    monthRevenue: 0, monthProfit: 0, monthExpenses: 0, profitMargin: 0,
    totalCustomers: 0, newCustomers: 0, revenueChart: [], topProducts: [],
    paymentBreakdown: {},
  );
}

class AIMessage {
  const AIMessage({required this.role, required this.content, this.isLoading = false});
  final String role;
  final String content;
  final bool isLoading;
}
