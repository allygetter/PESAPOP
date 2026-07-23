// lib/features/inventory/presentation/screens/inventory_screen.dart
// PESAPOP AI — Inventory Screen

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/utils/formatters.dart';
import '../../../../core/widgets/pp_bottom_nav.dart';
import '../../../../core/widgets/pp_button.dart';
import '../../../../core/widgets/pp_card.dart';
import '../../../cashier/domain/cashier_models.dart';
import '../providers/inventory_provider.dart';
import '../../domain/inventory_models.dart';

class InventoryScreen extends ConsumerStatefulWidget {
  const InventoryScreen({super.key, this.role = 'cashier'});
  final String role;

  @override
  ConsumerState<InventoryScreen> createState() => _InventoryScreenState();
}

class _InventoryScreenState extends ConsumerState<InventoryScreen> {
  final _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final products = ref.watch(filteredInventoryProvider);
    final stats = ref.watch(inventoryStatsProvider);
    final movements = ref.watch(recentMovementsProvider);
    final filter = ref.watch(inventoryFilterProvider);

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
        child: Column(children: [

          // ── Header ─────────────────────────────────
          Padding(
            padding: const EdgeInsets.fromLTRB(PPSpacing.screenH, 16, PPSpacing.screenH, 0),
            child: Row(children: [
              GestureDetector(
                onTap: () => context.pop(),
                child: Container(
                  width: 38, height: 38,
                  decoration: BoxDecoration(color: surf,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: border)),
                  child: Icon(Icons.arrow_back_ios_new_rounded, size: 16, color: textPrimary),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(child: Text('Inventory',
                  style: PPTypography.headingLG.copyWith(color: textPrimary))),
              GestureDetector(
                onTap: () => _showStockInSheet(context, isDark, surf, surf2, border, textPrimary, textSec),
                child: Container(
                  height: 36,
                  padding: const EdgeInsets.symmetric(horizontal: 14),
                  decoration: BoxDecoration(
                    color: PPColors.brand,
                    borderRadius: BorderRadius.circular(PPSpacing.radiusMD),
                  ),
                  child: Row(mainAxisSize: MainAxisSize.min, children: [
                    const Icon(Icons.add_rounded, color: Colors.black, size: 18),
                    const SizedBox(width: 4),
                    Text('Stock In', style: PPTypography.buttonSM.copyWith(color: Colors.black)),
                  ]),
                ),
              ),
            ]),
          ),

          const SizedBox(height: 16),

          // ── Stat cards ──────────────────────────────
          SizedBox(
            height: 82,
            child: ListView(
              padding: const EdgeInsets.symmetric(horizontal: PPSpacing.screenH),
              scrollDirection: Axis.horizontal,
              children: [
                _StatChip(label: 'Products', value: stats.totalProducts.toString(),
                    icon: Icons.inventory_2_outlined, color: PPColors.brand,
                    isDark: isDark, surf: surf, border: border, textPrimary: textPrimary, textSec: textSec),
                const SizedBox(width: 10),
                _StatChip(label: 'Stock Value', value: PPFormatter.ksh(stats.totalValue, compact: true),
                    icon: Icons.attach_money_rounded, color: PPColors.gold,
                    isDark: isDark, surf: surf, border: border, textPrimary: textPrimary, textSec: textSec),
                const SizedBox(width: 10),
                _StatChip(label: 'Low Stock', value: stats.lowStockCount.toString(),
                    icon: Icons.warning_amber_rounded, color: PPColors.warning,
                    isDark: isDark, surf: surf, border: border, textPrimary: textPrimary, textSec: textSec,
                    alert: true),
                const SizedBox(width: 10),
                _StatChip(label: 'Out of Stock', value: stats.outOfStockCount.toString(),
                    icon: Icons.remove_shopping_cart_outlined, color: PPColors.error,
                    isDark: isDark, surf: surf, border: border, textPrimary: textPrimary, textSec: textSec),
              ],
            ),
          ),

          const SizedBox(height: 14),

          // ── Search ──────────────────────────────────
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: PPSpacing.screenH),
            child: Container(
              height: 44,
              decoration: BoxDecoration(
                  color: surf2,
                  borderRadius: BorderRadius.circular(PPSpacing.radiusMD),
                  border: Border.all(color: border)),
              child: Row(children: [
                const SizedBox(width: 12),
                Icon(Icons.search_rounded, color: PPColors.brand, size: 20),
                const SizedBox(width: 10),
                Expanded(
                  child: TextField(
                    controller: _searchController,
                    onChanged: (q) => ref.read(inventorySearchProvider.notifier).state = q,
                    style: PPTypography.bodyMD.copyWith(color: textPrimary),
                    decoration: InputDecoration(
                      hintText: 'Search products...',
                      hintStyle: PPTypography.bodyMD.copyWith(color: textSec),
                      border: InputBorder.none, enabledBorder: InputBorder.none,
                      focusedBorder: InputBorder.none, filled: false,
                      contentPadding: EdgeInsets.zero, isDense: true,
                    ),
                  ),
                ),
                if (_searchController.text.isNotEmpty)
                  GestureDetector(
                    onTap: () { _searchController.clear(); ref.read(inventorySearchProvider.notifier).state = ''; },
                    child: Icon(Icons.close_rounded, color: textSec, size: 18),
                  ),
                const SizedBox(width: 12),
              ]),
            ),
          ),

          const SizedBox(height: 10),

          // ── Filter chips ────────────────────────────
          SizedBox(
            height: 34,
            child: ListView(
              padding: const EdgeInsets.symmetric(horizontal: PPSpacing.screenH),
              scrollDirection: Axis.horizontal,
              children: ['All', 'Low Stock', 'Beverages', 'Groceries', 'Cleaning', 'Personal Care', 'Snacks']
                  .map((f) {
                final sel = f == filter;
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: GestureDetector(
                    onTap: () => ref.read(inventoryFilterProvider.notifier).state = f,
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 160),
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
                      decoration: BoxDecoration(
                        color: sel
                            ? (f == 'Low Stock' ? PPColors.warning : PPColors.brand)
                            : surf2,
                        borderRadius: BorderRadius.circular(PPSpacing.radiusFull),
                        border: Border.all(color: sel
                            ? (f == 'Low Stock' ? PPColors.warning : PPColors.brand)
                            : border),
                      ),
                      child: Text(f,
                          style: PPTypography.labelMD.copyWith(
                            color: sel ? Colors.black : textSec,
                            fontWeight: sel ? FontWeight.w600 : FontWeight.w400,
                          )),
                    ),
                  ),
                );
              }).toList(),
            ),
          ),

          const SizedBox(height: 10),

          // ── Product list ────────────────────────────
          Expanded(
            child: ListView.separated(
              padding: const EdgeInsets.fromLTRB(PPSpacing.screenH, 0, PPSpacing.screenH, 100),
              itemCount: products.length + 1,
              separatorBuilder: (_, __) => const SizedBox(height: 8),
              itemBuilder: (context, i) {
                if (i == products.length) {
                  return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    const SizedBox(height: 20),
                    PPSectionHeader(title: 'Recent Movements', action: 'See all', onAction: () {}),
                    const SizedBox(height: 12),
                    ...movements.map((m) => Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: _MovementRow(movement: m, isDark: isDark, surf: surf,
                          border: border, textPrimary: textPrimary, textSec: textSec),
                    )),
                  ]);
                }
                return _ProductRow(
                  product: products[i],
                  isDark: isDark, surf: surf, border: border,
                  textPrimary: textPrimary, textSec: textSec,
                  onStockIn: () => _showStockInSheet(context, isDark, surf, surf2, border, textPrimary, textSec, product: products[i]),
                );
              },
            ),
          ),
        ]),
      ),
      bottomNavigationBar: PPBottomNav(
        items: cashierNavItems,
        currentIndex: 2,
        onTap: (i) {
          if (i == 0) context.go('/cashier');
          if (i == 1) context.push('/cashier/pos');
        },
      ),
    );
  }

  void _showStockInSheet(BuildContext context, bool isDark, Color surf, Color surf2,
      Color border, Color textPrimary, Color textSec, {PPProduct? product}) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _StockInSheet(
        isDark: isDark, surf: surf, surf2: surf2, border: border,
        textPrimary: textPrimary, textSec: textSec, product: product,
      ),
    );
  }
}

