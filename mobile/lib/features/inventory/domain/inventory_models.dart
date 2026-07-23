// lib/features/inventory/domain/inventory_models.dart
import 'package:flutter/material.dart';

enum StockMovementType { stockIn, stockOut, transfer, adjustment, returned }

extension StockMovementExt on StockMovementType {
  String get label {
    switch (this) {
      case StockMovementType.stockIn: return 'Stock In';
      case StockMovementType.stockOut: return 'Stock Out';
      case StockMovementType.transfer: return 'Transfer';
      case StockMovementType.adjustment: return 'Adjustment';
      case StockMovementType.returned: return 'Returned';
    }
  }
  Color get color {
    switch (this) {
      case StockMovementType.stockIn: return const Color(0xFF00C896);
      case StockMovementType.stockOut: return const Color(0xFFFF3B5C);
      case StockMovementType.transfer: return const Color(0xFF2196F3);
      case StockMovementType.adjustment: return const Color(0xFFFFB800);
      case StockMovementType.returned: return const Color(0xFFAB47BC);
    }
  }
}

class StockMovement {
  const StockMovement({
    required this.id,
    required this.productId,
    required this.productName,
    required this.type,
    required this.qty,
    required this.createdAt,
    this.note,
    this.reference,
  });
  final String id;
  final String productId;
  final String productName;
  final StockMovementType type;
  final int qty;
  final DateTime createdAt;
  final String? note;
  final String? reference;
}

class InventoryStats {
  const InventoryStats({
    required this.totalProducts,
    required this.totalValue,
    required this.lowStockCount,
    required this.outOfStockCount,
    required this.categories,
  });
  final int totalProducts;
  final double totalValue;
  final int lowStockCount;
  final int outOfStockCount;
  final int categories;

  static InventoryStats get mock => const InventoryStats(
    totalProducts: 24,
    totalValue: 284600,
    lowStockCount: 4,
    outOfStockCount: 0,
    categories: 5,
  );
}
