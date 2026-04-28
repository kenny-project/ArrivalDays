import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:file_picker/file_picker.dart';
import '../database/database_helper.dart';
import '../../models/user_settings.dart';
import '../../models/countdown_target.dart';

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

      if (data['settings'] != null) {
        final settings = UserSettings.fromMap(data['settings']);
        await _db.insertUserSettings(settings);
      }

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