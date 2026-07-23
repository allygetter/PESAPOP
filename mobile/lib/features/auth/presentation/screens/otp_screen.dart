// lib/features/auth/presentation/screens/otp_screen.dart
// PESAPOP AI — OTP Verification Screen

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/widgets/pp_button.dart';
import '../providers/auth_provider.dart';

class OTPScreen extends ConsumerStatefulWidget {
  const OTPScreen({super.key, required this.phoneNumber});
  final String phoneNumber;

  @override
  ConsumerState<OTPScreen> createState() => _OTPScreenState();
}

class _OTPScreenState extends ConsumerState<OTPScreen>
    with SingleTickerProviderStateMixin {
  // 6 separate controllers + focus nodes for each digit box
  final List<TextEditingController> _controllers =
      List.generate(6, (_) => TextEditingController());
  final List<FocusNode> _focusNodes = List.generate(6, (_) => FocusNode());

  // Countdown timer
  Timer? _timer;
  int _secondsRemaining = 60;
  bool _canResend = false;

  // Animation
  late AnimationController _shakeController;
  late Animation<double> _shakeAnimation;

  @override
  void initState() {
    super.initState();
    _startTimer();
    _shakeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    _shakeAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _shakeController, curve: Curves.elasticIn),
    );
  }

  void _startTimer() {
    _timer?.cancel();
    setState(() {
      _secondsRemaining = 60;
      _canResend = false;
    });
    _timer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (_secondsRemaining <= 1) {
        t.cancel();
        setState(() => _canResend = true);
      } else {
        setState(() => _secondsRemaining--);
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    for (final c in _controllers) c.dispose();
    for (final f in _focusNodes) f.dispose();
    _shakeController.dispose();
    super.dispose();
  }

  String get _otpValue =>
      _controllers.map((c) => c.text).join();

  bool get _isComplete => _otpValue.length == 6;

  void _onDigitChanged(int index, String value) {
    if (value.isEmpty) {
      // Backspace: go to previous field
      if (index > 0) {
        _focusNodes[index - 1].requestFocus();
        _controllers[index - 1].clear();
      }
      return;
    }
    // If pasting all 6 digits at once
    if (value.length == 6) {
      for (int i = 0; i < 6; i++) {
        _controllers[i].text = value[i];
      }
      _focusNodes[5].requestFocus();
      setState(() {});
      if (_isComplete) _verify();
      return;
    }
    // Move forward
    _controllers[index].text = value[value.length - 1];
    if (index < 5) {
      _focusNodes[index + 1].requestFocus();
    } else {
      _focusNodes[index].unfocus();
      if (_isComplete) _verify();
    }
    setState(() {});
  }

  Future<void> _verify() async {
    final otp = _otpValue;
    if (otp.length != 6) return;

    final success = await ref.read(authProvider.notifier).verifyOTP(otp);
    if (!mounted) return;

    if (success) {
      final role = ref.read(authProvider).userRole;
      context.go(role == UserRole.cashier ? '/cashier' : '/owner');
    } else {
      // Shake the OTP boxes
      for (final c in _controllers) c.clear();
      _focusNodes[0].requestFocus();
      _shakeController
        ..reset()
        ..forward();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Incorrect OTP. Please try again.'),
            backgroundColor: PPColors.error,
            behavior: SnackBarBehavior.floating,
            margin: const EdgeInsets.all(16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        );
      }
    }
  }

  Future<void> _resend() async {
    if (!_canResend) return;
    final success = await ref.read(authProvider.notifier).requestOTP(
      widget.phoneNumber,
    );
    if (success) _startTimer();
  }

  String get _maskedPhone {
    final p = widget.phoneNumber;
    if (p.length < 4) return p;
    return '${p.substring(0, p.length - 4)}****';
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final authState = ref.watch(authProvider);

    return Scaffold(
      backgroundColor: isDark ? PPColors.darkBg : PPColors.lightBg,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back_ios_new_rounded,
            color: isDark ? PPColors.darkText : PPColors.lightText,
            size: 20,
          ),
          onPressed: () => context.pop(),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: PPSpacing.screenH,
            vertical: PPSpacing.base,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── Header ───────────────────────────────
              Container(
                width: 52, height: 52,
                decoration: BoxDecoration(
                  color: PPColors.brand.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: const Icon(
                  Icons.message_outlined,
                  color: PPColors.brand,
                  size: 26,
                ),
              ),
              const SizedBox(height: 20),
              Text(
                'Enter OTP code',
                style: PPTypography.displaySM.copyWith(
                  color: isDark ? PPColors.darkText : PPColors.lightText,
                ),
              ),
              const SizedBox(height: 8),
              RichText(
                text: TextSpan(
                  style: PPTypography.bodyMD.copyWith(
                    color: isDark
                        ? PPColors.darkTextSecondary
                        : PPColors.lightTextSecondary,
                  ),
                  children: [
                    const TextSpan(text: 'We sent a 6-digit code to '),
                    TextSpan(
                      text: _maskedPhone,
                      style: PPTypography.bodyMD.copyWith(
                        color: isDark ? PPColors.darkText : PPColors.lightText,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: PPSpacing.xl2),

              // ── OTP input boxes ───────────────────────
              AnimatedBuilder(
                animation: _shakeAnimation,
                builder: (context, child) {
                  final shake = (_shakeAnimation.value * 20) *
                      ((_shakeAnimation.value * 10).floor().isEven ? 1 : -1);
                  return Transform.translate(
                    offset: Offset(shake.clamp(-8, 8), 0),
                    child: child,
                  );
                },
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: List.generate(
                    6,
                    (i) => _OTPBox(
                      controller: _controllers[i],
                      focusNode: _focusNodes[i],
                      onChanged: (v) => _onDigitChanged(i, v),
                      isDark: isDark,
                      isFilled: _controllers[i].text.isNotEmpty,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: PPSpacing.xl2),

              // ── Verify button ─────────────────────────
              PPButton(
                label: 'Verify & Continue',
                onTap: _isComplete ? _verify : null,
                isLoading: authState.isLoading,
                isDisabled: !_isComplete,
                size: PPButtonSize.lg,
                icon: const Icon(Icons.verified_outlined),
              ),

              const SizedBox(height: PPSpacing.xl),

              // ── Resend section ────────────────────────
              Center(
                child: _canResend
                    ? GestureDetector(
                        onTap: _resend,
                        child: RichText(
                          text: TextSpan(
                            text: "Didn't receive it? ",
                            style: PPTypography.bodyMD.copyWith(
                              color: isDark
                                  ? PPColors.darkTextSecondary
                                  : PPColors.lightTextSecondary,
                            ),
                            children: [
                              TextSpan(
                                text: 'Resend OTP',
                                style: PPTypography.bodyMD.copyWith(
                                  color: PPColors.brand,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ),
                      )
                    : Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            'Resend code in ',
                            style: PPTypography.bodyMD.copyWith(
                              color: isDark
                                  ? PPColors.darkTextSecondary
                                  : PPColors.lightTextSecondary,
                            ),
                          ),
                          _CountdownBadge(seconds: _secondsRemaining),
                        ],
                      ),
              ),

              const Spacer(),

              // ── Security note ─────────────────────────
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: PPColors.brand.withOpacity(0.06),
                  borderRadius: BorderRadius.circular(PPSpacing.radiusMD),
                  border: Border.all(color: PPColors.brand.withOpacity(0.2)),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.shield_outlined,
                        color: PPColors.brand, size: 18),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        'Never share your OTP with anyone. PESAPOP will never ask for it.',
                        style: PPTypography.bodySM.copyWith(
                          color: isDark
                              ? PPColors.darkTextSecondary
                              : PPColors.lightTextSecondary,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: PPSpacing.base),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Single OTP digit box ─────────────────────────────────────
class _OTPBox extends StatelessWidget {
  const _OTPBox({
    required this.controller,
    required this.focusNode,
    required this.onChanged,
    required this.isDark,
    required this.isFilled,
  });
  final TextEditingController controller;
  final FocusNode focusNode;
  final ValueChanged<String> onChanged;
  final bool isDark;
  final bool isFilled;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 46,
      height: 56,
      child: TextField(
        controller: controller,
        focusNode: focusNode,
        textAlign: TextAlign.center,
        keyboardType: TextInputType.number,
        maxLength: 6, // Allow paste
        inputFormatters: [FilteringTextInputFormatter.digitsOnly],
        style: PPTypography.headingXL.copyWith(
          color: isDark ? PPColors.darkText : PPColors.lightText,
          letterSpacing: 0,
        ),
        decoration: InputDecoration(
          counterText: '',
          contentPadding: EdgeInsets.zero,
          filled: true,
          fillColor: isFilled
              ? PPColors.brand.withOpacity(isDark ? 0.15 : 0.08)
              : (isDark ? PPColors.darkSurface2 : PPColors.lightSurface2),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(PPSpacing.radiusMD),
            borderSide: BorderSide(
              color: isFilled
                  ? PPColors.brand
                  : (isDark ? PPColors.darkBorder : PPColors.lightBorder),
              width: isFilled ? 1.5 : 1,
            ),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(PPSpacing.radiusMD),
            borderSide: const BorderSide(color: PPColors.brand, width: 2),
          ),
        ),
        onChanged: onChanged,
      ),
    );
  }
}

// ── Countdown badge ───────────────────────────────────────────
class _CountdownBadge extends StatelessWidget {
  const _CountdownBadge({required this.seconds});
  final int seconds;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: PPColors.brand.withOpacity(0.12),
        borderRadius: BorderRadius.circular(PPSpacing.radiusFull),
      ),
      child: Text(
        '${seconds}s',
        style: PPTypography.labelMD.copyWith(
          color: PPColors.brand,
          fontFamily: 'Sora',
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}
