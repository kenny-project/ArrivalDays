import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../models/countdown_target.dart';
import '../../../shared/providers/database_providers.dart';

final wishViewModelProvider = Provider<WishViewModel>((ref) {
  return WishViewModel(ref);
});

class WishViewModel {
  final Ref _ref;

  WishViewModel(this._ref);

  List<CountdownTarget> get uncompletedWishes {
    final targets = _ref.read(countdownTargetsProvider);
    return targets
        .where((t) => t.type == CountdownTargetType.wish && !t.isCompleted)
        .toList()
      ..sort((a, b) {
        if (a.targetDate == null && b.targetDate == null) return 0;
        if (a.targetDate == null) return 1;
        if (b.targetDate == null) return -1;
        return a.targetDate!.compareTo(b.targetDate!);
      });
  }

  List<CountdownTarget> get completedWishes {
    final targets = _ref.read(countdownTargetsProvider);
    return targets
        .where((t) => t.type == CountdownTargetType.wish && t.isCompleted)
        .toList()
      ..sort((a, b) {
        if (a.completedAt == null) return 1;
        if (b.completedAt == null) return -1;
        return b.completedAt!.compareTo(a.completedAt!);
      });
  }

  Future<void> addWish(CountdownTarget wish) async {
    await _ref.read(countdownTargetsProvider.notifier).addTarget(wish);
  }

  Future<void> updateWish(CountdownTarget wish) async {
    await _ref.read(countdownTargetsProvider.notifier).updateTarget(wish);
  }

  Future<void> completeWish(String id) async {
    final targets = _ref.read(countdownTargetsProvider);
    final wish = targets.firstWhere((t) => t.id == id);
    await _ref.read(countdownTargetsProvider.notifier).updateTarget(
      wish.copyWith(
        isCompleted: true,
        completedAt: DateTime.now(),
        updatedAt: DateTime.now(),
      ),
    );
  }

  Future<void> reactivateWish(String id) async {
    final targets = _ref.read(countdownTargetsProvider);
    final wish = targets.firstWhere((t) => t.id == id);
    await _ref.read(countdownTargetsProvider.notifier).updateTarget(
      wish.copyWith(
        isCompleted: false,
        completedAt: null,
        updatedAt: DateTime.now(),
      ),
    );
  }

  Future<void> deleteWish(String id) async {
    await _ref.read(countdownTargetsProvider.notifier).deleteTarget(id);
  }
}