// ── Stat chip ─────────────────────────────────────────────────
class _StatChip extends StatelessWidget {
  const _StatChip({
    required this.label, required this.value, required this.icon,
    required this.color, required this.isDark, required this.surf,
    required this.border, required this.textPrimary, required this.textSec,
    this.alert = false,
  });
  final String label, value;
  final IconData icon;
  final Color color, surf, border, textPrimary, textSec;
  final bool isDark, alert;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 110,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: alert ? color.withOpacity(0.06) : surf,
        borderRadius: BorderRadius.circular(PPSpacing.radiusMD),
        border: Border.all(color: alert ? color.withOpacity(0.3) : border),
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisAlignment: MainAxisAlignment.center, children: [
        Row(children: [
          Icon(icon, color: color, size: 14),
          const SizedBox(width: 4),
          Text(label, style: PPTypography.labelXS.copyWith(color: textSec)),
        ]),
        const SizedBox(height: 6),
        Text(value, style: PPTypography.metricSM.copyWith(color: alert ? color : textPrimary, fontSize: 18)),
      ]),
    );
  }
}

// ── Product row ───────────────────────────────────────────────
class _ProductRow extends StatelessWidget {
  const _ProductRow({
    required this.product, required this.isDark, required this.surf,
    required this.border, required this.textPrimary, required this.textSec,
    required this.onStockIn,
  });
  final PPProduct product;
  final bool isDark;
  final Color surf, border, textPrimary, textSec;
  final VoidCallback onStockIn;

