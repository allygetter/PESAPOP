// lib/features/auth/presentation/screens/onboarding_screen.dart
// PESAPOP AI — Onboarding Screen (3-step PageView with animated indicators)

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/widgets/pp_button.dart';
import '../providers/auth_provider.dart';

// ── Onboarding page data ──────────────────────────────────────
class _OnboardPage {
  const _OnboardPage({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.color,
    required this.features,
  });
  final IconData icon;
  final String title;
  final String subtitle;
  final Color color;
  final List<String> features;
}

const _pages = [
  _OnboardPage(
    icon: Icons.point_of_sale_outlined,
    title: 'Smart POS & Payments',
    subtitle: 'Accept M-Pesa, Visa, Airtel Money and cash — all from one screen',
    color: PPColors.brand,
    features: [
      'Barcode & QR scanning',
      'Print or WhatsApp receipts',
      'Real-time M-Pesa STK push',
    ],
  ),
  _OnboardPage(
    icon: Icons.inventory_2_outlined,
    title: 'Inventory Intelligence',
    subtitle: 'Never run out of stock. AI predicts what you need before you need it',
    color: Color(0xFF2196F3),
    features: [
      'Real-time stock tracking',
      'Auto reorder alerts',
      'AI demand forecasting',
    ],
  ),
  _OnboardPage(
    icon: Icons.auto_graph_rounded,
    title: 'AI Business Advisor',
    subtitle: 'Ask PESA AI anything about your business in plain language',
    color: PPColors.accent,
    features: [
      '"What was my best seller?"',
      '"Which branch is underperforming?"',
      '"Forecast my revenue this month"',
    ],
  ),
];

class OnboardingScreen extends ConsumerStatefulWidget {
  const OnboardingScreen({super.key});

