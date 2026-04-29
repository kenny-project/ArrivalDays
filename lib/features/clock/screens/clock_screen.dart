import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/utils/logger.dart';
import '../../../shared/widgets/countdown_item.dart';
import '../../../shared/providers/database_providers.dart';
import '../providers/clock_provider.dart';
import '../widgets/life_timer_card.dart';
import '../widgets/clock_section_header.dart';

class ClockScreen extends ConsumerStatefulWidget {
  final VoidCallback? onNavigateToAnniversary;
  final VoidCallback? onNavigateToWish;

  const ClockScreen({
    super.key,
    this.onNavigateToAnniversary,
    this.onNavigateToWish,
  });

  @override
  ConsumerState<ClockScreen> createState() => _ClockScreenState();
}

class _ClockScreenState extends ConsumerState<ClockScreen> {
  @override
  void initState() {
    super.initState();
    _startTimer();
  }

  void _startTimer() {
    Future.delayed(const Duration(seconds: 1), () {
      if (mounted) {
        final now = DateTime.now();
        ref.read(tickerProvider.notifier).state = now;
        Log.i(LogTag.ui, 'ticker updated: $now');
        _startTimer();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final ticker = ref.watch(tickerProvider);
    Log.i(LogTag.ui, 'ClockScreen build, ticker: $ticker');
    final anniversaries = ref.watch(anniversaryListProvider);
    final wishes = ref.watch(wishListProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('人生倒计时'),
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          ref.invalidate(countdownTargetsProvider);
        },
        child: ListView(
          children: [
            LifeTimerCard(),
            ClockSectionHeader(
              title: '纪念日',
              onSeeAllPressed: widget.onNavigateToAnniversary,
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
                    showDeleteAction: false,
                  )),
            ClockSectionHeader(
              title: '心愿',
              onSeeAllPressed: widget.onNavigateToWish,
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
                    showDeleteAction: false,
                  )),
            const SizedBox(height: 100),
          ],
        ),
      ),
    );
  }
}