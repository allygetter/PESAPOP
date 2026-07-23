// lib/features/cashier/presentation/widgets/cart_bottom_sheet.dart
// PESAPOP AI — Cart Bottom Sheet (item list, totals, checkout)

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/utils/formatters.dart';
import '../../../../core/widgets/pp_button.dart';
import '../../domain/cashier_models.dart';
import '../providers/cart_provider.dart';

class CartBottomSheet extends ConsumerWidget {
  const CartBottomSheet({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cart = ref.watch(cartProvider);
    final cartNotifier = ref.read(cartProvider.notifier);

    final surf = isDark ? PPColors.darkSurface : PPColors.lightSurface;
    final surf2 = isDark ? PPColors.darkSurface2 : PPColors.lightSurface2;
    final border = isDark ? PPColors.darkBorder : PPColors.lightBorder;
    final textPrimary = isDark ? PPColors.darkText : PPColors.lightText;
    final textSec = isDark ? PPColors.darkTextSecondary : PPColors.lightTextSecondary;

    return Container(
      height: MediaQuery.of(context).size.height * 0.85,
      decoration: BoxDecoration(
        color: surf,
        borderRadius: const BorderRadius.vertical(
          top: Radius.circular(PPSpacing.radiusXXL),
        ),
      ),
      child: Column(
        children: [

          // ── Handle ────────────────────────────────────
          const SizedBox(height: 12),
          Container(
            width: 36, height: 4,
            decoration: BoxDecoration(
              color: PPColors.darkBorder,
              borderRadius: BorderRadius.circular(PPSpacing.radiusFull),
            ),
          ),
          const SizedBox(height: 16),

          // ── Header ────────────────────────────────────
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: PPSpacing.cardPad),
            child: Row(
              children: [
                Text('Cart',
                    style: PPTypography.headingLG.copyWith(color: textPrimary)),
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                  decoration: BoxDecoration(
                    color: PPColors.brand.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(PPSpacing.radiusFull),
                  ),
                  child: Text('${cart.itemCount} items',
                      style: PPTypography.labelSM.copyWith(color: PPColors.brand)),
                ),
                const Spacer(),
                if (!cart.isEmpty)
                  GestureDetector(
                    onTap: () {
                      cartNotifier.clearCart();
                      Navigator.pop(context);
                    },
                    child: Text('Clear all',
                        style: PPTypography.labelMD.copyWith(color: PPColors.error)),
                  ),
              ],
            ),
          ),

          const SizedBox(height: 12),
          Divider(color: border, thickness: 1, height: 1),

          // ── Cart items ────────────────────────────────
          Expanded(
            child: cart.isEmpty
                ? _EmptyCart(textSec: textSec)
                : ListView.separated(
                    padding: const EdgeInsets.symmetric(
                      horizontal: PPSpacing.cardPad,
                      vertical: 12,
                    ),
                    itemCount: cart.items.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 10),
                    itemBuilder: (_, i) => _CartItemRow(
                      item: cart.items[i],
                      isDark: isDark,
                      surf2: surf2,
                      border: border,
                      textPrimary: textPrimary,
                      textSec: textSec,
                    ),
                  ),
          ),

          // ── Totals + checkout ─────────────────────────
          if (!cart.isEmpty)
            _CartFooter(
              cart: cart,
              isDark: isDark,
              surf2: surf2,
              border: border,
              textPrimary: textPrimary,
              textSec: textSec,
              onCheckout: () {
                Navigator.pop(context);
                context.push('/cashier/payment');
              },
            ),
        ],
      ),
    );
  }
}

// ── Cart item row ─────────────────────────────────────────────
class _CartItemRow extends ConsumerWidget {
  const _CartItemRow({
    required this.item,
    required this.isDark,
    required this.surf2,
    required this.border,
    required this.textPrimary,
    required this.textSec,
  });
  final CartItem item;
  final bool isDark;
  final Color surf2, border, textPrimary, textSec;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cartNotifier = ref.read(cartProvider.notifier);

    return Dismissible(
      key: ValueKey(item.product.id),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        decoration: BoxDecoration(
          color: PPColors.error.withOpacity(0.15),
          borderRadius: BorderRadius.circular(PPSpacing.radiusMD),
        ),
        child: const Icon(Icons.delete_outline_rounded, color: PPColors.error),
      ),
      onDismissed: (_) {
        HapticFeedback.mediumImpact();
        cartNotifier.removeProduct(item.product.id);
      },
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: surf2,
          borderRadius: BorderRadius.circular(PPSpacing.radiusMD),
          border: Border.all(color: border),
        ),
        child: Row(
          children: [
            // Icon
            Container(
              width: 40, height: 40,
              decoration: BoxDecoration(
                color: PPColors.brand.withOpacity(0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(Icons.inventory_2_outlined,
                  color: PPColors.brand, size: 20),
            ),
            const SizedBox(width: 12),
            // Name + price
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(item.product.name,
                      style: PPTypography.labelLG.copyWith(color: textPrimary),
                      maxLines: 1, overflow: TextOverflow.ellipsis),
                  Text(PPFormatter.ksh(item.product.price) + ' each',
                      style: PPTypography.bodySM.copyWith(color: textSec)),
                ],
              ),
            ),
            // Qty controls
            _CartQtyControl(
              qty: item.qty,
              onAdd: () {
                HapticFeedback.lightImpact();
                cartNotifier.addProduct(item.product);
              },
              onRemove: () {
                HapticFeedback.lightImpact();
                cartNotifier.decreaseProduct(item.product.id);
              },
            ),
            const SizedBox(width: 12),
            // Line total
            Text(
              PPFormatter.ksh(item.subtotal),
              style: PPTypography.labelLG.copyWith(
                color: textPrimary,
                fontFamily: 'Sora',
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CartQtyControl extends StatelessWidget {
  const _CartQtyControl({required this.qty, required this.onAdd, required this.onRemove});
  final int qty;
  final VoidCallback onAdd, onRemove;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        _QBtn(icon: Icons.remove_rounded, onTap: onRemove),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10),
          child: Text('$qty',
              style: PPTypography.labelLG.copyWith(
                  color: PPColors.brand, fontFamily: 'Sora')),
        ),
        _QBtn(icon: Icons.add_rounded, onTap: onAdd, filled: true),
      ],
    );
  }
}

