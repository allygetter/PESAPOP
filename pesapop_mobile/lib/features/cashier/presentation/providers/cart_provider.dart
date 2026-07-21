// lib/features/cashier/presentation/providers/cart_provider.dart
// PESAPOP AI — Cart State (Riverpod StateNotifier)

import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/cashier_models.dart';

final cartProvider = StateNotifierProvider<CartNotifier, CartState>((ref) {
  return CartNotifier();
});

class CartNotifier extends StateNotifier<CartState> {
  CartNotifier() : super(const CartState());

  // Add product (or increment qty if already in cart)
  void addProduct(PPProduct product) {
    final existing = state.items.indexWhere((i) => i.product.id == product.id);
    if (existing >= 0) {
      final updated = List<CartItem>.from(state.items);
      updated[existing] = updated[existing].copyWith(
        qty: updated[existing].qty + 1,
      );
      state = state.copyWith(items: updated);
    } else {
      state = state.copyWith(
        items: [...state.items, CartItem(product: product, qty: 1)],
      );
    }
  }

  // Decrease qty (remove if reaches 0)
  void decreaseProduct(String productId) {
    final existing = state.items.indexWhere((i) => i.product.id == productId);
    if (existing < 0) return;
    final item = state.items[existing];
    if (item.qty <= 1) {
      removeProduct(productId);
    } else {
      final updated = List<CartItem>.from(state.items);
      updated[existing] = item.copyWith(qty: item.qty - 1);
      state = state.copyWith(items: updated);
    }
  }

  void setQty(String productId, int qty) {
    if (qty <= 0) { removeProduct(productId); return; }
    final idx = state.items.indexWhere((i) => i.product.id == productId);
    if (idx < 0) return;
    final updated = List<CartItem>.from(state.items);
    updated[idx] = updated[idx].copyWith(qty: qty);
    state = state.copyWith(items: updated);
  }

  void removeProduct(String productId) {
    state = state.copyWith(
      items: state.items.where((i) => i.product.id != productId).toList(),
    );
  }

  void applyItemDiscount(String productId, double discount) {
    final idx = state.items.indexWhere((i) => i.product.id == productId);
    if (idx < 0) return;
    final updated = List<CartItem>.from(state.items);
    updated[idx] = updated[idx].copyWith(discount: discount);
    state = state.copyWith(items: updated);
  }

  void applyCoupon(String code, double discount) {
    state = state.copyWith(couponCode: code, couponDiscount: discount);
  }

  void removeCoupon() {
    state = state.copyWith(couponCode: null, couponDiscount: 0);
  }

  void setCustomer(String id, String name) {
    state = state.copyWith(customerId: id, customerName: name);
  }

  void clearCart() {
    state = const CartState();
  }

  // Returns qty of a given product in cart (0 if absent)
  int qtyOf(String productId) {
    try {
      return state.items.firstWhere((i) => i.product.id == productId).qty;
    } catch (_) { return 0; }
  }
}
