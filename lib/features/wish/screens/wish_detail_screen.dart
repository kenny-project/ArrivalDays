import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../l10n/app_localizations.dart';
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
    final loc = AppLocalizations.of(context)!;
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
                    Text(loc.targetDate),
                    const SizedBox(height: 8),
                    CountdownDisplay(targetDate: target.targetDate!),
                  ] else
                    Text(loc.noDateLimit),
                  const SizedBox(height: 16),
                  if (target.isCompleted && target.completedAt != null) ...[
                    Text(
                      '${loc.completedOn}: ${target.completedAt!.toString().split(' ')[0]}',
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
                      child: Text(loc.reactivate),
                    ),
                  ] else
                    FilledButton(
                      onPressed: () {
                        viewModel.completeWish(target.id);
                        Navigator.pop(context);
                      },
                      child: Text(loc.markComplete),
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
    final loc = AppLocalizations.of(context)!;
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
              SnackBar(content: Text(loc.saveFailed)),
            );
          }
          return success;
        },
      ),
    );
  }

  void _showDeleteDialog(BuildContext context, WishViewModel viewModel) {
    final loc = AppLocalizations.of(context)!;
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(loc.deleteConfirm),
        content: Text('${loc.deleteConfirmDesc} "${target.name}" ?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(loc.cancel),
          ),
          TextButton(
            onPressed: () {
              viewModel.deleteWish(target.id);
              Navigator.pop(context);
              Navigator.pop(context);
            },
            child: Text(loc.delete, style: const TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}