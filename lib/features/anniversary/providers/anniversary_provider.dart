import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../models/countdown_target.dart';
import '../../../shared/providers/database_providers.dart';

final anniversaryViewModelProvider =
    Provider<AnniversaryViewModel>((ref) {
  return AnniversaryViewModel(ref);
});

class AnniversaryViewModel {
  final Ref _ref;

  AnniversaryViewModel(this._ref);

  List<CountdownTarget> get allAnniversaries {
    final targets = _ref.read(countdownTargetsProvider);
    return targets
        .where((t) => t.type == CountdownTargetType.anniversary || t.type == CountdownTargetType.birthday)
        .toList()
      ..sort((a, b) {
        if (a.targetDate == null) return 1;
        if (b.targetDate == null) return -1;
        return a.targetDate!.compareTo(b.targetDate!);
      });
  }

  List<CountdownTarget> get birthdays {
    return allAnniversaries.where((t) => t.type == CountdownTargetType.birthday).toList();
  }

  List<CountdownTarget> get regularAnniversaries {
    return allAnniversaries.where((t) => t.type == CountdownTargetType.anniversary).toList();
  }

  Future<void> addAnniversary(CountdownTarget target) async {
    await _ref.read(countdownTargetsProvider.notifier).addTarget(target);
  }

  Future<void> updateAnniversary(CountdownTarget target) async {
    await _ref.read(countdownTargetsProvider.notifier).updateTarget(target);
  }

  Future<void> deleteAnniversary(String id) async {
    await _ref.read(countdownTargetsProvider.notifier).deleteTarget(id);
  }
}