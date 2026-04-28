import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../models/countdown_target.dart';
import '../../../shared/widgets/countdown_item.dart';
import '../../../shared/widgets/empty_state.dart';
import '../../../shared/providers/database_providers.dart';
import '../widgets/anniversary_form.dart';
import 'anniversary_detail_screen.dart';

class AnniversaryListScreen extends ConsumerWidget {
  const AnniversaryListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
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
              onAddPressed: () => _showAddDialog(context, ref),
              buttonText: '添加纪念日',
            )
          : ListView.builder(
              itemCount: anniversaries.length,
              itemBuilder: (context, index) {
                final target = anniversaries[index];
                final isOverdue = target.targetDate != null &&
                    target.targetDate!.isBefore(DateTime.now());

                return CountdownItem(
                  target: target,
                  isOverdue: isOverdue,
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => AnniversaryDetailScreen(target: target),
                      ),
                    );
                  },
                );
              },
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddDialog(context, ref),
        child: const Icon(Icons.add),
      ),
    );
  }

  void _showAddDialog(BuildContext context, WidgetRef ref) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (_) => AnniversaryForm(
        onSave: (target) {
          ref.read(countdownTargetsProvider.notifier).addTarget(target);
          Navigator.pop(context);
        },
      ),
    );
  }
}