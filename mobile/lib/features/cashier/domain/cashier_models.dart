// lib/features/cashier/domain/cashier_models.dart
import 'package:flutter/material.dart';

class PPProduct {
  const PPProduct({
    required this.id,
    required this.name,
    required this.price,
    required this.category,
    required this.stockQty,
    this.barcode,
    this.imageUrl,
    this.unit = 'pcs',
    this.taxRate = 0.16,
    this.isVatExempt = false,
    this.reorderLevel = 5,
    this.isLowStock = false,
  });

  final String id;
  final String name;
  final double price;
  final String category;
  final int stockQty;
  final String? barcode;
  final String? imageUrl;
  final String unit;
  final double taxRate;
  final bool isVatExempt;
  final int reorderLevel;
  final bool isLowStock;

  bool get isOutOfStock => stockQty == 0;
  double get priceWithTax => isVatExempt ? price : price * (1 + taxRate);

  factory PPProduct.fromJson(Map<String, dynamic> json) {
    return PPProduct(
      id: json['id'] as String,
      name: json['name'] as String,
      price: (json['price'] as num).toDouble(),
      category: (json['category'] as Map<String, dynamic>?)?['name'] as String? ?? 'General',
      stockQty: json['stockQty'] as int? ?? 0,
      barcode: json['barcode'] as String?,
      imageUrl: json['imageUrl'] as String?,
      unit: json['unit'] as String? ?? 'pcs',
      taxRate: (json['taxRate'] as num?)?.toDouble() ?? 0.16,
      isVatExempt: json['isVatExempt'] as bool? ?? false,
      reorderLevel: json['reorderLevel'] as int? ?? 5,
      isLowStock: json['isLowStock'] as bool? ?? false,
    );
  }
}

class CartItem {
  const CartItem({required this.product, required this.qty, this.discount = 0, this.note});
  final PPProduct product;
  final int qty;
  final double discount;
  final String? note;

  double get subtotal => (product.price * qty) - discount;
  double get tax => product.isVatExempt ? 0 : subtotal * product.taxRate;
  double get total => subtotal + tax;

  CartItem copyWith({int? qty, double? discount, String? note}) =>
      CartItem(product: product, qty: qty ?? this.qty, discount: discount ?? this.discount, note: note ?? this.note);
}

class CartState {
  const CartState({this.items = const [], this.couponCode, this.couponDiscount = 0, this.customerId, this.customerName});
  final List<CartItem> items;
  final String? couponCode;
  final double couponDiscount;
  final String? customerId;
  final String? customerName;

  bool get isEmpty => items.isEmpty;
  int get itemCount => items.fold(0, (s, i) => s + i.qty);
  double get subtotal => items.fold(0.0, (s, i) => s + i.subtotal);
  double get taxTotal => items.fold(0.0, (s, i) => s + i.tax);
  double get totalDiscount => items.fold(0.0, (s, i) => s + i.discount) + couponDiscount;
  double get grandTotal => subtotal + taxTotal - couponDiscount;

  CartState copyWith({List<CartItem>? items, String? couponCode, double? couponDiscount, String? customerId, String? customerName}) =>
      CartState(
        items: items ?? this.items,
        couponCode: couponCode ?? this.couponCode,
        couponDiscount: couponDiscount ?? this.couponDiscount,
        customerId: customerId ?? this.customerId,
        customerName: customerName ?? this.customerName,
      );
}

enum PaymentMethodType { mpesa, airtelMoney, cash, visa, mastercard, bankTransfer, loyalty }

