import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:googleapis/drive/v3.dart' as drive;
import 'package:shared_preferences/shared_preferences.dart';
import '../services/google_auth_service.dart';
import '../services/hive_service.dart';

typedef JsonMap = Map<String, dynamic>;

class DriveSyncService {
  static const String _lastSyncKey = 'last_sync_timestamp';
  static const List<String> _moduleFiles = [
    'tasks.json',
    'notes.json',
    'habits.json',
    'habit_logs.json',
    'expenses.json',
    'budgets.json',
    'allowance.json',
    'finance.json',
    'bill_splits.json',
    'tuition.json',
    'class_routine.json',
    'exams.json',
    'assignments.json',
    'attendance.json',
    'syllabus.json',
    'grades.json',
    'study_sessions.json',
    'pomodoro.json',
    'subscriptions.json',
    'bus_routes.json',
    'notices.json',
    'load_shedding.json',
    'inbox.json',
    'health_logs.json',
    'reading.json',
    'settings.json',
    'profile.json',
  ];

  static bool _isSyncing = false;
  static bool get isSyncing => _isSyncing;

  static DateTime? _lastSynced;
  static DateTime? get lastSynced => _lastSynced;

  static Future<void> init() async {
    final prefs = await SharedPreferences.getInstance();
    final ts = prefs.getInt(_lastSyncKey);
    if (ts != null) {
      _lastSynced = DateTime.fromMillisecondsSinceEpoch(ts);
    }
  }

  // Pull all module data from Drive
  static Future<bool> pullFromDrive() async {
    if (_isSyncing) return false;
    _isSyncing = true;
    try {
      final driveApi = await GoogleAuthService.getDriveApi();
      if (driveApi == null) return false;

      for (final fileName in _moduleFiles) {
        await _pullFile(driveApi, fileName);
      }

      _lastSynced = DateTime.now();
      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt(_lastSyncKey, _lastSynced!.millisecondsSinceEpoch);
      return true;
    } catch (e) {
      debugPrint('Drive pull error: $e');
      return false;
    } finally {
      _isSyncing = false;
    }
  }

  // Push a single module file to Drive
  static Future<bool> pushModule(String moduleName, List<JsonMap> data) async {
    try {
      final driveApi = await GoogleAuthService.getDriveApi();
      if (driveApi == null) return false;

      final fileName = '$moduleName.json';
      final content = jsonEncode({'data': data, 'updated_at': DateTime.now().millisecondsSinceEpoch});
      await _pushFile(driveApi, fileName, content);
      return true;
    } catch (e) {
      debugPrint('Drive push error for $moduleName: $e');
      return false;
    }
  }

  static Future<void> _pullFile(drive.DriveApi api, String fileName) async {
    try {
      final fileList = await api.files.list(
        spaces: 'appDataFolder',
        q: "name = '$fileName'",
        $fields: 'files(id, name)',
      );

      if (fileList.files == null || fileList.files!.isEmpty) return;

      final fileId = fileList.files!.first.id!;
      final response = await api.files.get(
        fileId,
        downloadOptions: drive.DownloadOptions.fullMedia,
      ) as drive.Media;

      final bytes = await _collectBytes(response.stream);
      final content = utf8.decode(bytes);
      final decoded = jsonDecode(content) as JsonMap;

      // Store raw JSON in settings box keyed by fileName for merge
      HiveService.settings.put('drive_$fileName', content);
      debugPrint('Pulled $fileName (${bytes.length} bytes)');
    } catch (e) {
      debugPrint('Pull error for $fileName: $e');
    }
  }

  static Future<void> _pushFile(drive.DriveApi api, String fileName, String content) async {
    final bytes = utf8.encode(content);
    final stream = Stream.fromIterable([bytes]);
    final media = drive.Media(stream, bytes.length, contentType: 'application/json');

    final fileList = await api.files.list(
      spaces: 'appDataFolder',
      q: "name = '$fileName'",
      $fields: 'files(id)',
    );

    if (fileList.files != null && fileList.files!.isNotEmpty) {
      await api.files.update(drive.File(), fileList.files!.first.id!, uploadMedia: media);
    } else {
      final driveFile = drive.File()
        ..name = fileName
        ..parents = ['appDataFolder'];
      await api.files.create(driveFile, uploadMedia: media);
    }
    debugPrint('Pushed $fileName');
  }

  static Future<List<int>> _collectBytes(Stream<List<int>> stream) async {
    final bytes = <int>[];
    await for (final chunk in stream) {
      bytes.addAll(chunk);
    }
    return bytes;
  }

  static String? getCachedDriveData(String moduleName) {
    return HiveService.settings.get('drive_$moduleName.json') as String?;
  }
}