  @override
  ConsumerState<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends ConsumerState<OnboardingScreen>
    with TickerProviderStateMixin {
  final _pageController = PageController();
  int _currentPage = 0;
  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _fadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );
    _fadeAnimation = CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeOut,
    );
    _fadeController.forward();
  }

  @override
  void dispose() {
    _pageController.dispose();
    _fadeController.dispose();
    super.dispose();
  }

  void _next() {
    if (_currentPage < _pages.length - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 350),
        curve: Curves.easeOutCubic,
      );
    } else {
      _finish();
    }
  }

  void _skip() => _finish();

  Future<void> _finish() async {
    await ref.read(authProvider.notifier).completeOnboarding();
    if (mounted) context.go('/login');
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final page = _pages[_currentPage];
    final isLast = _currentPage == _pages.length - 1;

    return Scaffold(
      backgroundColor: isDark ? PPColors.darkBg : PPColors.lightBg,
      body: Stack(
        children: [
          // Animated background blob
          AnimatedPositioned(
            duration: const Duration(milliseconds: 600),
            curve: Curves.easeOutCubic,
            top: -60,
            right: _currentPage == 0 ? -40 : _currentPage == 1 ? -80 : -20,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 600),
              curve: Curves.easeOutCubic,
              width: 260,
              height: 260,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: page.color.withOpacity(0.08),
              ),
            ),
          ),
          Positioned(
            bottom: -80,
            left: _currentPage == 2 ? -40 : -80,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 600),
              curve: Curves.easeOutCubic,
              width: 220,
              height: 220,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: page.color.withOpacity(0.05),
              ),
            ),
          ),

          SafeArea(
            child: Column(
              children: [
                // ── Skip button ──────────────────────────
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: PPSpacing.screenH,
                    vertical: PPSpacing.base,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // Page counter
                      Text(
                        '${_currentPage + 1} / ${_pages.length}',
                        style: PPTypography.labelMD.copyWith(
                          color: isDark
                              ? PPColors.darkTextSecondary
                              : PPColors.lightTextSecondary,
                        ),
                      ),
                      if (!isLast)
                        GestureDetector(
                          onTap: _skip,
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 7,
                            ),
                            decoration: BoxDecoration(
                              color: isDark
                                  ? PPColors.darkSurface2
                                  : PPColors.lightSurface2,
                              borderRadius: BorderRadius.circular(
                                PPSpacing.radiusFull,
                              ),
                              border: Border.all(
                                color: isDark
                                    ? PPColors.darkBorder
                                    : PPColors.lightBorder,
                              ),
                            ),
                            child: Text(
                              'Skip',
                              style: PPTypography.labelMD.copyWith(
                                color: isDark
                                    ? PPColors.darkTextSecondary
                                    : PPColors.lightTextSecondary,
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                ),

                // ── Page content ─────────────────────────
                Expanded(
                  child: PageView.builder(
                    controller: _pageController,
                    onPageChanged: (i) {
                      setState(() => _currentPage = i);
                      _fadeController
                        ..reset()
                        ..forward();
                    },
                    itemCount: _pages.length,
                    itemBuilder: (context, index) => _OnboardPageView(
                      page: _pages[index],
                      isDark: isDark,
                      fadeAnimation: _fadeAnimation,
                    ),
                  ),
                ),

                // ── Bottom controls ───────────────────────
                Padding(
                  padding: const EdgeInsets.fromLTRB(
                    PPSpacing.screenH, 0,
                    PPSpacing.screenH, PPSpacing.xl2,
                  ),
                  child: Column(
                    children: [
                      // Page indicators
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: List.generate(
                          _pages.length,
                          (i) => _PageDot(
                            isActive: i == _currentPage,
                            color: page.color,
                          ),
                        ),
                      ),
                      const SizedBox(height: PPSpacing.xl),

                      // CTA button
                      PPButton(
                        label: isLast ? 'Get Started' : 'Next',
                        onTap: _next,
                        size: PPButtonSize.lg,
                        trailing: Icon(
                          isLast
                              ? Icons.rocket_launch_outlined
                              : Icons.arrow_forward_rounded,
                          size: 18,
                        ),
                      ),
                    ],
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

// ── Single onboarding page content ──────────────────────────
class _OnboardPageView extends StatelessWidget {
  const _OnboardPageView({
    required this.page,
    required this.isDark,
    required this.fadeAnimation,
  });
  final _OnboardPage page;
  final bool isDark;
  final Animation<double> fadeAnimation;

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: fadeAnimation,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: PPSpacing.screenH),
        child: Column(
          children: [
            const SizedBox(height: PPSpacing.xl),

            // ── Big icon illustration ─────────────────
            Container(
              width: 140, height: 140,
              decoration: BoxDecoration(
                color: page.color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(40),
                border: Border.all(
                  color: page.color.withOpacity(0.2),
                  width: 1.5,
                ),
              ),
              child: Icon(page.icon, color: page.color, size: 64),
            ),

            const SizedBox(height: PPSpacing.xl2),

            // ── Title ──────────────────────────────────
            Text(
              page.title,
              style: PPTypography.displaySM.copyWith(
                color: isDark ? PPColors.darkText : PPColors.lightText,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),

            // ── Subtitle ───────────────────────────────
            Text(
              page.subtitle,
              style: PPTypography.bodyLG.copyWith(
                color: isDark
                    ? PPColors.darkTextSecondary
                    : PPColors.lightTextSecondary,
                height: 1.6,
              ),
              textAlign: TextAlign.center,
            ),

            const SizedBox(height: PPSpacing.xl2),

            // ── Feature list ───────────────────────────
            ...page.features.map(
              (f) => Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16, vertical: 12,
                  ),
                  decoration: BoxDecoration(
                    color: isDark ? PPColors.darkSurface2 : PPColors.lightSurface,
                    borderRadius: BorderRadius.circular(PPSpacing.radiusMD),
                    border: Border.all(
                      color: isDark ? PPColors.darkBorder : PPColors.lightBorder,
                    ),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 28, height: 28,
                        decoration: BoxDecoration(
                          color: page.color.withOpacity(0.12),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Icon(Icons.check_rounded,
                            color: page.color, size: 16),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          f,
                          style: PPTypography.bodyMD.copyWith(
                            color: isDark ? PPColors.darkText : PPColors.lightText,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Animated page dot indicator ──────────────────────────────
class _PageDot extends StatelessWidget {
  const _PageDot({required this.isActive, required this.color});
  final bool isActive;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeOutCubic,
      margin: const EdgeInsets.symmetric(horizontal: 4),
      width: isActive ? 24 : 8,
      height: 8,
      decoration: BoxDecoration(
        color: isActive ? color : color.withOpacity(0.25),
        borderRadius: BorderRadius.circular(PPSpacing.radiusFull),
      ),
    );
  }
}
