import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../l10n/app_localizations.dart';
import '../../../shared/widgets/countdown_item.dart';
import '../../../shared/providers/countdown_targets_provider.dart';
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
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    ref.watch(tickerProvider); // watch ticker to trigger rebuild
    final loc = AppLocalizations.of(context)!;
    final anniversaries = ref.watch(anniversaryListProvider);
    final wishes = ref.watch(wishListProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(loc.appTitle),
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          ref.invalidate(countdownTargetsProvider);
        },
        child: ListView(
          children: [
            LifeTimerCard(),
            ClockSectionHeader(
              title: loc.anniversary,
              onSeeAllPressed: widget.onNavigateToAnniversary,
            ),
            if (anniversaries.isEmpty)
              Padding(
                padding: const EdgeInsets.all(32),
                child: Center(
                  child: Text(loc.noAnniversary),
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
              title: loc.wish,
              onSeeAllPressed: widget.onNavigateToWish,
            ),
            if (wishes.isEmpty)
              Padding(
                padding: const EdgeInsets.all(32),
                child: Center(
                  child: Text(loc.noWish),
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