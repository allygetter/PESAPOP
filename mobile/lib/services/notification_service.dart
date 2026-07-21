// lib/services/notification_service.dart
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final notificationServiceProvider = Provider<NotificationService>((ref) => NotificationService());

@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
  // Handle background messages (low stock alerts, payment confirmations)
}

class NotificationService {
  final _fcm = FirebaseMessaging.instance;
  final _localNotifs = FlutterLocalNotificationsPlugin();

  Future<void> init() async {
    // Request permission
    await _fcm.requestPermission(alert: true, badge: true, sound: true);

    // Register background handler
    FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

    // Local notification channel
    const androidChannel = AndroidNotificationChannel(
      'pesapop_channel', 'PESAPOP Notifications',
      description: 'Sales, inventory, and payment alerts',
      importance: Importance.high,
    );

    await _localNotifs.resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(androidChannel);

    await _localNotifs.initialize(
      const InitializationSettings(
        android: AndroidInitializationSettings('@mipmap/ic_launcher'),
        iOS: DarwinInitializationSettings(),
      ),
    );

    // Handle foreground messages
    FirebaseMessaging.onMessage.listen((message) {
      final notif = message.notification;
      if (notif == null) return;
      _localNotifs.show(
        notif.hashCode,
        notif.title,
        notif.body,
        NotificationDetails(
          android: AndroidNotificationDetails(
            'pesapop_channel', 'PESAPOP Notifications',
            icon: '@mipmap/ic_launcher',
          ),
          iOS: const DarwinNotificationDetails(),
        ),
      );
    });
  }

  Future<String?> getToken() => _fcm.getToken();

  // Subscribe to topics
  Future<void> subscribeToLowStockAlerts() => _fcm.subscribeToTopic('low_stock');
  Future<void> subscribeToPayments() => _fcm.subscribeToTopic('payments');
}
