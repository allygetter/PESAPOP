// lib/features/cashier/data/inventory_repository.dart

import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants/api_constants.dart';
import '../../../services/api_service.dart';
import '../domain/cashier_models.dart';

final inventoryRepositoryProvider = Provider<InventoryRepository>((ref) {
  return InventoryRepository(ref.read(apiServiceProvider));
});

class InventoryRepository {
  InventoryRepository(this._api);
  final ApiService _api;

  Future<List<PPProduct>> getInventory({String? branchId}) async {
    final data = await _api.get<List<dynamic>>(ApiConstants.inventory,
        params: branchId != null ? {'branchId': branchId} : null);
    return data.map((d) => PPProduct.fromJson(d as Map<String, dynamic>)).toList();
  }

  Future<Map<String, dynamic>> getStats() async {
    return _api.get<Map<String, dynamic>>(ApiConstants.inventoryStats);
  }

  Future<List<dynamic>> getMovements({String? productId}) async {
    return _api.get<List<dynamic>>(ApiConstants.movements,
        params: productId != null ? {'productId': productId} : null);
  }

  Future<Map<String, dynamic>> stockIn({
    required String productId,
    required String branchId,
    required int qty,
    String? reference,
    String? note,
  }) async {
    return _api.post<Map<String, dynamic>>(ApiConstants.stockIn, data: {
      'productId': productId, 'branchId': branchId, 'qty': qty,
      if (reference != null) 'reference': reference,
      if (note != null) 'note': note,
    });
  }

  Future<List<PPProduct>> getLowStockAlerts() async {
    final data = await _api.get<List<dynamic>>(ApiConstants.inventoryAlerts);
    return data.map((d) => PPProduct.fromJson(d as Map<String, dynamic>)).toList();
  }
}
