import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/database/database_helper.dart';
import '../../core/utils/logger.dart';
import '../../models/user_settings.dart';
import '../../models/countdown_target.dart';

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
    state = await _db.getUserSettings();
    Log.i(LogTag.provider, 'settings loaded: ${state?.birthDate}');
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

final countdownTargetsProvider =
    StateNotifierProvider<CountdownTargetsNotifier, List<CountdownTarget>>((ref) {
  return CountdownTargetsNotifier(ref.watch(databaseHelperProvider));
});

class CountdownTargetsNotifier extends StateNotifier<List<CountdownTarget>> {
  final DatabaseHelper _db;

  CountdownTargetsNotifier(this._db) : super([]) {
    _loadTargets();
  }

  Future<void> _loadTargets() async {
    state = await _db.getAllCountdownTargets();
    Log.i(LogTag.provider, 'targets loaded: ${state.length}');
  }

  Future<bool> addTarget(CountdownTarget target) async {
    try {
      await _db.insertCountdownTarget(target);
      state = [...state, target];
      Log.i(LogTag.provider, 'addTarget success: ${target.name}');
      return true;
    } catch (e) {
      Log.e(LogTag.provider, 'addTarget failed: $e');
      return false;
    }
  }

  Future<bool> updateTarget(CountdownTarget target) async {
    try {
      await _db.updateCountdownTarget(target);
      state = state.map((t) => t.id == target.id ? target : t).toList();
      Log.i(LogTag.provider, 'updateTarget success: ${target.name}');
      return true;
    } catch (e) {
      Log.e(LogTag.provider, 'updateTarget failed: $e');
      return false;
    }
  }

  Future<bool> deleteTarget(String id) async {
    try {
      await _db.deleteCountdownTarget(id);
      state = state.where((t) => t.id != id).toList();
      Log.i(LogTag.provider, 'deleteTarget success: $id');
      return true;
    } catch (e) {
      Log.e(LogTag.provider, 'deleteTarget failed: $e');
      return false;
    }
  }

  Future<void> refresh() async {
    await _loadTargets();
  }
}