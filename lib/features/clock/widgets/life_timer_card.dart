import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/utils/countdown_utils.dart';
import '../../../l10n/app_localizations.dart';
import '../../../shared/providers/user_settings_provider.dart';
import '../../../shared/providers/life_timer_provider.dart';
import '../providers/clock_provider.dart';

class LifeTimerCard extends ConsumerWidget {
  const LifeTimerCard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final lifeTimer = ref.watch(lifeTimerProvider);
    final settings = ref.watch(userSettingsProvider);
    final retirementDate = ref.watch(retirementTimerProvider);
    final theme = Theme.of(context);
    final loc = AppLocalizations.of(context)!;

    return Card(
      margin: const EdgeInsets.all(16),
      child: Container(
        height: MediaQuery.of(context).size.height * 0.25,
        width: double.infinity,
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.timer, color: theme.colorScheme.primary),
                const SizedBox(width: 8),
                Text(
                  loc.lifeTimer,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const Spacer(),
            if (lifeTimer?.targetDate != null) ...[
              _buildCountdownRow(
                context,
                loc.distanceFromLeaving,
                CountdownUtils.calculateCountdown(lifeTimer!.targetDate!),
              ),
              const SizedBox(height: 8),
              if (settings != null)
                _buildElapsedRow(context, settings.birthDate),
            ] else
              Center(
                child: Text(
                  loc.setIdealLeaveDate,
                  style: theme.textTheme.bodyLarge,
                ),
              ),
            if (retirementDate != null) ...[
              const SizedBox(height: 8),
              _buildCountdownRow(
                context,
                loc.distanceFromRetirement,
                CountdownUtils.calculateCountdown(retirementDate),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildCountdownRow(BuildContext context, String label, CountdownDuration countdown) {
    final theme = Theme.of(context);
    final loc = AppLocalizations.of(context)!;
    final isOverdue = countdown.isOverdue;

    return Row(
      children: [
        Text(
          '$label: ',
          style: theme.textTheme.bodyMedium,
        ),
        Text(
          isOverdue
              ? '${loc.elapsed}${countdown.toDisplayString(loc: loc.countdownLoc)}'
              : countdown.toDisplayString(loc: loc.countdownLoc),
          style: theme.textTheme.bodyLarge?.copyWith(
            fontWeight: FontWeight.bold,
            color: isOverdue ? Colors.red : theme.colorScheme.primary,
          ),
        ),
      ],
    );
  }

  Widget _buildElapsedRow(BuildContext context, DateTime birthDate) {
    final theme = Theme.of(context);
    final loc = AppLocalizations.of(context)!;
    final elapsed = DateTime.now().difference(birthDate);
    final years = elapsed.inDays ~/ 365;
    final months = (elapsed.inDays % 365) ~/ 30;
    final hours = elapsed.inHours % 24;
    final minutes = elapsed.inMinutes % 60;

    return Row(
      children: [
        Text(
          '${loc.elapsed}: ',
          style: theme.textTheme.bodyMedium,
        ),
        Text(
          '$years${loc.years}$months${loc.months}${hours.toString().padLeft(2, '0')}${loc.hours}${minutes.toString().padLeft(2, '0')}${loc.minutes}',
          style: theme.textTheme.bodyLarge?.copyWith(
            fontWeight: FontWeight.bold,
            color: theme.colorScheme.secondary,
          ),
        ),
      ],
    );
  }
}