class _QBtn extends StatelessWidget {
  const _QBtn({required this.icon, required this.onTap, this.filled = false});
  final IconData icon;
  final VoidCallback onTap;
  final bool filled;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 28, height: 28,
        decoration: BoxDecoration(
          color: filled ? PPColors.brand : PPColors.darkSurface3,
          borderRadius: BorderRadius.circular(7),
          border: filled ? null : Border.all(color: PPColors.darkBorder),
        ),
        child: Icon(icon,
            color: filled ? Colors.black : PPColors.brand, size: 15),
      ),
    );
  }
}

// ── Cart footer with totals + checkout ───────────────────────
class _CartFooter extends StatelessWidget {
  const _CartFooter({
    required this.cart,
    required this.isDark,
    required this.surf2,
    required this.border,
    required this.textPrimary,
    required this.textSec,
    required this.onCheckout,
  });
  final CartState cart;
  final bool isDark;
  final Color surf2, border, textPrimary, textSec;
  final VoidCallback onCheckout;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.fromLTRB(
        PPSpacing.cardPad, 16, PPSpacing.cardPad,
        PPSpacing.cardPad + MediaQuery.of(context).padding.bottom,
      ),
      decoration: BoxDecoration(
        color: isDark ? PPColors.darkSurface : PPColors.lightSurface,
        border: Border(top: BorderSide(color: border, width: 1)),
      ),
      child: Column(
        children: [
          // Subtotal row
          _TotalRow(label: 'Subtotal',
              value: PPFormatter.ksh(cart.subtotal),
              textPrimary: textPrimary, textSec: textSec),
          const SizedBox(height: 6),
          _TotalRow(label: 'VAT (16%)',
              value: PPFormatter.ksh(cart.taxTotal),
              textPrimary: textPrimary, textSec: textSec),
          if (cart.couponDiscount > 0) ...[
            const SizedBox(height: 6),
            _TotalRow(
              label: 'Coupon (${cart.couponCode})',
              value: '- ${PPFormatter.ksh(cart.couponDiscount)}',
              textPrimary: PPColors.success, textSec: textSec,
            ),
          ],
          const SizedBox(height: 10),
          Divider(color: border, thickness: 1, height: 1),
          const SizedBox(height: 10),
          _TotalRow(
            label: 'Total',
            value: PPFormatter.ksh(cart.grandTotal),
            textPrimary: textPrimary,
            textSec: textSec,
            isTotal: true,
          ),
          const SizedBox(height: 14),
          PPButton(
            label: 'Proceed to Payment',
            onTap: onCheckout,
            size: PPButtonSize.lg,
            icon: const Icon(Icons.payment_rounded),
          ),
        ],
      ),
    );
  }
}

class _TotalRow extends StatelessWidget {
  const _TotalRow({
    required this.label,
    required this.value,
    required this.textPrimary,
    required this.textSec,
    this.isTotal = false,
  });
  final String label, value;
  final Color textPrimary, textSec;
  final bool isTotal;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text(label,
            style: isTotal
                ? PPTypography.headingSM.copyWith(color: textPrimary)
                : PPTypography.bodyMD.copyWith(color: textSec)),
        const Spacer(),
        Text(value,
            style: isTotal
                ? PPTypography.metricSM.copyWith(color: PPColors.brand)
                : PPTypography.labelLG.copyWith(color: textPrimary, fontFamily: 'Sora')),
      ],
    );
  }
}

// ── Empty cart ────────────────────────────────────────────────
class _EmptyCart extends StatelessWidget {
  const _EmptyCart({required this.textSec});
  final Color textSec;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.shopping_cart_outlined, size: 56,
              color: textSec.withOpacity(0.3)),
          const SizedBox(height: 14),
          Text('Cart is empty',
              style: PPTypography.headingSM.copyWith(color: textSec)),
          const SizedBox(height: 6),
          Text('Add products from the POS screen',
              style: PPTypography.bodySM.copyWith(color: textSec.withOpacity(0.6))),
        ],
      ),
    );
  }
}
