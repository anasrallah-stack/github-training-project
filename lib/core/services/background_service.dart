import 'dart:async';
import 'dart:ui';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_background_service/flutter_background_service.dart';
import 'package:flutter_background_service_android/flutter_background_service_android.dart';
import 'package:network_info_plus/network_info_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../firebase_options.dart';
import '../../../features/tracking/data/repositories/tracking_repository_impl.dart';
import '../../../features/tracking/domain/repositories/tracking_repository.dart';

final _bgService = FlutterBackgroundService();

/// تهيئة الـ Service — يُستدعى مرة واحدة في main()
Future<void> initBackgroundService() async {
  await _bgService.configure(
    androidConfiguration: AndroidConfiguration(
      onStart: onBackgroundStart,
      autoStart: false,        // ✅ لا يبدأ تلقائياً
      isForegroundMode: true,
      notificationChannelId: 'wifi_tracker_channel',
      initialNotificationTitle: 'TimeSync',
      initialNotificationContent: 'جارٍ مراقبة شبكة العمل...',
      foregroundServiceNotificationId: 888,
    ),
    iosConfiguration: IosConfiguration(
      autoStart: false,
      onForeground: onBackgroundStart,
    ),
  );
}

/// يبدأ الـ Service — يُستدعى عند فتح التطبيق
Future<void> startBackgroundService() async {
  final isRunning = await _bgService.isRunning();
  if (!isRunning) {
    await _bgService.startService();
  }
}

/// يوقف الـ Service — يُستدعى عند إغلاق التطبيق
Future<void> stopBackgroundService() async {
  final isRunning = await _bgService.isRunning();
  if (isRunning) {
    _bgService.invoke('stop');
  }
}

@pragma('vm:entry-point')
void onBackgroundStart(ServiceInstance service) async {
  DartPluginRegistrant.ensureInitialized();

  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
  } catch (_) {}

  final prefs = await SharedPreferences.getInstance();
  final userId = prefs.getString('userId');
  final workSsid = prefs.getString('work_ssid');

  if (userId == null || workSsid == null) {
    service.stopSelf();
    return;
  }

  _startBackgroundTracking(service, userId, workSsid);
}

void _startBackgroundTracking(
    ServiceInstance service,
    String userId,
    String workSsid,
    ) {
  final TrackingRepository repository = TrackingRepositoryImpl();
  String? activeSessionId;
  bool isTracking = false;

  Timer.periodic(const Duration(minutes: 2), (_) async {
    final ssid = await NetworkInfo().getWifiName();
    final cleaned = ssid?.replaceAll('"', '').trim();
    final isOnWork = cleaned != null &&
        cleaned.toLowerCase() == workSsid.toLowerCase();

    if (service is AndroidServiceInstance) {
      service.setForegroundNotificationInfo(
        title: 'TimeSync',
        content: isOnWork
            ? '✅ متصل بـ $workSsid — جارٍ التتبع'
            : '⏸ في انتظار الاتصال بـ $workSsid',
      );
    }

    if (isOnWork && !isTracking) {
      final existing = await repository.getActiveSession(userId);
      if (existing == null) {
        final session = await repository.startSession(
            userId, workSsid, 'bg_$userId');
        activeSessionId = session.id;
      } else {
        activeSessionId = existing.id;
      }
      isTracking = true;
    } else if (!isOnWork && isTracking && activeSessionId != null) {
      await repository.stopSession(activeSessionId!);
      activeSessionId = null;
      isTracking = false;
    }
  });

  // ✅ استمع لأمر الإيقاف
  service.on('stop').listen((_) async {
    if (activeSessionId != null) {
      await repository.stopSession(activeSessionId!);
    }
    service.stopSelf();
  });
}