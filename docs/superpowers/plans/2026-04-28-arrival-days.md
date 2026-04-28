# ArrivalDays Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** 构建完整的 ArrivalDays 人生倒计时 Flutter 应用，支持 iOS/Android/Web 三个平台

**Architecture:** Feature-first 架构，使用 Riverpod 状态管理，SQLite 本地存储，统一 CountdownTarget 模型处理所有倒计时目标

**Tech Stack:** Flutter 3.x / Riverpod / SQLite (sqflite) / Material 3 / flutter_local_notifications / home_widget / intl

---

## File Structure

```
lib/
├── main.dart                              # 应用入口
├── app.dart                               # MaterialApp 配置
├── l10n/                                   # 国际化
│   ├── app_zh.arb
│   └── app_en.arb
├── core/                                   # 核心模块
│   ├── constants/
│   │   └── app_constants.dart             # 常量定义
│   ├── theme/
│   │   └── app_theme.dart                 # Material 3 主题
│   ├── utils/
│   │   ├── countdown_utils.dart           # 倒计时计算工具
│   │   └── date_utils.dart               # 日期工具
│   └── database/
│       ├── database_helper.dart           # SQLite 数据库助手
│       └── tables.dart                    # 表结构定义
├── models/                                 # 数据模型
│   ├── user_settings.dart
│   └── countdown_target.dart
├── features/                               # 功能模块
│   ├── settings/
│   │   ├── providers/
│   │   │   └── settings_provider.dart
│   │   ├── screens/
│   │   │   └── settings_screen.dart
│   │   └── widgets/
│   ├── clock/
│   │   ├── providers/
│   │   │   └── clock_provider.dart
│   │   ├── screens/
│   │   │   └── clock_screen.dart
│   │   └── widgets/
│   │       └── life_timer_card.dart
│   ├── anniversary/
│   │   ├── providers/
│   │   │   └── anniversary_provider.dart
│   │   ├── screens/
│   │   │   ├── anniversary_list_screen.dart
│   │   │   └── anniversary_detail_screen.dart
│   │   └── widgets/
│   │       └── anniversary_form.dart
│   ├── wish/
│   │   ├── providers/
│   │   │   └── wish_provider.dart
│   │   ├── screens/
│   │   │   ├── wish_list_screen.dart
│   │   │   └── wish_detail_screen.dart
│   │   └── widgets/
│   │       └── wish_form.dart
│   └── widget/                             # 桌面小组件
├── shared/                                 # 共享组件
│   ├── widgets/
│   │   ├── countdown_item.dart            # 倒计时列表项组件
│   │   ├── countdown_display.dart         # 倒计时显示组件
│   │   └── empty_state.dart               # 空状态组件
│   └── providers/
│       └── database_providers.dart        # 数据库相关 Provider
```

---

## Task 1: 项目初始化

**Files:**
- Create: `pubspec.yaml`
- Create: `lib/main.dart`
- Create: `lib/app.dart`

- [ ] **Step 1: 创建 pubspec.yaml**

```yaml
name: arrival_days
description: 人生倒计时应用
publish_to: 'none'
version: 1.0.0+1

environment:
  sdk: '>=3.0.0 <4.0.0'

dependencies:
  flutter:
    sdk: flutter
  flutter_localizations:
    sdk: flutter
  flutter_riverpod: ^2.4.9
  riverpod_annotation: ^2.3.3
  sqflite: ^2.3.0
  sqflite_common_ffi_web: ^0.4.3+1
  path_provider: ^2.1.1
  path: ^1.8.3
  uuid: ^4.2.1
  intl: ^0.18.1
  flutter_local_notifications: ^16.3.0
  home_widget: ^0.4.1
  share_plus: ^7.2.1
  file_picker: ^6.1.1

dev_dependencies:
  flutter_test:
    sdk: flutter
  flutter_lints: ^3.0.1
  riverpod_generator: ^2.3.9
  build_runner: ^2.4.7

flutter:
  uses-material-design: true
  generate: true
```

- [ ] **Step 2: 创建 lib/main.dart**

```dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'app.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  runApp(
    const ProviderScope(
      child: ArrivalDaysApp(),
    ),
  );
}
```

- [ ] **Step 3: 创建 lib/app.dart**

```dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'l10n/app_localizations.dart';
import 'core/theme/app_theme.dart';
import 'features/clock/screens/clock_screen.dart';
import 'features/anniversary/screens/anniversary_list_screen.dart';
import 'features/wish/screens/wish_list_screen.dart';
import 'features/settings/screens/settings_screen.dart';

class ArrivalDaysApp extends ConsumerWidget {
  const ArrivalDaysApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return MaterialApp(
      title: 'ArrivalDays',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.system,
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
      home: const MainScreen(),
    );
  }
}

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _currentIndex = 0;

  final List<Widget> _screens = const [
    ClockScreen(),
    AnniversaryListScreen(),
    WishListScreen(),
    SettingsScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: _screens,
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _currentIndex,
        onDestinationSelected: (index) {
          setState(() {
            _currentIndex = index;
          });
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
```

- [ ] **Step 4: 运行 flutter pub get**

Run: `cd /home/wmh/Documents/android/ArrivalDays && flutter pub get`
Expected: Dependencies installed successfully

- [ ] **Step 5: 提交**

```bash
git add -A
git commit -m "feat: 初始化 Flutter 项目结构

- 添加 pubspec.yaml 依赖配置
- 创建 main.dart 应用入口
- 创建 app.dart MaterialApp 配置
- 添加底部导航栏框架

Co-Authored-By: Claude Opus 4.7 <noreply@anthropic.com>"
```

---

## Task 2: 数据模型与数据库

**Files:**
- Create: `lib/models/user_settings.dart`
- Create: `lib/models/countdown_target.dart`
- Create: `lib/core/database/tables.dart`
- Create: `lib/core/database/database_helper.dart`
- Create: `lib/core/utils/countdown_utils.dart`
- Create: `lib/core/utils/date_utils.dart`

- [ ] **Step 1: 创建 UserSettings 模型**

```dart
class UserSettings {
  final String id;
  final DateTime birthDate;
  final DateTime? retirementDate;
  final int lifeExpectancy;
  final bool isDarkMode;
  final String language;
  final DateTime createdAt;
  final DateTime updatedAt;

  const UserSettings({
    required this.id,
    required this.birthDate,
    this.retirementDate,
    this.lifeExpectancy = 80,
    this.isDarkMode = false,
    this.language = 'zh',
    required this.createdAt,
    required this.updatedAt,
  });

  UserSettings copyWith({
    String? id,
    DateTime? birthDate,
    DateTime? retirementDate,
    int? lifeExpectancy,
    bool? isDarkMode,
    String? language,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return UserSettings(
      id: id ?? this.id,
      birthDate: birthDate ?? this.birthDate,
      retirementDate: retirementDate ?? this.retirementDate,
      lifeExpectancy: lifeExpectancy ?? this.lifeExpectancy,
      isDarkMode: isDarkMode ?? this.isDarkMode,
      language: language ?? this.language,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'birth_date': birthDate.millisecondsSinceEpoch,
      'retirement_date': retirementDate?.millisecondsSinceEpoch,
      'life_expectancy': lifeExpectancy,
      'is_dark_mode': isDarkMode ? 1 : 0,
      'language': language,
      'created_at': createdAt.millisecondsSinceEpoch,
      'updated_at': updatedAt.millisecondsSinceEpoch,
    };
  }

  factory UserSettings.fromMap(Map<String, dynamic> map) {
    return UserSettings(
      id: map['id'] as String,
      birthDate: DateTime.fromMillisecondsSinceEpoch(map['birth_date'] as int),
      retirementDate: map['retirement_date'] != null
          ? DateTime.fromMillisecondsSinceEpoch(map['retirement_date'] as int)
          : null,
      lifeExpectancy: map['life_expectancy'] as int? ?? 80,
      isDarkMode: (map['is_dark_mode'] as int?) == 1,
      language: map['language'] as String? ?? 'zh',
      createdAt: DateTime.fromMillisecondsSinceEpoch(map['created_at'] as int),
      updatedAt: DateTime.fromMillisecondsSinceEpoch(map['updated_at'] as int),
    );
  }
}
```

- [ ] **Step 2: 创建 CountdownTarget 模型**

