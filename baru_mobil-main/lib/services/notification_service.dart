import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class NotificationService {
  static final FirebaseMessaging _messaging = FirebaseMessaging.instance;
  static final FlutterLocalNotificationsPlugin _localNotifications =
      FlutterLocalNotificationsPlugin();

  // Bildirim kanalları
  static const AndroidNotificationChannel clubsChannel =
      AndroidNotificationChannel(
    'clubs_channel',
    'Kulüp Bildirimleri',
    description: 'Kulüp gönderilerinden haberdar olun',
    importance: Importance.high,
    enableVibration: true,
    playSound: true,
  );

  static const AndroidNotificationChannel announcementsChannel =
      AndroidNotificationChannel(
    'announcements_channel',
    'Duyuru Bildirimleri',
    description: 'Üniversite duyurularından haberdar olun',
    importance: Importance.high,
  );

  static const AndroidNotificationChannel cafeteriaChannel =
      AndroidNotificationChannel(
    'cafeteria_channel',
    'Yemekhane Bildirimleri',
    description: 'Günlük yemek menüsünden haberdar olun',
    importance: Importance.low,
  );

  static Future<void> initialize() async {
    // FCM izinlerini al
    await _messaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );

    // Local notifications başlat
    await _localNotifications.initialize(
      const InitializationSettings(
        android: AndroidInitializationSettings('@mipmap/ic_launcher'),
        iOS: DarwinInitializationSettings(),
      ),
    );

    // Kanalları oluştur
    final platform = _localNotifications.resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>();
    await platform?.createNotificationChannel(clubsChannel);
    await platform?.createNotificationChannel(announcementsChannel);
    await platform?.createNotificationChannel(cafeteriaChannel);

    // Bildirim ayarlarını kontrol et
    await updateNotificationSubscription();

    // Arka plan bildirimleri
    FirebaseMessaging.onBackgroundMessage(_handleBackgroundMessage);

    // Ön plan bildirimleri
    FirebaseMessaging.onMessage.listen(_handleForegroundMessage);
  }

  // Test bildirimi gönder
  static Future<void> sendTestNotification({
    required String title,
    required String body,
    String channelId = 'clubs_channel',
  }) async {
    await _localNotifications.show(
      DateTime.now().millisecond,
      title,
      body,
      NotificationDetails(
        android: AndroidNotificationDetails(
          channelId,
          channelId == 'clubs_channel'
              ? 'Kulüp Bildirimleri'
              : channelId == 'announcements_channel'
                  ? 'Duyuru Bildirimleri'
                  : 'Yemekhane Bildirimleri',
          channelDescription: 'Test bildirimi',
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

  static Future<void> updateNotificationSubscription() async {
    final prefs = await SharedPreferences.getInstance();
    final notificationsEnabled = prefs.getBool('clubs_notifications') ?? true;

    try {
      if (notificationsEnabled) {
        await _messaging.subscribeToTopic('clubs_notifications');
        print('clubs_notifications topic\'ine abone olundu');
      } else {
        await _messaging.unsubscribeFromTopic('clubs_notifications');
        print('clubs_notifications topic aboneliği kaldırıldı');
      }
    } catch (e) {
      print('Topic abonelik hatası: $e');
    }
  }

  static Future<void> _handleBackgroundMessage(RemoteMessage message) async {
    final prefs = await SharedPreferences.getInstance();
    final notificationsEnabled = prefs.getBool('clubs_notifications') ?? true;

    if (!notificationsEnabled) return;

    // Bildirim göster
    final flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();
    await flutterLocalNotificationsPlugin.show(
      message.hashCode,
      message.notification?.title,
      message.notification?.body,
      NotificationDetails(
        android: AndroidNotificationDetails(
          'clubs_channel',
          'Kulüp Bildirimleri',
          channelDescription: 'Kulüp gönderilerinden haberdar olun',
          importance: Importance.high,
          priority: Priority.high,
        ),
      ),
    );
  }

  static void _handleForegroundMessage(RemoteMessage message) async {
    final prefs = await SharedPreferences.getInstance();
    final notificationsEnabled = prefs.getBool('clubs_notifications') ?? true;

    if (!notificationsEnabled) return;

    await _localNotifications.show(
      message.hashCode,
      message.notification?.title,
      message.notification?.body,
      NotificationDetails(
        android: AndroidNotificationDetails(
          'clubs_channel',
          'Kulüp Bildirimleri',
          channelDescription: 'Kulüp gönderilerinden haberdar olun',
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
}
