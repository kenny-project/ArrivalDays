import 'package:flutter/material.dart';
import '../../core/utils/countdown_utils.dart';
import '../../l10n/app_localizations.dart';
import '../../models/countdown_target.dart';

class CountdownItem extends StatelessWidget {
  final CountdownTarget target;
  final VoidCallback? onTap;
  final VoidCallback? onDelete;
  final VoidCallback? onComplete;
  final bool showCompleteButton;
  final bool showDeleteAction;
  final bool isOverdue;

  const CountdownItem({
    super.key,
    required this.target,
    this.onTap,
    this.onDelete,
    this.onComplete,
    this.showCompleteButton = false,
    this.showDeleteAction = true,
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

  String _formatDisplayDate(CountdownTarget target, AppLocalizations loc) {
    final date = target.useDate ?? target.targetDate;
    if (date == null) return '';

    final dateStr = '${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
    if (target.isLunarCalendar) {
      return '$dateStr${loc.lunarSuffix}';
    }
    return dateStr;
  }

  String _getCountdownText(AppLocalizations loc) {
    if (target.targetDate == null) {
      return loc.noDate;
    }

    final displayTarget = target.isRecurring && target.type == CountdownTargetType.birthday
        ? CountdownUtils.getNextRecurringDate(target.targetDate!)
        : target.targetDate!;

    final countdown = CountdownUtils.calculateCountdown(displayTarget);
    final cLoc = loc.countdownLoc;

    if (target.type == CountdownTargetType.birthday) {
      if (target.isLunarCalendar) {
        return '${countdown.isOverdue ? loc.elapsed : loc.daysUntilBirthday}${countdown.toMinimalDisplayString(loc: cLoc)}';
      } else {
        final age = CountdownUtils.calculateAge(target.targetDate!);
        return '${loc.thisYear}$age${loc.yearsOld} ${countdown.isOverdue ? loc.elapsed : loc.daysUntilBirthday}${countdown.toMinimalDisplayString(loc: cLoc)}';
      }
    }

    return countdown.isOverdue
        ? '${loc.elapsed}${countdown.toMinimalDisplayString(loc: cLoc)}'
        : '${loc.distance}${countdown.toMinimalDisplayString(loc: cLoc)}';
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final loc = AppLocalizations.of(context)!;
    final isBirthday = target.type == CountdownTargetType.birthday;
    final displayDate = _formatDisplayDate(target, loc);

    return Dismissible(
      key: Key(target.id),
      direction: showDeleteAction ? DismissDirection.endToStart : DismissDirection.none,
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        color: Colors.red,
        child: const Icon(Icons.delete, color: Colors.white),
      ),
      confirmDismiss: (_) async {
        if (onDelete != null) {
          onDelete!();
          return true;
        }
        return false;
      },
      child: ListTile(
        leading: Icon(_icon, color: isBirthday ? Colors.pink : theme.colorScheme.primary),
        title: Text(
          displayDate.isEmpty
              ? _displayName
              : '$_displayName（$displayDate）',
        ),
        subtitle: Text(
          _getCountdownText(loc),
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