import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/inbox_item_model.dart';
import '../../../../core/services/hive_service.dart';

class InboxState {
  final List<InboxItemModel> items;
  const InboxState({this.items = const []});
  InboxState copyWith({List<InboxItemModel>? items}) => InboxState(items: items ?? this.items);
  int get unprocessedCount => items.where((i) => i.status == InboxStatus.unprocessed.index).length;
  List<InboxItemModel> get unprocessed => items.where((i) => i.status == InboxStatus.unprocessed.index).toList();
}

class InboxNotifier extends StateNotifier<InboxState> {
  InboxNotifier() : super(const InboxState()) { _load(); }

  void _load() {
    final items = HiveService.inbox.values.whereType<InboxItemModel>().toList();
    items.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    state = InboxState(items: items);
  }

  Future<void> addItem(String content) async {
    final item = InboxItemModel(content: content);
    await HiveService.inbox.put(item.id, item);
    state = state.copyWith(items: [item, ...state.items]);
  }

  Future<void> processItem(String id, String convertedTo) async {
    final idx = state.items.indexWhere((i) => i.id == id);
    if (idx < 0) return;
    final updated = state.items[idx].copyWith(
      status: InboxStatus.converted.index,
      convertedTo: convertedTo,
    );
    await HiveService.inbox.put(id, updated);
    final list = [...state.items];
    list[idx] = updated;
    state = state.copyWith(items: list);
  }

  Future<void> discard(String id) async {
    final idx = state.items.indexWhere((i) => i.id == id);
    if (idx < 0) return;
    final updated = state.items[idx].copyWith(status: InboxStatus.discarded.index);
    await HiveService.inbox.put(id, updated);
    final list = [...state.items];
    list[idx] = updated;
    state = state.copyWith(items: list);
  }

  Future<void> deleteItem(String id) async {
    await HiveService.inbox.delete(id);
    state = state.copyWith(items: state.items.where((i) => i.id != id).toList());
  }
}

final inboxProvider = StateNotifierProvider<InboxNotifier, InboxState>(
  (ref) => InboxNotifier(),
);
