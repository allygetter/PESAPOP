// lib/features/cashier/presentation/screens/pos_screen.dart
// PESAPOP AI — POS Screen: product grid, search, category filter, cart bar

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/utils/formatters.dart';
import '../../data/product_mock_data.dart';
import '../../domain/cashier_models.dart';
import '../providers/cart_provider.dart';
import '../providers/pos_provider.dart';
import '../widgets/cart_bottom_sheet.dart';

class POSScreen extends ConsumerStatefulWidget {
  const POSScreen({super.key});

  @override
  ConsumerState<POSScreen> createState() => _POSScreenState();
}

class _POSScreenState extends ConsumerState<POSScreen> {
  final _searchController = TextEditingController();
  final _searchFocus = FocusNode();

  @override
  void dispose() {
    _searchController.dispose();
    _searchFocus.dispose();
    super.dispose();
  }

  void _openCart() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => const CartBottomSheet(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final products = ref.watch(filteredProductsProvider);
    final cart = ref.watch(cartProvider);
    final category = ref.watch(posCategoryProvider);

    final bg = isDark ? PPColors.darkBg : PPColors.lightBg;
    final surf = isDark ? PPColors.darkSurface : PPColors.lightSurface;
    final surf2 = isDark ? PPColors.darkSurface2 : PPColors.lightSurface2;
    final border = isDark ? PPColors.darkBorder : PPColors.lightBorder;
    final textPrimary = isDark ? PPColors.darkText : PPColors.lightText;
    final textSec = isDark ? PPColors.darkTextSecondary : PPColors.lightTextSecondary;

    return Scaffold(
      backgroundColor: bg,
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [

            // ── Header ─────────────────────────────────
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
                  Expanded(
                    child: Text('Point of Sale',
                        style: PPTypography.headingLG.copyWith(color: textPrimary)),
                  ),
                  // Barcode scanner btn
                  GestureDetector(
                    onTap: _onScanBarcode,
                    child: Container(
                      width: 38, height: 38,
                      decoration: BoxDecoration(
                        color: PPColors.brand.withOpacity(0.12),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: PPColors.brand.withOpacity(0.3)),
                      ),
                      child: const Icon(Icons.qr_code_scanner_rounded,
                          color: PPColors.brand, size: 20),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 14),

            // ── Search bar ─────────────────────────────
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: PPSpacing.screenH),
              child: _SearchBar(
                controller: _searchController,
                focusNode: _searchFocus,
                isDark: isDark,
                surf2: surf2,
                border: border,
                textPrimary: textPrimary,
                textSec: textSec,
                onChanged: (q) => ref
                    .read(posSearchQueryProvider.notifier)
                    .state = q,
                onClear: () {
                  _searchController.clear();
                  ref.read(posSearchQueryProvider.notifier).state = '';
                },
              ),
            ),

            const SizedBox(height: 12),

            // ── Category chips ─────────────────────────
            SizedBox(
              height: 36,
              child: ListView.separated(
                padding: const EdgeInsets.symmetric(horizontal: PPSpacing.screenH),
                scrollDirection: Axis.horizontal,
                itemCount: kProductCategories.length,
                separatorBuilder: (_, __) => const SizedBox(width: 8),
                itemBuilder: (context, i) {
                  final cat = kProductCategories[i];
                  final isSelected = cat == category;
                  return _CategoryChip(
                    label: cat,
                    isSelected: isSelected,
                    isDark: isDark,
                    surf2: surf2,
                    border: border,
                    textSec: textSec,
                    onTap: () => ref
                        .read(posCategoryProvider.notifier)
                        .state = cat,
                  );
                },
              ),
            ),

            const SizedBox(height: 12),

            // ── Product count ──────────────────────────
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: PPSpacing.screenH),
              child: Row(
                children: [
                  Text(
                    '${products.length} products',
                    style: PPTypography.bodySM.copyWith(color: textSec),
                  ),
                  const Spacer(),
                  Icon(Icons.grid_view_rounded, size: 16, color: textSec),
                ],
              ),
            ),

            const SizedBox(height: 10),

            // ── Product grid ───────────────────────────
            Expanded(
              child: products.isEmpty
                  ? _EmptyProducts(isDark: isDark, textSec: textSec)
                  : GridView.builder(
                      padding: const EdgeInsets.fromLTRB(
                        PPSpacing.screenH, 0, PPSpacing.screenH, 120,
                      ),
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        crossAxisSpacing: 10,
                        mainAxisSpacing: 10,
                        childAspectRatio: 0.88,
                      ),
                      itemCount: products.length,
                      itemBuilder: (context, i) => _ProductCard(
                        product: products[i],
                        isDark: isDark,
                        surf: surf,
                        border: border,
                        textPrimary: textPrimary,
                        textSec: textSec,
                      ),
                    ),
            ),
          ],
        ),
      ),

      // ── Floating cart bar ──────────────────────────
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: cart.isEmpty
          ? null
          : _CartBar(cart: cart, onTap: _openCart),
    );
  }

  void _onScanBarcode() {
    // TODO: launch mobile_scanner
    HapticFeedback.mediumImpact();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Scanner opens camera — integrate mobile_scanner package'),
        backgroundColor: PPColors.darkSurface2,
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.all(16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }
}

