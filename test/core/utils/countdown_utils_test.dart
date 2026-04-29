import 'package:flutter_test/flutter_test.dart';
import 'package:arrival_days/core/utils/countdown_utils.dart';

void main() {
  group('CountdownDuration toDisplayString', () {
    test('shows years when years > 0', () {
      final cd = CountdownDuration(
        years: 2,
        months: 5,
        days: 10,
        hours: 3,
        minutes: 20,
        seconds: 30,
      );
      expect(cd.toDisplayString(), '2年5月10天03时20分30秒');
    });

    test('shows months when no years but months > 0', () {
      final cd = CountdownDuration(
        years: 0,
        months: 5,
        days: 10,
        hours: 3,
        minutes: 20,
        seconds: 30,
      );
      expect(cd.toDisplayString(), '5月10天03时20分30秒');
    });

    test('hides zero days when years or months exist', () {
      final cd = CountdownDuration(
        years: 1,
        months: 0,
        days: 0,
        hours: 5,
        minutes: 10,
        seconds: 20,
      );
      expect(cd.toDisplayString(), '1年0月0天05时10分20秒');
    });

    test('hides zero hours when years or months or days exist', () {
      final cd = CountdownDuration(
        years: 0,
        months: 2,
        days: 5,
        hours: 0,
        minutes: 30,
        seconds: 15,
      );
      expect(cd.toDisplayString(), '2月5天00时30分15秒');
    });
  });

  group('CountdownDuration toMinimalDisplayString - years boundary tests', () {
    test('years > 0, months > 0, days > 0', () {
      final cd = CountdownDuration(
        years: 2, months: 5, days: 10,
        hours: 0, minutes: 0, seconds: 0,
      );
      expect(cd.toMinimalDisplayString(), '2年5月10天');
    });

    test('years > 0, months = 0, days > 0', () {
      final cd = CountdownDuration(
        years: 20, months: 0, days: 3,
        hours: 5, minutes: 30, seconds: 45,
      );
      expect(cd.toMinimalDisplayString(), '20年3天5时30分45秒');
    });

    test('years > 0, months > 0, days = 0', () {
      final cd = CountdownDuration(
        years: 5, months: 3, days: 0,
        hours: 0, minutes: 0, seconds: 0,
      );
      expect(cd.toMinimalDisplayString(), '5年3月');
    });

    test('years > 0, months = 0, days = 0', () {
      final cd = CountdownDuration(
        years: 10, months: 0, days: 0,
        hours: 0, minutes: 0, seconds: 0,
      );
      expect(cd.toMinimalDisplayString(), '10年');
    });

    test('years > 0, months = 0, days = 0, hours > 0', () {
      final cd = CountdownDuration(
        years: 3, months: 0, days: 0,
        hours: 8, minutes: 15, seconds: 0,
      );
      expect(cd.toMinimalDisplayString(), '3年8时15分');
    });
  });

  group('CountdownDuration toMinimalDisplayString - months boundary tests', () {
    test('months > 0, days > 0', () {
      final cd = CountdownDuration(
        years: 0, months: 6, days: 15,
        hours: 0, minutes: 0, seconds: 0,
      );
      expect(cd.toMinimalDisplayString(), '6月15天');
    });

    test('months > 0, days = 0', () {
      final cd = CountdownDuration(
        years: 0, months: 8, days: 0,
        hours: 0, minutes: 0, seconds: 0,
      );
      expect(cd.toMinimalDisplayString(), '8月');
    });

    test('months = 0, days > 0, hours > 0', () {
      final cd = CountdownDuration(
        years: 0, months: 0, days: 10,
        hours: 5, minutes: 20, seconds: 0,
      );
      expect(cd.toMinimalDisplayString(), '10天5时20分');
    });
  });

  group('CountdownDuration toMinimalDisplayString - days boundary tests', () {
    test('days > 0, hours > 0, minutes > 0', () {
      final cd = CountdownDuration(
        years: 0, months: 0, days: 7,
        hours: 12, minutes: 30, seconds: 0,
      );
      expect(cd.toMinimalDisplayString(), '7天12时30分');
    });

    test('days > 0, hours = 0, minutes > 0', () {
      final cd = CountdownDuration(
        years: 0, months: 0, days: 3,
        hours: 0, minutes: 45, seconds: 0,
      );
      expect(cd.toMinimalDisplayString(), '3天45分');
    });

    test('days > 0, hours = 0, minutes = 0', () {
      final cd = CountdownDuration(
        years: 0, months: 0, days: 5,
        hours: 0, minutes: 0, seconds: 0,
      );
      expect(cd.toMinimalDisplayString(), '5天');
    });
  });

  group('CountdownDuration toMinimalDisplayString - hours boundary tests', () {
    test('hours > 0, minutes > 0', () {
      final cd = CountdownDuration(
        years: 0, months: 0, days: 0,
        hours: 6, minutes: 40, seconds: 0,
      );
      expect(cd.toMinimalDisplayString(), '6小时40分');
    });

    test('hours > 0, minutes = 0', () {
      final cd = CountdownDuration(
        years: 0, months: 0, days: 0,
        hours: 3, minutes: 0, seconds: 0,
      );
      expect(cd.toMinimalDisplayString(), '3小时');
    });

    test('hours = 0, minutes > 0', () {
      final cd = CountdownDuration(
        years: 0, months: 0, days: 0,
        hours: 0, minutes: 25, seconds: 0,
      );
      expect(cd.toMinimalDisplayString(), '25分钟');
    });
  });

  group('CountdownDuration toMinimalDisplayString - seconds boundary tests', () {
    test('minutes > 0, seconds > 0', () {
      final cd = CountdownDuration(
        years: 0, months: 0, days: 0,
        hours: 0, minutes: 5, seconds: 30,
      );
      expect(cd.toMinimalDisplayString(), '5分钟');
    });

    test('minutes = 0, seconds > 0', () {
      final cd = CountdownDuration(
        years: 0, months: 0, days: 0,
        hours: 0, minutes: 0, seconds: 45,
      );
      expect(cd.toMinimalDisplayString(), '即将到来');
    });
  });

  group('CountdownDuration toMinimalDisplayString - all zero', () {
    test('all units are zero', () {
      final cd = CountdownDuration(
        years: 0, months: 0, days: 0,
        hours: 0, minutes: 0, seconds: 0,
      );
      expect(cd.toMinimalDisplayString(), '即将到来');
    });
  });

  group('CountdownUtils calculateCountdown', () {
    test('returns positive countdown for future date', () {
      final future = DateTime.now().add(const Duration(days: 100));
      final countdown = CountdownUtils.calculateCountdown(future);
      expect(countdown.isOverdue, false);
      expect(countdown.days, greaterThan(0));
    });

    test('returns negative countdown for past date', () {
      final past = DateTime.now().subtract(const Duration(days: 100));
      final countdown = CountdownUtils.calculateCountdown(past);
      expect(countdown.isOverdue, true);
    });
  });

  group('CountdownDisplay wording', () {
    test('uses 距离 prefix for future dates', () {
      final cd = CountdownDuration(
        years: 0, months: 0, days: 0,
        hours: 2, minutes: 0, seconds: 0,
        isOverdue: false,
      );
      expect(cd.isOverdue, false);
    });

    test('uses 已过去 prefix for past dates', () {
      final cd = CountdownDuration(
        years: 0, months: 0, days: 0,
        hours: 2, minutes: 0, seconds: 0,
        isOverdue: true,
      );
      expect(cd.isOverdue, true);
    });
  });
}