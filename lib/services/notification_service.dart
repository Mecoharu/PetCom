import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class NotificationService {
  static final _plugin = FlutterLocalNotificationsPlugin();

  static const _channel = AndroidNotificationChannel(
    'petcompanion_adopt',
    'PetCompanion Adopsi',
    description: 'Notifications regarding animal adoption applications and status',
    importance: Importance.high,
  );

  static Future<void> initialize() async {
    const android = AndroidInitializationSettings('@mipmap/ic_launcher');
    const ios = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );
    await _plugin.initialize(
      const InitializationSettings(android: android, iOS: ios),
    );

    await _plugin
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(_channel);

    // FCM foreground handler
    FirebaseMessaging.onMessage.listen((msg) {
      showLocalNotification(
        id: DateTime.now().millisecondsSinceEpoch ~/ 1000,
        title: msg.notification?.title ?? 'PetCompanion',
        body: msg.notification?.body ?? '',
      );
    });

    await FirebaseMessaging.instance.requestPermission(
      alert: true, badge: true, sound: true,
    );
  }

  static Future<String?> getToken() =>
      FirebaseMessaging.instance.getToken();

  static Future<void> showLocalNotification({
    required int id,
    required String title,
    required String body,
  }) async {
    await _plugin.show(
      id,
      title,
      body,
      NotificationDetails(
        android: AndroidNotificationDetails(
          _channel.id,
          _channel.name,
          channelDescription: _channel.description,
          importance: Importance.high,
          priority: Priority.high,
          icon: '@mipmap/ic_launcher',
        ),
        iOS: const DarwinNotificationDetails(
          presentAlert: true,
          presentBadge: true,
          presentSound: true,
        ),
      ),
    );
  }

  static Future<void> cancelAll() => _plugin.cancelAll();
}
