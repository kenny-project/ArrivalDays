import 'package:flutter_test/flutter_test.dart';
import 'package:arrival_days/models/user_settings.dart';

void main() {
  group('UserSettings', () {
    test('create with default values', () {
      final settings = UserSettings(
        id: 'default',
        birthDate: DateTime(1990, 1, 15),
        createdAt: DateTime(2024, 1, 1),
        updatedAt: DateTime(2024, 1, 1),
      );

      expect(settings.id, 'default');
      expect(settings.birthDate, DateTime(1990, 1, 15));
      expect(settings.lifeExpectancy, 80);
      expect(settings.isDarkMode, false);
      expect(settings.language, 'zh');
      expect(settings.retirementDate, isNull);
    });

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
        lifeExpectancy: 85,
      );

      expect(updated.birthDate, DateTime(2000, 6, 15));
      expect(updated.lifeExpectancy, 85);
      expect(updated.id, 'default');
      expect(updated.isDarkMode, false);
    });

    test('toMap and fromMap roundtrip', () {
      final original = UserSettings(
        id: 'default',
        birthDate: DateTime(1990, 1, 15),
        retirementDate: DateTime(2050, 6, 1),
        lifeExpectancy: 80,
        isDarkMode: true,
        language: 'en',
        createdAt: DateTime(2024, 1, 1),
        updatedAt: DateTime(2024, 6, 15),
      );

      final map = original.toMap();
      final restored = UserSettings.fromMap(map);

      expect(restored.id, original.id);
      expect(restored.birthDate, original.birthDate);
      expect(restored.retirementDate, original.retirementDate);
      expect(restored.lifeExpectancy, original.lifeExpectancy);
      expect(restored.isDarkMode, original.isDarkMode);
      expect(restored.language, original.language);
    });
  });
}