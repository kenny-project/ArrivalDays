import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../models/countdown_target.dart';
import '../../../shared/widgets/countdown_item.dart';
import '../../../shared/widgets/empty_state.dart';
import '../../../shared/providers/countdown_targets_provider.dart';
import '../widgets/anniversary_form.dart';

class AnniversaryListScreen extends ConsumerStatefulWidget {
  const AnniversaryListScreen({super.key});

  @override
  ConsumerState<AnniversaryListScreen> createState() => _AnniversaryListScreenState();
}

class _AnniversaryListScreenState extends ConsumerState<AnniversaryListScreen> {
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    // debug: Log.i(LogTag.ui, 'AnniversaryListScreen initState');
  }

  @override
  void dispose() {
    // debug: Log.i(LogTag.ui, 'AnniversaryListScreen disposed');
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final targets = ref.watch(countdownTargetsProvider);
    final anniversaries = targets
        .where((t) => t.type == CountdownTargetType.anniversary || t.type == CountdownTargetType.birthday)
        .toList()
      ..sort((a, b) {
        if (a.targetDate == null) return 1;
        if (b.targetDate == null) return -1;
        return a.targetDate!.compareTo(b.targetDate!);
      });

    return Scaffold(
      appBar: AppBar(
        title: const Text('纪念日'),
      ),
      body: anniversaries.isEmpty
          ? EmptyState(
              message: '还没有纪念日，添加第一个吧',
              onAddPressed: () => _showAddDialog(context),
              buttonText: '添加纪念日',
            )
          : ListView.builder(
              controller: _scrollController,
              itemCount: anniversaries.length,
              itemBuilder: (context, index) {
                final target = anniversaries[index];
                final isOverdue = target.targetDate != null &&
                    target.targetDate!.isBefore(DateTime.now());

                return CountdownItem(
                  target: target,
                  isOverdue: isOverdue,
                  onTap: () => _showEditDialog(context, target),
                  onDelete: () {
                    ref.read(countdownTargetsProvider.notifier).deleteTarget(target.id);
                  },
                );
              },
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddDialog(context),
        child: const Icon(Icons.add),
      ),
    );
  }

  void _showAddDialog(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (_) => AnniversaryForm(
        onSave: (target) async {
          final success = await ref.read(countdownTargetsProvider.notifier).addTarget(target);
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

  void _showEditDialog(BuildContext context, CountdownTarget target) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (_) => AnniversaryForm(
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
}