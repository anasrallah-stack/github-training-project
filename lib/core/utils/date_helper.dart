import 'package:intl/intl.dart';
import '../constants/app_strings.dart';

class DateHelper {
  /// يحوّل weekday من Dart:
  /// 1=الاثنين ... 6=السبت ... 7=الأحد
  ///
  /// إلى index يبدأ من السبت:
  /// 0=السبت، 1=الأحد، 2=الاثنين ... 6=الجمعة
  static int weekDayIndex(DateTime date) {
    final localDate = date.toLocal();

    return switch (localDate.weekday) {
      DateTime.saturday  => 0,
      DateTime.sunday    => 1,
      DateTime.monday    => 2,
      DateTime.tuesday   => 3,
      DateTime.wednesday => 4,
      DateTime.thursday  => 5,
      DateTime.friday    => 6,
      _ => 0,
    };
  }
  /// يرجع بداية الأسبوع الحالي (السبت)
  static DateTime getWeekStart(DateTime date) {
    final normalized = DateTime(date.year, date.month, date.day);
    final daysFromSaturday = weekDayIndex(normalized);
    return normalized.subtract(Duration(days: daysFromSaturday));
  }

  /// يرجع أيام الأسبوع الحالي من السبت إلى الجمعة
  static List<DateTime> getWeekDays(DateTime date) {
    final weekStart = getWeekStart(date);

    return List.generate(
      7,
          (index) => weekStart.add(Duration(days: index)),
    );
  }

  /// مثال:
  /// الخميس، 30 أبريل 2026
  static String formatDate(DateTime date) {
    final dayName = AppStrings.days[weekDayIndex(date)];
    final monthName = AppStrings.months[date.month - 1];

    return '$dayName، ${date.day} $monthName ${date.year}';
  }

  static String formatTime(DateTime time) {
    return DateFormat('hh:mm a', 'ar').format(time);
  }

  static String formatDuration(Duration duration) {
    final h = duration.inHours;
    final m = duration.inMinutes.remainder(60);

    if (h == 0) return '${m}د';
    if (m == 0) return '${h}س';

    return '${h}س ${m}د';
  }

  static String formatHours(double hours) {
    final h = hours.floor();
    final m = ((hours - h) * 60).round();

    return '${h}:${m.toString().padLeft(2, '0')}';
  }

  static bool isSameDay(DateTime a, DateTime b) {
    return a.year == b.year &&
        a.month == b.month &&
        a.day == b.day;
  }
}