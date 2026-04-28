import 'package:flutter/material.dart';
import '../../core/utils/countdown_utils.dart';
import '../../models/countdown_target.dart';

class CountdownItem extends StatelessWidget {
  final CountdownTarget target;
  final VoidCallback? onTap;
  final VoidCallback? onComplete;
  final bool showCompleteButton;
  final bool isOverdue;

  const CountdownItem({
    super.key,
    required this.target,
    this.onTap,
    this.onComplete,
    this.showCompleteButton = false,
    this.isOverdue = false,
  });

  IconData get _icon {
    switch (target.type) {
      case CountdownTargetType.birthday:
        return Icons.cake;
      case CountdownTargetType.anniversary:
        return Icons.celebration;
      case CountdownTargetType.wish:
        return Icons.favorite;
      case CountdownTargetType.lifeTimer:
        return Icons.timer;
    }
  }

  String get _displayName {
    if (target.type == CountdownTargetType.birthday && target.relation != null) {
      return '${target.name} ${target.relation}';
    }
    return target.name;
  }

  String get _countdownText {
    if (target.targetDate == null) {
      return '无日期';
    }

    final displayTarget = target.isRecurring && target.type == CountdownTargetType.birthday
        ? CountdownUtils.getNextRecurringDate(target.targetDate!)
        : target.targetDate!;

    final countdown = CountdownUtils.calculateCountdown(displayTarget);

    if (target.type == CountdownTargetType.birthday) {
      final age = CountdownUtils.calculateAge(target.targetDate!);
      return '$age岁 ${countdown.isOverdue ? '已过' : '还差'}${countdown.toShortDisplayString()}';
    }

    return countdown.isOverdue
        ? '已过${countdown.toShortDisplayString()}'
        : '还差${countdown.toShortDisplayString()}';
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isBirthday = target.type == CountdownTargetType.birthday;

    return Dismissible(
      key: Key(target.id),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        color: Colors.red,
        child: const Icon(Icons.delete, color: Colors.white),
      ),
      onDismissed: (_) => onTap?.call(),
      child: ListTile(
        leading: Icon(_icon, color: isBirthday ? Colors.pink : theme.colorScheme.primary),
        title: Text(_displayName),
        subtitle: Text(
          _countdownText,
          style: TextStyle(
            color: isOverdue ? Colors.red : null,
          ),
        ),
        trailing: showCompleteButton && !target.isCompleted
            ? IconButton(
                icon: const Icon(Icons.check_circle_outline),
                onPressed: onComplete,
              )
            : null,
        onTap: onTap,
      ),
    );
  }
}