  @override
  Widget build(BuildContext context) {
    final pct = (product.stockQty / 60).clamp(0.0, 1.0);
    final stockColor = product.isOutOfStock
        ? PPColors.error
        : product.isLowStock ? PPColors.warning : PPColors.success;

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: surf,
        borderRadius: BorderRadius.circular(PPSpacing.radiusMD),
        border: Border.all(color: product.isLowStock ? PPColors.warning.withOpacity(0.4) : border),
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          // Category icon
          Container(
            width: 38, height: 38,
            decoration: BoxDecoration(
              color: _catColor(product.category).withOpacity(0.1),
              borderRadius: BorderRadius.circular(9),
            ),
            child: Icon(_catIcon(product.category), color: _catColor(product.category), size: 19),
          ),
          const SizedBox(width: 10),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(product.name, style: PPTypography.labelLG.copyWith(color: textPrimary),
                maxLines: 1, overflow: TextOverflow.ellipsis),
            Text(product.category,
                style: PPTypography.bodySM.copyWith(color: textSec)),
          ])),
          const SizedBox(width: 8),
          Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
            Text(PPFormatter.ksh(product.price),
                style: PPTypography.labelLG.copyWith(color: textPrimary, fontFamily: 'Sora')),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
              decoration: BoxDecoration(
                color: stockColor.withOpacity(0.12),
                borderRadius: BorderRadius.circular(PPSpacing.radiusFull),
              ),
              child: Text(
                product.isOutOfStock ? 'Out of stock'
                    : product.isLowStock ? 'Low: ${product.stockQty}'
                    : '${product.stockQty} ${product.unit}',
                style: PPTypography.labelXS.copyWith(color: stockColor),
              ),
            ),
          ]),
        ]),
        const SizedBox(height: 10),
        // Stock bar
        Row(children: [
          Expanded(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(PPSpacing.radiusFull),
              child: LinearProgressIndicator(
                value: pct,
                minHeight: 5,
                backgroundColor: stockColor.withOpacity(0.12),
                valueColor: AlwaysStoppedAnimation(stockColor),
              ),
            ),
          ),
          const SizedBox(width: 10),
          GestureDetector(
            onTap: onStockIn,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              decoration: BoxDecoration(
                color: PPColors.brand.withOpacity(0.1),
                borderRadius: BorderRadius.circular(PPSpacing.radiusSM),
                border: Border.all(color: PPColors.brand.withOpacity(0.3)),
              ),
              child: Row(mainAxisSize: MainAxisSize.min, children: [
                const Icon(Icons.add_rounded, color: PPColors.brand, size: 13),
                const SizedBox(width: 3),
                Text('Stock In', style: PPTypography.labelXS.copyWith(color: PPColors.brand)),
              ]),
            ),
          ),
        ]),
      ]),
    );
  }

  Color _catColor(String cat) {
    switch (cat) {
      case 'Beverages': return const Color(0xFF2196F3);
      case 'Groceries': return PPColors.gold;
      case 'Cleaning': return PPColors.accent;
      case 'Personal Care': return const Color(0xFFAB47BC);
      default: return PPColors.brand;
    }
  }

  IconData _catIcon(String cat) {
    switch (cat) {
      case 'Beverages': return Icons.local_drink_outlined;
      case 'Groceries': return Icons.shopping_basket_outlined;
      case 'Cleaning': return Icons.cleaning_services_outlined;
      case 'Personal Care': return Icons.spa_outlined;
      default: return Icons.lunch_dining_outlined;
    }
  }
}