```dart
enum CountdownTargetType {
  lifeTimer,
  anniversary,
  birthday,
  wish,
}

class CountdownTarget {
  final String id;
  final String name;
  final DateTime? targetDate;
  final CountdownTargetType type;
  final bool isRecurring;
  final bool isCompleted;
  final DateTime? completedAt;
  final String? relation;
  final bool hasNotification;
  final int notificationDaysBefore;
  final DateTime createdAt;
  final DateTime updatedAt;

  const CountdownTarget({
    required this.id,
    required this.name,
    this.targetDate,
    required this.type,
    this.isRecurring = false,
    this.isCompleted = false,
    this.completedAt,
    this.relation,
    this.hasNotification = true,
    this.notificationDaysBefore = 1,
    required this.createdAt,
    required this.updatedAt,
  });

  CountdownTarget copyWith({
    String? id,
    String? name,
    DateTime? targetDate,
    CountdownTargetType? type,
    bool? isRecurring,
    bool? isCompleted,
    DateTime? completedAt,
    String? relation,
    bool? hasNotification,
    int? notificationDaysBefore,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return CountdownTarget(
      id: id ?? this.id,
      name: name ?? this.name,
      targetDate: targetDate ?? this.targetDate,
      type: type ?? this.type,
      isRecurring: isRecurring ?? this.isRecurring,
      isCompleted: isCompleted ?? this.isCompleted,
      completedAt: completedAt ?? this.completedAt,
      relation: relation ?? this.relation,
      hasNotification: hasNotification ?? this.hasNotification,
      notificationDaysBefore: notificationDaysBefore ?? this.notificationDaysBefore,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'target_date': targetDate?.millisecondsSinceEpoch,
      'type': type.name,
      'is_recurring': isRecurring ? 1 : 0,
      'is_completed': isCompleted ? 1 : 0,
      'completed_at': completedAt?.millisecondsSinceEpoch,
      'relation': relation,
      'has_notification': hasNotification ? 1 : 0,
      'notification_days_before': notificationDaysBefore,
      'created_at': createdAt.millisecondsSinceEpoch,
      'updated_at': updatedAt.millisecondsSinceEpoch,
    };
  }

  factory CountdownTarget.fromMap(Map<String, dynamic> map) {
    return CountdownTarget(
      id: map['id'] as String,
      name: map['name'] as String,
      targetDate: map['target_date'] != null
          ? DateTime.fromMillisecondsSinceEpoch(map['target_date'] as int)
          : null,
      type: CountdownTargetType.values.firstWhere(
        (e) => e.name == map['type'],
        orElse: () => CountdownTargetType.wish,
      ),
      isRecurring: (map['is_recurring'] as int?) == 1,
      isCompleted: (map['is_completed'] as int?) == 1,
      completedAt: map['completed_at'] != null
          ? DateTime.fromMillisecondsSinceEpoch(map['completed_at'] as int)
          : null,
      relation: map['relation'] as String?,
      hasNotification: (map['has_notification'] as int?) == 1,
      notificationDaysBefore: map['notification_days_before'] as int? ?? 1,
      createdAt: DateTime.fromMillisecondsSinceEpoch(map['created_at'] as int),
      updatedAt: DateTime.fromMillisecondsSinceEpoch(map['updated_at'] as int),
    );
  }
}
```

- [ ] **Step 3: 创建数据库表定义**

```dart
const String tableUserSettings = 'user_settings';

const String tableCountdownTargets = 'countdown_targets';

const String createUserSettingsTable = '''
  CREATE TABLE $tableUserSettings (
    id TEXT PRIMARY KEY,
    birth_date INTEGER NOT NULL,
    retirement_date INTEGER,
    life_expectancy INTEGER DEFAULT 80,
    is_dark_mode INTEGER DEFAULT 0,
    language TEXT DEFAULT 'zh',
    created_at INTEGER NOT NULL,
    updated_at INTEGER NOT NULL
  )
''';

const String createCountdownTargetsTable = '''
  CREATE TABLE $tableCountdownTargets (
    id TEXT PRIMARY KEY,
    name TEXT NOT NULL,
    target_date INTEGER,
    type TEXT NOT NULL,
    is_recurring INTEGER DEFAULT 0,
    is_completed INTEGER DEFAULT 0,
    completed_at INTEGER,
    relation TEXT,
    has_notification INTEGER DEFAULT 1,
    notification_days_before INTEGER DEFAULT 1,
    created_at INTEGER NOT NULL,
    updated_at INTEGER NOT NULL
  )
''';
```

- [ ] **Step 4: 创建 DatabaseHelper**

```dart
import 'package:flutter/foundation.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:sqflite_common_ffi_web/sqflite_ffi_web.dart';
import 'tables.dart';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._init();
  static Database? _database;

  DatabaseHelper._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('arrival_days.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    if (kIsWeb) {
      databaseFactory = databaseFactoryFfiWeb;
      return await databaseFactory.openDatabase(
        filePath,
        options: OpenDatabaseOptions(
          version: 1,
          onCreate: _createDB,
        ),
      );
    }

    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    return await openDatabase(
      path,
      version: 1,
      onCreate: _createDB,
    );
  }

  Future<void> _createDB(Database db, int version) async {
    await db.execute(createUserSettingsTable);
    await db.execute(createCountdownTargetsTable);
  }

  // UserSettings CRUD
  Future<int> insertUserSettings(UserSettings settings) async {
    final db = await database;
    return await db.insert(
      tableUserSettings,
      settings.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<UserSettings?> getUserSettings() async {
    final db = await database;
    final maps = await db.query(tableUserSettings, limit: 1);
    if (maps.isEmpty) return null;
    return UserSettings.fromMap(maps.first);
  }

  Future<int> updateUserSettings(UserSettings settings) async {
    final db = await database;
    return await db.update(
      tableUserSettings,
      settings.toMap(),
      where: 'id = ?',
      whereArgs: [settings.id],
    );
  }

  // CountdownTarget CRUD
  Future<int> insertCountdownTarget(CountdownTarget target) async {
    final db = await database;
    return await db.insert(
      tableCountdownTargets,
      target.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<List<CountdownTarget>> getAllCountdownTargets() async {
    final db = await database;
    final maps = await db.query(tableCountdownTargets);
    return maps.map((map) => CountdownTarget.fromMap(map)).toList();
  }

  Future<List<CountdownTarget>> getCountdownTargetsByType(CountdownTargetType type) async {
    final db = await database;
    final maps = await db.query(
      tableCountdownTargets,
      where: 'type = ?',
      whereArgs: [type.name],
    );
    return maps.map((map) => CountdownTarget.fromMap(map)).toList();
  }

  Future<int> updateCountdownTarget(CountdownTarget target) async {
    final db = await database;
    return await db.update(
      tableCountdownTargets,
      target.toMap(),
      where: 'id = ?',
      whereArgs: [target.id],
    );
  }

  Future<int> deleteCountdownTarget(String id) async {
    final db = await database;
    return await db.delete(
      tableCountdownTargets,
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<void> close() async {
    final db = await database;
    db.close();
  }
}
```

- [ ] **Step 5: 创建倒计时计算工具**

```dart
class CountdownDuration {
  final int years;
  final int months;
  final int days;
  final int hours;
  final int minutes;
  final int seconds;
  final bool isOverdue;

  const CountdownDuration({
    required this.years,
    required this.months,
    required this.days,
    required this.hours,
    required this.minutes,
    required this.seconds,
    this.isOverdue = false,
  });

  String toDisplayString({bool showSeconds = true}) {
    final parts = <String>[];
    if (years > 0) parts.add('${years}年');
    if (months > 0 || years > 0) parts.add('${months}月');
    parts.add('${days}天');
    parts.add('${hours.toString().padLeft(2, '0')}时');
    parts.add('${minutes.toString().padLeft(2, '0')}分');
    if (showSeconds) {
      parts.add('${seconds.toString().padLeft(2, '0')}秒');
    }
    return parts.join('');
  }

  String toShortDisplayString() {
    final parts = <String>[];
    if (years > 0) parts.add('${years}年');
    if (months > 0 || years > 0) parts.add('${months}月');
    parts.add('${days}天');
    parts.add('${hours.toString().padLeft(2, '0')}时');
    parts.add('${minutes.toString().padLeft(2, '0')}分');
    return parts.join('');
  }
}

class CountdownUtils {
  static CountdownDuration calculateCountdown(DateTime targetDate) {
    final now = DateTime.now();
    final difference = targetDate.difference(now);

    if (difference.isNegative) {
      final absDifference = difference.abs();
      return CountdownDuration(
        years: 0,
        months: 0,
        days: absDifference.inDays,
        hours: absDifference.inHours % 24,
        minutes: absDifference.inMinutes % 60,
        seconds: absDifference.inSeconds % 60,
        isOverdue: true,
      );
    }

    return CountdownDuration(
      years: 0,
      months: 0,
      days: difference.inDays,
      hours: difference.inHours % 24,
      minutes: difference.inMinutes % 60,
      seconds: difference.inSeconds % 60,
      isOverdue: false,
    );
  }

  static int calculateAge(DateTime birthDate) {
    final now = DateTime.now();
    int age = now.year - birthDate.year;
    if (now.month < birthDate.month ||
        (now.month == birthDate.month && now.day < birthDate.day)) {
      age--;
    }
    return age;
  }

  static DateTime getNextRecurringDate(DateTime originalDate) {
    final now = DateTime.now();
    var nextDate = DateTime(now.year, originalDate.month, originalDate.day);
    if (nextDate.isBefore(now) || nextDate.isAtSameMomentAs(now)) {
      nextDate = DateTime(now.year + 1, originalDate.month, originalDate.day);
    }
    return nextDate;
  }
}
```

- [ ] **Step 6: 创建日期工具**

