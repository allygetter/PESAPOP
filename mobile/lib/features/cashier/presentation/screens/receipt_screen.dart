// lib/features/cashier/presentation/screens/receipt_screen.dart
// PESAPOP AI — Receipt Screen (print, share, WhatsApp)

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
import '../providers/pos_provider.dart';

class ReceiptScreen extends ConsumerWidget {
  const ReceiptScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    // Pull sale from route extra, fall back to a mock for preview
    final sale = (ModalRoute.of(context)?.settings.arguments
            ?? GoRouterState.of(context).extra)
        as CompletedSale?;

    if (sale == null) {
      return Scaffold(
        backgroundColor: isDark ? PPColors.darkBg : PPColors.lightBg,
        body: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.receipt_long_outlined, size: 48, color: PPColors.brand),
              const SizedBox(height: 14),
              Text('No receipt data',
                  style: PPTypography.headingSM.copyWith(
                      color: isDark ? PPColors.darkText : PPColors.lightText)),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () => context.go('/cashier'),
                child: const Text('Back to Home'),
              ),
            ],
          ),
        ),
      );
    }

    final bg = isDark ? PPColors.darkBg : PPColors.lightBg;
    final surf = isDark ? PPColors.darkSurface : PPColors.lightSurface;
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
                    onTap: () => context.go('/cashier'),
                    child: Container(
                      width: 38, height: 38,
                      decoration: BoxDecoration(
                        color: surf,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: border),
                      ),
                      child: Icon(Icons.close_rounded, size: 20, color: textPrimary),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Text('Receipt',
                      style: PPTypography.headingLG.copyWith(color: textPrimary)),
                  const Spacer(),
                  _IconAction(
                    icon: Icons.share_outlined,
                    label: 'Share',
                    isDark: isDark,
                    onTap: () => _shareReceipt(context, sale),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // ── Receipt paper ───────────────────────────
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: PPSpacing.screenH),
                child: Column(
                  children: [
                    _ReceiptPaper(
                      sale: sale,
                      isDark: isDark,
                      surf: surf,
                      border: border,
                      textPrimary: textPrimary,
                      textSec: textSec,
                    ),
                    const SizedBox(height: 20),

                    // ── Send receipt row ─────────────────
                    Text('Send Receipt',
                        style: PPTypography.headingSM.copyWith(color: textPrimary)),
                    const SizedBox(height: 12),
                    _SendReceiptRow(
                      isDark: isDark,
                      surf: surf,
                      border: border,
                      textPrimary: textPrimary,
                      textSec: textSec,
                    ),
                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ),

            // ── Bottom actions ──────────────────────────
            Container(
              padding: EdgeInsets.fromLTRB(
                PPSpacing.screenH, 16, PPSpacing.screenH,
                PPSpacing.cardPad + MediaQuery.of(context).padding.bottom,
              ),
              decoration: BoxDecoration(
                color: surf,
                border: Border(top: BorderSide(color: border)),
              ),
              child: Column(
                children: [
                  PPButton(
                    label: 'Print Receipt',
                    onTap: () => _printReceipt(context),
                    size: PPButtonSize.lg,
                    icon: const Icon(Icons.print_outlined),
                  ),
                  const SizedBox(height: 10),
                  PPButton(
                    label: 'New Sale',
                    onTap: () {
                      ref.read(paymentProvider.notifier).reset();
                      context.go('/cashier/pos');
                    },
                    variant: PPButtonVariant.outline,
                    size: PPButtonSize.lg,
                    icon: const Icon(Icons.add_shopping_cart_rounded),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _shareReceipt(BuildContext context, CompletedSale sale) {
    // TODO: integrate share_plus package
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Sharing receipt...')),
    );
  }

  void _printReceipt(BuildContext context) {
    // TODO: integrate printing + bluetooth_print packages
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Sending to printer...')),
    );
  }
}

// ── Receipt paper widget ──────────────────────────────────────
class _ReceiptPaper extends StatelessWidget {
  const _ReceiptPaper({
    required this.sale,
    required this.isDark,
    required this.surf,
    required this.border,
    required this.textPrimary,
    required this.textSec,
  });
  final CompletedSale sale;
  final bool isDark;
  final Color surf, border, textPrimary, textSec;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: surf,
        borderRadius: BorderRadius.circular(PPSpacing.radiusXL),
        border: Border.all(color: border),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(isDark ? 0.3 : 0.06),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        children: [

          // ── Receipt header ─────────────────────────
          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                // Logo
                Container(
                  width: 52, height: 52,
                  decoration: BoxDecoration(
                    color: PPColors.brand,
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: const Center(
                    child: Text('P',
                        style: TextStyle(
                            fontFamily: 'Sora',
                            fontSize: 28, fontWeight: FontWeight.w700,
                            color: Colors.black)),
                  ),
                ),
                const SizedBox(height: 8),
                Text('PESAPOP STORE',
                    style: PPTypography.headingMD.copyWith(color: textPrimary)),
                const SizedBox(height: 2),
                Text('Nairobi, Kenya',
                    style: PPTypography.bodySM.copyWith(color: textSec)),
                const SizedBox(height: 14),
                // Success badge
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    color: PPColors.success.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(PPSpacing.radiusFull),
                    border: Border.all(color: PPColors.success.withOpacity(0.3)),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.check_circle_rounded,
                          color: PPColors.success, size: 16),
                      const SizedBox(width: 6),
                      Text('Payment Confirmed',
                          style: PPTypography.labelMD.copyWith(
                              color: PPColors.success)),
                    ],
                  ),
                ),
              ],
            ),
          ),

          _Dashes(color: border),

          // ── Receipt meta ───────────────────────────
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
            child: Column(
              children: [
                _ReceiptRow(
                  label: 'Receipt No.',
                  value: sale.receiptNumber ?? 'RCP000001',
                  textPrimary: textPrimary, textSec: textSec,
                  valueMono: true,
                ),
                const SizedBox(height: 8),
                _ReceiptRow(
                  label: 'Date & Time',
                  value: PPFormatter.dateTime(sale.createdAt),
                  textPrimary: textPrimary, textSec: textSec,
                ),
                const SizedBox(height: 8),
                _ReceiptRow(
                  label: 'Cashier',
                  value: sale.cashierName ?? '—',
                  textPrimary: textPrimary, textSec: textSec,
                ),
                if (sale.mpesaRef != null) ...[
                  const SizedBox(height: 8),
                  _ReceiptRow(
                    label: 'M-Pesa Ref',
                    value: sale.mpesaRef!,
                    textPrimary: textPrimary, textSec: textSec,
                    valueMono: true,
                    valueColor: PPColors.mpesa,
                  ),
                ],
              ],
            ),
          ),

          _Dashes(color: border),

          // ── Line items ─────────────────────────────
          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                // Header
                Row(
                  children: [
                    Expanded(
                      child: Text('Item',
                          style: PPTypography.labelSM.copyWith(color: textSec)),
                    ),
                    Text('Qty',
                        style: PPTypography.labelSM.copyWith(color: textSec)),
                    const SizedBox(width: 20),
                    SizedBox(
                      width: 70,
                      child: Text('Amount',
                          style: PPTypography.labelSM.copyWith(color: textSec),
                          textAlign: TextAlign.right),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                ...sale.items.map((item) => Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: Row(
                        children: [
                          Expanded(
                            child: Text(item.product.name,
                                style: PPTypography.bodyMD
                                    .copyWith(color: textPrimary),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis),
                          ),
                          Text('${item.qty}',
                              style: PPTypography.bodyMD.copyWith(color: textSec)),
                          const SizedBox(width: 20),
                          SizedBox(
                            width: 70,
                            child: Text(PPFormatter.ksh(item.subtotal),
                                style: PPTypography.labelLG.copyWith(
                                    color: textPrimary, fontFamily: 'Sora'),
                                textAlign: TextAlign.right),
                          ),
                        ],
                      ),
                    )),
              ],
            ),
          ),

          _Dashes(color: border),

          // ── Totals ────────────────────────────────
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 14, 20, 20),
            child: Column(
              children: [
                _ReceiptRow(
                  label: 'Subtotal',
                  value: PPFormatter.ksh(sale.subtotal),
                  textPrimary: textPrimary, textSec: textSec,
                ),
                const SizedBox(height: 6),
                _ReceiptRow(
                  label: 'VAT (16%)',
                  value: PPFormatter.ksh(sale.taxTotal),
                  textPrimary: textPrimary, textSec: textSec,
                ),
                const SizedBox(height: 10),
                Divider(color: border, thickness: 1),
                const SizedBox(height: 10),
                Row(
                  children: [
                    Text('TOTAL',
                        style: PPTypography.headingMD.copyWith(color: textPrimary)),
                    const Spacer(),
                    Text(PPFormatter.ksh(sale.grandTotal),
                        style: PPTypography.metricMD.copyWith(color: PPColors.brand)),
                  ],
                ),
                const SizedBox(height: 10),
                _ReceiptRow(
                  label: 'Paid (${sale.paymentMethod.label})',
                  value: PPFormatter.ksh(sale.amountPaid),
                  textPrimary: textPrimary, textSec: textSec,
                  valueColor: PPColors.success,
                ),
                if (sale.change > 0) ...[
                  const SizedBox(height: 6),
                  _ReceiptRow(
                    label: 'Change',
                    value: PPFormatter.ksh(sale.change),
                    textPrimary: textPrimary, textSec: textSec,
                  ),
                ],
              ],
            ),
          ),

          // ── Footer ────────────────────────────────
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 16),
            decoration: BoxDecoration(
              color: PPColors.brand.withOpacity(0.06),
              borderRadius: const BorderRadius.vertical(
                bottom: Radius.circular(PPSpacing.radiusXL),
              ),
            ),
            child: Column(
              children: [
                Text('Thank you for shopping with us!',
                    style: PPTypography.bodyMD.copyWith(color: textSec)),
                const SizedBox(height: 4),
                Text('Powered by PESAPOP AI',
                    style: PPTypography.labelSM.copyWith(color: PPColors.brand)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ── Send receipt row (WhatsApp, SMS, Email) ──────────────────
class _SendReceiptRow extends StatelessWidget {
  const _SendReceiptRow({
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
    return Row(
      children: [
        _SendBtn(
          icon: Icons.chat_rounded,
          label: 'WhatsApp',
          color: const Color(0xFF25D366),
          isDark: isDark, surf: surf, border: border,
          textSec: textSec, onTap: () {},
        ),
        const SizedBox(width: 10),
        _SendBtn(
          icon: Icons.sms_outlined,
          label: 'SMS',
          color: PPColors.brand,
          isDark: isDark, surf: surf, border: border,
          textSec: textSec, onTap: () {},
        ),
        const SizedBox(width: 10),
        _SendBtn(
          icon: Icons.mail_outline_rounded,
          label: 'Email',
          color: const Color(0xFFEA4335),
          isDark: isDark, surf: surf, border: border,
          textSec: textSec, onTap: () {},
        ),
      ],
    );
  }
}

class _SendBtn extends StatelessWidget {
  const _SendBtn({
    required this.icon,
    required this.label,
    required this.color,
    required this.isDark,
    required this.surf,
    required this.border,
    required this.textSec,
    required this.onTap,
  });
  final IconData icon;
  final String label;
  final Color color, surf, border, textSec;
  final bool isDark;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 14),
          decoration: BoxDecoration(
            color: surf,
            borderRadius: BorderRadius.circular(PPSpacing.radiusMD),
            border: Border.all(color: border),
          ),
          child: Column(
            children: [
              Icon(icon, color: color, size: 24),
              const SizedBox(height: 5),
              Text(label,
                  style: PPTypography.labelSM.copyWith(color: textSec)),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Helpers ───────────────────────────────────────────────────
class _ReceiptRow extends StatelessWidget {
  const _ReceiptRow({
    required this.label,
    required this.value,
    required this.textPrimary,
    required this.textSec,
    this.valueMono = false,
    this.valueColor,
  });
  final String label, value;
  final Color textPrimary, textSec;
  final bool valueMono;
  final Color? valueColor;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text(label, style: PPTypography.bodyMD.copyWith(color: textSec)),
        const Spacer(),
        Text(
          value,
          style: valueMono
              ? PPTypography.mono.copyWith(
                  color: valueColor ?? textPrimary)
              : PPTypography.labelLG.copyWith(
                  color: valueColor ?? textPrimary,
                  fontFamily: 'Sora'),
        ),
      ],
    );
  }
}

class _Dashes extends StatelessWidget {
  const _Dashes({required this.color});
  final Color color;

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: const Size(double.infinity, 1),
      painter: _DashedLinePainter(color: color),
    );
  }
}

class _DashedLinePainter extends CustomPainter {
  const _DashedLinePainter({required this.color});
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = color..strokeWidth = 1;
    const dashWidth = 6.0;
    const dashSpace = 4.0;
    double x = 0;
    while (x < size.width) {
      canvas.drawLine(Offset(x, 0), Offset(x + dashWidth, 0), paint);
      x += dashWidth + dashSpace;
    }
  }

  @override
  bool shouldRepaint(_DashedLinePainter old) => old.color != color;
}

class _IconAction extends StatelessWidget {
  const _IconAction({
    required this.icon,
    required this.label,
    required this.isDark,
    required this.onTap,
  });
  final IconData icon;
  final String label;
  final bool isDark;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Row(
        children: [
          Icon(icon,
              color: isDark ? PPColors.darkTextSecondary : PPColors.lightTextSecondary,
              size: 18),
          const SizedBox(width: 4),
          Text(label,
              style: PPTypography.labelMD.copyWith(
                color: isDark ? PPColors.darkTextSecondary : PPColors.lightTextSecondary,
              )),
        ],
      ),
    );
  }
}
