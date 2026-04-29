import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../models/countdown_target.dart';
import '../../../shared/providers/user_settings_provider.dart';
import '../../../shared/providers/countdown_targets_provider.dart';
import 'ticker_provider.dart';

export 'ticker_provider.dart';

final retirementTimerProvider = Provider<DateTime?>((ref) {
  ref.watch(tickerProvider);
  final settings = ref.watch(userSettingsProvider);
  return settings?.retirementDate;
});

final anniversaryListProvider = Provider<List<CountdownTarget>>((ref) {
  ref.watch(tickerProvider);
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
  ref.watch(tickerProvider);
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