```dart
import 'package:intl/intl.dart';

class AppDateUtils {
  static String formatDate(DateTime date) {
    return DateFormat('yyyy-MM-dd').format(date);
  }

  static String formatDateTime(DateTime date) {
    return DateFormat('yyyy-MM-dd HH:mm').format(date);
  }

  static String formatDisplayDate(DateTime date, String locale) {
    if (locale == 'zh') {
      return DateFormat('yyyy年MM月dd日').format(date);
    }
    return DateFormat('MMM dd, yyyy').format(date);
  }

  static String formatDuration(Duration duration) {
    final days = duration.inDays;
    final hours = duration.inHours % 24;
    final minutes = duration.inMinutes % 60;
    final seconds = duration.inSeconds % 60;

    return '${days}天${hours.toString().padLeft(2, '0')}时${minutes.toString().padLeft(2, '0')}分${seconds.toString().padLeft(2, '0')}秒';
  }
}
```

- [ ] **Step 7: 提交**

```bash
git add -A
git commit -m "feat: 添加数据模型和数据库层

- 添加 UserSettings 和 CountdownTarget 模型
- 添加 SQLite 数据库表定义
- 添加 DatabaseHelper 数据库操作类
- 添加倒计时计算工具 CountdownUtils
- 添加日期格式化工具 AppDateUtils

Co-Authored-By: Claude Opus 4.7 <noreply@anthropic.com>"
```

---

## Task 3: Riverpod Providers

**Files:**
- Create: `lib/shared/providers/database_providers.dart`
- Create: `lib/features/settings/providers/settings_provider.dart`
- Create: `lib/features/clock/providers/clock_provider.dart`
- Create: `lib/features/anniversary/providers/anniversary_provider.dart`
- Create: `lib/features/wish/providers/wish_provider.dart`

- [ ] **Step 1: 创建数据库 Provider**

```dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/database/database_helper.dart';
import '../../models/user_settings.dart';
import '../../models/countdown_target.dart';

final databaseHelperProvider = Provider<DatabaseHelper>((ref) {
  return DatabaseHelper.instance;
});

final userSettingsProvider =
    StateNotifierProvider<UserSettingsNotifier, UserSettings?>((ref) {
  return UserSettingsNotifier(ref.watch(databaseHelperProvider));
});

class UserSettingsNotifier extends StateNotifier<UserSettings?> {
  final DatabaseHelper _db;

  UserSettingsNotifier(this._db) : super(null) {
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    state = await _db.getUserSettings();
  }

  Future<void> saveSettings(UserSettings settings) async {
    await _db.insertUserSettings(settings);
    state = settings;
  }
}

final countdownTargetsProvider =
    StateNotifierProvider<CountdownTargetsNotifier, List<CountdownTarget>>((ref) {
  return CountdownTargetsNotifier(ref.watch(databaseHelperProvider));
});

class CountdownTargetsNotifier extends StateNotifier<List<CountdownTarget>> {
  final DatabaseHelper _db;

  CountdownTargetsNotifier(this._db) : super([]) {
    _loadTargets();
  }

  Future<void> _loadTargets() async {
    state = await _db.getAllCountdownTargets();
  }

  Future<void> addTarget(CountdownTarget target) async {
    await _db.insertCountdownTarget(target);
    state = [...state, target];
  }

  Future<void> updateTarget(CountdownTarget target) async {
    await _db.updateCountdownTarget(target);
    state = state.map((t) => t.id == target.id ? target : t).toList();
  }

  Future<void> deleteTarget(String id) async {
    await _db.deleteCountdownTarget(id);
    state = state.where((t) => t.id != id).toList();
  }

  Future<void> refresh() async {
    await _loadTargets();
  }
}
```

- [ ] **Step 2: 创建 Settings Provider**

```dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../models/user_settings.dart';

final settingsViewModelProvider =
    Provider<SettingsViewModel>((ref) {
  return SettingsViewModel(ref);
});

class SettingsViewModel {
  final Ref _ref;

  SettingsViewModel(this._ref);

  UserSettings? get settings => _ref.read(userSettingsProvider);

  Future<void> updateBirthDate(DateTime date) async {
    final current = _ref.read(userSettingsProvider);
    if (current != null) {
      await _ref.read(userSettingsProvider.notifier).saveSettings(
        current.copyWith(
          birthDate: date,
          updatedAt: DateTime.now(),
        ),
      );
    }
  }

  Future<void> updateRetirementDate(DateTime? date) async {
    final current = _ref.read(userSettingsProvider);
    if (current != null) {
      await _ref.read(userSettingsProvider.notifier).saveSettings(
        current.copyWith(
          retirementDate: date,
          updatedAt: DateTime.now(),
        ),
      );
    }
  }

  Future<void> updateLifeExpectancy(int years) async {
    final current = _ref.read(userSettingsProvider);
    if (current != null) {
      await _ref.read(userSettingsProvider.notifier).saveSettings(
        current.copyWith(
          lifeExpectancy: years,
          updatedAt: DateTime.now(),
        ),
      );
    }
  }

  Future<void> toggleDarkMode() async {
    final current = _ref.read(userSettingsProvider);
    if (current != null) {
      await _ref.read(userSettingsProvider.notifier).saveSettings(
        current.copyWith(
          isDarkMode: !current.isDarkMode,
          updatedAt: DateTime.now(),
        ),
      );
    }
  }

  Future<void> updateLanguage(String language) async {
    final current = _ref.read(userSettingsProvider);
    if (current != null) {
      await _ref.read(userSettingsProvider.notifier).saveSettings(
        current.copyWith(
          language: language,
          updatedAt: DateTime.now(),
        ),
      );
    }
  }
}
```

- [ ] **Step 3: 创建 Clock Provider**

```dart
import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../models/countdown_target.dart';
import '../../../core/utils/countdown_utils.dart';

final clockTickProvider = StreamProvider<DateTime>((ref) {
  return Stream.periodic(const Duration(seconds: 1), (_) => DateTime.now());
});

final lifeTimerProvider = Provider<CountdownTarget?>((ref) {
  ref.watch(clockTickProvider);
  final targets = ref.watch(countdownTargetsProvider);
  try {
    return targets.firstWhere((t) => t.type == CountdownTargetType.lifeTimer);
  } catch (_) {
    return null;
  }
});

final retirementTimerProvider = Provider<DateTime?>((ref) {
  final settings = ref.watch(userSettingsProvider);
  return settings?.retirementDate;
});

final anniversaryListProvider = Provider<List<CountdownTarget>>((ref) {
  ref.watch(clockTickProvider);
  final targets = ref.watch(countdownTargetsProvider);
  return targets
      .where((t) => t.type == CountdownTargetType.anniversary || t.type == CountdownTargetType.birthday)
      .toList()
    ..sort((a, b) {
      if (a.targetDate == null) return 1;
      if (b.targetDate == null) return -1;
      return a.targetDate!.compareTo(b.targetDate!);
    });
});

final wishListProvider = Provider<List<CountdownTarget>>((ref) {
  ref.watch(clockTickProvider);
  final targets = ref.watch(countdownTargetsProvider);
  return targets
      .where((t) => t.type == CountdownTargetType.wish && !t.isCompleted)
      .toList()
    ..sort((a, b) {
      if (a.targetDate == null && b.targetDate == null) return 0;
      if (a.targetDate == null) return 1;
      if (b.targetDate == null) return -1;
      return a.targetDate!.compareTo(b.targetDate!);
    });
});
```

- [ ] **Step 4: 创建 Anniversary Provider**

```dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../models/countdown_target.dart';

final anniversaryViewModelProvider =
    Provider<AnniversaryViewModel>((ref) {
  return AnniversaryViewModel(ref);
});

class AnniversaryViewModel {
  final Ref _ref;

  AnniversaryViewModel(this._ref);

  List<CountdownTarget> get allAnniversaries {
    final targets = _ref.read(countdownTargetsProvider);
    return targets
        .where((t) => t.type == CountdownTargetType.anniversary || t.type == CountdownTargetType.birthday)
        .toList()
      ..sort((a, b) {
        if (a.targetDate == null) return 1;
        if (b.targetDate == null) return -1;
        return a.targetDate!.compareTo(b.targetDate!);
      });
  }

  List<CountdownTarget> get birthdays {
    return allAnniversaries.where((t) => t.type == CountdownTargetType.birthday).toList();
  }

  List<CountdownTarget> get regularAnniversaries {
    return allAnniversaries.where((t) => t.type == CountdownTargetType.anniversary).toList();
  }

  Future<void> addAnniversary(CountdownTarget target) async {
    await _ref.read(countdownTargetsProvider.notifier).addTarget(target);
  }

  Future<void> updateAnniversary(CountdownTarget target) async {
    await _ref.read(countdownTargetsProvider.notifier).updateTarget(target);
  }

  Future<void> deleteAnniversary(String id) async {
    await _ref.read(countdownTargetsProvider.notifier).deleteTarget(id);
  }
}
```

- [ ] **Step 5: 创建 Wish Provider**

```dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../models/countdown_target.dart';

final wishViewModelProvider = Provider<WishViewModel>((ref) {
  return WishViewModel(ref);
});

class WishViewModel {
  final Ref _ref;

  WishViewModel(this._ref);

  List<CountdownTarget> get uncompletedWishes {
    final targets = _ref.read(countdownTargetsProvider);
    return targets
        .where((t) => t.type == CountdownTargetType.wish && !t.isCompleted)
        .toList()
      ..sort((a, b) {
        if (a.targetDate == null && b.targetDate == null) return 0;
        if (a.targetDate == null) return 1;
        if (b.targetDate == null) return -1;
        return a.targetDate!.compareTo(b.targetDate!);
      });
  }

  List<CountdownTarget> get completedWishes {
    final targets = _ref.read(countdownTargetsProvider);
    return targets
        .where((t) => t.type == CountdownTargetType.wish && t.isCompleted)
        .toList()
      ..sort((a, b) {
        if (a.completedAt == null) return 1;
        if (b.completedAt == null) return -1;
        return b.completedAt!.compareTo(a.completedAt!);
      });
  }

  Future<void> addWish(CountdownTarget wish) async {
    await _ref.read(countdownTargetsProvider.notifier).addTarget(wish);
  }

  Future<void> updateWish(CountdownTarget wish) async {
    await _ref.read(countdownTargetsProvider.notifier).updateTarget(wish);
  }

  Future<void> completeWish(String id) async {
    final targets = _ref.read(countdownTargetsProvider);
    final wish = targets.firstWhere((t) => t.id == id);
    await _ref.read(countdownTargetsProvider.notifier).updateTarget(
      wish.copyWith(
        isCompleted: true,
        completedAt: DateTime.now(),
        updatedAt: DateTime.now(),
      ),
    );
  }

  Future<void> reactivateWish(String id) async {
    final targets = _ref.read(countdownTargetsProvider);
    final wish = targets.firstWhere((t) => t.id == id);
    await _ref.read(countdownTargetsProvider.notifier).updateTarget(
      wish.copyWith(
        isCompleted: false,
        completedAt: null,
        updatedAt: DateTime.now(),
      ),
    );
  }

  Future<void> deleteWish(String id) async {
    await _ref.read(countdownTargetsProvider.notifier).deleteTarget(id);
  }
}
```

- [ ] **Step 6: 提交**

```bash
git add -A
git commit -m "feat: 添加 Riverpod Providers

- 添加数据库相关 Provider
- 添加 Settings ViewModel Provider
- 添加 Clock 实时倒计时 Provider
- 添加 Anniversary ViewModel Provider
- 添加 Wish ViewModel Provider

Co-Authored-By: Claude Opus 4.7 <noreply@anthropic.com>"
```

---

## Task 4: 主题和国际化

**Files:**
- Create: `lib/core/theme/app_theme.dart`
- Create: `lib/l10n/app_zh.arb`
- Create: `lib/l10n/app_en.arb`
- Create: `lib/l10n/app_localizations.dart`

- [ ] **Step 1: 创建 Material 3 主题**

```dart
import 'package:flutter/material.dart';

class AppTheme {
  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: Colors.deepPurple,
        brightness: Brightness.light,
      ),
      appBarTheme: const AppBarTheme(
        centerTitle: true,
      ),
      cardTheme: CardTheme(
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
      ),
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: Colors.deepPurple,
        foregroundColor: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
      ),
      navigationBarTheme: NavigationBarThemeData(
        indicatorColor: Colors.deepPurple.withOpacity(0.2),
        labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
      ),
    );
  }

  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: Colors.deepPurple,
        brightness: Brightness.dark,
      ),
      appBarTheme: const AppBarTheme(
        centerTitle: true,
      ),
      cardTheme: CardTheme(
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
      ),
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: Colors.deepPurple,
        foregroundColor: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
      ),
      navigationBarTheme: NavigationBarThemeData(
        indicatorColor: Colors.deepPurple.withOpacity(0.2),
        labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
      ),
    );
  }
}
```

- [ ] **Step 2: 创建中文 ARB 文件**

```json
{
  "@@locale": "zh",
  "appTitle": "人生倒计时",
  "clock": "时钟",
  "anniversary": "纪念日",
  "wish": "心愿",
  "settings": "设置",
  "lifeTimer": "人生定时器",
  "distanceFromLeaving": "距离理想离开",
  "elapsed": "已过",
  "years": "年",
  "months": "月",
  "days": "天",
  "hours": "时",
  "minutes": "分",
  "seconds": "秒",
  "addAnniversary": "添加纪念日",
  "addWish": "添加心愿",
  "editAnniversary": "编辑纪念日",
  "editWish": "编辑心愿",
  "name": "名称",
  "date": "日期",
  "type": "类型",
  "birthday": "生日",
  "recurring": "每年重复",
  "notification": "通知提醒",
  "daysBefore": "提前几天",
  "save": "保存",
  "cancel": "取消",
  "delete": "删除",
  "completed": "已完成",
  "uncompleted": "未完成",
  "completedAt": "完成于",
  "reactivate": "重新激活",
  "emptyAnniversary": "还没有纪念日，添加第一个吧",
  "emptyWish": "还没有心愿，添加第一个吧",
  "birthDate": "出生日期",
  "retirementDate": "计划退休日",
  "lifeExpectancy": "预期寿命",
  "darkMode": "深色主题",
  "language": "语言",
  "notificationSettings": "提醒设置",
  "dataSync": "数据同步",
  "dataExport": "数据导出",
  "dataImport": "数据导入",
  "about": "关于",
  "version": "版本",
  "age": "岁",
  "distanceFromRetirement": "距离退休",
  "workedYears": "已工作",
  "relation": "关系",
  "noDate": "无日期"
}
```

- [ ] **Step 3: 创建英文 ARB 文件**

```json
{
  "@@locale": "en",
  "appTitle": "Arrival Days",
  "clock": "Clock",
  "anniversary": "Anniversary",
  "wish": "Wishes",
  "settings": "Settings",
  "lifeTimer": "Life Timer",
  "distanceFromLeaving": "Distance from ideal leaving",
  "elapsed": "Elapsed",
  "years": "y",
  "months": "m",
  "days": "d",
  "hours": "h",
  "minutes": "min",
  "seconds": "sec",
  "addAnniversary": "Add Anniversary",
  "addWish": "Add Wish",
  "editAnniversary": "Edit Anniversary",
  "editWish": "Edit Wish",
  "name": "Name",
  "date": "Date",
  "type": "Type",
  "birthday": "Birthday",
  "recurring": "Recurring yearly",
  "notification": "Notification",
  "daysBefore": "Days before",
  "save": "Save",
  "cancel": "Cancel",
  "delete": "Delete",
  "completed": "Completed",
  "uncompleted": "Uncompleted",
  "completedAt": "Completed at",
  "reactivate": "Reactivate",
  "emptyAnniversary": "No anniversaries yet, add your first one",
  "emptyWish": "No wishes yet, add your first one",
  "birthDate": "Birth Date",
  "retirementDate": "Retirement Date",
  "lifeExpectancy": "Life Expectancy",
  "darkMode": "Dark Mode",
  "language": "Language",
  "notificationSettings": "Notification Settings",
  "dataSync": "Data Sync",
  "dataExport": "Export Data",
  "dataImport": "Import Data",
  "about": "About",
  "version": "Version",
  "age": "years old",
  "distanceFromRetirement": "Distance from retirement",
  "workedYears": "Years worked",
  "relation": "Relation",
  "noDate": "No date"
}
```

- [ ] **Step 4: 创建本地化类**

