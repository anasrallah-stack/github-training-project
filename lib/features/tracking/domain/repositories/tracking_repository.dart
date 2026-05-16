import '../entities/session_entity.dart';

abstract class TrackingRepository {
  Future<SessionEntity> startSession(String userId, String wifiSsid, String deviceId);
  Future<SessionEntity> stopSession(String sessionId);
  // ✅ جديد: لإغلاق الجلسات اليتيمة بوقت محدد
  Future<void> stopSessionAt(String sessionId, DateTime endTime);
  Stream<List<SessionEntity>> getTodaySessions(String userId);
  Stream<List<SessionEntity>> getWeekSessions(String userId);
  Future<List<SessionEntity>> getHistorySessions(String userId, {int limit = 30});
  Future<SessionEntity?> getActiveSession(String userId);
}