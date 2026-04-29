import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../models/countdown_target.dart';
import '../../../shared/providers/countdown_targets_provider.dart';
import '../../../shared/widgets/countdown_display.dart';
import '../providers/wish_provider.dart';
import '../widgets/wish_form.dart';

class WishDetailScreen extends ConsumerWidget {
  final CountdownTarget target;

  const WishDetailScreen({super.key, required this.target});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final viewModel = ref.watch(wishViewModelProvider);

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
            onPressed: () => _showDeleteDialog(context, viewModel),
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
                        target.isCompleted
                            ? Icons.check_circle
                            : Icons.favorite,
                        size: 32,
                        color: target.isCompleted
                            ? Colors.green
                            : theme.colorScheme.primary,
                      ),
                      const SizedBox(width: 12),
                      Text(
                        target.name,
                        style: theme.textTheme.titleLarge,
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  if (target.targetDate != null) ...[
                    const Text('目标日期'),
                    const SizedBox(height: 8),
                    CountdownDisplay(targetDate: target.targetDate!),
                  ] else
                    const Text('无日期限制'),
                  const SizedBox(height: 16),
                  if (target.isCompleted && target.completedAt != null) ...[
                    Text(
                      '完成于: ${target.completedAt!.toString().split(' ')[0]}',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: Colors.green,
                      ),
                    ),
                    const SizedBox(height: 16),
                    OutlinedButton(
                      onPressed: () {
                        viewModel.reactivateWish(target.id);
                        Navigator.pop(context);
                      },
                      child: const Text('重新激活'),
                    ),
                  ] else
                    FilledButton(
                      onPressed: () {
                        viewModel.completeWish(target.id);
                        Navigator.pop(context);
                      },
                      child: const Text('标记完成'),
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
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (_) => WishForm(
        target: target,
        onSave: (updated) async {
          final success = await ref.read(countdownTargetsProvider.notifier).updateTarget(updated);
          if (success && context.mounted) {
            Navigator.pop(context);
          } else if (!success && context.mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('保存失败')),
            );
          }
          return success;
        },
      ),
    );
  }

  void _showDeleteDialog(BuildContext context, WishViewModel viewModel) {
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
              viewModel.deleteWish(target.id);
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