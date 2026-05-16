import 'package:equatable/equatable.dart';

class SessionEntity extends Equatable {
  final String id;
  final String userId;
  final DateTime startTime;
  final DateTime? endTime;
  final String wifiSsid;
  final String deviceId;
  final bool isSynced;

  const SessionEntity({
    required this.id,
    required this.userId,
    required this.startTime,
    this.endTime,
    required this.wifiSsid,
    required this.deviceId,
    this.isSynced = true,
  });

  Duration get duration {
    final end = endTime ?? DateTime.now();
    final raw = end.difference(startTime);
    // ✅ حد أقصى 12 ساعة للجلسة الواحدة — منع تضخيم الأرقام بسبب الجلسات اليتيمة
    const maxDuration = Duration(hours: 12);
    return raw > maxDuration ? maxDuration : raw;
  }

  double get hours => duration.inMinutes / 60.0;

  bool get isActive => endTime == null;

  SessionEntity copyWith({DateTime? endTime, bool? isSynced}) => SessionEntity(
    id: id,
    userId: userId,
    startTime: startTime,
    endTime: endTime ?? this.endTime,
    wifiSsid: wifiSsid,
    deviceId: deviceId,
    isSynced: isSynced ?? this.isSynced,
  );

  @override
  List<Object?> get props => [id, userId, startTime, endTime, wifiSsid, deviceId];
}