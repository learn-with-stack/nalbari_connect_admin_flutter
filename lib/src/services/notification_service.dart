import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:nalbari_connect/src/utils/logger.dart';

@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  try {
    await Firebase.initializeApp();
    AppLogger.info('[FCM] Background message: ${message.messageId}');
  } catch (_) {
    // Firebase native files may not be configured during prototype builds.
  }
}

class NotificationService {
  NotificationService._();
  static final NotificationService instance = NotificationService._();

  Future<void> init() async {
    final enabled = dotenv.get('FIREBASE_NOTIFICATIONS_ENABLED', fallback: 'false') == 'true';
    if (!enabled) {
      AppLogger.info('[FCM] Notifications disabled by env.');
      return;
    }

    try {
      await Firebase.initializeApp();
      FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);
      final messaging = FirebaseMessaging.instance;
      final settings = await messaging.requestPermission(
        alert: true,
        badge: true,
        sound: true,
      );
      await messaging.setForegroundNotificationPresentationOptions(
        alert: true,
        badge: true,
        sound: true,
      );
      AppLogger.info('[FCM] Permission: ${settings.authorizationStatus.name}');

      final token = await messaging.getToken();
      AppLogger.info('[FCM] Device token: ${token ?? 'not available'}');

      FirebaseMessaging.onMessage.listen((message) {
        AppLogger.info('[FCM] Foreground message: ${message.notification?.title ?? message.messageId}');
      });

      FirebaseMessaging.onMessageOpenedApp.listen((message) {
        AppLogger.info('[FCM] Opened from notification: ${message.messageId}');
      });
    } catch (error, stackTrace) {
      AppLogger.warning('[FCM] Firebase is not configured yet. Skipping notification init.');
      AppLogger.error('[FCM] Init error', error, stackTrace);
    }
  }
}
