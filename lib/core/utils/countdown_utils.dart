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
    if (days > 0 || years > 0 || months > 0) parts.add('${days}天');
    if (hours > 0 || years > 0 || months > 0 || days > 0) {
      parts.add('${hours.toString().padLeft(2, '0')}时');
    }
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
    if (days > 0 || years > 0 || months > 0) parts.add('${days}天');
    if (hours > 0 || years > 0 || months > 0 || days > 0) {
      parts.add('${hours.toString().padLeft(2, '0')}时');
    }
    parts.add('${minutes.toString().padLeft(2, '0')}分');
    return parts.join('');
  }

    String toMinimalDisplayString({bool showSeconds = true}) {
    if (years > 0) {
      String result = '${years}年';
      if (months > 0) result += '${months}月';
      if (days > 0) result += '${days}天';
      if (months == 0) {
        if (hours > 0) result += '${hours}时';
        if (minutes > 0) result += '${minutes}分';
        if (showSeconds && seconds > 0) result += '${seconds}秒';
      }
      return result;
    }
    if (months > 0) {
      String result = '${months}月';
      if (days > 0) result += '${days}天';
      if (days == 0) {
        if (hours > 0) result += '${hours}时';
        if (minutes > 0) result += '${minutes}分';
      }
      return result;
    }
    if (days > 0) {
      String result = '${days}天';
      if (hours > 0) result += '${hours}时';
      if (minutes > 0) result += '${minutes}分';
      return result;
    }
    if (hours > 0) {
      String result = '${hours}小时';
      if (minutes > 0) result += '${minutes}分';
      return result;
    }
    if (minutes > 0) return '${minutes}分钟';
    return '即将到来';
  }
}

class CountdownUtils {
  static final Map<int, List<int>> _lunarYearData = {
    // year: [chineseNewYearMonth, chineseNewYearDay, daysInYear]
    // This is a simplified table - more accurate data would be needed for production
    2026: [2, 17, 0],
    2025: [1, 29, 0],
    2024: [2, 10, 0],
    2023: [1, 22, 0],
    2022: [2, 1, 0],
    2021: [2, 12, 0],
    2020: [1, 25, 0],
    2019: [2, 5, 0],
    2018: [2, 16, 0],
    2017: [1, 28, 0],
    2016: [2, 8, 0],
    2015: [2, 19, 0],
    2014: [1, 31, 0],
    2013: [2, 10, 0],
    2012: [1, 23, 0],
    2011: [2, 3, 0],
    2010: [2, 14, 0],
    2009: [1, 26, 0],
    2008: [2, 7, 0],
    2007: [2, 18, 0],
    2006: [1, 29, 0],
    2005: [2, 9, 0],
    2004: [1, 22, 0],
    2003: [2, 1, 0],
    2002: [2, 12, 0],
    2001: [1, 24, 0],
    2000: [2, 5, 0],
  };

  static DateTime convertLunarToSolar(int targetYear, int lunarMonth, int lunarDay) {
    // Find the closest Chinese New Year data for targetYear
    if (!_lunarYearData.containsKey(targetYear)) {
      // Estimate if year not in table - use Feb 1 as default
      return DateTime(targetYear, lunarMonth + 1, lunarDay);
    }

    final cnyData = _lunarYearData[targetYear]!;
    final cnyMonth = cnyData[0];
    final cnyDay = cnyData[1];

    // Calculate days from Chinese New Year
    final cnyThisYear = DateTime(targetYear, cnyMonth, cnyDay);
    // Approximate: each lunar month is ~29.5 days
    int daysFromCny = ((lunarMonth - 1) * 29.5).round() + lunarDay - 1;

    return cnyThisYear.add(Duration(days: daysFromCny));
  }

  static String calculateZodiac(int year) {
    final zodiacs = ['鼠', '牛', '虎', '兔', '龙', '蛇', '马', '羊', '猴', '鸡', '狗', '猪'];
    final baseYear = 1990;
    final baseIndex = 6; // 马
    final offset = (year - baseYear) % 12;
    final index = (baseIndex + offset + 12) % 12;
    return zodiacs[index];
  }

  static DateTime? calculateTargetDate(DateTime? useDate, bool isLunarCalendar) {
    if (useDate == null) return null;

    if (isLunarCalendar) {
      final now = DateTime.now();
      return convertLunarToSolar(now.year, useDate.month, useDate.day);
    } else {
      return useDate;
    }
  }

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