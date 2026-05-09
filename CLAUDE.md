# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

ArrivalDays is a Flutter life countdown app ("人生倒计时") that tracks life timer, retirement, anniversaries, birthdays, and wishes. It targets Android primarily, with iOS and web support. The product spec is in `SPEC.md` (Chinese).

## Common Commands

```bash
# Run the app
flutter run

# Run all tests
flutter test

# Run a single test file
flutter test test/core/utils/countdown_utils_test.dart

# Run tests with verbose output
flutter test --reporter expanded

# Analyze code
flutter analyze

# Build APK
flutter build apk

# Build for web
flutter build web

# Code generation (Riverpod annotations - though manual providers are primarily used)
dart run build_runner build
```

## Architecture

**Feature-first directory structure** with MVVM-like ViewModels using Riverpod.

### State Management (Riverpod)

Provider hierarchy flows top-down:
1. **Core providers** (`lib/shared/providers/`) — `databaseHelperProvider`, `userSettingsProvider`, `countdownTargetsProvider` (StateNotifiers for DB CRUD)
2. **Ticker** (`lib/features/clock/providers/ticker_provider.dart`) — 1-second `StateProvider<DateTime>` updated from `MainScreen` timer
3. **Derived providers** (`lib/features/clock/providers/clock_provider.dart`) — computed life/retirement/anniversary/wish lists
4. **ViewModels** (per-feature `*_provider.dart`) — wrap CRUD operations for screens

### Navigation

4-tab `NavigationBar` with `IndexedStack` in `MainScreen` (`lib/app.dart`): Clock → Anniversary → Wish → Settings. Detail screens use `Navigator.push`.

### Data Layer

- SQLite via `sqflite` (web: `sqflite_common_ffi_web`)
- `DatabaseHelper` singleton in `lib/core/database/database_helper.dart`
- 2 tables: `user_settings`, `countdown_targets` (schema in `tables.dart`, version 3)
- Models: `UserSettings`, `CountdownTarget` with `copyWith()`/`toMap()`/`fromMap()`
- `CountdownTargetType` enum: `lifeTimer`, `anniversary`, `birthday`, `wish`
- Lunar calendar support via `isLunarCalendar` and `useDate` fields

### Localization

Manual localization (not `intl` codegen) in `lib/l10n/app_localizations.dart` with ARB files for zh/en.

## Key Patterns

- **All screens are ConsumerWidgets/ConsumerStatefulWidgets** — read providers with `ref.watch()`/`ref.read()`
- **Immutable models** with `copyWith()` — never mutate model instances directly
- **Forms use bottom sheets** (`showModalBottomSheet`) for add/edit operations
- **Countdown display** uses `CountdownDuration` extension methods in `lib/core/utils/countdown_utils.dart` — respect zero-suppression rules documented in memory
- **IDs are UUIDs** generated via the `uuid` package
- **Logger** (`lib/core/utils/logger.dart`) — use `Logger.log(tag, message)` for debug output; do not remove debug log statements, only silence overly frequent ones

## Tests

Pure unit tests only (no widget or integration tests). Provider tests simulate logic in-memory without real DB. Run with `flutter test`.
