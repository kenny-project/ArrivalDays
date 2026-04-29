import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/database/database_helper.dart';
import '../../../core/utils/logger.dart';
import '../../../core/utils/countdown_utils.dart';
import '../../../models/countdown_target.dart';

final databaseHelperProvider = Provider<DatabaseHelper>((ref) {
  return DatabaseHelper.instance;
});

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
    final loaded = await _db.getAllCountdownTargets();
    final calculated = loaded.map((t) {
      final targetDate = CountdownUtils.calculateTargetDate(t.useDate, t.isLunarCalendar);
      return t.copyWith(targetDate: targetDate);
    }).toList();
    state = calculated;
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
