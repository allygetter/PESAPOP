import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/cashier_models.dart';

final filteredProductsProvider =
    Provider<List<PPProduct>>((ref) {
  return [];
});