// ── Stock movement row ────────────────────────────────────────
class _MovementRow extends StatelessWidget {
  const _MovementRow({
    required this.movement, required this.isDark, required this.surf,
    required this.border, required this.textPrimary, required this.textSec,
  });
  final StockMovement movement;
  final bool isDark;
  final Color surf, border, textPrimary, textSec;

  @override
  Widget build(BuildContext context) {
    final c = movement.type.color;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: surf,
        borderRadius: BorderRadius.circular(PPSpacing.radiusMD),
        border: Border.all(color: border),
      ),
      child: Row(children: [
        Container(
          width: 34, height: 34,
          decoration: BoxDecoration(color: c.withOpacity(0.12), shape: BoxShape.circle),
          child: Icon(
            movement.type == StockMovementType.stockIn ? Icons.arrow_downward_rounded
                : movement.type == StockMovementType.stockOut ? Icons.arrow_upward_rounded
                : Icons.swap_horiz_rounded,
            color: c, size: 16,
          ),
        ),
        const SizedBox(width: 10),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(movement.productName,
              style: PPTypography.labelMD.copyWith(color: textPrimary),
              maxLines: 1, overflow: TextOverflow.ellipsis),
          Text('${movement.type.label} · ${PPFormatter.timeAgo(movement.createdAt)}',
              style: PPTypography.bodySM.copyWith(color: textSec)),
        ])),
        Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
          Text(
            (movement.type == StockMovementType.stockIn ? '+' : '-') + movement.qty.toString(),
            style: PPTypography.labelLG.copyWith(color: c, fontFamily: 'Sora'),
          ),
          if (movement.reference != null)
            Text(movement.reference!,
                style: PPTypography.bodyXS.copyWith(color: textSec)),
        ]),
      ]),
    );
  }
}

// ── Stock-in bottom sheet ─────────────────────────────────────
class _StockInSheet extends ConsumerStatefulWidget {
  const _StockInSheet({
    required this.isDark, required this.surf, required this.surf2,
    required this.border, required this.textPrimary, required this.textSec,
    this.product,
  });
  final bool isDark;
  final Color surf, surf2, border, textPrimary, textSec;
  final PPProduct? product;

