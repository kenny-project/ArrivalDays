import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../shared/widgets/countdown_item.dart';
import '../../../shared/widgets/empty_state.dart';
import '../providers/wish_provider.dart';
import '../widgets/wish_form.dart';
import 'wish_detail_screen.dart';

class WishListScreen extends ConsumerStatefulWidget {
  const WishListScreen({super.key});

  @override
  ConsumerState<WishListScreen> createState() => _WishListScreenState();
}

class _WishListScreenState extends ConsumerState<WishListScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
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
      itemCount: wishes.length,
      itemBuilder: (context, index) {
        final target = wishes[index];
        final isOverdue = target.targetDate != null &&
            target.targetDate!.isBefore(DateTime.now());

        return CountdownItem(
          target: target,
          isOverdue: isOverdue,
          showCompleteButton: true,
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => WishDetailScreen(target: target),
              ),
            );
          },
          onComplete: () {
            viewModel.completeWish(target.id);
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
      itemCount: wishes.length,
      itemBuilder: (context, index) {
        final target = wishes[index];

        return ListTile(
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
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => WishDetailScreen(target: target),
              ),
            );
          },
        );
      },
    );
  }

  void _showAddDialog(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (_) => WishForm(
        onSave: (target) {
          ref.read(wishViewModelProvider).addWish(target);
          Navigator.pop(context);
        },
      ),
    );
  }
}