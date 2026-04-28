import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/database/database_helper.dart';
import '../../models/user_settings.dart';
import '../../models/countdown_target.dart';

final databaseHelperProvider = Provider<DatabaseHelper>((ref) {
  debugPrint('[Provider] databaseHelperProvider created');
  return DatabaseHelper.instance;
});

final userSettingsProvider =
    StateNotifierProvider<UserSettingsNotifier, UserSettings?>((ref) {
  debugPrint('[Provider] userSettingsProvider created');
  return UserSettingsNotifier(ref.watch(databaseHelperProvider));
});

class UserSettingsNotifier extends StateNotifier<UserSettings?> {
  final DatabaseHelper _db;

  UserSettingsNotifier(this._db) : super(null) {
    debugPrint('[Provider] UserSettingsNotifier constructed');
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    debugPrint('[Provider] UserSettingsNotifier._loadSettings called');
    state = await _db.getUserSettings();
    debugPrint('[Provider] UserSettingsNotifier._loadSettings result: ${state?.id}');
  }

  Future<void> saveSettings(UserSettings settings) async {
    debugPrint('[Provider] UserSettingsNotifier.saveSettings called: ${settings.id}');
    await _db.insertUserSettings(settings);
    state = settings;
    debugPrint('[Provider] UserSettingsNotifier.saveSettings completed');
  }
}

final countdownTargetsProvider =
    StateNotifierProvider<CountdownTargetsNotifier, List<CountdownTarget>>((ref) {
  debugPrint('[Provider] countdownTargetsProvider created');
  return CountdownTargetsNotifier(ref.watch(databaseHelperProvider));
});

class CountdownTargetsNotifier extends StateNotifier<List<CountdownTarget>> {
  final DatabaseHelper _db;

  CountdownTargetsNotifier(this._db) : super([]) {
    debugPrint('[Provider] CountdownTargetsNotifier constructed');
    _loadTargets();
  }

  Future<void> _loadTargets() async {
    debugPrint('[Provider] CountdownTargetsNotifier._loadTargets called');
    state = await _db.getAllCountdownTargets();
    debugPrint('[Provider] CountdownTargetsNotifier._loadTargets result count: ${state.length}');
  }

  Future<void> addTarget(CountdownTarget target) async {
    debugPrint('[Provider] CountdownTargetsNotifier.addTarget called');
    await _db.insertCountdownTarget(target);
    state = [...state, target];
  }

  Future<void> updateTarget(CountdownTarget target) async {
    debugPrint('[Provider] CountdownTargetsNotifier.updateTarget called');
    await _db.updateCountdownTarget(target);
    state = state.map((t) => t.id == target.id ? target : t).toList();
  }

  Future<void> deleteTarget(String id) async {
    debugPrint('[Provider] CountdownTargetsNotifier.deleteTarget called: $id');
    await _db.deleteCountdownTarget(id);
    state = state.where((t) => t.id != id).toList();
  }

  Future<void> refresh() async {
    await _loadTargets();
  }
}