  @override
  ConsumerState<_StockInSheet> createState() => _StockInSheetState();
}

class _StockInSheetState extends ConsumerState<_StockInSheet> {
  final _qtyController = TextEditingController(text: '1');
  final _noteController = TextEditingController();
  PPProduct? _selectedProduct;

  @override
  void initState() {
    super.initState();
    _selectedProduct = widget.product;
  }

  @override
  void dispose() {
    _qtyController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
      child: Container(
        decoration: BoxDecoration(
          color: widget.surf,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(PPSpacing.radiusXXL)),
        ),
        padding: const EdgeInsets.fromLTRB(PPSpacing.screenH, 12, PPSpacing.screenH, PPSpacing.xl2),
        child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [
          Center(child: Container(width: 36, height: 4,
              decoration: BoxDecoration(color: widget.border,
                  borderRadius: BorderRadius.circular(PPSpacing.radiusFull)))),
          const SizedBox(height: 16),
          Text('Add Stock', style: PPTypography.headingLG.copyWith(color: widget.textPrimary)),
          const SizedBox(height: 4),
          Text('Record new inventory received', style: PPTypography.bodyMD.copyWith(color: widget.textSec)),
          const SizedBox(height: 20),

          // Product selector
          Text('Product', style: PPTypography.labelMD.copyWith(color: widget.textSec)),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            decoration: BoxDecoration(
              color: widget.surf2,
              borderRadius: BorderRadius.circular(PPSpacing.radiusMD),
              border: Border.all(color: widget.border),
            ),
            child: Row(children: [
              Icon(Icons.inventory_2_outlined, color: PPColors.brand, size: 18),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  _selectedProduct?.name ?? 'Select a product...',
                  style: PPTypography.bodyMD.copyWith(
                    color: _selectedProduct != null ? widget.textPrimary : widget.textSec,
                  ),
                ),
              ),
              Icon(Icons.keyboard_arrow_down_rounded, color: widget.textSec, size: 20),
            ]),
          ),
          const SizedBox(height: 14),

          // Qty + ref row
          Row(children: [
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text('Quantity', style: PPTypography.labelMD.copyWith(color: widget.textSec)),
              const SizedBox(height: 8),
              TextField(
                controller: _qtyController,
                keyboardType: TextInputType.number,
                style: PPTypography.bodyMD.copyWith(color: widget.textPrimary),
                decoration: const InputDecoration(prefixIcon: Icon(Icons.add_box_outlined)),
              ),
            ])),
            const SizedBox(width: 12),
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text('Reference / PO#', style: PPTypography.labelMD.copyWith(color: widget.textSec)),
              const SizedBox(height: 8),
              TextField(
                style: PPTypography.bodyMD.copyWith(color: widget.textPrimary),
                decoration: InputDecoration(
                  hintText: 'e.g. PO-0042',
                  hintStyle: PPTypography.bodyMD.copyWith(color: widget.textSec),
                  prefixIcon: const Icon(Icons.tag_rounded),
                ),
              ),
            ])),
          ]),
          const SizedBox(height: 14),

          Text('Note (optional)', style: PPTypography.labelMD.copyWith(color: widget.textSec)),
          const SizedBox(height: 8),
          TextField(
            controller: _noteController,
            maxLines: 2,
            style: PPTypography.bodyMD.copyWith(color: widget.textPrimary),
            decoration: InputDecoration(
              hintText: 'e.g. Delivery from ABC Suppliers',
              hintStyle: PPTypography.bodyMD.copyWith(color: widget.textSec),
            ),
          ),
          const SizedBox(height: 20),

          PPButton(
            label: 'Confirm Stock In',
            onTap: () => Navigator.pop(context),
            size: PPButtonSize.lg,
            icon: const Icon(Icons.check_circle_outline_rounded),
          ),
        ]),
      ),
    );
  }
}
