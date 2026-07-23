import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/pos_models.dart';

final filteredProductsProvider =
    Provider<List<PPProduct>>((ref) {
  return [];
});
