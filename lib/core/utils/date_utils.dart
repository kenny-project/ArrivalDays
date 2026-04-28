import 'package:intl/intl.dart';

class AppDateUtils {
  static String formatDate(DateTime date) {
    return DateFormat('yyyy-MM-dd').format(date);
  }

  static String formatDateTime(DateTime date) {
    return DateFormat('yyyy-MM-dd HH:mm').format(date);
  }

  static String formatDisplayDate(DateTime date, String locale) {
    if (locale == 'zh') {
      return DateFormat('yyyy年MM月dd日').format(date);
    }
    return DateFormat('MMM dd, yyyy').format(date);
  }

  static String formatDuration(Duration duration) {
    final days = duration.inDays;
    final hours = duration.inHours % 24;
    final minutes = duration.inMinutes % 60;
    final seconds = duration.inSeconds % 60;

    return '${days}天${hours.toString().padLeft(2, '0')}时${minutes.toString().padLeft(2, '0')}分${seconds.toString().padLeft(2, '0')}秒';
  }
}