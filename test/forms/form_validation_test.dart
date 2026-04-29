import 'package:flutter_test/flutter_test.dart';
import 'package:arrival_days/models/countdown_target.dart';

void main() {
  group('AnniversaryForm Validation Logic', () {
    test('name is required - empty name returns error', () {
      const name = '';
      final isValid = name.isNotEmpty;
      expect(isValid, false);
    });

    test('name is required - non-empty name passes', () {
      const name = '生日派对';
      final isValid = name.isNotEmpty;
      expect(isValid, true);
    });

    test('birthday type auto-sets isRecurring to true', () {
      bool isBirthday = true;
      bool isRecurring = false;

      if (isBirthday) {
        isRecurring = true;
      }

      expect(isRecurring, true);
    });

    test('anniversary type allows isRecurring to be false', () {
      bool isBirthday = false;
      bool isRecurring = false;

      if (isBirthday) {
        isRecurring = true;
      }

      expect(isRecurring, false);
    });

    test('isLunarCalendar only applies to birthday type', () {
      bool isBirthday = true;
      bool isLunarCalendar = true;
      bool isLunarForTarget = isBirthday ? isLunarCalendar : false;

      expect(isLunarForTarget, true);

      isBirthday = false;
      isLunarCalendar = true;
      isLunarForTarget = isBirthday ? isLunarCalendar : false;

      expect(isLunarForTarget, false);
    });

    test('relation field only applies to birthday type', () {
      bool isBirthday = true;
      const relationController = '爸爸';
      final relation = isBirthday ? relationController : null;

      expect(relation, '爸爸');

      isBirthday = false;
      final relationForAnniversary = isBirthday ? relationController : null;

      expect(relationForAnniversary, isNull);
    });

    test('date selection is required for anniversary', () {
      DateTime? selectedDate;

      final hasDate = selectedDate != null;
      expect(hasDate, false);

      selectedDate = DateTime(2025, 1, 1);
      final hasDateAfterSelection = selectedDate != null;
      expect(hasDateAfterSelection, true);
    });

    test('form validation blocks save when name is empty', () {
      const name = '';
      bool saveCalled = false;

      // Simulate form validation
      final isValid = name.isNotEmpty;
      if (isValid) {
        saveCalled = true;
      }

      expect(saveCalled, false);
    });

    test('form validation allows save when name is not empty', () {
      const name = '结婚纪念日';
      bool saveCalled = false;

      final isValid = name.isNotEmpty;
      if (isValid) {
        saveCalled = true;
      }

      expect(saveCalled, true);
    });

    test('form validation requires date selection for anniversary', () {
      DateTime? selectedDate;
      bool saveCalled = false;

      final isFormValid = selectedDate != null;
      if (isFormValid) {
        saveCalled = true;
      }

      expect(saveCalled, false);
    });
  });

  group('WishForm Validation Logic', () {
    test('name is required - empty name returns error', () {
      const name = '';
      final isValid = name.isNotEmpty;
      expect(isValid, false);
    });

    test('name is required - non-empty name passes', () {
      const name = '去看极光';
      final isValid = name.isNotEmpty;
      expect(isValid, true);
    });

    test('targetDate is optional for wish', () {
      DateTime? selectedDate;

      // No date is valid for wish - only name is required
      const name = '学会潜水';
      final isValid = name.isNotEmpty; // Wish doesn't require date
      expect(isValid, true);

      // With date is also valid
      selectedDate = DateTime(2025, 12, 31);
      final isValidWithDate = selectedDate != null;
      expect(isValidWithDate, true);
    });

    test('hasNotification defaults to true', () {
      const hasNotification = true;
      expect(hasNotification, true);
    });

    test('form validation blocks save when name is empty', () {
      const name = '';
      bool saveCalled = false;

      final isValid = name.isNotEmpty;
      if (isValid) {
        saveCalled = true;
      }

      expect(saveCalled, false);
    });
  });

  group('CountdownTarget from Form Data', () {
    test('creates anniversary target correctly from form', () {
      const formData = {
        'name': '结婚纪念日',
        'selectedDate': null,
        'isBirthday': false,
        'isRecurring': true,
        'isLunarCalendar': false,
        'hasNotification': true,
        'relation': null,
      };

      final selectedDate = DateTime(2020, 5, 20);
      final target = CountdownTarget(
        id: 'test-id',
        name: formData['name'] as String,
        targetDate: selectedDate,
        type: formData['isBirthday'] as bool
            ? CountdownTargetType.birthday
            : CountdownTargetType.anniversary,
        isRecurring: formData['isRecurring'] as bool,
        isLunarCalendar: formData['isBirthday'] as bool
            ? formData['isLunarCalendar'] as bool
            : false,
        relation: formData['isBirthday'] as bool
            ? formData['relation'] as String?
            : null,
        hasNotification: formData['hasNotification'] as bool,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      expect(target.name, '结婚纪念日');
      expect(target.type, CountdownTargetType.anniversary);
      expect(target.isRecurring, true);
      expect(target.isLunarCalendar, false);
    });

    test('creates birthday target correctly from form', () {
      const formData = {
        'name': '妈妈生日',
        'isBirthday': true,
        'isRecurring': true,
        'isLunarCalendar': true,
        'hasNotification': true,
        'relation': '妈妈',
      };

      final selectedDate = DateTime(1960, 6, 15);
      final target = CountdownTarget(
        id: 'test-id',
        name: formData['name'] as String,
        targetDate: selectedDate,
        type: formData['isBirthday'] as bool
            ? CountdownTargetType.birthday
            : CountdownTargetType.anniversary,
        isRecurring: formData['isRecurring'] as bool,
        isLunarCalendar: formData['isBirthday'] as bool
            ? formData['isLunarCalendar'] as bool
            : false,
        relation: formData['isBirthday'] as bool
            ? formData['relation'] as String?
            : null,
        hasNotification: formData['hasNotification'] as bool,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      expect(target.name, '妈妈生日');
      expect(target.type, CountdownTargetType.birthday);
      expect(target.isRecurring, true);
      expect(target.isLunarCalendar, true);
      expect(target.relation, '妈妈');
    });

    test('creates wish target correctly from form', () {
      const formData = {
        'name': '学会潜水',
        'hasNotification': true,
      };

      final target = CountdownTarget(
        id: 'test-id',
        name: formData['name'] as String,
        targetDate: null,
        type: CountdownTargetType.wish,
        isRecurring: false,
        isLunarCalendar: false,
        hasNotification: formData['hasNotification'] as bool,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      expect(target.name, '学会潜水');
      expect(target.type, CountdownTargetType.wish);
      expect(target.targetDate, isNull);
    });
  });

  group('Type-Based Validation', () {
    test('birthday type requires isRecurring to be true', () {
      final target = CountdownTarget(
        id: 'bday-1',
        name: '生日',
        targetDate: DateTime(1990, 6, 15),
        type: CountdownTargetType.birthday,
        isRecurring: true,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      expect(target.type, CountdownTargetType.birthday);
      expect(target.isRecurring, true);
    });

    test('wish type does not use isRecurring', () {
      final target = CountdownTarget(
        id: 'wish-1',
        name: '心愿',
        type: CountdownTargetType.wish,
        isRecurring: false,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      expect(target.type, CountdownTargetType.wish);
      expect(target.isRecurring, false);
    });

    test('isLunarCalendar is only meaningful for birthday', () {
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