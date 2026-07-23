// lib/features/cashier/data/pos_repository.dart
// Replaces mock data in pos_provider.dart + cart_provider.dart

import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants/api_constants.dart';
import '../../../services/api_service.dart';
import '../domain/cashier_models.dart';

final posRepositoryProvider = Provider<PosRepository>((ref) {
  return PosRepository(ref.read(apiServiceProvider));
});

class PosRepository {
  PosRepository(this._api);
  final ApiService _api;

  // ── Products ────────────────────────────────────
  Future<List<PPProduct>> getProducts({String? search, String? categoryId}) async {
    final data = await _api.get<List<dynamic>>(ApiConstants.products, params: {
      if (search != null && search.isNotEmpty) 'search': search,
      if (categoryId != null && categoryId != 'All') 'categoryId': categoryId,
    });
    return data.map((d) => PPProduct.fromJson(d as Map<String, dynamic>)).toList();
  }

  Future<PPProduct> getProductByBarcode(String barcode) async {
    final data = await _api.get<Map<String, dynamic>>(ApiConstants.productByBarcode(barcode));
    return PPProduct.fromJson(data);
  }

  // ── Sales ───────────────────────────────────────
  Future<CompletedSale> createSale(CartState cart, PaymentMethodType method, {
    String? mpesaPhone, double? amountPaid,
  }) async {
    final data = await _api.post<Map<String, dynamic>>(ApiConstants.sales, data: {
      'items': cart.items.map((i) => {
        'productId': i.product.id,
        'name': i.product.name,
        'qty': i.qty,
        'price': i.product.price,
        'discount': i.discount,
        'tax': i.product.isVatExempt ? 0.0 : i.product.price * i.product.taxRate,
      }).toList(),
      'paymentMethod': method.name.toUpperCase(),
      if (mpesaPhone != null) 'mpesaPhone': mpesaPhone,
      if (amountPaid != null) 'amountPaid': amountPaid,
      if (cart.customerId != null) 'customerId': cart.customerId,
    });
    return CompletedSale.fromJson(data);
  }

  Future<Map<String, dynamic>> getTodaySummary() async {
    return _api.get<Map<String, dynamic>>(ApiConstants.todaySummary);
  }

  Future<Map<String, dynamic>> getPaymentStatus(String saleId) async {
    return _api.get<Map<String, dynamic>>(ApiConstants.paymentStatus(saleId));
  }

  // ── M-Pesa STK push ─────────────────────────────
  Future<Map<String, dynamic>> initiateMpesaStk({
    required String saleId, required String phone, required double amount,
  }) async {
    return _api.post<Map<String, dynamic>>(ApiConstants.mpesaStk, data: {
      'saleId': saleId, 'phone': phone, 'amount': amount,
    });
  }
}
