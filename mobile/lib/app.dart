// lib/app.dart
// PESAPOP AI — Root App Widget

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'core/theme/app_theme.dart';
import 'core/router/app_router.dart';
import 'features/settings/presentation/providers/theme_provider.dart';

class PesaPopApp extends ConsumerWidget {
  const PesaPopApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(themeProvider);
    final router = ref.watch(routerProvider);

    return MaterialApp.router(
      title: 'PESAPOP AI',
      debugShowCheckedModeBanner: false,

      // ── Themes ─────────────────────────────────────
      theme: PPTheme.light,
      darkTheme: PPTheme.dark,
      themeMode: themeMode,

      // ── Router ─────────────────────────────────────
      routerConfig: router,

      // ── Locale ─────────────────────────────────────
      // Add localization support for African markets
      // supportedLocales: [Locale('en'), Locale('sw'), Locale('fr')],
    );
  }
}
