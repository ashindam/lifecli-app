import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/drive_sync_service.dart';

class SyncState {
  final bool isSyncing;
  final DateTime? lastSynced;
  final String? error;

  const SyncState({this.isSyncing = false, this.lastSynced, this.error});

  SyncState copyWith({bool? isSyncing, DateTime? lastSynced, String? error}) =>
      SyncState(
        isSyncing: isSyncing ?? this.isSyncing,
        lastSynced: lastSynced ?? this.lastSynced,
        error: error,
      );

  String get lastSyncedText {
    if (lastSynced == null) return 'Never synced';
    final diff = DateTime.now().difference(lastSynced!);
    if (diff.inSeconds < 60) return 'Just now';
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    return '${diff.inDays}d ago';
  }
}

class SyncNotifier extends StateNotifier<SyncState> {
  SyncNotifier() : super(SyncState(lastSynced: DriveSyncService.lastSynced));

  Future<void> sync() async {
    if (state.isSyncing) return;
    state = state.copyWith(isSyncing: true, error: null);
    try {
      final success = await DriveSyncService.pullFromDrive();
      state = SyncState(
        isSyncing: false,
        lastSynced: success ? DateTime.now() : state.lastSynced,
        error: success ? null : 'Sync failed — check internet connection',
      );
    } catch (e) {
      state = state.copyWith(isSyncing: false, error: e.toString());
    }
  }

  Future<void> pushModule(String moduleName, List<Map<String, dynamic>> data) async {
    await DriveSyncService.pushModule(moduleName, data);
    state = state.copyWith(lastSynced: DateTime.now());
  }
}

final syncProvider = StateNotifierProvider<SyncNotifier, SyncState>(
  (ref) => SyncNotifier(),
);
