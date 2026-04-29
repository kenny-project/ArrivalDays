import 'package:flutter_test/flutter_test.dart';
import 'package:arrival_days/models/countdown_target.dart';

void main() {
  group('CountdownTarget', () {
    test('create anniversary target', () {
      final target = CountdownTarget(
        id: 'test-1',
        name: '测试纪念日',
        targetDate: DateTime(2025, 1, 1),
        type: CountdownTargetType.anniversary,
        createdAt: DateTime(2024, 1, 1),
        updatedAt: DateTime(2024, 1, 1),
      );

      expect(target.id, 'test-1');
      expect(target.name, '测试纪念日');
      expect(target.type, CountdownTargetType.anniversary);
      expect(target.targetDate, DateTime(2025, 1, 1));
      expect(target.isRecurring, false);
      expect(target.isCompleted, false);
    });

    test('create birthday target', () {
      final target = CountdownTarget(
        id: 'bday-1',
        name: '妈妈生日',
        targetDate: DateTime(1990, 6, 15),
        type: CountdownTargetType.birthday,
        relation: '妈妈',
        isLunarCalendar: true,
        createdAt: DateTime(2024, 1, 1),
        updatedAt: DateTime(2024, 1, 1),
      );

      expect(target.type, CountdownTargetType.birthday);
      expect(target.relation, '妈妈');
      expect(target.isLunarCalendar, true);
    });

    test('create wish target without date', () {
      final target = CountdownTarget(
        id: 'wish-1',
        name: '学习画画',
        type: CountdownTargetType.wish,
        createdAt: DateTime(2024, 1, 1),
        updatedAt: DateTime(2024, 1, 1),
      );

      expect(target.type, CountdownTargetType.wish);
      expect(target.targetDate, isNull);
    });

    test('copyWith marks wish complete', () {
      final original = CountdownTarget(
        id: 'wish-1',
        name: '学习画画',
        type: CountdownTargetType.wish,
        createdAt: DateTime(2024, 1, 1),
        updatedAt: DateTime(2024, 1, 1),
      );

      final completed = original.copyWith(
        isCompleted: true,
        completedAt: DateTime(2024, 6, 15),
      );

      expect(completed.isCompleted, true);
      expect(completed.completedAt, DateTime(2024, 6, 15));
      expect(completed.name, '学习画画');
    });

    test('toMap and fromMap roundtrip', () {
      final original = CountdownTarget(
        id: 'test-1',
        name: '测试',
        targetDate: DateTime(2025, 1, 1),
        type: CountdownTargetType.anniversary,
        isRecurring: true,
        hasNotification: true,
        notificationDaysBefore: 3,
        createdAt: DateTime(2024, 1, 1),
        updatedAt: DateTime(2024, 1, 1),
      );

      final map = original.toMap();
      final restored = CountdownTarget.fromMap(map);

      expect(restored.id, original.id);
      expect(restored.name, original.name);
      expect(restored.targetDate, original.targetDate);
      expect(restored.type, original.type);
      expect(restored.isRecurring, original.isRecurring);
      expect(restored.hasNotification, original.hasNotification);
      expect(restored.notificationDaysBefore, original.notificationDaysBefore);
    });

    test('toMap and fromMap roundtrip with lunar calendar', () {
      final original = CountdownTarget(
        id: 'test-lunar',
        name: '生日(农历)',
        targetDate: DateTime(2025, 1, 1),
        type: CountdownTargetType.birthday,
        isLunarCalendar: true,
        isRecurring: true,
        createdAt: DateTime(2024, 1, 1),
        updatedAt: DateTime(2024, 1, 1),
      );

      final map = original.toMap();
      final restored = CountdownTarget.fromMap(map);

      expect(restored.isLunarCalendar, true);
    });

    test('filter by type works correctly', () {
      final targets = [
        CountdownTarget(
          id: '1',
          name: '纪念日1',
          type: CountdownTargetType.anniversary,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        ),
        CountdownTarget(
          id: '2',
          name: '生日',
          type: CountdownTargetType.birthday,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        ),
        CountdownTarget(
          id: '3',
          name: '心愿1',
          type: CountdownTargetType.wish,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        ),
        CountdownTarget(
          id: '4',
          name: '心愿2',
          type: CountdownTargetType.wish,
          isCompleted: true,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        ),
      ];

      final anniversaries = targets.where(
        (t) => t.type == CountdownTargetType.anniversary || t.type == CountdownTargetType.birthday,
      ).toList();
      final uncompletedWishes = targets.where(
        (t) => t.type == CountdownTargetType.wish && !t.isCompleted,
      ).toList();
      final completedWishes = targets.where(
        (t) => t.type == CountdownTargetType.wish && t.isCompleted,
      ).toList();

      expect(anniversaries.length, 2);
      expect(uncompletedWishes.length, 1);
      expect(completedWishes.length, 1);
    });
  });
}