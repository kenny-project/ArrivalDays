import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../models/countdown_target.dart';
import '../../../shared/providers/database_providers.dart';

final clockTickProvider = StreamProvider<DateTime>((ref) {
  return Stream.periodic(const Duration(seconds: 1), (_) => DateTime.now());
});

final lifeTimerProvider = Provider<CountdownTarget?>((ref) {
  ref.watch(clockTickProvider);
  final targets = ref.watch(countdownTargetsProvider);
  try {
    return targets.firstWhere((t) => t.type == CountdownTargetType.lifeTimer);
  } catch (_) {
    return null;
  }
});

final retirementTimerProvider = Provider<DateTime?>((ref) {
  final settings = ref.watch(userSettingsProvider);
  return settings?.retirementDate;
});

final anniversaryListProvider = Provider<List<CountdownTarget>>((ref) {
  ref.watch(clockTickProvider);
  final targets = ref.watch(countdownTargetsProvider);
  return targets
      .where((t) => t.type == CountdownTargetType.anniversary || t.type == CountdownTargetType.birthday)
      .toList()
    ..sort((a, b) {
      if (a.targetDate == null) return 1;
      if (b.targetDate == null) return -1;
      return a.targetDate!.compareTo(b.targetDate!);
    });
});

final wishListProvider = Provider<List<CountdownTarget>>((ref) {
  ref.watch(clockTickProvider);
  final targets = ref.watch(countdownTargetsProvider);
  return targets
      .where((t) => t.type == CountdownTargetType.wish && !t.isCompleted)
      .toList()
    ..sort((a, b) {
      if (a.targetDate == null && b.targetDate == null) return 0;
      if (a.targetDate == null) return 1;
      if (b.targetDate == null) return -1;
      return a.targetDate!.compareTo(b.targetDate!);
    });
});