import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/utils/countdown_utils.dart';
import '../../../shared/providers/database_providers.dart';
import '../providers/clock_provider.dart';

class LifeTimerCard extends ConsumerWidget {
  const LifeTimerCard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final lifeTimer = ref.watch(lifeTimerProvider);
    final settings = ref.watch(userSettingsProvider);
    final retirementDate = ref.watch(retirementTimerProvider);
    final theme = Theme.of(context);

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
                  '人生定时器',
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
                '距离理想离开',
                CountdownUtils.calculateCountdown(lifeTimer!.targetDate!),
              ),
              const SizedBox(height: 8),
              if (settings != null)
                _buildElapsedRow(context, settings.birthDate),
            ] else
              Center(
                child: Text(
                  '设置你的理想离开日期',
                  style: theme.textTheme.bodyLarge,
                ),
              ),
            if (retirementDate != null) ...[
              const SizedBox(height: 8),
              _buildCountdownRow(
                context,
                '距离退休',
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
    final isOverdue = countdown.isOverdue;

    return Row(
      children: [
        Text(
          '$label: ',
          style: theme.textTheme.bodyMedium,
        ),
        Text(
          isOverdue
              ? '已过${countdown.toDisplayString()}'
              : '还差${countdown.toDisplayString()}',
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
    final elapsed = DateTime.now().difference(birthDate);
    final years = elapsed.inDays ~/ 365;
    final months = (elapsed.inDays % 365) ~/ 30;

    return Row(
      children: [
        Text(
          '已过: ',
          style: theme.textTheme.bodyMedium,
        ),
        Text(
          '${years}年${months}月',
          style: theme.textTheme.bodyLarge?.copyWith(
            fontWeight: FontWeight.bold,
            color: theme.colorScheme.secondary,
          ),
        ),
      ],
    );
  }
}