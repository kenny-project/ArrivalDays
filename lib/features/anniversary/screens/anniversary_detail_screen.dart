import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/utils/countdown_utils.dart';
import '../../../models/countdown_target.dart';
import '../../../shared/widgets/countdown_display.dart';
import '../providers/anniversary_provider.dart';
import '../widgets/anniversary_form.dart';

class AnniversaryDetailScreen extends ConsumerWidget {
  final CountdownTarget target;

  const AnniversaryDetailScreen({super.key, required this.target});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(target.name),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () => _showEditDialog(context, ref),
          ),
          IconButton(
            icon: const Icon(Icons.delete),
            onPressed: () => _showDeleteDialog(context, ref),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        target.type == CountdownTargetType.birthday
                            ? Icons.cake
                            : Icons.celebration,
                        size: 32,
                        color: theme.colorScheme.primary,
                      ),
                      const SizedBox(width: 12),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            target.name,
                            style: theme.textTheme.titleLarge,
                          ),
                          if (target.relation != null)
                            Text(
                              target.relation!,
                              style: theme.textTheme.bodyMedium?.copyWith(
                                color: theme.colorScheme.outline,
                              ),
                            ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  if (target.targetDate != null) ...[
                    if (target.type == CountdownTargetType.birthday) ...[
                      Text(
                        '年龄: ${CountdownUtils.calculateAge(target.targetDate!)}岁',
                        style: theme.textTheme.bodyLarge,
                      ),
                      const SizedBox(height: 8),
                    ],
                    CountdownDisplay(
                      targetDate: target.targetDate!,
                      isRecurring: target.isRecurring,
                      recurringBaseDate: target.targetDate,
                    ),
                  ],
                  const SizedBox(height: 16),
                  SwitchListTile(
                    title: const Text('每年重复'),
                    value: target.isRecurring,
                    onChanged: null,
                  ),
                  SwitchListTile(
                    title: const Text('通知提醒'),
                    value: target.hasNotification,
                    onChanged: null,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showEditDialog(BuildContext context, WidgetRef ref) {
    final viewModel = ref.read(anniversaryViewModelProvider);
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (_) => AnniversaryForm(
        target: target,
        onSave: (updated) {
          viewModel.updateAnniversary(updated);
          Navigator.pop(context);
        },
      ),
    );
  }

  void _showDeleteDialog(BuildContext context, WidgetRef ref) {
    final viewModel = ref.read(anniversaryViewModelProvider);
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('删除确认'),
        content: Text('确定要删除 "${target.name}" 吗？'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('取消'),
          ),
          TextButton(
            onPressed: () {
              viewModel.deleteAnniversary(target.id);
              Navigator.pop(context);
              Navigator.pop(context);
            },
            child: const Text('删除', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}