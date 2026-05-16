import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:uuid/uuid.dart';
import '../../domain/entities/session_entity.dart';
import '../../domain/repositories/tracking_repository.dart';
import '../models/session_model.dart';

class TrackingRepositoryImpl implements TrackingRepository {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final _uuid = const Uuid();

  CollectionReference get _sessions => _db.collection('sessions');

  @override
  Future<SessionEntity> startSession(String userId, String wifiSsid, String deviceId) async {
    final session = SessionModel(
      id: _uuid.v4(),
      userId: userId,
      startTime: DateTime.now(),
      wifiSsid: wifiSsid,
      deviceId: deviceId,
    );
    await _sessions.doc(session.id).set(session.toFirestore());
    return session;
  }

  @override
  Future<SessionEntity> stopSession(String sessionId) async {
    final now = DateTime.now();
    await _sessions.doc(sessionId).update({
      'endTime': Timestamp.fromDate(now),
    });
    final doc = await _sessions.doc(sessionId).get();
    return SessionModel.fromFirestore(doc);
  }

  // ✅ إغلاق جلسة يتيمة بوقت محدد
  @override
  Future<void> stopSessionAt(String sessionId, DateTime endTime) async {
    await _sessions.doc(sessionId).update({
      'endTime': Timestamp.fromDate(endTime),
    });
  }

  @override
  Stream<List<SessionEntity>> getTodaySessions(String userId) {
    final today = DateTime.now();
    final dateStr =
        '${today.year}-${today.month.toString().padLeft(2, '0')}-${today.day.toString().padLeft(2, '0')}';

    // ✅ بدون composite index — نفلتر بـ userId و date فقط ثم نرتب client-side
    return _sessions
        .where('userId', isEqualTo: userId)
        .where('date', isEqualTo: dateStr)
        .snapshots()
        .map((s) {
      final list = s.docs.map((d) => SessionModel.fromFirestore(d)).toList();
      list.sort((a, b) => a.startTime.compareTo(b.startTime));
      return list;
    });
  }

  @override
  Stream<List<SessionEntity>> getWeekSessions(String userId) {
    final now = DateTime.now();

    // الأسبوع يبدأ من السبت
    final int daysFromSat = switch (now.weekday) {
      6 => 0,
      7 => 1,
      1 => 2,
      2 => 3,
      3 => 4,
      4 => 5,
      5 => 6,
      _ => 0,
    };

    final saturday = now.subtract(Duration(days: daysFromSat));
    final weekStart = DateTime(saturday.year, saturday.month, saturday.day);

    // ✅ بدون composite index — نفلتر بـ userId فقط ثم نفلتر بالتاريخ client-side
    return _sessions
        .where('userId', isEqualTo: userId)
        .snapshots()
        .map((s) {
      final list = s.docs
          .map((d) => SessionModel.fromFirestore(d))
          .where((session) =>
      !session.startTime.isBefore(weekStart))
          .toList();
      list.sort((a, b) => a.startTime.compareTo(b.startTime));
      return list;
    });
  }

  @override
  Future<List<SessionEntity>> getHistorySessions(String userId, {int limit = 30}) async {
    // ✅ بدون composite index — نفلتر بـ userId فقط ثم نرتب client-side
    final snap = await _sessions
        .where('userId', isEqualTo: userId)
        .limit(limit * 2) // نجلب أكثر ثم نرتب
        .get();

    final list = snap.docs.map((d) => SessionModel.fromFirestore(d)).toList();
    list.sort((a, b) => b.startTime.compareTo(a.startTime)); // أحدث أولاً
    return list.take(limit).toList();
  }

  @override
  Future<SessionEntity?> getActiveSession(String userId) async {
    final snap = await _sessions
        .where('userId', isEqualTo: userId)
        .get();

    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    final activeDocs = snap.docs
        .map((d) => SessionModel.fromFirestore(d))
        .where((s) => s.endTime == null)
        .toList();

    if (activeDocs.isEmpty) return null;

    // ✅ أغلق كل الجلسات المفتوحة من أيام سابقة تلقائياً
    for (final session in activeDocs) {
      final sessionDay = DateTime(
        session.startTime.year,
        session.startTime.month,
        session.startTime.day,
      );
      if (sessionDay.isBefore(today)) {
        final endOfDay = DateTime(
          session.startTime.year,
          session.startTime.month,
          session.startTime.day,
          23, 59, 59,
        );
        await _sessions.doc(session.id).update({
          'endTime': Timestamp.fromDate(endOfDay),
        });
      }
    }

    // ابحث عن جلسة مفتوحة من اليوم فقط
    final todayActive = activeDocs.where((s) {
      final sessionDay = DateTime(
        s.startTime.year, s.startTime.month, s.startTime.day,
      );
      return !sessionDay.isBefore(today);
    }).toList();

    if (todayActive.isEmpty) return null;
    todayActive.sort((a, b) => b.startTime.compareTo(a.startTime));
    return todayActive.first;
  }
}