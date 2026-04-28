import 'package:flutter/material.dart';

class ClockSectionHeader extends StatelessWidget {
  final String title;
  final VoidCallback? onSeeAllPressed;

  const ClockSectionHeader({
    super.key,
    required this.title,
    this.onSeeAllPressed,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: theme.textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          if (onSeeAllPressed != null)
            TextButton(
              onPressed: onSeeAllPressed,
              child: const Text('查看全部'),
            ),
        ],
      ),
    );
  }
}