// ── Search bar ────────────────────────────────────────────────
class _SearchBar extends StatelessWidget {
  const _SearchBar({
    required this.controller,
    required this.focusNode,
    required this.isDark,
    required this.surf2,
    required this.border,
    required this.textPrimary,
    required this.textSec,
    required this.onChanged,
    required this.onClear,
  });
  final TextEditingController controller;
  final FocusNode focusNode;
  final bool isDark;
  final Color surf2, border, textPrimary, textSec;
  final ValueChanged<String> onChanged;
  final VoidCallback onClear;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 46,
      decoration: BoxDecoration(
        color: surf2,
        borderRadius: BorderRadius.circular(PPSpacing.radiusMD),
        border: Border.all(color: border),
      ),
      child: Row(
        children: [
          const SizedBox(width: 12),
          Icon(Icons.search_rounded, color: PPColors.brand, size: 20),
          const SizedBox(width: 10),
          Expanded(
            child: TextField(
              controller: controller,
              focusNode: focusNode,
              onChanged: onChanged,
              style: PPTypography.bodyMD.copyWith(color: textPrimary),
              decoration: InputDecoration(
                hintText: 'Search products or scan barcode...',
                hintStyle: PPTypography.bodyMD.copyWith(color: textSec),
                border: InputBorder.none,
                enabledBorder: InputBorder.none,
                focusedBorder: InputBorder.none,
                filled: false,
                contentPadding: EdgeInsets.zero,
                isDense: true,
              ),
            ),
          ),
          if (controller.text.isNotEmpty)
            GestureDetector(
              onTap: onClear,
              child: Icon(Icons.close_rounded, color: textSec, size: 18),
            ),
          const SizedBox(width: 12),
        ],
      ),
    );
  }
}

// ── Category chip ─────────────────────────────────────────────
class _CategoryChip extends StatelessWidget {
  const _CategoryChip({
    required this.label,
    required this.isSelected,
    required this.isDark,
    required this.surf2,
    required this.border,
    required this.textSec,
    required this.onTap,
  });
  final String label;
  final bool isSelected;
  final bool isDark;
  final Color surf2, border, textSec;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? PPColors.brand : surf2,
          borderRadius: BorderRadius.circular(PPSpacing.radiusFull),
          border: Border.all(
            color: isSelected ? PPColors.brand : border,
            width: isSelected ? 0 : 1,
          ),
        ),
        child: Text(
          label,
          style: PPTypography.labelMD.copyWith(
            color: isSelected ? Colors.black : textSec,
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
          ),
        ),
      ),
    );
  }
}

