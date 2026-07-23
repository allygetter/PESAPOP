// lib/features/inventory/presentation/providers/inventory_provider.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../cashier/data/product_mock_data.dart';
import '../../../cashier/domain/cashier_models.dart';
import '../../domain/inventory_models.dart';

final inventorySearchProvider = StateProvider<String>((ref) => '');
final inventoryFilterProvider = StateProvider<String>((ref) => 'All');

final filteredInventoryProvider = Provider<List<PPProduct>>((ref) {
  final query = ref.watch(inventorySearchProvider).toLowerCase();
  final filter = ref.watch(inventoryFilterProvider);
  return kMockProducts.where((p) {
    final matchCat = filter == 'All' || filter == 'Low Stock'
        ? (filter == 'Low Stock' ? p.isLowStock : true)
        : p.category == filter;
    final matchQ = query.isEmpty || p.name.toLowerCase().contains(query);
    return matchCat && matchQ;
  }).toList()
    ..sort((a, b) {
      if (a.isLowStock && !b.isLowStock) return -1;
      if (!a.isLowStock && b.isLowStock) return 1;
      return a.name.compareTo(b.name);
    });
});

final inventoryStatsProvider = Provider<InventoryStats>((ref) => InventoryStats.mock);

final recentMovementsProvider = Provider<List<StockMovement>>((ref) => [
  StockMovement(id: 'm1', productId: 'p001', productName: 'Tusker Lager 500ml',
      type: StockMovementType.stockIn, qty: 48, createdAt: DateTime.now().subtract(const Duration(hours: 2)), reference: 'PO-0041'),
  StockMovement(id: 'm2', productId: 'p013', productName: 'Omo Detergent 1kg',
      type: StockMovementType.stockOut, qty: 5, createdAt: DateTime.now().subtract(const Duration(hours: 5))),
  StockMovement(id: 'm3', productId: 'p016', productName: 'Bleach 1L',
      type: StockMovementType.adjustment, qty: 4, createdAt: DateTime.now().subtract(const Duration(hours: 8)), note: 'Expired stock removed'),
  StockMovement(id: 'm4', productId: 'p007', productName: 'Unga Pembe 2kg',
      type: StockMovementType.stockIn, qty: 30, createdAt: DateTime.now().subtract(const Duration(days: 1)), reference: 'PO-0040'),
]);
