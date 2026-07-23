// lib/features/auth/presentation/screens/login_screen.dart
// PESAPOP AI — Login Screen (Phone + Email/Password tabs)

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/widgets/pp_button.dart';
import '../providers/auth_provider.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final _phoneController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  bool _obscurePassword = true;
  int _selectedTab = 0; // 0 = phone, 1 = email

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this)
      ..addListener(() {
        setState(() => _selectedTab = _tabController.index);
      });
  }

  @override
  void dispose() {
    _tabController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _onPhoneContinue() async {
    if (_phoneController.text.trim().length < 9) {
      _showError('Enter a valid phone number');
      return;
    }
    final phone = _phoneController.text.trim();
    final success = await ref.read(authProvider.notifier).requestOTP(phone);
    if (success && mounted) {
      context.push('/otp', extra: phone);
    }
  }

  Future<void> _onEmailLogin() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    final success = await ref.read(authProvider.notifier).loginWithEmail(
      _emailController.text.trim(),
      _passwordController.text,
    );
    if (success && mounted) {
      final role = ref.read(authProvider).userRole;
      context.go(role == UserRole.cashier ? '/cashier' : '/owner');
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
    final authState = ref.watch(authProvider);

    // Show API errors
    ref.listen(authProvider, (prev, next) {
      if (next.status == AuthStatus.error && next.errorMessage != null) {
        _showError(next.errorMessage!);
        ref.read(authProvider.notifier).clearError();
      }
    });

    return Scaffold(
      backgroundColor: isDark ? PPColors.darkBg : PPColors.lightBg,
      body: Stack(
        children: [
          // Background decoration
          Positioned(
            top: -60, right: -60,
            child: Container(
              width: 220, height: 220,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: PPColors.brand.withOpacity(0.06),
              ),
            ),
          ),

          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(
                horizontal: PPSpacing.screenH,
                vertical: PPSpacing.xl,
              ),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // ── Logo ────────────────────────────
                    _PPLogoMark(),
                    const SizedBox(height: PPSpacing.xl2),

                    // ── Headline ─────────────────────────
                    Text(
                      'Welcome back',
                      style: PPTypography.displaySM.copyWith(
                        color: isDark ? PPColors.darkText : PPColors.lightText,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'Sign in to manage your business',
                      style: PPTypography.bodyMD.copyWith(
                        color: isDark
                            ? PPColors.darkTextSecondary
                            : PPColors.lightTextSecondary,
                      ),
                    ),
                    const SizedBox(height: PPSpacing.xl2),

                    // ── Tab switcher ─────────────────────
                    _TabSwitcher(
                      selectedIndex: _selectedTab,
                      onChanged: (i) => _tabController.animateTo(i),
                      isDark: isDark,
                    ),
                    const SizedBox(height: PPSpacing.xl),

                    // ── Tab content ───────────────────────
                    AnimatedSwitcher(
                      duration: const Duration(milliseconds: 250),
                      transitionBuilder: (child, anim) => FadeTransition(
                        opacity: anim,
                        child: SlideTransition(
                          position: Tween<Offset>(
                            begin: const Offset(0.05, 0),
                            end: Offset.zero,
                          ).animate(anim),
                          child: child,
                        ),
                      ),
                      child: _selectedTab == 0
                          ? _PhoneTab(
                              key: const ValueKey('phone'),
                              controller: _phoneController,
                              isDark: isDark,
                            )
                          : _EmailTab(
                              key: const ValueKey('email'),
                              emailController: _emailController,
                              passwordController: _passwordController,
                              obscurePassword: _obscurePassword,
                              onToggleObscure: () => setState(
                                () => _obscurePassword = !_obscurePassword,
                              ),
                              isDark: isDark,
                            ),
                    ),

                    const SizedBox(height: PPSpacing.xl),

                    // ── CTA Button ────────────────────────
                    PPButton(
                      label: _selectedTab == 0 ? 'Continue' : 'Sign In',
                      onTap: _selectedTab == 0
                          ? _onPhoneContinue
                          : _onEmailLogin,
                      isLoading: authState.isLoading,
                      size: PPButtonSize.lg,
                    ),

                    const SizedBox(height: PPSpacing.xl),

                    // ── Divider ───────────────────────────
                    _OrDivider(isDark: isDark),
                    const SizedBox(height: PPSpacing.xl),

                    // ── Social login ──────────────────────
                    _SocialLoginRow(isDark: isDark),

                    const SizedBox(height: PPSpacing.xl2),

                    // ── Sign up link ──────────────────────
                    Center(
                      child: RichText(
                        text: TextSpan(
                          text: "Don't have an account? ",
                          style: PPTypography.bodyMD.copyWith(
                            color: isDark
                                ? PPColors.darkTextSecondary
                                : PPColors.lightTextSecondary,
                          ),
                          children: [
                            WidgetSpan(
                              child: GestureDetector(
                                onTap: () {
                                  // TODO: Navigate to signup
                                },
                                child: Text(
                                  'Sign up free',
                                  style: PPTypography.bodyMD.copyWith(
                                    color: PPColors.brand,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: PPSpacing.xl),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Logo mark widget ─────────────────────────────────────────
class _PPLogoMark extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 40, height: 40,
          decoration: BoxDecoration(
            color: PPColors.brand,
            borderRadius: BorderRadius.circular(11),
          ),
          child: const Center(
            child: Text(
              'P',
              style: TextStyle(
                fontFamily: 'Sora',
                fontSize: 22,
                fontWeight: FontWeight.w700,
                color: Colors.black,
                height: 1,
              ),
            ),
          ),
        ),
        const SizedBox(width: 10),
        const Text(
          'PESAPOP',
          style: TextStyle(
            fontFamily: 'Sora',
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: PPColors.brand,
            letterSpacing: 0.5,
          ),
        ),
      ],
    );
  }
}

// ── Custom tab switcher ──────────────────────────────────────
class _TabSwitcher extends StatelessWidget {
  const _TabSwitcher({
    required this.selectedIndex,
    required this.onChanged,
    required this.isDark,
  });
  final int selectedIndex;
  final ValueChanged<int> onChanged;
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 46,
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: isDark ? PPColors.darkSurface2 : PPColors.lightSurface2,
        borderRadius: BorderRadius.circular(PPSpacing.radiusMD),
        border: Border.all(
          color: isDark ? PPColors.darkBorder : PPColors.lightBorder,
        ),
      ),
      child: Row(
        children: [
          _TabItem(
            label: 'Phone Number',
            icon: Icons.phone_outlined,
            isSelected: selectedIndex == 0,
            onTap: () => onChanged(0),
            isDark: isDark,
          ),
          _TabItem(
            label: 'Email',
            icon: Icons.mail_outline_rounded,
            isSelected: selectedIndex == 1,
            onTap: () => onChanged(1),
            isDark: isDark,
          ),
        ],
      ),
    );
  }
}

class _TabItem extends StatelessWidget {
  const _TabItem({
    required this.label,
    required this.icon,
    required this.isSelected,
    required this.onTap,
    required this.isDark,
  });
  final String label;
  final IconData icon;
  final bool isSelected;
  final VoidCallback onTap;
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeOut,
          decoration: BoxDecoration(
            color: isSelected
                ? PPColors.brand
                : Colors.transparent,
            borderRadius: BorderRadius.circular(PPSpacing.radiusSM),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                size: 16,
                color: isSelected
                    ? Colors.black
                    : (isDark ? PPColors.darkTextSecondary : PPColors.lightTextSecondary),
              ),
              const SizedBox(width: 6),
              Text(
                label,
                style: PPTypography.labelMD.copyWith(
                  color: isSelected
                      ? Colors.black
                      : (isDark ? PPColors.darkTextSecondary : PPColors.lightTextSecondary),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Phone tab ────────────────────────────────────────────────
class _PhoneTab extends StatelessWidget {
  const _PhoneTab({
    super.key,
    required this.controller,
    required this.isDark,
  });
  final TextEditingController controller;
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Phone number',
          style: PPTypography.labelMD.copyWith(
            color: isDark ? PPColors.darkTextSecondary : PPColors.lightTextSecondary,
          ),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            // Country code picker
            Container(
              height: PPSpacing.inputHeight,
              padding: const EdgeInsets.symmetric(horizontal: 12),
              decoration: BoxDecoration(
                color: isDark ? PPColors.darkSurface3 : PPColors.lightSurface3,
                borderRadius: BorderRadius.circular(PPSpacing.radiusMD),
                border: Border.all(
                  color: isDark ? PPColors.darkBorder : PPColors.lightBorder,
                ),
              ),
              child: Row(
                children: [
                  Text('🇰🇪', style: const TextStyle(fontSize: 20)),
                  const SizedBox(width: 6),
                  Text(
                    '+254',
                    style: PPTypography.bodyMD.copyWith(
                      color: isDark ? PPColors.darkText : PPColors.lightText,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(width: 4),
                  Icon(
                    Icons.keyboard_arrow_down_rounded,
                    size: 16,
                    color: isDark ? PPColors.darkTextSecondary : PPColors.lightTextSecondary,
                  ),
                ],
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: SizedBox(
                height: PPSpacing.inputHeight,
                child: TextFormField(
                  controller: controller,
                  keyboardType: TextInputType.phone,
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  style: PPTypography.bodyMD.copyWith(
                    color: isDark ? PPColors.darkText : PPColors.lightText,
                  ),
                  decoration: InputDecoration(
                    hintText: '7XX XXX XXX',
                    hintStyle: PPTypography.bodyMD.copyWith(
                      color: isDark ? PPColors.darkTextMuted : PPColors.lightTextMuted,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Icon(Icons.lock_outline_rounded, size: 14, color: PPColors.brand),
            const SizedBox(width: 6),
            Text(
              'We\'ll send a 6-digit OTP to verify your number',
              style: PPTypography.bodyXS.copyWith(
                color: isDark ? PPColors.darkTextSecondary : PPColors.lightTextSecondary,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

// ── Email tab ────────────────────────────────────────────────
class _EmailTab extends StatelessWidget {
  const _EmailTab({
    super.key,
    required this.emailController,
    required this.passwordController,
    required this.obscurePassword,
    required this.onToggleObscure,
    required this.isDark,
  });
  final TextEditingController emailController;
  final TextEditingController passwordController;
  final bool obscurePassword;
  final VoidCallback onToggleObscure;
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Email address',
          style: PPTypography.labelMD.copyWith(
            color: isDark ? PPColors.darkTextSecondary : PPColors.lightTextSecondary,
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: emailController,
          keyboardType: TextInputType.emailAddress,
          style: PPTypography.bodyMD.copyWith(
            color: isDark ? PPColors.darkText : PPColors.lightText,
          ),
          validator: (v) {
            if (v == null || v.trim().isEmpty) return 'Enter your email';
            if (!v.contains('@')) return 'Enter a valid email';
            return null;
          },
          decoration: const InputDecoration(
            hintText: 'you@example.com',
            prefixIcon: Icon(Icons.mail_outline_rounded),
          ),
        ),
        const SizedBox(height: 14),
        Text(
          'Password',
          style: PPTypography.labelMD.copyWith(
            color: isDark ? PPColors.darkTextSecondary : PPColors.lightTextSecondary,
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: passwordController,
          obscureText: obscurePassword,
          style: PPTypography.bodyMD.copyWith(
            color: isDark ? PPColors.darkText : PPColors.lightText,
          ),
          validator: (v) {
            if (v == null || v.isEmpty) return 'Enter your password';
            if (v.length < 6) return 'Password too short';
            return null;
          },
          decoration: InputDecoration(
            hintText: '••••••••',
            prefixIcon: const Icon(Icons.lock_outline_rounded),
            suffixIcon: IconButton(
              icon: Icon(
                obscurePassword ? Icons.visibility_outlined : Icons.visibility_off_outlined,
                size: 20,
              ),
              onPressed: onToggleObscure,
            ),
          ),
        ),
        const SizedBox(height: 12),
        Align(
          alignment: Alignment.centerRight,
          child: GestureDetector(
            onTap: () {}, // TODO: forgot password
            child: Text(
              'Forgot password?',
              style: PPTypography.labelMD.copyWith(color: PPColors.brand),
            ),
          ),
        ),
      ],
    );
  }
}

// ── Or divider ───────────────────────────────────────────────
class _OrDivider extends StatelessWidget {
  const _OrDivider({required this.isDark});
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Divider(
            color: isDark ? PPColors.darkBorder : PPColors.lightBorder,
            thickness: 1,
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14),
          child: Text(
            'or continue with',
            style: PPTypography.bodySM.copyWith(
              color: isDark ? PPColors.darkTextMuted : PPColors.lightTextMuted,
            ),
          ),
        ),
        Expanded(
          child: Divider(
            color: isDark ? PPColors.darkBorder : PPColors.lightBorder,
            thickness: 1,
          ),
        ),
      ],
    );
  }
}

// ── Social login row ─────────────────────────────────────────
class _SocialLoginRow extends StatelessWidget {
  const _SocialLoginRow({required this.isDark});
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        _SocialBtn(
          label: 'Google',
          icon: Icons.g_mobiledata_rounded,
          iconColor: const Color(0xFFEA4335),
          isDark: isDark,
          onTap: () {},
        ),
        const SizedBox(width: 12),
        _SocialBtn(
          label: 'Apple',
          icon: Icons.apple_rounded,
          iconColor: isDark ? Colors.white : Colors.black,
          isDark: isDark,
          onTap: () {},
        ),
      ],
    );
  }
}

class _SocialBtn extends StatelessWidget {
  const _SocialBtn({
    required this.label,
    required this.icon,
    required this.iconColor,
    required this.isDark,
    required this.onTap,
  });
  final String label;
  final IconData icon;
  final Color iconColor;
  final bool isDark;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          height: 48,
          decoration: BoxDecoration(
            color: isDark ? PPColors.darkSurface2 : PPColors.lightSurface,
            borderRadius: BorderRadius.circular(PPSpacing.radiusMD),
            border: Border.all(
              color: isDark ? PPColors.darkBorder : PPColors.lightBorder,
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, color: iconColor, size: 22),
              const SizedBox(width: 8),
              Text(
                label,
                style: PPTypography.labelLG.copyWith(
                  color: isDark ? PPColors.darkText : PPColors.lightText,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
