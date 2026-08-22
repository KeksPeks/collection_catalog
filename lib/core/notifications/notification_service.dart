import 'package:flutter_local_notifications/flutter_local_notifications.dart';

/// Сервис локальных уведомлений.
///
/// Поддерживает Android, iOS, macOS, Linux и Windows.
class NotificationService {
  NotificationService._();

  static final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();
  static bool _initialized = false;

  static Future<void> initialize() async {
    if (_initialized) {
      return;
    }

    const settings = InitializationSettings(
      android: AndroidInitializationSettings('@mipmap/ic_launcher'),
      iOS: DarwinInitializationSettings(),
      macOS: DarwinInitializationSettings(),
      linux: LinuxInitializationSettings(defaultActionName: 'Открыть'),
      windows: WindowsInitializationSettings(
        appName: 'Collection Catalog',
        appUserModelId: 'com.example.collection_catalog',
        guid: '5f2d2e6b-2c0d-4a4e-8f9d-3a8a3b4b9f21',
      ),
    );

    await _plugin.initialize(settings);
    _initialized = true;
  }

  static Future<bool> requestPermission() async {
    await initialize();

    final android = _plugin
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>();
    final androidResult = await android?.requestNotificationsPermission();

    final ios = _plugin
        .resolvePlatformSpecificImplementation<IOSFlutterLocalNotificationsPlugin>();
    final iosResult = await ios?.requestPermissions(
      alert: true,
      badge: true,
      sound: true,
    );

    return androidResult ?? iosResult ?? true;
  }

  static Future<void> show({
    required String title,
    required String body,
    int id = 100,
  }) async {
    await initialize();

    const details = NotificationDetails(
      android: AndroidNotificationDetails(
        'collection_updates',
        'Обновления коллекции',
        channelDescription: 'Изменения каталогов и прогресса коллекции',
        importance: Importance.high,
        priority: Priority.high,
      ),
      iOS: DarwinNotificationDetails(),
      macOS: DarwinNotificationDetails(),
    );

    await _plugin.show(id, title, body, details);
  }
}
