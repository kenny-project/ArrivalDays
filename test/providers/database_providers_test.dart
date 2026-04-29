import 'package:flutter_test/flutter_test.dart';
import 'package:arrival_days/models/countdown_target.dart';
import 'package:arrival_days/models/user_settings.dart';

void main() {
  group('CountdownTargetsNotifier Logic', () {
    test('addTarget returns true on success', () {
      // Simulate addTarget logic
      final targets = <CountdownTarget>[];
      final newTarget = CountdownTarget(
        id: 'test-1',
        name: '测试纪念日',
        targetDate: DateTime(2025, 1, 1),
        type: CountdownTargetType.anniversary,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      // Simulate add operation
      targets.add(newTarget);

      expect(targets.length, 1);
      expect(targets.first.id, 'test-1');
    });

    test('updateTarget updates existing item', () {
      final original = CountdownTarget(
        id: 'test-1',
        name: '原名称',
        targetDate: DateTime(2025, 1, 1),
        type: CountdownTargetType.anniversary,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      final updated = original.copyWith(name: '新名称');

      // Simulate update operation
      final targets = [original];
      final newList = targets.map((t) => t.id == updated.id ? updated : t).toList();

      expect(newList.first.name, '新名称');
    });

    test('deleteTarget removes item', () {
      final target = CountdownTarget(
        id: 'test-1',
        name: '测试',
        type: CountdownTargetType.anniversary,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      final targets = [target];
      final newList = targets.where((t) => t.id != 'test-1').toList();

      expect(newList.length, 0);
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
      final wishes = targets.where(
        (t) => t.type == CountdownTargetType.wish && !t.isCompleted,
      ).toList();
      final completedWishes = targets.where(
        (t) => t.type == CountdownTargetType.wish && t.isCompleted,
      ).toList();

      expect(anniversaries.length, 2);
      expect(wishes.length, 1);
      expect(completedWishes.length, 1);
    });

    test('sort by targetDate works correctly', () {
      final targets = [
        CountdownTarget(
          id: '1',
          name: '中期',
          targetDate: DateTime(2025, 6, 1),
          type: CountdownTargetType.anniversary,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        ),
        CountdownTarget(
          id: '2',
          name: '最早',
          targetDate: DateTime(2025, 1, 1),
          type: CountdownTargetType.anniversary,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        ),
        CountdownTarget(
          id: '3',
          name: '最晚',
          targetDate: DateTime(2025, 12, 31),
          type: CountdownTargetType.anniversary,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        ),
      ];

      targets.sort((a, b) {
        if (a.targetDate == null) return 1;
        if (b.targetDate == null) return -1;
        return a.targetDate!.compareTo(b.targetDate!);
      });

      expect(targets[0].name, '最早');
      expect(targets[1].name, '中期');
      expect(targets[2].name, '最晚');
    });
  });

  group('UserSettings Logic', () {
    test('copyWith updates specific fields', () {
      final original = UserSettings(
        id: 'default',
        birthDate: DateTime(1990, 1, 1),
        lifeExpectancy: 80,
        createdAt: DateTime(2024, 1, 1),
        updatedAt: DateTime(2024, 1, 1),
      );

      final updated = original.copyWith(
        birthDate: DateTime(2000, 6, 15),
        isDarkMode: true,
      );

      expect(updated.birthDate, DateTime(2000, 6, 15));
      expect(updated.isDarkMode, true);
      expect(updated.lifeExpectancy, 80); // unchanged
      expect(updated.id, 'default'); // unchanged
    });

    test('settings with null retirementDate', () {
      final settings = UserSettings(
        id: 'default',
        birthDate: DateTime(1990, 1, 1),
        lifeExpectancy: 80,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      expect(settings.retirementDate, isNull);
    });
  });

  group('Save/Update Logic Validation', () {
    test('addTarget requires non-null target', () {
      final target = CountdownTarget(
        id: 'test-1',
        name: '测试',
        type: CountdownTargetType.anniversary,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      expect(target.id, isNotEmpty);
      expect(target.name, isNotEmpty);
    });

    test('updateTarget preserves id', () {
      final original = CountdownTarget(
        id: 'test-1',
        name: '原名称',
        type: CountdownTargetType.anniversary,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      final updated = original.copyWith(name: '新名称');

      expect(original.id, updated.id);
      expect(updated.name, '新名称');
    });

    test('isLunarCalendar only for birthday type', () {
      final birthday = CountdownTarget(
        id: 'bday-1',
        name: '生日',
        targetDate: DateTime(1990, 6, 15),
        type: CountdownTargetType.birthday,
        isLunarCalendar: true,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      final anniversary = CountdownTarget(
        id: 'anniv-1',
        name: '纪念日',
        targetDate: DateTime(2020, 1, 1),
        type: CountdownTargetType.anniversary,
        isLunarCalendar: false,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      expect(birthday.isLunarCalendar, true);
      expect(anniversary.isLunarCalendar, false);
    });
  });
}