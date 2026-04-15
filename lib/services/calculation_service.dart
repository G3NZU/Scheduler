import '../models/work_session.dart';

/// Provides calculations for daily and monthly summaries.
class CalculationService {
  /// Returns all sessions that started on the given [date] (by calendar day).
  static List<WorkSession> sessionsForDay(
      List<WorkSession> sessions, DateTime date) {
    return sessions.where((s) {
      return s.startTime.year == date.year &&
          s.startTime.month == date.month &&
          s.startTime.day == date.day;
    }).toList();
  }

  /// Total worked duration for a single calendar day.
  static Duration totalWorkedForDay(
      List<WorkSession> sessions, DateTime date) {
    final daySessions = sessionsForDay(sessions, date);
    Duration total = Duration.zero;
    for (final s in daySessions) {
      total += s.workedDuration;
    }
    return total;
  }

  /// Total worked duration for a given month/year.
  static Duration totalWorkedForMonth(
      List<WorkSession> sessions, int year, int month) {
    final monthSessions = sessions.where(
        (s) => s.startTime.year == year && s.startTime.month == month);
    Duration total = Duration.zero;
    for (final s in monthSessions) {
      total += s.workedDuration;
    }
    return total;
  }

  /// Average worked hours per day (excluding days with 0 work).
  static double averageHoursPerDay(
      List<WorkSession> sessions, int year, int month) {
    final monthSessions = sessions
        .where((s) => s.startTime.year == year && s.startTime.month == month)
        .toList();
    if (monthSessions.isEmpty) return 0;

    // Group by day
    final Map<int, Duration> perDay = {};
    for (final s in monthSessions) {
      final day = s.startTime.day;
      perDay[day] = (perDay[day] ?? Duration.zero) + s.workedDuration;
    }
    if (perDay.isEmpty) return 0;

    final total = perDay.values.fold<Duration>(
        Duration.zero, (prev, d) => prev + d);
    return total.inMinutes / 60 / perDay.length;
  }

  /// Hours worked per ISO week number within a given month.
  /// Returns a map of {weekNumber: hoursDouble}.
  static Map<int, double> hoursPerWeek(
      List<WorkSession> sessions, int year, int month) {
    final monthSessions = sessions
        .where((s) => s.startTime.year == year && s.startTime.month == month)
        .toList();
    final Map<int, double> weekMap = {};
    for (final s in monthSessions) {
      final weekNum = _isoWeekNumber(s.startTime);
      weekMap[weekNum] =
          (weekMap[weekNum] ?? 0) + s.workedDuration.inMinutes / 60;
    }
    return weekMap;
  }

  /// ISO 8601 week number.
  static int _isoWeekNumber(DateTime date) {
    final jan4 = DateTime(date.year, 1, 4);
    final startOfWeek1 =
        jan4.subtract(Duration(days: jan4.weekday - 1));
    final diff = date.difference(startOfWeek1).inDays;
    return (diff / 7).floor() + 1;
  }

  /// Format a Duration as HH:MM:SS string.
  static String formatDuration(Duration d) {
    final h = d.inHours.toString().padLeft(2, '0');
    final m = (d.inMinutes % 60).toString().padLeft(2, '0');
    final s = (d.inSeconds % 60).toString().padLeft(2, '0');
    return '$h:$m:$s';
  }

  /// Format a Duration as "Xh Ym" for summary display.
  static String formatDurationShort(Duration d) {
    final h = d.inHours;
    final m = d.inMinutes % 60;
    if (h == 0) return '${m}m';
    return '${h}h ${m}m';
  }
}
