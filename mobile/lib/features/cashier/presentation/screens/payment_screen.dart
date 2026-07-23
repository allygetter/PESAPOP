// lib/features/cashier/presentation/screens/payment_screen.dart
// PESAPOP AI — Payment Screen: method selection, M-Pesa, cash numpad, card

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/utils/formatters.dart';
import '../../../../core/widgets/pp_button.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../domain/cashier_models.dart';
import '../providers/cart_provider.dart';
import '../providers/pos_provider.dart';

class PaymentScreen extends ConsumerStatefulWidget {
  const PaymentScreen({super.key});

  @override
  ConsumerState<PaymentScreen> createState() => _PaymentScreenState();
}

class _PaymentScreenState extends ConsumerState<PaymentScreen>
    with SingleTickerProviderStateMixin {
  final _phoneController = TextEditingController();
  final _cashController = TextEditingController();
  late AnimationController _successController;
  late Animation<double> _successScale;

  @override
  void initState() {
    super.initState();
    _successController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _successScale = Tween<double>(begin: 0.5, end: 1.0).animate(
      CurvedAnimation(parent: _successController, curve: Curves.elasticOut),
    );
  }

  @override
  void dispose() {
    _phoneController.dispose();
    _cashController.dispose();
    _successController.dispose();
    super.dispose();
  }

  Future<void> _processPayment() async {
    final cart = ref.read(cartProvider);
    final user = ref.read(authProvider).user;
    final paymentNotifier = ref.read(paymentProvider.notifier);

    if (ref.read(paymentProvider).selectedMethod == PaymentMethodType.cash) {
      final paid = double.tryParse(_cashController.text.replaceAll(',', '')) ?? 0;
      if (paid < cart.grandTotal) {
        _showError('Amount entered is less than total due');
        return;
      }
      paymentNotifier.setAmountPaid(paid);
    }

    if (ref.read(paymentProvider).selectedMethod == PaymentMethodType.mpesa) {
      final phone = _phoneController.text.trim();
      if (phone.length < 9) {
        _showError('Enter a valid M-Pesa phone number');
        return;
      }
      paymentNotifier.setMpesaPhone(phone);
    }

    final sale = await paymentNotifier.processPayment(
      cart: cart,
      cashierName: user?.name ?? 'Cashier',
    );

    if (sale != null && mounted) {
      _successController.forward();
      await Future.delayed(const Duration(milliseconds: 1400));
      ref.read(cartProvider.notifier).clearCart();
      if (mounted) {
        context.pushReplacement('/cashier/receipt', extra: sale);
      }
    }
  }

  void _showError(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg),
        backgroundColor: PPColors.error,
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.all(16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cart = ref.watch(cartProvider);
    final paymentState = ref.watch(paymentProvider);

    final bg = isDark ? PPColors.darkBg : PPColors.lightBg;
    final surf = isDark ? PPColors.darkSurface : PPColors.lightSurface;
    final surf2 = isDark ? PPColors.darkSurface2 : PPColors.lightSurface2;
    final border = isDark ? PPColors.darkBorder : PPColors.lightBorder;
    final textPrimary = isDark ? PPColors.darkText : PPColors.lightText;
    final textSec = isDark ? PPColors.darkTextSecondary : PPColors.lightTextSecondary;

    // Success overlay
    if (paymentState.status == PaymentFlowStatus.success) {
      return Scaffold(
        backgroundColor: bg,
        body: Center(
          child: ScaleTransition(
            scale: _successScale,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 96, height: 96,
                  decoration: BoxDecoration(
                    color: PPColors.success.withOpacity(0.1),
                    shape: BoxShape.circle,
                    border: Border.all(
                        color: PPColors.success.withOpacity(0.3), width: 2),
                  ),
                  child: const Icon(Icons.check_circle_outline_rounded,
                      color: PPColors.success, size: 52),
                ),
                const SizedBox(height: 20),
                Text('Payment Successful!',
                    style: PPTypography.displaySM.copyWith(color: textPrimary)),
                const SizedBox(height: 6),
                Text(PPFormatter.ksh(cart.grandTotal),
                    style: PPTypography.metricLG.copyWith(color: PPColors.brand)),
                const SizedBox(height: 8),
                Text('Generating receipt...',
                    style: PPTypography.bodyMD.copyWith(color: textSec)),
              ],
            ),
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: bg,
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [

            // ── Header ──────────────────────────────────
            Padding(
              padding: const EdgeInsets.fromLTRB(
                PPSpacing.screenH, 14, PPSpacing.screenH, 0,
              ),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: () => context.pop(),
                    child: Container(
                      width: 38, height: 38,
                      decoration: BoxDecoration(
                        color: surf,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: border),
                      ),
                      child: Icon(Icons.arrow_back_ios_new_rounded,
                          size: 16, color: textPrimary),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Text('Payment',
                      style: PPTypography.headingLG.copyWith(color: textPrimary)),
                ],
              ),
            ),

            const SizedBox(height: 20),

            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(
                  horizontal: PPSpacing.screenH,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [

                    // ── Order summary card ─────────────
                    _OrderSummaryCard(
                      cart: cart,
                      isDark: isDark,
                      surf: surf,
                      border: border,
                      textPrimary: textPrimary,
                      textSec: textSec,
                    ),

                    const SizedBox(height: 22),

                    // ── Payment methods ────────────────
                    Text('Payment Method',
                        style: PPTypography.headingSM.copyWith(color: textPrimary)),
                    const SizedBox(height: 12),
                    _PaymentMethodGrid(
                      selected: paymentState.selectedMethod,
                      isDark: isDark,
                      surf: surf,
                      surf2: surf2,
                      border: border,
                      onSelect: (m) =>
                          ref.read(paymentProvider.notifier).selectMethod(m),
                    ),

                    const SizedBox(height: 22),

                    // ── Method-specific input ──────────
                    AnimatedSwitcher(
                      duration: const Duration(milliseconds: 250),
                      transitionBuilder: (child, anim) => FadeTransition(
                        opacity: anim,
                        child: SlideTransition(
                          position: Tween<Offset>(
                            begin: const Offset(0, 0.08),
                            end: Offset.zero,
                          ).animate(anim),
                          child: child,
                        ),
                      ),
                      child: _buildMethodInput(
                        paymentState.selectedMethod,
                        cart,
                        isDark: isDark,
                        surf: surf,
                        surf2: surf2,
                        border: border,
                        textPrimary: textPrimary,
                        textSec: textSec,
                      ),
                    ),

                    const SizedBox(height: 120),
                  ],
                ),
              ),
            ),

            // ── Bottom pay button ────────────────────────
            Container(
              padding: EdgeInsets.fromLTRB(
                PPSpacing.screenH, 16, PPSpacing.screenH,
                PPSpacing.cardPad + MediaQuery.of(context).padding.bottom,
              ),
              decoration: BoxDecoration(
                color: isDark ? PPColors.darkSurface : PPColors.lightSurface,
                border: Border(top: BorderSide(color: border)),
              ),
              child: PPButton(
                label: 'Confirm Payment — ${PPFormatter.ksh(cart.grandTotal)}',
                onTap: _processPayment,
                isLoading: paymentState.isProcessing,
                size: PPButtonSize.lg,
                icon: const Icon(Icons.lock_outline_rounded),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMethodInput(
    PaymentMethodType method,
    CartState cart, {
    required bool isDark,
    required Color surf,
    required Color surf2,
    required Color border,
    required Color textPrimary,
    required Color textSec,
  }) {
    switch (method) {
      case PaymentMethodType.mpesa:
        return _MpesaInput(
          key: const ValueKey('mpesa'),
          controller: _phoneController,
          total: cart.grandTotal,
          isDark: isDark,
          surf: surf,
          border: border,
          textPrimary: textPrimary,
          textSec: textSec,
        );
      case PaymentMethodType.cash:
        return _CashInput(
          key: const ValueKey('cash'),
          controller: _cashController,
          total: cart.grandTotal,
          isDark: isDark,
          surf: surf,
          surf2: surf2,
          border: border,
          textPrimary: textPrimary,
          textSec: textSec,
          onChange: (v) => setState(() {}),
        );
      case PaymentMethodType.airtelMoney:
        return _MpesaInput(
          key: const ValueKey('airtel'),
          controller: _phoneController,
          total: cart.grandTotal,
          isDark: isDark,
          surf: surf,
          border: border,
          textPrimary: textPrimary,
          textSec: textSec,
          label: 'Airtel Money Number',
          hint: 'e.g. 0733 XXX XXX',
          brandColor: PPColors.airtelMoney,
        );
      default:
        return _CardInput(
          key: ValueKey(method.name),
          isDark: isDark,
          surf: surf,
          border: border,
          textPrimary: textPrimary,
          textSec: textSec,
        );
    }
  }
}

// ── Order summary card ────────────────────────────────────────
class _OrderSummaryCard extends StatelessWidget {
  const _OrderSummaryCard({
    required this.cart,
    required this.isDark,
    required this.surf,
    required this.border,
    required this.textPrimary,
    required this.textSec,
  });
  final CartState cart;
  final bool isDark;
  final Color surf, border, textPrimary, textSec;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: surf,
        borderRadius: BorderRadius.circular(PPSpacing.radiusLG),
        border: Border.all(color: border),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Text('${cart.itemCount} items',
                  style: PPTypography.bodyMD.copyWith(color: textSec)),
              const Spacer(),
              Text('Order Total',
                  style: PPTypography.labelMD.copyWith(color: textSec)),
            ],
          ),
          const SizedBox(height: 6),
          Row(
            children: [
              // Mini product chips
              Expanded(
                child: Wrap(
                  spacing: 6, runSpacing: 4,
                  children: cart.items.take(3).map((item) => Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: PPColors.brand.withOpacity(0.08),
                      borderRadius: BorderRadius.circular(PPSpacing.radiusFull),
                      border: Border.all(color: PPColors.brand.withOpacity(0.2)),
                    ),
                    child: Text(
                      '${item.qty}x ${item.product.name.split(' ').first}',
                      style: PPTypography.labelXS.copyWith(color: PPColors.brand),
                    ),
                  )).toList()
                    ..addAll(cart.items.length > 3
                        ? [Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                            decoration: BoxDecoration(
                              color: PPColors.darkBorder.withOpacity(0.3),
                              borderRadius: BorderRadius.circular(PPSpacing.radiusFull),
                            ),
                            child: Text('+${cart.items.length - 3} more',
                                style: PPTypography.labelXS.copyWith(color: textSec)),
                          )]
                        : []),
                ),
              ),
              const SizedBox(width: 12),
              Text(
                PPFormatter.ksh(cart.grandTotal),
                style: PPTypography.metricMD.copyWith(color: PPColors.brand),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ── Payment method grid ───────────────────────────────────────
class _PaymentMethodGrid extends StatelessWidget {
  const _PaymentMethodGrid({
    required this.selected,
    required this.isDark,
    required this.surf,
    required this.surf2,
    required this.border,
    required this.onSelect,
  });
  final PaymentMethodType selected;
  final bool isDark;
  final Color surf, surf2, border;
  final ValueChanged<PaymentMethodType> onSelect;

  static const _methods = [
    PaymentMethodType.mpesa,
    PaymentMethodType.airtelMoney,
    PaymentMethodType.cash,
    PaymentMethodType.visa,
    PaymentMethodType.mastercard,
    PaymentMethodType.bankTransfer,
  ];

  @override
  Widget build(BuildContext context) {
    return GridView.count(
      crossAxisCount: 3,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisSpacing: 10,
      mainAxisSpacing: 10,
      childAspectRatio: 1.3,
      children: _methods.map((m) {
        final isSelected = m == selected;
        return GestureDetector(
          onTap: () {
            HapticFeedback.selectionClick();
            onSelect(m);
          },
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 180),
            decoration: BoxDecoration(
              color: isSelected
                  ? m.color.withOpacity(isDark ? 0.15 : 0.08)
                  : surf,
              borderRadius: BorderRadius.circular(PPSpacing.radiusMD),
              border: Border.all(
                color: isSelected ? m.color : border,
                width: isSelected ? 1.5 : 1,
              ),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(m.icon,
                    color: isSelected ? m.color : (isDark ? PPColors.darkTextSecondary : PPColors.lightTextSecondary),
                    size: 22),
                const SizedBox(height: 5),
                Text(m.label,
                    style: PPTypography.labelXS.copyWith(
                      color: isSelected ? m.color : (isDark ? PPColors.darkTextSecondary : PPColors.lightTextSecondary),
                      fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                    ),
                    textAlign: TextAlign.center),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }
}

// ── M-Pesa input ──────────────────────────────────────────────
class _MpesaInput extends StatelessWidget {
  const _MpesaInput({
    super.key,
    required this.controller,
    required this.total,
    required this.isDark,
    required this.surf,
    required this.border,
    required this.textPrimary,
    required this.textSec,
    this.label = 'M-Pesa Number',
    this.hint = 'e.g. 0712 345 678',
    this.brandColor = PPColors.mpesa,
  });
  final TextEditingController controller;
  final double total;
  final bool isDark;
  final Color surf, border, textPrimary, textSec;
  final String label, hint;
  final Color brandColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: surf,
        borderRadius: BorderRadius.circular(PPSpacing.radiusLG),
        border: Border.all(color: border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: brandColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(Icons.phone_android_rounded, color: brandColor, size: 18),
              ),
              const SizedBox(width: 10),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(label,
                      style: PPTypography.labelLG.copyWith(color: textPrimary)),
                  Text('STK push will be sent',
                      style: PPTypography.bodySM.copyWith(color: textSec)),
                ],
              ),
            ],
          ),
          const SizedBox(height: 14),
          TextField(
            controller: controller,
            keyboardType: TextInputType.phone,
            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
            style: PPTypography.bodyMD.copyWith(color: textPrimary),
            decoration: InputDecoration(
              hintText: hint,
              hintStyle: PPTypography.bodyMD.copyWith(color: textSec),
              prefixText: '+254  ',
              prefixStyle: PPTypography.bodyMD.copyWith(
                color: brandColor, fontWeight: FontWeight.w600,
              ),
            ),
          ),
          const SizedBox(height: 14),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: brandColor.withOpacity(0.06),
              borderRadius: BorderRadius.circular(PPSpacing.radiusMD),
            ),
            child: Row(
              children: [
                Icon(Icons.info_outline_rounded, color: brandColor, size: 16),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Customer will receive a prompt for ${PPFormatter.ksh(total)}. Confirm before approving.',
                    style: PPTypography.bodySM.copyWith(color: textSec),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ── Cash input with numpad ────────────────────────────────────
class _CashInput extends StatelessWidget {
  const _CashInput({
    super.key,
    required this.controller,
    required this.total,
    required this.isDark,
    required this.surf,
    required this.surf2,
    required this.border,
    required this.textPrimary,
    required this.textSec,
    required this.onChange,
  });
  final TextEditingController controller;
  final double total;
  final bool isDark;
  final Color surf, surf2, border, textPrimary, textSec;
  final VoidCallback onChange;

  double get _paid =>
      double.tryParse(controller.text.replaceAll(',', '')) ?? 0;
  double get _change => (_paid - total).clamp(0, double.infinity);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: surf,
        borderRadius: BorderRadius.circular(PPSpacing.radiusLG),
        border: Border.all(color: border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.payments_outlined, color: PPColors.brand, size: 20),
              const SizedBox(width: 8),
              Text('Cash Payment',
                  style: PPTypography.labelLG.copyWith(color: textPrimary)),
            ],
          ),
          const SizedBox(height: 14),

          // Amount display
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
            decoration: BoxDecoration(
              color: surf2,
              borderRadius: BorderRadius.circular(PPSpacing.radiusMD),
              border: Border.all(color: PPColors.brand.withOpacity(0.4)),
            ),
            child: Row(
              children: [
                Text('KES  ', style: PPTypography.labelLG.copyWith(color: PPColors.brand)),
                Expanded(
                  child: Text(
                    controller.text.isEmpty ? '0' : controller.text,
                    style: PPTypography.metricMD.copyWith(color: textPrimary),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 12),

          // Quick amount buttons
          Row(
            children: [total, total + 50, total + 100, total + 200]
                .map((amt) => Expanded(
                      child: Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: GestureDetector(
                          onTap: () {
                            controller.text = amt.toInt().toString();
                            onChange();
                          },
                          child: Container(
                            padding: const EdgeInsets.symmetric(vertical: 8),
                            decoration: BoxDecoration(
                              color: surf2,
                              borderRadius: BorderRadius.circular(PPSpacing.radiusSM),
                              border: Border.all(color: border),
                            ),
                            child: Text(
                              PPFormatter.ksh(amt, compact: true),
                              style: PPTypography.labelSM.copyWith(color: textSec),
                              textAlign: TextAlign.center,
                              maxLines: 1,
                            ),
                          ),
                        ),
                      ),
                    ))
                .toList(),
          ),

          const SizedBox(height: 12),

          // Numpad
          _Numpad(
            onDigit: (d) {
              controller.text += d;
              onChange();
            },
            onDelete: () {
              if (controller.text.isNotEmpty) {
                controller.text = controller.text
                    .substring(0, controller.text.length - 1);
                onChange();
              }
            },
            onClear: () {
              controller.clear();
              onChange();
            },
            isDark: isDark,
            surf2: surf2,
            border: border,
            textPrimary: textPrimary,
          ),

          if (_paid > 0 && _paid >= total) ...[
            const SizedBox(height: 14),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              decoration: BoxDecoration(
                color: PPColors.success.withOpacity(0.08),
                borderRadius: BorderRadius.circular(PPSpacing.radiusMD),
                border: Border.all(color: PPColors.success.withOpacity(0.3)),
              ),
              child: Row(
                children: [
                  Text('Change due:',
                      style: PPTypography.labelLG.copyWith(color: PPColors.success)),
                  const Spacer(),
                  Text(PPFormatter.ksh(_change),
                      style: PPTypography.metricSM.copyWith(color: PPColors.success)),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}

// ── Numpad ────────────────────────────────────────────────────
class _Numpad extends StatelessWidget {
  const _Numpad({
    required this.onDigit,
    required this.onDelete,
    required this.onClear,
    required this.isDark,
    required this.surf2,
    required this.border,
    required this.textPrimary,
  });
  final ValueChanged<String> onDigit;
  final VoidCallback onDelete, onClear;
  final bool isDark;
  final Color surf2, border, textPrimary;

  @override
  Widget build(BuildContext context) {
    const rows = [
      ['1','2','3'],
      ['4','5','6'],
      ['7','8','9'],
      ['C','0','⌫'],
    ];
    return Column(
      children: rows.map((row) => Padding(
        padding: const EdgeInsets.only(bottom: 8),
        child: Row(
          children: row.map((key) {
            final isAction = key == 'C' || key == '⌫';
            return Expanded(
              child: Padding(
                padding: EdgeInsets.only(right: row.indexOf(key) < 2 ? 8 : 0),
                child: GestureDetector(
                  onTap: () {
                    HapticFeedback.selectionClick();
                    if (key == '⌫') onDelete();
                    else if (key == 'C') onClear();
                    else onDigit(key);
                  },
                  child: Container(
                    height: 48,
                    decoration: BoxDecoration(
                      color: isAction
                          ? PPColors.error.withOpacity(0.1)
                          : surf2,
                      borderRadius: BorderRadius.circular(PPSpacing.radiusMD),
                      border: Border.all(
                        color: isAction
                            ? PPColors.error.withOpacity(0.3)
                            : border,
                      ),
                    ),
                    child: Center(
                      child: Text(
                        key,
                        style: PPTypography.headingMD.copyWith(
                          color: isAction ? PPColors.error : textPrimary,
                          fontFamily: 'Sora',
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      )).toList(),
    );
  }
}

// ── Card / bank input placeholder ────────────────────────────
class _CardInput extends StatelessWidget {
  const _CardInput({
    super.key,
    required this.isDark,
    required this.surf,
    required this.border,
    required this.textPrimary,
    required this.textSec,
  });
  final bool isDark;
  final Color surf, border, textPrimary, textSec;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: surf,
        borderRadius: BorderRadius.circular(PPSpacing.radiusLG),
        border: Border.all(color: border),
      ),
      child: Column(
        children: [
          Icon(Icons.credit_card_rounded, size: 40,
              color: textSec.withOpacity(0.4)),
          const SizedBox(height: 12),
          Text('Connect card terminal',
              style: PPTypography.headingSM.copyWith(color: textPrimary)),
          const SizedBox(height: 6),
          Text('Pair your POS card reader in Settings to accept card payments.',
              style: PPTypography.bodyMD.copyWith(color: textSec),
              textAlign: TextAlign.center),
          const SizedBox(height: 14),
          OutlinedButton(
            onPressed: () {},
            style: OutlinedButton.styleFrom(minimumSize: const Size(160, 42)),
            child: const Text('Connect Terminal'),
          ),
        ],
      ),
    );
  }
}
