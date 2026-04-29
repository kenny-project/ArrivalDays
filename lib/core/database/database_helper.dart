import 'package:flutter/foundation.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:sqflite_common_ffi_web/sqflite_ffi_web.dart';
import 'tables.dart';
import '../../models/user_settings.dart';
import '../../models/countdown_target.dart';
import '../utils/logger.dart';

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
    Log.i(LogTag.db, 'initDB: $filePath');
    if (kIsWeb) {
      databaseFactory = databaseFactoryFfiWeb;
      return await databaseFactory.openDatabase(
        filePath,
        options: OpenDatabaseOptions(
          version: 3,
          onCreate: _createDB,
          onUpgrade: _upgradeDB,
        ),
      );
    }

    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);
    Log.i(LogTag.db, 'native path: $path');

    return await openDatabase(
      path,
      version: 3,
      onCreate: _createDB,
      onUpgrade: _upgradeDB,
    );
  }

  Future<void> _upgradeDB(Database db, int oldVersion, int newVersion) async {
    Log.i(LogTag.db, 'upgrade DB: $oldVersion -> $newVersion');
    if (oldVersion < 2) {
      await db.execute('ALTER TABLE $tableCountdownTargets ADD COLUMN is_lunar_calendar INTEGER DEFAULT 0');
      Log.i(LogTag.db, 'added is_lunar_calendar column');
    }
    if (oldVersion < 3) {
      await db.execute('ALTER TABLE $tableCountdownTargets ADD COLUMN use_date INTEGER');
      Log.i(LogTag.db, 'added use_date column');
    }
  }

  Future<void> _createDB(Database db, int version) async {
    Log.i(LogTag.db, 'createTables');
    await db.execute(createUserSettingsTable);
    await db.execute(createCountdownTargetsTable);
  }

  Future<int> insertUserSettings(UserSettings settings) async {
    final db = await database;
    Log.i(LogTag.db, 'save settings: birthDate=${settings.birthDate}');
    final result = await db.insert(
      tableUserSettings,
      settings.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
    Log.i(LogTag.db, 'save result: $result');
    return result;
  }

  Future<UserSettings?> getUserSettings() async {
    final db = await database;
    final maps = await db.query(tableUserSettings, limit: 1);
    if (maps.isEmpty) {
      Log.i(LogTag.db, 'load settings: none');
      return null;
    }
    final result = UserSettings.fromMap(maps.first);
    Log.i(LogTag.db, 'load settings: birthDate=${result.birthDate}');
    return result;
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

  Future<int> insertCountdownTarget(CountdownTarget target) async {
    final db = await database;
    Log.i(LogTag.db, 'save target: ${target.name}');
    return await db.insert(
      tableCountdownTargets,
      target.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<List<CountdownTarget>> getAllCountdownTargets() async {
    final db = await database;
    final maps = await db.query(tableCountdownTargets);
    Log.i(LogTag.db, 'load targets: ${maps.length}');
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