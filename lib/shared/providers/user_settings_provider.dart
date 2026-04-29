import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/database/database_helper.dart';
import '../../../core/utils/logger.dart';
import '../../../models/user_settings.dart';

final databaseHelperProvider = Provider<DatabaseHelper>((ref) {
  return DatabaseHelper.instance;
});

final userSettingsProvider =
    StateNotifierProvider<UserSettingsNotifier, UserSettings?>((ref) {
  return UserSettingsNotifier(ref.watch(databaseHelperProvider));
});

class UserSettingsNotifier extends StateNotifier<UserSettings?> {
  final DatabaseHelper _db;

  UserSettingsNotifier(this._db) : super(null) {
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final loaded = await _db.getUserSettings();
    if (loaded != null) {
      state = loaded;
    } else {
      final defaultSettings = UserSettings(
        id: 'default',
        birthDate: DateTime(1990, 1, 1),
        lifeExpectancy: 80,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );
      await _db.insertUserSettings(defaultSettings);
      state = defaultSettings;
    }
  }

  Future<bool> saveSettings(UserSettings settings) async {
    try {
      await _db.insertUserSettings(settings);
      state = settings;
      Log.i(LogTag.provider, 'settings saved: ${settings.birthDate}');
      return true;
    } catch (e) {
      Log.e(LogTag.provider, 'save settings failed: $e');
      return false;
    }
  }
}
