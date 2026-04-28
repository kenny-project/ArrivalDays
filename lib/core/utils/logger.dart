import 'package:flutter/foundation.dart';

enum LogTag {
  db,
  provider,
  settings,
  ui,
  error,
}

class Log {
  Log._();

  static bool _debugMode = true;

  static void setDebugMode(bool enabled) {
    _debugMode = enabled;
  }

  static void d(LogTag tag, String message) {
    if (!_debugMode) return;
    _log('D', tag, message);
  }

  static void i(LogTag tag, String message) {
    _log('I', tag, message);
  }

  static void w(LogTag tag, String message) {
    _log('W', tag, message);
  }

  static void e(LogTag tag, String message, [Object? error, StackTrace? stackTrace]) {
    _log('E', tag, message);
    if (error != null) debugPrint('[$tag] E error: $error');
  }

  static void _log(String level, LogTag tag, String message) {
    final caller = _getCaller();
    debugPrint('[$tag] $level [$caller] $message');
  }

  static String _getCaller() {
    try {
      final stack = StackTrace.current.toString().split('\n');
      if (stack.length >= 4) {
        final frame = stack[4].trim();
        final match = RegExp(r'\(([^)]+:\d+)').firstMatch(frame);
        if (match != null) {
          final path = match.group(1)!;
          final file = path.split('/').last;
          return file;
        }
      }
    } catch (_) {}
    return 'unknown';
  }
}