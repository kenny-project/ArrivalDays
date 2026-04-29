import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../models/countdown_target.dart';
import 'user_settings_provider.dart';
import '../../features/clock/providers/ticker_provider.dart';

final lifeTimerProvider = Provider<CountdownTarget?>((ref) {
  ref.watch(tickerProvider);
  final settings = ref.watch(userSettingsProvider);
  if (settings == null) return null;

  final leavingDate = DateTime(
    settings.birthDate.year + settings.lifeExpectancy,
    settings.birthDate.month,
    settings.birthDate.day,
  );
  return CountdownTarget(
    id: 'life_timer',
    name: '理想离开',
    targetDate: leavingDate,
    type: CountdownTargetType.lifeTimer,
    createdAt: DateTime.now(),
    updatedAt: DateTime.now(),
  );
});
