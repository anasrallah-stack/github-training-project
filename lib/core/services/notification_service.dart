import 'package:awesome_notifications/awesome_notifications.dart';

class NotificationService {
  bool _initialized = false;

  Future<void> initialize() async {
    if (_initialized) return;

    await AwesomeNotifications().initialize(
      null, // null = default app icon
      [
        NotificationChannel(
          channelKey: 'tracking',
          channelName: 'تتبع العمل',
          channelDescription: 'إشعارات جلسات العمل',
          importance: NotificationImportance.High,
          defaultPrivacy: NotificationPrivacy.Public,
          locked: true, // مكافئ لـ ongoing: true
        ),
      ],
    );

    // اطلب الإذن من المستخدم
    await AwesomeNotifications().requestPermissionToSendNotifications();

    _initialized = true;
  }

  Future<void> showSessionStarted(String ssid) async {
    await initialize();

    await AwesomeNotifications().createNotification(
      content: NotificationContent(
        id: 1,
        channelKey: 'tracking',
        title: '⏱️ بدأ تتبع الوقت',
        body: 'متصل بـ $ssid — جارٍ احتساب ساعات العمل',
        notificationLayout: NotificationLayout.Default,
        locked: true, // ongoing — المستخدم لا يقدر يمسحه
        autoDismissible: false,
      ),
    );
  }

  Future<void> showSessionEnded(Duration duration) async {
    await initialize();

    final h = duration.inHours;
    final m = duration.inMinutes.remainder(60);

    // أولاً امسح إشعار الجلسة الجارية
    await AwesomeNotifications().cancel(1);

    await AwesomeNotifications().createNotification(
      content: NotificationContent(
        id: 2,
        channelKey: 'tracking',
        title: '✅ انتهت جلسة العمل',
        body: 'مدة الجلسة: ${h}س ${m}د — تم الحفظ تلقائياً',
        notificationLayout: NotificationLayout.Default,
        autoDismissible: true,
      ),
    );
  }

  Future<void> cancelAll() async {
    await initialize();
    await AwesomeNotifications().cancelAll();
  }
}