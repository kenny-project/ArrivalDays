import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'l10n/app_localizations.dart';
import 'core/theme/app_theme.dart';
import 'shared/providers/database_providers.dart';
import 'features/clock/screens/clock_screen.dart';
import 'features/clock/providers/clock_provider.dart';
import 'features/anniversary/screens/anniversary_list_screen.dart';
import 'features/wish/screens/wish_list_screen.dart';
import 'features/settings/screens/settings_screen.dart';

class ArrivalDaysApp extends ConsumerWidget {
  const ArrivalDaysApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(userSettingsProvider);
    final isDarkMode = settings?.isDarkMode ?? false;

    return MaterialApp(
      title: 'ArrivalDays',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: isDarkMode ? ThemeMode.dark : ThemeMode.light,
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [
        Locale('en'),
        Locale('zh'),
      ],
      locale: Locale(settings?.language ?? 'zh'),
      home: const MainScreen(),
    );
  }
}

class MainScreen extends ConsumerStatefulWidget {
  const MainScreen({super.key});

  @override
  ConsumerState<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends ConsumerState<MainScreen> with WidgetsBindingObserver {
  int _currentIndex = 0;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _startTimerIfNeeded();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _timer?.cancel();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _startTimerIfNeeded();
    } else if (state == AppLifecycleState.paused) {
      _stopTimer();
    }
  }

  void _startTimerIfNeeded() {
    if (_currentIndex == 0) {
      _timer?.cancel();
      _timer = Timer.periodic(const Duration(seconds: 1), (_) {
        ref.read(tickerProvider.notifier).state = DateTime.now();
      });
    }
  }

  void _stopTimer() {
    _timer?.cancel();
    _timer = null;
  }

  void _navigateToTab(int index) {
    setState(() {
      _currentIndex = index;
    });
    if (index == 0) {
      _startTimerIfNeeded();
    } else {
      _stopTimer();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: [
          const ClockScreen(
            onNavigateToAnniversary: null,
            onNavigateToWish: null,
          ),
          const AnniversaryListScreen(),
          const WishListScreen(),
          const SettingsScreen(),
        ],
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _currentIndex,
        onDestinationSelected: (index) {
          _navigateToTab(index);
        },
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.access_time),
            label: '时钟',
          ),
          NavigationDestination(
            icon: Icon(Icons.celebration),
            label: '纪念日',
          ),
          NavigationDestination(
            icon: Icon(Icons.favorite),
            label: '心愿',
          ),
          NavigationDestination(
            icon: Icon(Icons.settings),
            label: '设置',
          ),
        ],
      ),
    );
  }
}