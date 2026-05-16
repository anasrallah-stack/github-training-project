import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/repositories/tracking_repository_impl.dart';
import '../../domain/entities/session_entity.dart';
import '../../domain/repositories/tracking_repository.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../../../core/utils/date_helper.dart';

final trackingRepositoryProvider = Provider<TrackingRepository>((ref) => TrackingRepositoryImpl());

final todaySessionsProvider = StreamProvider<List<SessionEntity>>((ref) {
  final user = ref.watch(authStateProvider).value;
  if (user == null) return const Stream.empty();
  return ref.watch(trackingRepositoryProvider).getTodaySessions(user.uid);
});

final weekSessionsProvider = StreamProvider<List<SessionEntity>>((ref) {
  final user = ref.watch(authStateProvider).value;
  if (user == null) return const Stream.empty();
  return ref.watch(trackingRepositoryProvider).getWeekSessions(user.uid);
});

final historySessionsProvider = FutureProvider<List<SessionEntity>>((ref) async {
  final user = ref.watch(authStateProvider).value;
  if (user == null) return [];
  return ref.watch(trackingRepositoryProvider).getHistorySessions(user.uid);
});

final todayHoursProvider = Provider<double>((ref) {
  final sessions = ref.watch(todaySessionsProvider).value ?? [];
  return sessions.fold(0.0, (sum, s) => sum + s.hours);
});

final weekHoursProvider = Provider<double>((ref) {
  final sessions = ref.watch(weekSessionsProvider).value ?? [];
  return sessions.fold(0.0, (sum, s) => sum + s.hours);
});

/// Map من index اليوم (0=سبت ... 6=جمعة) إلى ساعات العمل
final weekChartDataProvider = Provider<Map<int, double>>((ref) {
  final sessions = ref.watch(weekSessionsProvider).value ?? [];
  final map = <int, double>{};
  for (final s in sessions) {
    // نستخدم weekDayIndex الذي يعطي 0=سبت ... 6=جمعة
    final key = DateHelper.weekDayIndex(s.startTime);
    map[key] = (map[key] ?? 0) + s.hours;
  }
  return map;
});

/// أيام الأسبوع الحالي من السبت إلى الجمعة
final currentWeekDaysProvider = Provider<List<DateTime>>((ref) {

  return DateHelper.getWeekDays(DateTime.now());
});