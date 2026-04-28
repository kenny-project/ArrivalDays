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

  Future<void> saveSettings(UserSettings settings) async {
    await _db.insertUserSettings(settings);
    state = await _db.getUserSettings();
    Log.i(LogTag.provider, 'settings saved, reload: ${state?.birthDate}');
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

  Future<void> addTarget(CountdownTarget target) async {
    await _db.insertCountdownTarget(target);
    state = [...state, target];
  }

  Future<void> updateTarget(CountdownTarget target) async {
    await _db.updateCountdownTarget(target);
    state = state.map((t) => t.id == target.id ? target : t).toList();
  }

  Future<void> deleteTarget(String id) async {
    await _db.deleteCountdownTarget(id);
    state = state.where((t) => t.id != id).toList();
  }

  Future<void> refresh() async {
    await _loadTargets();
  }
}