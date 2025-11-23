import 'package:intl/intl.dart';

class DateHelper {
  static String formatTime(DateTime dateTime) {
    return DateFormat('HH:mm').format(dateTime);
  }

  static String formatDate(DateTime dateTime) {
    return DateFormat('yyyy-MM-dd').format(dateTime);
  }

  static String formatFullDate(DateTime dateTime) {
    return DateFormat('yyyy年MM月dd日').format(dateTime);
  }

  static String formatWeekday(DateTime dateTime) {
    const weekdays = ['周一', '周二', '周三', '周四', '周五', '周六', '周日'];
    return weekdays[(dateTime.weekday - 1) % 7];
  }

  static String getWeekRangeLabel(DateTime date) {
    final startOfWeek = date.subtract(Duration(days: date.weekday - 1));
    final endOfWeek = startOfWeek.add(const Duration(days: 6));
    final start = DateFormat('MM/dd').format(startOfWeek);
    final end = DateFormat('MM/dd').format(endOfWeek);
    return '$start - $end';
  }

  static int getWeekNumber(DateTime date) {
    final dayOfYear = int.parse(DateFormat('D').format(date));
    final weekNumber = ((dayOfYear - date.weekday + 10) ~/ 7);
    return weekNumber;
  }
}
