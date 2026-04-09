import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:intl/intl.dart';

class DebugLogger {
  static Future<File> get _logFile async {
    final directory = await getApplicationDocumentsDirectory();
    final logDir = Directory('${directory.path}/data');
    if (!await logDir.exists()) {
      await logDir.create(recursive: true);
    }
    return File('${logDir.path}/community_debug.log');
  }

  static Future<void> log(String message) async {
    try {
      final file = await _logFile;
      final timestamp = DateFormat('yyyy-MM-dd HH:mm:ss').format(DateTime.now());
      final logEntry = '[$timestamp] $message\n';
      
      // Also print to console
      print(logEntry);
      
      // Append to file
      await file.writeAsString(logEntry, mode: FileMode.append);
    } catch (e) {
      print('Error writing to log file: $e');
    }
  }

  static Future<String> readLogs() async {
    try {
      final file = await _logFile;
      if (await file.exists()) {
        return await file.readAsString();
      }
      return 'No logs found.';
    } catch (e) {
      return 'Error reading logs: $e';
    }
  }

  static Future<void> clearLogs() async {
    try {
      final file = await _logFile;
      if (await file.exists()) {
        await file.delete();
      }
    } catch (e) {
      print('Error clearing logs: $e');
    }
  }
}