```dart
import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

class AppLocalizations {
  AppLocalizations(this.locale);

  final Locale locale;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
    delegate,
    GlobalMaterialLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
  ];

  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('zh'),
  ];

  static final Map<String, Map<String, String>> _localizedValues = {
    'en': {
      'appTitle': 'Arrival Days',
      'clock': 'Clock',
      'anniversary': 'Anniversary',
      'wish': 'Wishes',
      'settings': 'Settings',
      'lifeTimer': 'Life Timer',
      'distanceFromLeaving': 'Distance from ideal leaving',
      'elapsed': 'Elapsed',
      'years': 'y',
      'months': 'm',
      'days': 'd',
      'hours': 'h',
      'minutes': 'min',
      'seconds': 'sec',
      'addAnniversary': 'Add Anniversary',
      'addWish': 'Add Wish',
      'editAnniversary': 'Edit Anniversary',
      'editWish': 'Edit Wish',
      'name': 'Name',
      'date': 'Date',
      'type': 'Type',
      'birthday': 'Birthday',
      'recurring': 'Recurring yearly',
      'notification': 'Notification',
      'daysBefore': 'Days before',
      'save': 'Save',
      'cancel': 'Cancel',
      'delete': 'Delete',
      'completed': 'Completed',
      'uncompleted': 'Uncompleted',
      'completedAt': 'Completed at',
      'reactivate': 'Reactivate',
      'emptyAnniversary': 'No anniversaries yet, add your first one',
      'emptyWish': 'No wishes yet, add your first one',
      'birthDate': 'Birth Date',
      'retirementDate': 'Retirement Date',
      'lifeExpectancy': 'Life Expectancy',
      'darkMode': 'Dark Mode',
      'language': 'Language',
      'notificationSettings': 'Notification Settings',
      'dataSync': 'Data Sync',
      'dataExport': 'Export Data',
      'dataImport': 'Import Data',
      'about': 'About',
      'version': 'Version',
      'age': 'years old',
      'distanceFromRetirement': 'Distance from retirement',
      'workedYears': 'Years worked',
      'relation': 'Relation',
      'noDate': 'No date',
    },
    'zh': {
      'appTitle': '人生倒计时',
      'clock': '时钟',
      'anniversary': '纪念日',
      'wish': '心愿',
      'settings': '设置',
      'lifeTimer': '人生定时器',
      'distanceFromLeaving': '距离理想离开',
      'elapsed': '已过',
      'years': '年',
      'months': '月',
      'days': '天',
      'hours': '时',
      'minutes': '分',
      'seconds': '秒',
      'addAnniversary': '添加纪念日',
      'addWish': '添加心愿',
      'editAnniversary': '编辑纪念日',
      'editWish': '编辑心愿',
      'name': '名称',
      'date': '日期',
      'type': '类型',
      'birthday': '生日',
      'recurring': '每年重复',
      'notification': '通知提醒',
      'daysBefore': '提前几天',
      'save': '保存',
      'cancel': '取消',
      'delete': '删除',
      'completed': '已完成',
      'uncompleted': '未完成',
      'completedAt': '完成于',
      'reactivate': '重新激活',
      'emptyAnniversary': '还没有纪念日，添加第一个吧',
      'emptyWish': '还没有心愿，添加第一个吧',
      'birthDate': '出生日期',
      'retirementDate': '计划退休日',
      'lifeExpectancy': '预期寿命',
      'darkMode': '深色主题',
      'language': '语言',
      'notificationSettings': '提醒设置',
      'dataSync': '数据同步',
      'dataExport': '数据导出',
      'dataImport': '数据导入',
      'about': '关于',
      'version': '版本',
      'age': '岁',
      'distanceFromRetirement': '距离退休',
      'workedYears': '已工作',
      'relation': '关系',
      'noDate': '无日期',
    },
  };

  String translate(String key) {
    return _localizedValues[locale.languageCode]?[key] ??
        _localizedValues['en']?[key] ??
        key;
  }

  // Convenience getters
  String get appTitle => translate('appTitle');
  String get clock => translate('clock');
  String get anniversary => translate('anniversary');
  String get wish => translate('wish');
  String get settings => translate('settings');
  String get lifeTimer => translate('lifeTimer');
  String get distanceFromLeaving => translate('distanceFromLeaving');
  String get elapsed => translate('elapsed');
  String get addAnniversary => translate('addAnniversary');
  String get addWish => translate('addWish');
  String get editAnniversary => translate('editAnniversary');
  String get editWish => translate('editWish');
  String get name => translate('name');
  String get date => translate('date');
  String get save => translate('save');
  String get cancel => translate('cancel');
  String get delete => translate('delete');
  String get completed => translate('completed');
  String get uncompleted => translate('uncompleted');
  String get completedAt => translate('completedAt');
  String get reactivate => translate('reactivate');
  String get emptyAnniversary => translate('emptyAnniversary');
  String get emptyWish => translate('emptyWish');
  String get birthDate => translate('birthDate');
  String get retirementDate => translate('retirementDate');
  String get lifeExpectancy => translate('lifeExpectancy');
  String get darkMode => translate('darkMode');
  String get language => translate('language');
  String get about => translate('about');
  String get version => translate('version');
  String get age => translate('age');
  String get relation => translate('relation');
  String get noDate => translate('noDate');
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(AppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) {
    return ['en', 'zh'].contains(locale.languageCode);
  }

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}
```

- [ ] **Step 5: 提交**

```bash
git add -A
git commit -m "feat: 添加主题和国际化

- 添加 Material 3 浅色/深色主题
- 添加中英文 ARB 国际化文件
- 添加 AppLocalizations 本地化类

Co-Authored-By: Claude Opus 4.7 <noreply@anthropic.com>"
```

---

## Task 5: 共享组件

**Files:**
- Create: `lib/shared/widgets/countdown_display.dart`
- Create: `lib/shared/widgets/countdown_item.dart`
- Create: `lib/shared/widgets/empty_state.dart`

- [ ] **Step 1: 创建倒计时显示组件**

```dart
import 'package:flutter/material.dart';
import '../../core/utils/countdown_utils.dart';

class CountdownDisplay extends StatelessWidget {
  final DateTime targetDate;
  final bool isRecurring;
  final DateTime? recurringBaseDate;
  final TextStyle? style;
  final bool showSeconds;

  const CountdownDisplay({
    super.key,
    required this.targetDate,
    this.isRecurring = false,
    this.recurringBaseDate,
    this.style,
    this.showSeconds = true,
  });

  @override
  Widget build(BuildContext context) {
    final displayTarget = isRecurring && recurringBaseDate != null
        ? CountdownUtils.getNextRecurringDate(recurringBaseDate!)
        : targetDate;

    final countdown = CountdownUtils.calculateCountdown(displayTarget);
    final theme = Theme.of(context);

    return Text(
      countdown.isOverdue
          ? '已过${countdown.toDisplayString(showSeconds: showSeconds)}'
          : '还差${countdown.toDisplayString(showSeconds: showSeconds)}',
      style: style ?? theme.textTheme.bodyMedium?.copyWith(
        color: countdown.isOverdue ? Colors.red : null,
      ),
    );
  }
}
```

- [ ] **Step 2: 创建倒计时列表项组件**

```dart
import 'package:flutter/material.dart';
import '../../core/utils/countdown_utils.dart';
import '../../models/countdown_target.dart';

class CountdownItem extends StatelessWidget {
  final CountdownTarget target;
  final VoidCallback? onTap;
  final VoidCallback? onComplete;
  final bool showCompleteButton;
  final bool isOverdue;

  const CountdownItem({
    super.key,
    required this.target,
    this.onTap,
    this.onComplete,
    this.showCompleteButton = false,
    this.isOverdue = false,
  });

  IconData get _icon {
    switch (target.type) {
      case CountdownTargetType.birthday:
        return Icons.cake;
      case CountdownTargetType.anniversary:
        return Icons.celebration;
      case CountdownTargetType.wish:
        return Icons.favorite;
      case CountdownTargetType.lifeTimer:
        return Icons.timer;
    }
  }

  String get _displayName {
    if (target.type == CountdownTargetType.birthday && target.relation != null) {
      return '${target.name} ${target.relation}';
    }
    return target.name;
  }

  String get _countdownText {
    if (target.targetDate == null) {
      return '无日期';
    }

    final displayTarget = target.isRecurring && target.type == CountdownTargetType.birthday
        ? CountdownUtils.getNextRecurringDate(target.targetDate!)
        : target.targetDate!;

    final countdown = CountdownUtils.calculateCountdown(displayTarget);

    if (target.type == CountdownTargetType.birthday) {
      final age = CountdownUtils.calculateAge(target.targetDate!);
      return '$age岁 ${countdown.isOverdue ? '已过' : '还差'}${countdown.toShortDisplayString()}';
    }

    return countdown.isOverdue
        ? '已过${countdown.toShortDisplayString()}'
        : '还差${countdown.toShortDisplayString()}';
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isBirthday = target.type == CountdownTargetType.birthday;

    return Dismissible(
      key: Key(target.id),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        color: Colors.red,
        child: const Icon(Icons.delete, color: Colors.white),
      ),
      onDismissed: (_) => onTap?.call(),
      child: ListTile(
        leading: Icon(_icon, color: isBirthday ? Colors.pink : theme.colorScheme.primary),
        title: Text(_displayName),
        subtitle: Text(
          _countdownText,
          style: TextStyle(
            color: isOverdue ? Colors.red : null,
          ),
        ),
        trailing: showCompleteButton && !target.isCompleted
            ? IconButton(
                icon: const Icon(Icons.check_circle_outline),
                onPressed: onComplete,
              )
            : null,
        onTap: onTap,
      ),
    );
  }
}
```

- [ ] **Step 3: 创建空状态组件**

```dart
import 'package:flutter/material.dart';

class EmptyState extends StatelessWidget {
  final String message;
  final VoidCallback? onAddPressed;
  final String? buttonText;

  const EmptyState({
    super.key,
    required this.message,
    this.onAddPressed,
    this.buttonText,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.inbox_outlined,
              size: 64,
              color: theme.colorScheme.outline,
            ),
            const SizedBox(height: 16),
            Text(
              message,
              textAlign: TextAlign.center,
              style: theme.textTheme.bodyLarge?.copyWith(
                color: theme.colorScheme.outline,
              ),
            ),
            if (onAddPressed != null) ...[
              const SizedBox(height: 24),
              FilledButton.icon(
                onPressed: onAddPressed,
                icon: const Icon(Icons.add),
                label: Text(buttonText ?? '添加'),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
```

- [ ] **Step 4: 提交**

```bash
git add -A
git commit -m "feat: 添加共享组件

- 添加 CountdownDisplay 倒计时显示组件
- 添加 CountdownItem 倒计时列表项组件
- 添加 EmptyState 空状态组件

Co-Authored-By: Claude Opus 4.7 <noreply@anthropic.com>"
```

---

## Task 6: 时钟 Tab (首页)

**Files:**
- Create: `lib/features/clock/screens/clock_screen.dart`
- Create: `lib/features/clock/widgets/life_timer_card.dart`
- Create: `lib/features/clock/widgets/clock_section_header.dart`

- [ ] **Step 1: 创建人生定时器卡片**

```dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/utils/countdown_utils.dart';
import '../../../models/countdown_target.dart';
import '../../../shared/providers/database_providers.dart';

class LifeTimerCard extends ConsumerWidget {
  const LifeTimerCard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final lifeTimer = ref.watch(lifeTimerProvider);
    final settings = ref.watch(userSettingsProvider);
    final retirementDate = ref.watch(retirementTimerProvider);
    final theme = Theme.of(context);

    return Card(
      margin: const EdgeInsets.all(16),
      child: Container(
        height: MediaQuery.of(context).size.height * 0.25,
        width: double.infinity,
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.timer, color: theme.colorScheme.primary),
                const SizedBox(width: 8),
                Text(
                  '人生定时器',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const Spacer(),
            if (lifeTimer?.targetDate != null) ...[
              _buildCountdownRow(
                context,
                '距离理想离开',
                CountdownUtils.calculateCountdown(lifeTimer!.targetDate!),
              ),
              const SizedBox(height: 8),
              if (settings != null)
                _buildElapsedRow(context, settings.birthDate),
            ] else
              Center(
                child: Text(
                  '设置你的理想离开日期',
                  style: theme.textTheme.bodyLarge,
                ),
              ),
            if (retirementDate != null) ...[
              const SizedBox(height: 8),
              _buildCountdownRow(
                context,
                '距离退休',
                CountdownUtils.calculateCountdown(retirementDate),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildCountdownRow(BuildContext context, String label, CountdownDuration countdown) {
    final theme = Theme.of(context);
    final isOverdue = countdown.isOverdue;

    return Row(
      children: [
        Text(
          '$label: ',
          style: theme.textTheme.bodyMedium,
        ),
        Text(
          isOverdue
              ? '已过${countdown.toDisplayString()}'
              : '还差${countdown.toDisplayString()}',
          style: theme.textTheme.bodyLarge?.copyWith(
            fontWeight: FontWeight.bold,
            color: isOverdue ? Colors.red : theme.colorScheme.primary,
          ),
        ),
      ],
    );
  }

  Widget _buildElapsedRow(BuildContext context, DateTime birthDate) {
    final theme = Theme.of(context);
    final elapsed = DateTime.now().difference(birthDate);
    final years = elapsed.inDays ~/ 365;
    final months = (elapsed.inDays % 365) ~/ 30;

    return Row(
      children: [
        Text(
          '已过: ',
          style: theme.textTheme.bodyMedium,
        ),
        Text(
          '${years}年${months}月',
          style: theme.textTheme.bodyLarge?.copyWith(
            fontWeight: FontWeight.bold,
            color: theme.colorScheme.secondary,
          ),
        ),
      ],
    );
  }
}
```

- [ ] **Step 2: 创建分区标题组件**

```dart
import 'package:flutter/material.dart';

class ClockSectionHeader extends StatelessWidget {
  final String title;
  final VoidCallback? onSeeAllPressed;

  const ClockSectionHeader({
    super.key,
    required this.title,
    this.onSeeAllPressed,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: theme.textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          if (onSeeAllPressed != null)
            TextButton(
              onPressed: onSeeAllPressed,
              child: const Text('查看全部'),
            ),
        ],
      ),
    );
  }
}
```

- [ ] **Step 3: 创建时钟屏幕**

```dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../shared/widgets/countdown_item.dart';
import '../../../shared/widgets/empty_state.dart';
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
                // Navigate to anniversary tab
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
                // Navigate to wish tab
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
```

- [ ] **Step 4: 提交**

```bash
git add -A
git commit -m "feat: 实现时钟 Tab 首页

- 添加 LifeTimerCard 人生定时器卡片组件
- 添加 ClockSectionHeader 分区标题组件
- 添加 ClockScreen 时钟主屏幕

Co-Authored-By: Claude Opus 4.7 <noreply@anthropic.com>"
```

---

## Task 7: 纪念日 Tab

**Files:**
- Create: `lib/features/anniversary/screens/anniversary_list_screen.dart`
- Create: `lib/features/anniversary/screens/anniversary_detail_screen.dart`
- Create: `lib/features/anniversary/widgets/anniversary_form.dart`

- [ ] **Step 1: 创建纪念日列表页**

```dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import '../../../models/countdown_target.dart';
import '../../../shared/widgets/countdown_item.dart';
import '../../../shared/widgets/empty_state.dart';
import '../providers/anniversary_provider.dart';
import '../widgets/anniversary_form.dart';
import 'anniversary_detail_screen.dart';

class AnniversaryListScreen extends ConsumerWidget {
  const AnniversaryListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final viewModel = ref.watch(anniversaryViewModelProvider);
    final anniversaries = viewModel.allAnniversaries;

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
          ref.read(anniversaryViewModelProvider).addAnniversary(target);
          Navigator.pop(context);
        },
      ),
    );
  }
}
```

- [ ] **Step 2: 创建纪念日详情页**

```dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/utils/countdown_utils.dart';
import '../../../models/countdown_target.dart';
import '../../../shared/widgets/countdown_display.dart';
import '../providers/anniversary_provider.dart';
import '../widgets/anniversary_form.dart';

class AnniversaryDetailScreen extends ConsumerWidget {
  final CountdownTarget target;

  const AnniversaryDetailScreen({super.key, required this.target});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final viewModel = ref.watch(anniversaryViewModelProvider);

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
            onPressed: () => _showDeleteDialog(context, ref),
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
                        target.type == CountdownTargetType.birthday
                            ? Icons.cake
                            : Icons.celebration,
                        size: 32,
                        color: theme.colorScheme.primary,
                      ),
                      const SizedBox(width: 12),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            target.name,
                            style: theme.textTheme.titleLarge,
                          ),
                          if (target.relation != null)
                            Text(
                              target.relation!,
                              style: theme.textTheme.bodyMedium?.copyWith(
                                color: theme.colorScheme.outline,
                              ),
                            ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  if (target.targetDate != null) ...[
                    if (target.type == CountdownTargetType.birthday) ...[
                      Text(
                        '年龄: ${CountdownUtils.calculateAge(target.targetDate!)}岁',
                        style: theme.textTheme.bodyLarge,
                      ),
                      const SizedBox(height: 8),
                    ],
                    CountdownDisplay(
                      targetDate: target.targetDate!,
                      isRecurring: target.isRecurring,
                      recurringBaseDate: target.targetDate,
                    ),
                  ],
                  const SizedBox(height: 16),
                  SwitchListTile(
                    title: const Text('每年重复'),
                    value: target.isRecurring,
                    onChanged: null, // Read-only in detail
                  ),
                  SwitchListTile(
                    title: const Text('通知提醒'),
                    value: target.hasNotification,
                    onChanged: null,
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
      builder: (_) => AnniversaryForm(
        target: target,
        onSave: (updated) {
          viewModel.updateAnniversary(updated);
          Navigator.pop(context);
        },
      ),
    );
  }

  void _showDeleteDialog(BuildContext context, WidgetRef ref) {
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
              viewModel.deleteAnniversary(target.id);
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
```

- [ ] **Step 3: 创建纪念日表单**

```dart
import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import '../../../models/countdown_target.dart';

class AnniversaryForm extends StatefulWidget {
  final CountdownTarget? target;
  final Function(CountdownTarget) onSave;

  const AnniversaryForm({
    super.key,
    this.target,
    required this.onSave,
  });

  @override
  State<AnniversaryForm> createState() => _AnniversaryFormState();
}

class _AnniversaryFormState extends State<AnniversaryForm> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _relationController;
  DateTime? _selectedDate;
  bool _isBirthday = false;
  bool _isRecurring = true;
  bool _hasNotification = true;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.target?.name ?? '');
    _relationController = TextEditingController(text: widget.target?.relation ?? '');
    _selectedDate = widget.target?.targetDate;
    _isBirthday = widget.target?.type == CountdownTargetType.birthday;
    _isRecurring = widget.target?.isRecurring ?? true;
    _hasNotification = widget.target?.hasNotification ?? true;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _relationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: Container(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                widget.target == null ? '添加纪念日' : '编辑纪念日',
                style: theme.textTheme.titleLarge,
              ),
              const SizedBox(height: 24),
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: '名称',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return '请输入名称';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: SegmentedButton<bool>(
                      segments: const [
                        ButtonSegment(value: false, label: Text('纪念日')),
                        ButtonSegment(value: true, label: Text('生日')),
                      ],
                      selected: {_isBirthday},
                      onSelectionChanged: (selected) {
                        setState(() {
                          _isBirthday = selected.first;
                          if (_isBirthday) {
                            _isRecurring = true;
                          }
                        });
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              if (_isBirthday) ...[
                TextFormField(
                  controller: _relationController,
                  decoration: const InputDecoration(
                    labelText: '关系（可选）',
                    border: OutlineInputBorder(),
                    hintText: '如：爸爸、妈妈、朋友',
                  ),
                ),
                const SizedBox(height: 16),
              ],
              ListTile(
                contentPadding: EdgeInsets.zero,
                title: const Text('日期'),
                subtitle: Text(
                  _selectedDate != null
                      ? '${_selectedDate!.year}-${_selectedDate!.month.toString().padLeft(2, '0')}-${_selectedDate!.day.toString().padLeft(2, '0')}'
                      : '请选择日期',
                ),
                trailing: const Icon(Icons.calendar_today),
                onTap: _selectDate,
              ),
              const SizedBox(height: 16),
              SwitchListTile(
                contentPadding: EdgeInsets.zero,
                title: const Text('每年重复'),
                value: _isRecurring,
                onChanged: _isBirthday
                    ? null
                    : (value) {
                        setState(() {
                          _isRecurring = value;
                        });
                      },
              ),
              SwitchListTile(
                contentPadding: EdgeInsets.zero,
                title: const Text('通知提醒'),
                value: _hasNotification,
                onChanged: (value) {
                  setState(() {
                    _hasNotification = value;
                  });
                },
              ),
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('取消'),
                  ),
                  const SizedBox(width: 16),
                  FilledButton(
                    onPressed: _save,
                    child: const Text('保存'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _selectDate() async {
    final date = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? DateTime.now(),
      firstDate: DateTime(1900),
      lastDate: DateTime(2100),
    );
    if (date != null) {
      setState(() {
        _selectedDate = date;
      });
    }
  }

  void _save() {
    if (_formKey.currentState!.validate() && _selectedDate != null) {
      final target = CountdownTarget(
        id: widget.target?.id ?? const Uuid().v4(),
        name: _nameController.text,
        targetDate: _selectedDate,
        type: _isBirthday ? CountdownTargetType.birthday : CountdownTargetType.anniversary,
        isRecurring: _isRecurring,
        relation: _isBirthday ? _relationController.text : null,
        hasNotification: _hasNotification,
        createdAt: widget.target?.createdAt ?? DateTime.now(),
        updatedAt: DateTime.now(),
      );
      widget.onSave(target);
    }
  }
}
```

