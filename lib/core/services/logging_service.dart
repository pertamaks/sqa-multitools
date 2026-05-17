import 'dart:io';
import 'dart:developer' as developer;
import 'package:flutter/foundation.dart';
import 'package:logging/logging.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;

part 'logging_service.g.dart';

/// A centralized service for application-wide logging.
/// This service captures structured logs and can eventually be configured 
/// to persist them to a file or send them to an external observability tool.
@Riverpod(keepAlive: true)
class LoggingService extends _$LoggingService {
  final List<LogRecord> _logs = [];
  static const int _maxLogs = 1000;
  File? _logFile;

  @override
  void build() {
    // Standard configuration for the 'logging' package
    Logger.root.level = kDebugMode ? Level.ALL : Level.INFO;

    _initFileLogging();
    
    Logger.root.onRecord.listen((record) {
      _logs.add(record);
      if (_logs.length > _maxLogs) {
        _logs.removeAt(0);
      }

      // Output to developer console
      developer.log(
        record.message,
        time: record.time,
        sequenceNumber: record.sequenceNumber,
        level: record.level.value,
        name: record.loggerName,
        error: record.error,
        stackTrace: record.stackTrace,
      );

      // Write to file
      _writeToLogFile(record);

      // In debug mode, also print to console for easier visibility in some IDEs
      if (kDebugMode) {
        // ignore: avoid_print
        print('${record.time} [${record.level.name}] ${record.loggerName}: ${record.message}');
        if (record.error != null) {
          // ignore: avoid_print
          print('Error: ${record.error}');
        }
        if (record.stackTrace != null) {
          // ignore: avoid_print
          print('StackTrace: ${record.stackTrace}');
        }
      }
    });

    logInfo('Logging initialized');
  }

  Future<void> _initFileLogging() async {
    try {
      final dir = await getApplicationSupportDirectory();
      final logDir = Directory(p.join(dir.path, 'logs'));
      if (!await logDir.exists()) {
        await logDir.create(recursive: true);
      }

      final file = File(p.join(logDir.path, 'app.log'));
      
      // If file exists and is > 5MB, clear it (simple rotation)
      if (await file.exists()) {
        final size = await file.length();
        if (size > 5 * 1024 * 1024) {
          await file.writeAsString('-- Log rotated at ${DateTime.now()} --\n');
        }
      } else {
        await file.create();
      }

      _logFile = file;
    } catch (e) {
      debugPrint('Failed to initialize file logging: $e');
    }
  }

  void _writeToLogFile(LogRecord record) {
    if (_logFile == null) return;

    final timestamp = record.time.toIso8601String();
    final level = record.level.name;
    final name = record.loggerName;
    final message = record.message;
    final error = record.error != null ? ' | Error: ${record.error}' : '';
    final stack = record.stackTrace != null ? '\n${record.stackTrace}' : '';

    final logLine = '$timestamp [$level] $name: $message$error$stack\n';
    
    try {
      _logFile?.writeAsStringSync(logLine, mode: FileMode.append);
    } catch (e) {
      // Avoid recursive logging on file write error
      debugPrint('Error writing to log file: $e');
    }
  }

  /// Returns the path to the current log file.
  Future<String?> getLogFilePath() async {
    if (_logFile != null) return _logFile!.path;
    final dir = await getApplicationSupportDirectory();
    return p.join(dir.path, 'logs', 'app.log');
  }

  /// Returns a snapshot of the current logs.
  List<LogRecord> get logs => List.unmodifiable(_logs);

  void logInfo(String message, [String? name]) {
    Logger(name ?? 'App').info(message);
  }

  void logWarning(String message, [String? name, Object? error, StackTrace? stackTrace]) {
    Logger(name ?? 'App').warning(message, error, stackTrace);
  }

  void logError(String message, [String? name, Object? error, StackTrace? stackTrace]) {
    Logger(name ?? 'App').severe(message, error, stackTrace);
  }

  void logDebug(String message, [String? name]) {
    Logger(name ?? 'App').fine(message);
  }
}