// ── Product card ──────────────────────────────────────────────
class _ProductCard extends ConsumerWidget {
  const _ProductCard({
    required this.product,
    required this.isDark,
    required this.surf,
    required this.border,
    required this.textPrimary,
    required this.textSec,
  });
  final PPProduct product;
  final bool isDark;
  final Color surf, border, textPrimary, textSec;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cartNotifier = ref.read(cartProvider.notifier);
    final qtyInCart = ref.watch(cartProvider.select(
      (c) => c.items
          .where((i) => i.product.id == product.id)
          .fold(0, (sum, i) => sum + i.qty),
    ));
    final isInCart = qtyInCart > 0;
    final isOut = product.isOutOfStock;

    return GestureDetector(
      onTap: isOut ? null : () {
        HapticFeedback.lightImpact();
        cartNotifier.addProduct(product);
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: isInCart
              ? (isDark
                  ? PPColors.brand.withOpacity(0.08)
                  : PPColors.brandSurface)
              : surf,
          borderRadius: BorderRadius.circular(PPSpacing.radiusLG),
          border: Border.all(
            color: isInCart ? PPColors.brand.withOpacity(0.5) : border,
            width: isInCart ? 1.5 : 1,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [

            // ── Top row: icon + badge ────────────────
            Row(
              children: [
                Expanded(
                  child: Container(
                    height: 48,
                    decoration: BoxDecoration(
                      color: _categoryColor(product.category).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(
                      _categoryIcon(product.category),
                      color: _categoryColor(product.category),
                      size: 24,
                    ),
                  ),
                ),
                const SizedBox(width: 6),
                if (product.isLowStock)
                  _StockBadge(label: 'Low', color: PPColors.warning)
                else if (isOut)
                  _StockBadge(label: 'Out', color: PPColors.error)
                else if (isInCart)
                  _StockBadge(label: '$qtyInCart', color: PPColors.brand),
              ],
            ),

            const SizedBox(height: 10),

            // ── Name ─────────────────────────────────
            Text(
              product.name,
              style: PPTypography.labelLG.copyWith(color: textPrimary),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),

            const SizedBox(height: 4),

            // ── Stock ─────────────────────────────────
            Text(
              'Stock: ${product.stockQty} ${product.unit}',
              style: PPTypography.bodyXS.copyWith(color: textSec),
            ),

            const Spacer(),

            // ── Price + add btn ───────────────────────
            Row(
              children: [
                Expanded(
                  child: Text(
                    PPFormatter.ksh(product.price),
                    style: PPTypography.metricSM.copyWith(
                      color: isInCart ? PPColors.brand : textPrimary,
                      fontSize: 15,
                    ),
                  ),
                ),
                if (!isOut)
                  _AddRemoveControl(
                    qty: qtyInCart,
                    onAdd: () {
                      HapticFeedback.lightImpact();
                      cartNotifier.addProduct(product);
                    },
                    onRemove: () {
                      HapticFeedback.lightImpact();
                      cartNotifier.decreaseProduct(product.id);
                    },
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Color _categoryColor(String cat) {
    switch (cat) {
      case 'Beverages': return const Color(0xFF2196F3);
      case 'Groceries': return PPColors.gold;
      case 'Cleaning': return PPColors.accent;
      case 'Personal Care': return const Color(0xFFAB47BC);
      case 'Snacks': return const Color(0xFFFF7043);
      default: return PPColors.brand;
    }
  }

  IconData _categoryIcon(String cat) {
    switch (cat) {
      case 'Beverages': return Icons.local_drink_outlined;
      case 'Groceries': return Icons.shopping_basket_outlined;
      case 'Cleaning': return Icons.cleaning_services_outlined;
      case 'Personal Care': return Icons.spa_outlined;
      case 'Snacks': return Icons.lunch_dining_outlined;
      default: return Icons.inventory_2_outlined;
    }
  }
}

// ── Add / remove qty control ──────────────────────────────────
class _AddRemoveControl extends StatelessWidget {
  const _AddRemoveControl({
    required this.qty,
    required this.onAdd,
    required this.onRemove,
  });
  final int qty;
  final VoidCallback onAdd;
  final VoidCallback onRemove;

  @override
  Widget build(BuildContext context) {
    if (qty == 0) {
      return GestureDetector(
        onTap: onAdd,
        child: Container(
          width: 30, height: 30,
          decoration: BoxDecoration(
            color: PPColors.brand,
            borderRadius: BorderRadius.circular(8),
          ),
          child: const Icon(Icons.add_rounded, color: Colors.black, size: 18),
        ),
      );
    }
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        GestureDetector(
          onTap: onRemove,
          child: Container(
            width: 26, height: 26,
            decoration: BoxDecoration(
              color: PPColors.darkSurface2,
              borderRadius: BorderRadius.circular(7),
              border: Border.all(color: PPColors.darkBorder),
            ),
            child: const Icon(Icons.remove_rounded, color: PPColors.brand, size: 15),
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 7),
          child: Text(
            '$qty',
            style: PPTypography.labelMD.copyWith(
              color: PPColors.brand,
              fontFamily: 'Sora',
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
        GestureDetector(
          onTap: onAdd,
          child: Container(
            width: 26, height: 26,
            decoration: BoxDecoration(
              color: PPColors.brand,
              borderRadius: BorderRadius.circular(7),
            ),
            child: const Icon(Icons.add_rounded, color: Colors.black, size: 15),
          ),
        ),
      ],
    );
  }
}

// ── Floating cart bar ─────────────────────────────────────────
class _CartBar extends StatelessWidget {
  const _CartBar({required this.cart, required this.onTap});
  final CartState cart;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: PPSpacing.screenH),
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          height: 58,
          decoration: BoxDecoration(
            color: PPColors.brand,
            borderRadius: BorderRadius.circular(PPSpacing.radiusLG),
            boxShadow: [
              BoxShadow(
                color: PPColors.brand.withOpacity(0.4),
                blurRadius: 20,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Row(
            children: [
              const SizedBox(width: 16),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(PPSpacing.radiusFull),
                ),
                child: Text(
                  '${cart.itemCount}',
                  style: PPTypography.labelMD.copyWith(
                    color: Colors.white,
                    fontFamily: 'Sora',
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              const SizedBox(width: 10),
              const Expanded(
                child: Text(
                  'View Cart',
                  style: TextStyle(
                    fontFamily: 'DM Sans',
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: Colors.black,
                  ),
                ),
              ),
              Text(
                PPFormatter.ksh(cart.grandTotal),
                style: PPTypography.metricSM.copyWith(
                  color: Colors.black,
                  fontSize: 16,
                ),
              ),
              const SizedBox(width: 16),
              const Icon(Icons.arrow_forward_ios_rounded,
                  color: Colors.black, size: 14),
              const SizedBox(width: 14),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Stock badge ───────────────────────────────────────────────
class _StockBadge extends StatelessWidget {
  const _StockBadge({required this.label, required this.color});
  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
      decoration: BoxDecoration(
        color: color.withOpacity(0.15),
        borderRadius: BorderRadius.circular(PPSpacing.radiusFull),
      ),
      child: Text(label,
          style: PPTypography.labelXS.copyWith(color: color)),
    );
  }
}

// ── Empty state ───────────────────────────────────────────────
class _EmptyProducts extends StatelessWidget {
  const _EmptyProducts({required this.isDark, required this.textSec});
  final bool isDark;
  final Color textSec;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.search_off_rounded, size: 52,
              color: textSec.withOpacity(0.4)),
          const SizedBox(height: 12),
          Text('No products found',
              style: PPTypography.headingSM.copyWith(color: textSec)),
          const SizedBox(height: 4),
          Text('Try a different search or category',
              style: PPTypography.bodySM.copyWith(color: textSec.withOpacity(0.6))),
        ],
      ),
    );
  }
}
