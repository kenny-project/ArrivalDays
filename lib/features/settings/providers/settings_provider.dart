import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../models/user_settings.dart';
import '../../../shared/providers/database_providers.dart';

final settingsViewModelProvider =
    Provider<SettingsViewModel>((ref) {
  debugPrint('[SettingsVM] settingsViewModelProvider created');
  return SettingsViewModel(ref);
});

class SettingsViewModel {
  final Ref _ref;

  SettingsViewModel(this._ref);

  UserSettings? get settings => _ref.read(userSettingsProvider);

  Future<void> updateBirthDate(DateTime date) async {
    debugPrint('[SettingsVM] updateBirthDate called: $date');
    final current = _ref.read(userSettingsProvider);
    debugPrint('[SettingsVM] current settings: $current');
    if (current != null) {
      await _ref.read(userSettingsProvider.notifier).saveSettings(
        current.copyWith(
          birthDate: date,
          updatedAt: DateTime.now(),
        ),
      );
      debugPrint('[SettingsVM] updateBirthDate completed');
    } else {
      debugPrint('[SettingsVM] updateBirthDate: current is null, skipping');
    }
  }

  Future<void> updateRetirementDate(DateTime? date) async {
    debugPrint('[SettingsVM] updateRetirementDate called: $date');
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
    debugPrint('[SettingsVM] updateLifeExpectancy called: $years');
    final current = _ref.read(userSettingsProvider);
    debugPrint('[SettingsVM] current settings: $current');
    if (current != null) {
      await _ref.read(userSettingsProvider.notifier).saveSettings(
        current.copyWith(
          lifeExpectancy: years,
          updatedAt: DateTime.now(),
        ),
      );
      debugPrint('[SettingsVM] updateLifeExpectancy completed');
    } else {
      debugPrint('[SettingsVM] updateLifeExpectancy: current is null, skipping');
    }
  }

  Future<void> toggleDarkMode() async {
    debugPrint('[SettingsVM] toggleDarkMode called');
    final current = _ref.read(userSettingsProvider);
    debugPrint('[SettingsVM] current isDarkMode: ${current?.isDarkMode}');
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
    debugPrint('[SettingsVM] updateLanguage called: $language');
    final current = _ref.read(userSettingsProvider);
    debugPrint('[SettingsVM] current language: ${current?.language}');
    if (current != null) {
      await _ref.read(userSettingsProvider.notifier).saveSettings(
        current.copyWith(
          language: language,
          updatedAt: DateTime.now(),
        ),
      );
      debugPrint('[SettingsVM] updateLanguage completed');
    } else {
      debugPrint('[SettingsVM] updateLanguage: current is null, skipping');
    }
  }
}