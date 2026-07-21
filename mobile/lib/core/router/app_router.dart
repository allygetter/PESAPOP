// lib/core/router/app_router.dart
// PESAPOP AI — GoRouter Navigation Config

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'route_names.dart';

// ── Import all screens ──────────────────────────────────────
// Auth
import '../../features/auth/presentation/screens/splash_screen.dart';
import '../../features/auth/presentation/screens/login_screen.dart';
import '../../features/auth/presentation/screens/otp_screen.dart';
import '../../features/auth/presentation/screens/onboarding_screen.dart';

// Cashier
import '../../features/cashier/presentation/screens/cashier_home_screen.dart';
import '../../features/cashier/presentation/screens/pos_screen.dart';
import '../../features/cashier/presentation/screens/payment_screen.dart';
import '../../features/cashier/presentation/screens/receipt_screen.dart';

// Owner
import '../../features/owner/presentation/screens/owner_home_screen.dart';
import '../../features/owner/presentation/screens/reports_screen.dart';
import '../../features/owner/presentation/screens/ai_assistant_screen.dart';

// Inventory
import '../../features/inventory/presentation/screens/inventory_screen.dart';

// Settings
import '../../features/settings/presentation/screens/settings_screen.dart';

// ── Router Provider ─────────────────────────────────────────
final routerProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    initialLocation: PPRoutes.splash,
    debugLogDiagnostics: true,
    routes: [
      // ── Auth Routes ─────────────────────────────────
      GoRoute(
        path: PPRoutes.splash,
        name: 'splash',
        builder: (context, state) => const SplashScreen(),
      ),
      GoRoute(
        path: PPRoutes.login,
        name: 'login',
        pageBuilder: (context, state) => CustomTransitionPage(
          child: const LoginScreen(),
          transitionsBuilder: _fadeTransition,
        ),
      ),
      GoRoute(
        path: PPRoutes.otp,
        name: 'otp',
        pageBuilder: (context, state) {
          final phone = state.extra as String? ?? '';
          return CustomTransitionPage(
            child: OTPScreen(phoneNumber: phone),
            transitionsBuilder: _slideUpTransition,
          );
        },
      ),
      GoRoute(
        path: PPRoutes.onboarding,
        name: 'onboarding',
        pageBuilder: (context, state) => CustomTransitionPage(
          child: const OnboardingScreen(),
          transitionsBuilder: _fadeTransition,
        ),
      ),

      // ── Cashier App Routes ───────────────────────────
      GoRoute(
        path: PPRoutes.cashierHome,
        name: 'cashierHome',
        pageBuilder: (context, state) => CustomTransitionPage(
          child: const CashierHomeScreen(),
          transitionsBuilder: _fadeTransition,
        ),
        routes: [
          GoRoute(
            path: 'pos',
            name: 'pos',
            pageBuilder: (context, state) => CustomTransitionPage(
              child: const POSScreen(),
              transitionsBuilder: _slideRightTransition,
            ),
          ),
          GoRoute(
            path: 'payment',
            name: 'payment',
            pageBuilder: (context, state) => CustomTransitionPage(
              child: const PaymentScreen(),
              transitionsBuilder: _slideUpTransition,
            ),
          ),
          GoRoute(
            path: 'receipt',
            name: 'receipt',
            builder: (context, state) => const ReceiptScreen(),
          ),
          GoRoute(
            path: 'inventory',
            name: 'cashierInventory',
            builder: (context, state) => const InventoryScreen(role: 'cashier'),
          ),
        ],
      ),

      // ── Owner App Routes ─────────────────────────────
      GoRoute(
        path: PPRoutes.ownerHome,
        name: 'ownerHome',
        pageBuilder: (context, state) => CustomTransitionPage(
          child: const OwnerHomeScreen(),
          transitionsBuilder: _fadeTransition,
        ),
        routes: [
          GoRoute(
            path: 'reports',
            name: 'reports',
            builder: (context, state) => const ReportsScreen(),
          ),
          GoRoute(
            path: 'ai',
            name: 'aiAssistant',
            builder: (context, state) => const AIAssistantScreen(),
          ),
          GoRoute(
            path: 'inventory',
            name: 'ownerInventory',
            builder: (context, state) => const InventoryScreen(role: 'owner'),
          ),
        ],
      ),

      // ── Settings ─────────────────────────────────────
      GoRoute(
        path: PPRoutes.settings,
        name: 'settings',
        builder: (context, state) => const SettingsScreen(),
      ),
    ],

    // ── Error Handler ────────────────────────────────────
    errorBuilder: (context, state) => Scaffold(
      body: Center(
        child: Text('Page not found: ${state.error}'),
      ),
    ),
  );
});

// ── Transition Builders ──────────────────────────────────────
Widget _fadeTransition(
  BuildContext context,
  Animation<double> animation,
  Animation<double> secondaryAnimation,
  Widget child,
) {
  return FadeTransition(opacity: animation, child: child);
}

Widget _slideUpTransition(
  BuildContext context,
  Animation<double> animation,
  Animation<double> secondaryAnimation,
  Widget child,
) {
  return SlideTransition(
    position: Tween<Offset>(
      begin: const Offset(0, 1),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: animation, curve: Curves.easeOutCubic)),
    child: child,
  );
}

Widget _slideRightTransition(
  BuildContext context,
  Animation<double> animation,
  Animation<double> secondaryAnimation,
  Widget child,
) {
  return SlideTransition(
    position: Tween<Offset>(
      begin: const Offset(1, 0),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: animation, curve: Curves.easeOutCubic)),
    child: child,
  );
}