extension PaymentMethodExt on PaymentMethodType {
  String get label {
    switch (this) {
      case PaymentMethodType.mpesa: return 'M-Pesa';
      case PaymentMethodType.airtelMoney: return 'Airtel Money';
      case PaymentMethodType.cash: return 'Cash';
      case PaymentMethodType.visa: return 'Visa';
      case PaymentMethodType.mastercard: return 'Mastercard';
      case PaymentMethodType.bankTransfer: return 'Bank Transfer';
      case PaymentMethodType.loyalty: return 'Loyalty Points';
    }
  }
  Color get color {
    switch (this) {
      case PaymentMethodType.mpesa: return const Color(0xFF00A651);
      case PaymentMethodType.airtelMoney: return const Color(0xFFE40000);
      case PaymentMethodType.cash: return const Color(0xFF00C896);
      case PaymentMethodType.visa: return const Color(0xFF1A1F71);
      case PaymentMethodType.mastercard: return const Color(0xFFEB001B);
      case PaymentMethodType.bankTransfer: return const Color(0xFF2196F3);
      case PaymentMethodType.loyalty: return const Color(0xFFFFB800);
    }
  }
  IconData get icon {
    switch (this) {
      case PaymentMethodType.mpesa: return Icons.phone_android_rounded;
      case PaymentMethodType.airtelMoney: return Icons.phone_android_rounded;
      case PaymentMethodType.cash: return Icons.payments_outlined;
      case PaymentMethodType.visa: return Icons.credit_card_rounded;
      case PaymentMethodType.mastercard: return Icons.credit_card_rounded;
      case PaymentMethodType.bankTransfer: return Icons.account_balance_outlined;
      case PaymentMethodType.loyalty: return Icons.stars_rounded;
    }
  }
}

class CompletedSale {
  const CompletedSale({
    required this.id, required this.items, required this.subtotal, required this.taxTotal,
    required this.grandTotal, required this.paymentMethod, required this.amountPaid,
    required this.change, required this.createdAt,
    this.receiptNumber, this.cashierName, this.customerName, this.mpesaRef,
  });

  final String id;
  final List<CartItem> items;
  final double subtotal;
  final double taxTotal;
  final double grandTotal;
  final PaymentMethodType paymentMethod;
  final double amountPaid;
  final double change;
  final DateTime createdAt;
  final String? receiptNumber;
  final String? cashierName;
  final String? customerName;
  final String? mpesaRef;

  factory CompletedSale.fromJson(Map<String, dynamic> json) {
    final methodStr = (json['paymentMethod'] as String).toLowerCase();
    final method = PaymentMethodType.values.firstWhere(
      (m) => m.name.toLowerCase() == methodStr.replaceAll('_', ''),
      orElse: () => PaymentMethodType.cash,
    );
    return CompletedSale(
      id: json['id'] as String,
      items: (json['items'] as List<dynamic>? ?? []).map((i) => CartItem(
        product: PPProduct(
          id: i['productId'] as String,
          name: i['name'] as String,
          price: (i['price'] as num).toDouble(),
          category: '',
          stockQty: 0,
        ),
        qty: i['qty'] as int,
        discount: (i['discount'] as num?)?.toDouble() ?? 0,
      )).toList(),
      subtotal: (json['subtotal'] as num).toDouble(),
      taxTotal: (json['taxTotal'] as num).toDouble(),
      grandTotal: (json['grandTotal'] as num).toDouble(),
      paymentMethod: method,
      amountPaid: (json['amountPaid'] as num).toDouble(),
      change: (json['change'] as num?)?.toDouble() ?? 0,
      createdAt: DateTime.tryParse(json['createdAt'] as String? ?? '') ?? DateTime.now(),
      receiptNumber: json['receiptNumber'] as String?,
      cashierName: (json['cashier'] as Map<String, dynamic>?)?['name'] as String?,
      mpesaRef: json['mpesaRef'] as String?,
    );
  }
}

class CashierStats {
  const CashierStats({
    required this.todaySales, required this.todayTransactions,
    required this.todayProfit, required this.avgOrderValue, this.recentSales = const [],
  });
  final double todaySales;
  final int todayTransactions;
  final double todayProfit;
  final double avgOrderValue;
  final List<CompletedSale> recentSales;

  factory CashierStats.fromJson(Map<String, dynamic> json) => CashierStats(
    todaySales: (json['totalRevenue'] as num?)?.toDouble() ?? 0,
    todayTransactions: json['transactionCount'] as int? ?? 0,
    todayProfit: (json['totalRevenue'] as num? ?? 0).toDouble() * 0.26,
    avgOrderValue: (json['avgOrderValue'] as num?)?.toDouble() ?? 0,
  );

  static CashierStats get empty => const CashierStats(
    todaySales: 0, todayTransactions: 0, todayProfit: 0, avgOrderValue: 0,
  );
}
