// lib/main.dart — PESAPOP AI Entry Point (production-ready)
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'app.dart';
import 'services/notification_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Firebase (push notifications + analytics)
  await Firebase.initializeApp();

  // Local storage
  await Hive.initFlutter();

  // Portrait lock
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  // Status bar transparent
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(statusBarColor: Colors.transparent),
  );

  runApp(
    ProviderScope(
      overrides: const [],
      child: const PesaPopApp(),
    ),
  );

  // Init push notifications after app starts
  final container = ProviderContainer();
  await container.read(notificationServiceProvider).init();
}
