class CountdownDuration {
  final int years;
  final int months;
  final int days;
  final int hours;
  final int minutes;
  final int seconds;
  final bool isOverdue;

  const CountdownDuration({
    required this.years,
    required this.months,
    required this.days,
    required this.hours,
    required this.minutes,
    required this.seconds,
    this.isOverdue = false,
  });

  String toDisplayString({bool showSeconds = true}) {
    final parts = <String>[];
    if (years > 0) parts.add('${years}年');
    if (months > 0 || years > 0) parts.add('${months}月');
    parts.add('${days}天');
    parts.add('${hours.toString().padLeft(2, '0')}时');
    parts.add('${minutes.toString().padLeft(2, '0')}分');
    if (showSeconds) {
      parts.add('${seconds.toString().padLeft(2, '0')}秒');
    }
    return parts.join('');
  }

  String toShortDisplayString() {
    final parts = <String>[];
    if (years > 0) parts.add('${years}年');
    if (months > 0 || years > 0) parts.add('${months}月');
    parts.add('${days}天');
    parts.add('${hours.toString().padLeft(2, '0')}时');
    parts.add('${minutes.toString().padLeft(2, '0')}分');
    return parts.join('');
  }
}

class CountdownUtils {
  static CountdownDuration calculateCountdown(DateTime targetDate) {
    final now = DateTime.now();
    final difference = targetDate.difference(now);

    if (difference.isNegative) {
      final absDifference = difference.abs();
      final years = absDifference.inDays ~/ 365;
      final remainingDays = absDifference.inDays % 365;
      final months = remainingDays ~/ 30;
      final days = remainingDays % 30;
      return CountdownDuration(
        years: years,
        months: months,
        days: days,
        hours: absDifference.inHours % 24,
        minutes: absDifference.inMinutes % 60,
        seconds: absDifference.inSeconds % 60,
        isOverdue: true,
      );
    }

    final years = difference.inDays ~/ 365;
    final remainingDays = difference.inDays % 365;
    final months = remainingDays ~/ 30;
    final days = remainingDays % 30;
    return CountdownDuration(
      years: years,
      months: months,
      days: days,
      hours: difference.inHours % 24,
      minutes: difference.inMinutes % 60,
      seconds: difference.inSeconds % 60,
      isOverdue: false,
    );
  }

  static int calculateAge(DateTime birthDate) {
    final now = DateTime.now();
    int age = now.year - birthDate.year;
    if (now.month < birthDate.month ||
        (now.month == birthDate.month && now.day < birthDate.day)) {
      age--;
    }
    return age;
  }

  static DateTime getNextRecurringDate(DateTime originalDate) {
    final now = DateTime.now();
    var nextDate = DateTime(now.year, originalDate.month, originalDate.day);
    if (nextDate.isBefore(now) || nextDate.isAtSameMomentAs(now)) {
      nextDate = DateTime(now.year + 1, originalDate.month, originalDate.day);
    }
    return nextDate;
  }
}