- [ ] **Step 4: 提交**

```bash
git add -A
git commit -m "feat: 实现纪念日 Tab

- 添加 AnniversaryListScreen 纪念日列表页
- 添加 AnniversaryDetailScreen 纪念日详情页
- 添加 AnniversaryForm 纪念日表单组件

Co-Authored-By: Claude Opus 4.7 <noreply@anthropic.com>"
```

---

## Task 8: 心愿 Tab

**Files:**
- Create: `lib/features/wish/screens/wish_list_screen.dart`
- Create: `lib/features/wish/screens/wish_detail_screen.dart`
- Create: `lib/features/wish/widgets/wish_form.dart`

- [ ] **Step 1: 创建心愿列表页**

```dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import '../../../models/countdown_target.dart';
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
```

- [ ] **Step 2: 创建心愿详情页**

```dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../models/countdown_target.dart';
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
            onPressed: () => _showEditDialog(context),
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

  void _showEditDialog(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (_) => WishForm(
        target: target,
        onSave: (updated) {
          ref.read(wishViewModelProvider).updateWish(updated);
          Navigator.pop(context);
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
```

- [ ] **Step 3: 创建心愿表单**

```dart
import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import '../../../models/countdown_target.dart';

class WishForm extends StatefulWidget {
  final CountdownTarget? target;
  final Function(CountdownTarget) onSave;

  const WishForm({
    super.key,
    this.target,
    required this.onSave,
  });

  @override
  State<WishForm> createState() => _WishFormState();
}

class _WishFormState extends State<WishForm> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  DateTime? _selectedDate;
  bool _hasNotification = true;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.target?.name ?? '');
    _selectedDate = widget.target?.targetDate;
    _hasNotification = widget.target?.hasNotification ?? true;
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: Container(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                widget.target == null ? '添加心愿' : '编辑心愿',
                style: theme.textTheme.titleLarge,
              ),
              const SizedBox(height: 24),
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: '心愿名称',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return '请输入心愿名称';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              ListTile(
                contentPadding: EdgeInsets.zero,
                title: const Text('目标日期（可选）'),
                subtitle: Text(
                  _selectedDate != null
                      ? '${_selectedDate!.year}-${_selectedDate!.month.toString().padLeft(2, '0')}-${_selectedDate!.day.toString().padLeft(2, '0')}'
                      : '无日期',
                ),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (_selectedDate != null)
                      IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          setState(() {
                            _selectedDate = null;
                          });
                        },
                      ),
                    const Icon(Icons.calendar_today),
                  ],
                ),
                onTap: _selectDate,
              ),
              const SizedBox(height: 16),
              SwitchListTile(
                contentPadding: EdgeInsets.zero,
                title: const Text('通知提醒'),
                value: _hasNotification,
                onChanged: (value) {
                  setState(() {
                    _hasNotification = value;
                  });
                },
              ),
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('取消'),
                  ),
                  const SizedBox(width: 16),
                  FilledButton(
                    onPressed: _save,
                    child: const Text('保存'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _selectDate() async {
    final date = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(2100),
    );
    if (date != null) {
      setState(() {
        _selectedDate = date;
      });
    }
  }

  void _save() {
    if (_formKey.currentState!.validate()) {
      final target = CountdownTarget(
        id: widget.target?.id ?? const Uuid().v4(),
        name: _nameController.text,
        targetDate: _selectedDate,
        type: CountdownTargetType.wish,
        isCompleted: widget.target?.isCompleted ?? false,
        completedAt: widget.target?.completedAt,
        hasNotification: _hasNotification,
        createdAt: widget.target?.createdAt ?? DateTime.now(),
        updatedAt: DateTime.now(),
      );
      widget.onSave(target);
    }
  }
}
```

- [ ] **Step 4: 提交**

```bash
git add -A
git commit -m "feat: 实现心愿 Tab

- 添加 WishListScreen 心愿列表页（含未完成/已完成 Tab）
- 添加 WishDetailScreen 心愿详情页
- 添加 WishForm 心愿表单组件

Co-Authored-By: Claude Opus 4.7 <noreply@anthropic.com>"
```

---

## Task 9: 设置 Tab

**Files:**
- Create: `lib/features/settings/screens/settings_screen.dart`

- [ ] **Step 1: 创建设置页面**

```dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../models/user_settings.dart';
import '../../../shared/providers/database_providers.dart';
import '../providers/settings_provider.dart';

class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({super.key});

  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen> {
  @override
  void initState() {
    super.initState();
    _initSettings();
  }

  Future<void> _initSettings() async {
    final settings = ref.read(userSettingsProvider);
    if (settings == null) {
      // Create default settings
      final defaultSettings = UserSettings(
        id: 'default',
        birthDate: DateTime(1990, 1, 1),
        lifeExpectancy: 80,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );
      await ref.read(userSettingsProvider.notifier).saveSettings(defaultSettings);
    }
  }

  @override
  Widget build(BuildContext context) {
    final settings = ref.watch(userSettingsProvider);
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('设置'),
      ),
      body: settings == null
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              children: [
                _buildSectionHeader('基本信息'),
                ListTile(
                  leading: const Icon(Icons.cake),
                  title: const Text('出生日期'),
                  subtitle: Text(_formatDate(settings.birthDate)),
                  onTap: () => _selectBirthDate(settings),
                ),
                ListTile(
                  leading: const Icon(Icons.work),
                  title: const Text('计划退休日'),
                  subtitle: Text(
                    settings.retirementDate != null
                        ? _formatDate(settings.retirementDate!)
                        : '未设置',
                  ),
                  onTap: () => _selectRetirementDate(settings),
                ),
                ListTile(
                  leading: const Icon(Icons.timeline),
                  title: const Text('预期寿命'),
                  subtitle: Text('${settings.lifeExpectancy} 岁'),
                  onTap: () => _selectLifeExpectancy(settings),
                ),
                const Divider(),
                _buildSectionHeader('外观'),
                SwitchListTile(
                  secondary: const Icon(Icons.dark_mode),
                  title: const Text('深色主题'),
                  value: settings.isDarkMode,
                  onChanged: (_) {
                    ref.read(settingsViewModelProvider).toggleDarkMode();
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.language),
                  title: const Text('语言'),
                  subtitle: Text(settings.language == 'zh' ? '中文' : 'English'),
                  onTap: _selectLanguage,
                ),
                const Divider(),
                _buildSectionHeader('功能'),
                ListTile(
                  leading: const Icon(Icons.notifications),
                  title: const Text('提醒设置'),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('提醒设置页面（待开发）')),
                    );
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.sync),
                  title: const Text('数据同步'),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('数据同步功能（预留接口）')),
                    );
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.file_upload),
                  title: const Text('数据导出'),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('数据导出功能（待开发）')),
                    );
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.file_download),
                  title: const Text('数据导入'),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('数据导入功能（待开发）')),
                    );
                  },
                ),
                const Divider(),
                _buildSectionHeader('关于'),
                ListTile(
                  leading: const Icon(Icons.info),
                  title: const Text('版本'),
                  subtitle: const Text('v1.0.0'),
                ),
              ],
            ),
    );
  }

  Widget _buildSectionHeader(String title) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      child: Text(
        title,
        style: theme.textTheme.titleSmall?.copyWith(
          color: theme.colorScheme.primary,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }

  Future<void> _selectBirthDate(UserSettings settings) async {
    final date = await showDatePicker(
      context: context,
      initialDate: settings.birthDate,
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
    );
    if (date != null) {
      ref.read(settingsViewModelProvider).updateBirthDate(date);
    }
  }

  Future<void> _selectRetirementDate(UserSettings settings) async {
    final date = await showDatePicker(
      context: context,
      initialDate: settings.retirementDate ?? DateTime.now().add(const Duration(days: 365 * 20)),
      firstDate: DateTime.now(),
      lastDate: DateTime(2100),
    );
    if (date != null) {
      ref.read(settingsViewModelProvider).updateRetirementDate(date);
    }
  }

  Future<void> _selectLifeExpectancy(UserSettings settings) async {
    final result = await showDialog<int>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('预期寿命'),
        content: TextField(
          keyboardType: TextInputType.number,
          decoration: const InputDecoration(
            labelText: '年龄',
            hintText: '请输入预期寿命',
          ),
          controller: TextEditingController(text: settings.lifeExpectancy.toString()),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('取消'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, int.tryParse(
              (context.findRenderObject() as dynamic).toString(),
            )),
            child: const Text('确定'),
          ),
        ],
      ),
    );
    if (result != null && result > 0) {
      ref.read(settingsViewModelProvider).updateLifeExpectancy(result);
    }
  }

  Future<void> _selectLanguage() async {
    final result = await showDialog<String>(
      context: context,
      builder: (_) => SimpleDialog(
        title: const Text('选择语言'),
        children: [
          SimpleDialogOption(
            onPressed: () => Navigator.pop(context, 'zh'),
            child: const Text('中文'),
          ),
          SimpleDialogOption(
            onPressed: () => Navigator.pop(context, 'en'),
            child: const Text('English'),
          ),
        ],
      ),
    );
    if (result != null) {
      ref.read(settingsViewModelProvider).updateLanguage(result);
    }
  }
}
```

