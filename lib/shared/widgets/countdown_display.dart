import 'package:flutter/material.dart';
import '../../core/utils/countdown_utils.dart';

class CountdownDisplay extends StatelessWidget {
  final DateTime targetDate;
  final bool isRecurring;
  final DateTime? recurringBaseDate;
  final TextStyle? style;
  final bool showSeconds;

  const CountdownDisplay({
    super.key,
    required this.targetDate,
    this.isRecurring = false,
    this.recurringBaseDate,
    this.style,
    this.showSeconds = true,
  });

  @override
  Widget build(BuildContext context) {
    final displayTarget = isRecurring && recurringBaseDate != null
        ? CountdownUtils.getNextRecurringDate(recurringBaseDate!)
        : targetDate;

    final countdown = CountdownUtils.calculateCountdown(displayTarget);
    final theme = Theme.of(context);

    return Text(
      countdown.isOverdue
          ? '已过去${countdown.toMinimalDisplayString(showSeconds: showSeconds)}'
          : '距离${countdown.toMinimalDisplayString(showSeconds: showSeconds)}',
      style: style ?? theme.textTheme.bodyMedium?.copyWith(
        color: countdown.isOverdue ? Colors.red : null,
      ),
    );
  }
}