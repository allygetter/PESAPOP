// lib/features/cashier/presentation/providers/pos_provider.dart
// UPDATED — uses real PosRepository

import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/pos_repository.dart';
import '../../domain/cashier_models.dart';

// ── Product search/filter ──────────────────────────────────────
final posSearchQueryProvider = StateProvider<String>((ref) => '');
final posCategoryProvider = StateProvider<String>((ref) => 'All');

// Live products from API
final productsProvider = FutureProvider.autoDispose<List<PPProduct>>((ref) async {
  final query = ref.watch(posSearchQueryProvider);
  final category = ref.watch(posCategoryProvider);
  final repo = ref.read(posRepositoryProvider);
  return repo.getProducts(
    search: query.isEmpty ? null : query,
    categoryId: category == 'All' ? null : category,
  );
});

// Today's cashier stats from API
final todayStatsProvider = FutureProvider.autoDispose<Map<String, dynamic>>((ref) async {
  return ref.read(posRepositoryProvider).getTodaySummary();
});

// ── Payment state ──────────────────────────────────────────────
enum PaymentFlowStatus { idle, processing, polling, success, failed }

class PaymentState {
  const PaymentState({
    this.status = PaymentFlowStatus.idle,
    this.selectedMethod = PaymentMethodType.mpesa,
    this.amountPaid = 0,
    this.mpesaPhone = '',
    this.errorMessage,
    this.completedSale,
    this.mpesaCheckoutId,
  });

  final PaymentFlowStatus status;
  final PaymentMethodType selectedMethod;
  final double amountPaid;
  final String mpesaPhone;
  final String? errorMessage;
  final CompletedSale? completedSale;
  final String? mpesaCheckoutId;

  bool get isProcessing => status == PaymentFlowStatus.processing || status == PaymentFlowStatus.polling;

  PaymentState copyWith({
    PaymentFlowStatus? status,
    PaymentMethodType? selectedMethod,
    double? amountPaid,
    String? mpesaPhone,
    String? errorMessage,
    CompletedSale? completedSale,
    String? mpesaCheckoutId,
  }) => PaymentState(
    status: status ?? this.status,
    selectedMethod: selectedMethod ?? this.selectedMethod,
    amountPaid: amountPaid ?? this.amountPaid,
    mpesaPhone: mpesaPhone ?? this.mpesaPhone,
    errorMessage: errorMessage ?? this.errorMessage,
    completedSale: completedSale ?? this.completedSale,
    mpesaCheckoutId: mpesaCheckoutId ?? this.mpesaCheckoutId,
  );
}

final paymentProvider = StateNotifierProvider<PaymentNotifier, PaymentState>((ref) {
  return PaymentNotifier(ref.read(posRepositoryProvider));
});

class PaymentNotifier extends StateNotifier<PaymentState> {
  PaymentNotifier(this._repo) : super(const PaymentState());
  final PosRepository _repo;

  void selectMethod(PaymentMethodType m) => state = state.copyWith(selectedMethod: m);
  void setAmountPaid(double a) => state = state.copyWith(amountPaid: a);
  void setMpesaPhone(String p) => state = state.copyWith(mpesaPhone: p);

  Future<CompletedSale?> processPayment({required CartState cart, required String cashierName}) async {
    state = state.copyWith(status: PaymentFlowStatus.processing);
    try {
      final sale = await _repo.createSale(
        cart,
        state.selectedMethod,
        mpesaPhone: state.selectedMethod == PaymentMethodType.mpesa ? state.mpesaPhone : null,
        amountPaid: state.selectedMethod == PaymentMethodType.cash ? state.amountPaid : null,
      );

      // For M-Pesa, poll for payment confirmation
      if (state.selectedMethod == PaymentMethodType.mpesa) {
        state = state.copyWith(status: PaymentFlowStatus.polling);
        final confirmed = await _pollMpesaStatus(sale.id);
        if (!confirmed) {
          state = state.copyWith(status: PaymentFlowStatus.failed, errorMessage: 'M-Pesa payment not confirmed.');
          return null;
        }
      }

      state = state.copyWith(status: PaymentFlowStatus.success, completedSale: sale);
      return sale;
    } catch (e) {
      state = state.copyWith(status: PaymentFlowStatus.failed, errorMessage: e.toString());
      return null;
    }
  }

  // Poll backend every 3s for up to 60s waiting for M-Pesa callback
  Future<bool> _pollMpesaStatus(String saleId) async {
    for (int i = 0; i < 20; i++) {
      await Future.delayed(const Duration(seconds: 3));
      try {
        final status = await _repo.getPaymentStatus(saleId);
        if (status['status'] == 'COMPLETED') return true;
        if (status['status'] == 'FAILED') return false;
      } catch (_) {}
    }
    return false;
  }

  void reset() => state = const PaymentState();
}

// Live cashier stats (replaces CashierStats.mock)
final cashierStatsProvider = FutureProvider.autoDispose<Map<String, dynamic>>((ref) {
  return ref.read(posRepositoryProvider).getTodaySummary();
});
