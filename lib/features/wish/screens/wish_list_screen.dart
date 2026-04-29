import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../models/countdown_target.dart';
import '../../../shared/widgets/countdown_item.dart';
import '../../../shared/widgets/empty_state.dart';
import '../../../shared/providers/database_providers.dart';
import '../providers/wish_provider.dart';
import '../widgets/wish_form.dart';

class WishListScreen extends ConsumerStatefulWidget {
  const WishListScreen({super.key});

  @override
  ConsumerState<WishListScreen> createState() => _WishListScreenState();
}

class _WishListScreenState extends ConsumerState<WishListScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    // debug: _tabController.addListener(_onTabChanged);
  }

  // debug: void _onTabChanged() { Log.i(LogTag.ui, 'WishListScreen TabController changed: ${_tabController.index}'); }

  @override
  void dispose() {
    // debug: Log.i(LogTag.ui, 'WishListScreen disposed');
    _scrollController.dispose();
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final viewModel = ref.watch(wishViewModelProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('心愿'),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: '未完成'),
            Tab(text: '已完成'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildUncompletedList(viewModel),
          _buildCompletedList(viewModel),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddDialog(context),
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildUncompletedList(WishViewModel viewModel) {
    final wishes = viewModel.uncompletedWishes;

    if (wishes.isEmpty) {
      return EmptyState(
        message: '还没有心愿，添加第一个吧',
        onAddPressed: () => _showAddDialog(context),
        buttonText: '添加心愿',
      );
    }

    return ListView.builder(
      controller: _scrollController,
      itemCount: wishes.length,
      itemBuilder: (context, index) {
        final target = wishes[index];
        final isOverdue = target.targetDate != null &&
            target.targetDate!.isBefore(DateTime.now());

        return CountdownItem(
          target: target,
          isOverdue: isOverdue,
          showCompleteButton: true,
          onTap: () => _showEditDialog(context, target),
          onComplete: () {
            viewModel.completeWish(target.id);
          },
          onDelete: () {
            viewModel.deleteWish(target.id);
          },
        );
      },
    );
  }

  Widget _buildCompletedList(WishViewModel viewModel) {
    final wishes = viewModel.completedWishes;

    if (wishes.isEmpty) {
      return const EmptyState(message: '暂无已完成的心愿');
    }

    return ListView.builder(
      controller: _scrollController,
      itemCount: wishes.length,
      itemBuilder: (context, index) {
        final target = wishes[index];

        return Dismissible(
          key: Key(target.id),
          direction: DismissDirection.endToStart,
          background: Container(
            alignment: Alignment.centerRight,
            padding: const EdgeInsets.only(right: 20),
            color: Colors.red,
            child: const Icon(Icons.delete, color: Colors.white),
          ),
          onDismissed: (_) => viewModel.deleteWish(target.id),
          child: ListTile(
            leading: const Icon(Icons.check_circle, color: Colors.green),
            title: Text(target.name),
            subtitle: target.completedAt != null
                ? Text('完成于: ${target.completedAt!.toString().split(' ')[0]}')
                : null,
            trailing: TextButton(
              onPressed: () {
                viewModel.reactivateWish(target.id);
              },
              child: const Text('重新激活'),
            ),
            onTap: () => _showEditDialog(context, target),
          ),
        );
      },
    );
  }

  void _showAddDialog(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (_) => WishForm(
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
}