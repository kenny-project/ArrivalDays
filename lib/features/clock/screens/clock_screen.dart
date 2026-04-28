import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../shared/widgets/countdown_item.dart';
import '../providers/clock_provider.dart';
import '../widgets/life_timer_card.dart';
import '../widgets/clock_section_header.dart';

class ClockScreen extends ConsumerWidget {
  const ClockScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final anniversaries = ref.watch(anniversaryListProvider);
    final wishes = ref.watch(wishListProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('人生倒计时'),
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          ref.invalidate(clockTickProvider);
        },
        child: ListView(
          children: [
            const LifeTimerCard(),
            ClockSectionHeader(
              title: '纪念日',
              onSeeAllPressed: () {
                // Navigate to anniversary tab - handled by parent
              },
            ),
            if (anniversaries.isEmpty)
              const Padding(
                padding: EdgeInsets.all(32),
                child: Center(
                  child: Text('暂无纪念日'),
                ),
              )
            else
              ...anniversaries.take(3).map((target) => CountdownItem(
                    target: target,
                    isOverdue: target.targetDate != null &&
                        target.targetDate!.isBefore(DateTime.now()),
                  )),
            ClockSectionHeader(
              title: '心愿',
              onSeeAllPressed: () {
                // Navigate to wish tab - handled by parent
              },
            ),
            if (wishes.isEmpty)
              const Padding(
                padding: EdgeInsets.all(32),
                child: Center(
                  child: Text('暂无心愿'),
                ),
              )
            else
              ...wishes.take(3).map((target) => CountdownItem(
                    target: target,
                    showCompleteButton: true,
                  )),
            const SizedBox(height: 100),
          ],
        ),
      ),
    );
  }
}