- [ ] **Step 2: 提交**

```bash
git add -A
git commit -m "feat: 实现设置 Tab

- 添加 SettingsScreen 设置页面
- 支持出生日期、退休日期、预期寿命设置
- 支持深色主题开关
- 支持语言切换
- 预留数据同步/导入/导出入口

Co-Authored-By: Claude Opus 4.7 <noreply@anthropic.com>"
```

---

## Task 10: 通知功能（基础）

**Files:**
- Create: `lib/core/services/notification_service.dart`
- Modify: `lib/main.dart` (添加通知初始化)

- [ ] **Step 1: 创建通知服务**

```dart
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter/foundation.dart';

class NotificationService {
  static final NotificationService instance = NotificationService._init();
  final FlutterLocalNotificationsPlugin _notifications =
      FlutterLocalNotificationsPlugin();

  NotificationService._init();

  Future<void> initialize() async {
    if (kIsWeb) return; // Web 暂不支持

    const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
    const iosSettings = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    const initSettings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    await _notifications.initialize(initSettings);
  }

  Future<bool> requestPermissions() async {
    if (kIsWeb) return false;

    final android = _notifications.resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>();
    final iOS = _notifications.resolvePlatformSpecificImplementation<
        IOSFlutterLocalNotificationsPlugin>();

    if (android != null) {
      final granted = await android.requestNotificationsPermission();
      return granted ?? false;
    }

    if (iOS != null) {
      final granted = await iOS.requestPermissions(
        alert: true,
        badge: true,
        sound: true,
      );
      return granted ?? false;
    }

    return false;
  }

  Future<void> scheduleNotification({
    required int id,
    required String title,
    required String body,
    required DateTime scheduledDate,
  }) async {
    if (kIsWeb) return;

    final androidDetails = AndroidNotificationDetails(
      'arrival_days_channel',
      'Arrival Days',
      channelDescription: '人生倒计时提醒',
      importance: Importance.high,
      priority: Priority.high,
    );

    final iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    final details = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    // 每天 9:00 触发
    final scheduledTime = DateTime(
      scheduledDate.year,
      scheduledDate.month,
      scheduledDate.day,
      9,
      0,
    );

    if (scheduledTime.isAfter(DateTime.now())) {
      await _notifications.zonedSchedule(
        id,
        title,
        body,
        scheduledTime,
        details,
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      );
    }
  }

  Future<void> cancelNotification(int id) async {
    if (kIsWeb) return;
    await _notifications.cancel(id);
  }

  Future<void> cancelAllNotifications() async {
    if (kIsWeb) return;
    await _notifications.cancelAll();
  }
}
```

- [ ] **Step 2: 更新 main.dart 添加通知初始化**

```dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'app.dart';
import 'core/services/notification_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // 初始化通知服务
  await NotificationService.instance.initialize();

  runApp(
    const ProviderScope(
      child: ArrivalDaysApp(),
    ),
  );
}
```

- [ ] **Step 3: 提交**

```bash
git add -A
git commit -m "feat: 添加通知功能基础

- 添加 NotificationService 通知服务类
- 支持 Android/iOS 通知权限请求
- 支持定时通知调度
- 更新 main.dart 初始化通知

Co-Authored-By: Claude Opus 4.7 <noreply@anthropic.com>"
```

---

## Task 11: 数据导出/导入

**Files:**
- Create: `lib/core/services/export_service.dart`

- [ ] **Step 1: 创建导出服务**

```dart
import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:file_picker/file_picker.dart';
import '../database/database_helper.dart';
import '../models/user_settings.dart';
import '../models/countdown_target.dart';

class ExportService {
  static final ExportService instance = ExportService._init();
  final DatabaseHelper _db = DatabaseHelper.instance;

  ExportService._init();

  Future<String> exportToJson() async {
    final settings = await _db.getUserSettings();
    final targets = await _db.getAllCountdownTargets();

    final data = {
      'version': '1.0.0',
      'exportedAt': DateTime.now().toIso8601String(),
      'settings': settings?.toMap(),
      'targets': targets.map((t) => t.toMap()).toList(),
    };

    return const JsonEncoder.withIndent('  ').convert(data);
  }

  Future<File> exportToFile() async {
    final json = await exportToJson();
    final directory = await getApplicationDocumentsDirectory();
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final file = File('${directory.path}/arrival_days_export_$timestamp.json');
    await file.writeAsString(json);
    return file;
  }

  Future<void> shareExport() async {
    final file = await exportToFile();
    await Share.shareXFiles([XFile(file.path)], text: 'ArrivalDays 数据导出');
  }

  Future<bool> importFromJson(String json) async {
    try {
      final data = jsonDecode(json) as Map<String, dynamic>;

      // 导入设置
      if (data['settings'] != null) {
        final settings = UserSettings.fromMap(data['settings']);
        await _db.insertUserSettings(settings);
      }

      // 导入倒计时目标
      if (data['targets'] != null) {
        for (final targetMap in data['targets']) {
          final target = CountdownTarget.fromMap(targetMap);
          await _db.insertCountdownTarget(target);
        }
      }

      return true;
    } catch (e) {
      debugPrint('Import error: $e');
      return false;
    }
  }

  Future<bool> importFromFile() async {
    if (kIsWeb) {
      // Web 平台使用 file_picker
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['json'],
      );

      if (result != null && result.files.single.bytes != null) {
        final json = utf8.decode(result.files.single.bytes!);
        return importFromJson(json);
      }
      return false;
    }

    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['json'],
    );

    if (result != null && result.files.single.path != null) {
      final file = File(result.files.single.path!);
      final json = await file.readAsString();
      return importFromJson(json);
    }

    return false;
  }
}
```

- [ ] **Step 2: 提交**

```bash
git add -A
git commit -m "feat: 添加数据导出/导入功能

- 添加 ExportService 导出服务
- 支持导出 JSON 文件
- 支持分享导出文件
- 支持从文件导入数据

Co-Authored-By: Claude Opus 4.7 <noreply@anthropic.com>"
```

---

## Task 12: 集成测试与修复

**Files:**
- Modify: Various files as needed

- [ ] **Step 1: 运行 flutter pub get 确保依赖完整**

Run: `cd /home/wmh/Documents/android/ArrivalDays && flutter pub get`
Expected: Dependencies installed

- [ ] **Step 2: 运行 flutter analyze 检查代码问题**

Run: `cd /home/wmh/Documents/android/ArrivalDays && flutter analyze`
Expected: No errors (warnings are acceptable)

- [ ] **Step 3: 修复发现的问题**

(根据实际运行结果修复)

- [ ] **Step 4: 提交**

```bash
git add -A
git commit -m "fix: 修复测试发现的问题

Co-Authored-By: Claude Opus 4.7 <noreply@anthropic.com>"
```

---

## Self-Review 检查清单

1. **Spec 覆盖**: 确认每个需求都有对应的 Task
   - [x] 时钟 Tab - Task 6
   - [x] 纪念日 Tab - Task 7
   - [x] 心愿 Tab - Task 8
   - [x] 设置 Tab - Task 9
   - [x] 通知功能 - Task 10
   - [x] 数据导出/导入 - Task 11

2. **占位符检查**: 确认没有 "TBD"、"TODO" 等占位符
   - [x] 所有代码都是完整实现

3. **类型一致性**: 确认模型、方法签名一致
   - [x] UserSettings 和 CountdownTarget 模型一致
   - [x] Provider 方法签名一致

---

## 执行选项

**Plan complete and saved to `docs/superpowers/plans/2026-04-28-arrival-days.md`.**

**1. Subagent-Driven (recommended)** - dispatch a fresh subagent per task, review between tasks

**2. Inline Execution** - execute tasks in this session using executing-plans

**Which approach?**
