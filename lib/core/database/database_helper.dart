import 'package:flutter/foundation.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:sqflite_common_ffi_web/sqflite_ffi_web.dart';
import 'tables.dart';
import '../../models/user_settings.dart';
import '../../models/countdown_target.dart';

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
    debugPrint('[DB] _initDB called with path: $filePath');
    if (kIsWeb) {
      databaseFactory = databaseFactoryFfiWeb;
      debugPrint('[DB] Web platform detected, using FFI web');
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
    debugPrint('[DB] Native platform, DB path: $path');

    return await openDatabase(
      path,
      version: 1,
      onCreate: _createDB,
    );
  }

  Future<void> _createDB(Database db, int version) async {
    debugPrint('[DB] _createDB called');
    await db.execute(createUserSettingsTable);
    await db.execute(createCountdownTargetsTable);
    debugPrint('[DB] Tables created successfully');
  }

  // UserSettings CRUD
  Future<int> insertUserSettings(UserSettings settings) async {
    final db = await database;
    debugPrint('[DB] insertUserSettings called: ${settings.id}');
    debugPrint('[DB]   birthDate: ${settings.birthDate}');
    debugPrint('[DB]   isDarkMode: ${settings.isDarkMode}');
    debugPrint('[DB]   language: ${settings.language}');
    final result = await db.insert(
      tableUserSettings,
      settings.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
    debugPrint('[DB] insertUserSettings result: $result');
    return result;
  }

  Future<UserSettings?> getUserSettings() async {
    final db = await database;
    debugPrint('[DB] getUserSettings called');
    final maps = await db.query(tableUserSettings, limit: 1);
    debugPrint('[DB] getUserSettings query result count: ${maps.length}');
    if (maps.isEmpty) {
      debugPrint('[DB] getUserSettings: no settings found');
      return null;
    }
    final result = UserSettings.fromMap(maps.first);
    debugPrint('[DB] getUserSettings: ${result.id}, birthDate: ${result.birthDate}');
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

  // CountdownTarget CRUD
  Future<int> insertCountdownTarget(CountdownTarget target) async {
    final db = await database;
    debugPrint('[DB] insertCountdownTarget called: ${target.id}, name: ${target.name}, type: ${target.type}');
    final result = await db.insert(
      tableCountdownTargets,
      target.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
    debugPrint('[DB] insertCountdownTarget result: $result');
    return result;
  }

  Future<List<CountdownTarget>> getAllCountdownTargets() async {
    final db = await database;
    debugPrint('[DB] getAllCountdownTargets called');
    final maps = await db.query(tableCountdownTargets);
    debugPrint('[DB] getAllCountdownTargets query result count: ${maps.length}');
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