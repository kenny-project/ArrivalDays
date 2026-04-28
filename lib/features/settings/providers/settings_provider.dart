import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../models/user_settings.dart';
import '../../../shared/providers/database_providers.dart';

final settingsViewModelProvider =
    Provider<SettingsViewModel>((ref) {
  return SettingsViewModel(ref);
});

class SettingsViewModel {
  final Ref _ref;

  SettingsViewModel(this._ref);

  UserSettings? get settings => _ref.read(userSettingsProvider);

  Future<void> updateBirthDate(DateTime date) async {
    final current = _ref.read(userSettingsProvider);
    if (current != null) {
      await _ref.read(userSettingsProvider.notifier).saveSettings(
        current.copyWith(
          birthDate: date,
          updatedAt: DateTime.now(),
        ),
      );
    }
  }

  Future<void> updateRetirementDate(DateTime? date) async {
    final current = _ref.read(userSettingsProvider);
    if (current != null) {
      await _ref.read(userSettingsProvider.notifier).saveSettings(
        current.copyWith(
          retirementDate: date,
          updatedAt: DateTime.now(),
        ),
      );
    }
  }

  Future<void> updateLifeExpectancy(int years) async {
    final current = _ref.read(userSettingsProvider);
    if (current != null) {
      await _ref.read(userSettingsProvider.notifier).saveSettings(
        current.copyWith(
          lifeExpectancy: years,
          updatedAt: DateTime.now(),
        ),
      );
    }
  }

  Future<void> toggleDarkMode() async {
    final current = _ref.read(userSettingsProvider);
    if (current != null) {
      await _ref.read(userSettingsProvider.notifier).saveSettings(
        current.copyWith(
          isDarkMode: !current.isDarkMode,
          updatedAt: DateTime.now(),
        ),
      );
    }
  }

  Future<void> updateLanguage(String language) async {
    final current = _ref.read(userSettingsProvider);
    if (current != null) {
      await _ref.read(userSettingsProvider.notifier).saveSettings(
        current.copyWith(
          language: language,
          updatedAt: DateTime.now(),
        ),
      );
    }
  }
}