import 'dart:async';
import 'package:flutter/services.dart';
import 'package:flutter_background_service/flutter_background_service.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:network_info_plus/network_info_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../features/tracking/data/repositories/tracking_repository_impl.dart';
import '../../features/tracking/domain/entities/session_entity.dart';
import '../../features/tracking/domain/repositories/tracking_repository.dart';
import 'notification_service.dart';

final wifiTrackingServiceProvider = Provider((ref) => WifiTrackingService(
  repository: TrackingRepositoryImpl(),
  notifications: NotificationService(),
));

class WifiTrackingService {
  final TrackingRepository repository;
  final NotificationService? notifications; // ✅ nullable — لا يُستخدم في الخلفية
  final _info = NetworkInfo();

  static const _trackingChannel = MethodChannel('com.example.untitled16/tracking');

  Timer? _pollTimer;
  SessionEntity? _activeSession;
  String? _userId;
  String? _workSsid;
  String? _deviceId;

  bool _initialized = false;
  bool _isChecking = false;

  final _statusController = StreamController<TrackingStatus>.broadcast();
  Stream<TrackingStatus> get statusStream => _statusController.stream;

  WifiTrackingService({
    required this.repository,
    this.notifications, // ✅ اختياري
  });

  Future<void> initialize(String userId, String? workSsid, String deviceId) async {
    if (_initialized && _userId == userId) return;
    _initialized = true;
    _userId = userId;
    _workSsid = workSsid;
    _deviceId = deviceId;

    // احفظ بيانات المستخدم للـ background service
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('userId', userId);
    if (workSsid != null) await prefs.setString('work_ssid', workSsid);

    await _closeOrphanSessions(userId);
    _startPolling();
  }

  Future<void> _closeOrphanSessions(String userId) async {
    final orphan = await repository.getActiveSession(userId);
    if (orphan == null) return;

    final now = DateTime.now();
    final isSameDay = orphan.startTime.year == now.year &&
        orphan.startTime.month == now.month &&
        orphan.startTime.day == now.day;

    if (isSameDay) {
      _activeSession = orphan;
    } else {
      final endOfDay = DateTime(
        orphan.startTime.year,
        orphan.startTime.month,
        orphan.startTime.day,
        23, 59, 59,
      );
      await repository.stopSessionAt(orphan.id, endOfDay);
      _activeSession = null;
    }
  }

  void _startPolling() {
    _pollTimer?.cancel();
    _pollTimer = Timer.periodic(const Duration(seconds: 30), (_) => _checkWifi());
    _checkWifi();
  }

  Future<void> _checkWifi() async {
    if (_isChecking) return;
    if (_userId == null || _workSsid == null) return;

    _isChecking = true;
    try {
      final ssid = await _currentSsid();
      final isOnWork = ssid != null && ssid == _workSsid;

      if (isOnWork && _activeSession == null) {
        await _startTracking(ssid!);
      } else if (!isOnWork && _activeSession != null) {
        await _stopTracking();
      }

      if (!_statusController.isClosed) {
        _statusController.add(TrackingStatus(
          isTracking: _activeSession != null,
          currentSsid: ssid,
          workSsid: _workSsid,
          session: _activeSession,
        ));
      }
    } finally {
      _isChecking = false;
    }
  }

  Future<String?> _currentSsid() async {
    try {
      final ssid = await _info.getWifiName();
      return ssid?.replaceAll('"', '');
    } catch (_) {
      return null;
    }
  }

  Future<void> _startTracking(String ssid) async {
    final existing = await repository.getActiveSession(_userId!);
    if (existing != null) {
      _activeSession = existing;
      return;
    }
    _activeSession = await repository.startSession(_userId!, ssid, _deviceId!);
    await notifications?.showSessionStarted(_workSsid!);
  }

  Future<void> _stopTracking() async {
    if (_activeSession == null) return;
    final stopped = await repository.stopSession(_activeSession!.id);
    await notifications?.showSessionEnded(stopped.duration);
    _activeSession = null;
  }

  /// ✅ عند إغلاق التطبيق — يوقف الـ foreground polling
  /// لكن الـ background service يكمل يشتغل
  Future<void> stopForeground() async {
    _pollTimer?.cancel();
    _initialized = false;

    if (!_statusController.isClosed) {
      _statusController.add(TrackingStatus(isTracking: false));
    }
  }

  /// ✅ إيقاف كل شيء — يُستدعى عند تسجيل الخروج
  Future<void> stopAll() async {
    _pollTimer?.cancel();

    if (_activeSession != null) {
      await _stopTracking();
    }

    // أبلّغ الـ background service بالإيقاف
    try {
      final bgService = FlutterBackgroundService();
      bgService.invoke('stop');
    } catch (_) {}

    // أبلّغ Android
    try {
      await _trackingChannel.invokeMethod('stopTracking');
    } catch (_) {}

    await notifications?.cancelAll();
    _initialized = false;

    if (!_statusController.isClosed) {
      _statusController.add(TrackingStatus(isTracking: false));
    }
  }

  Future<void> manualCheck() => _checkWifi();

  void updateWorkSsid(String ssid) {
    _workSsid = ssid;
    // أبلّغ الـ background service بالـ SSID الجديد
    try {
      final bgService = FlutterBackgroundService();
      bgService.invoke('updateSsid', {'ssid': ssid});
    } catch (_) {}
    _checkWifi();
  }

  void dispose() {
    _pollTimer?.cancel();
    if (!_statusController.isClosed) _statusController.close();
  }
}

class TrackingStatus {
  final bool isTracking;
  final String? currentSsid;
  final String? workSsid;
  final SessionEntity? session;

  TrackingStatus({
    required this.isTracking,
    this.currentSsid,
    this.workSsid,
    this.session,
  });

  factory TrackingStatus.initial() => TrackingStatus(isTracking: false);
  factory TrackingStatus.tracking(SessionEntity session) =>
      TrackingStatus(isTracking: true, session: session);
}