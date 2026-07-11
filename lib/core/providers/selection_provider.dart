import 'package:flutter_riverpod/flutter_riverpod.dart';

class SelectionState {
  final Set<String> selectedIds;
  final int? lastIndex;
  SelectionState({this.selectedIds = const {}, this.lastIndex});
  SelectionState copyWith({Set<String>? selectedIds, int? lastIndex}) =>
      SelectionState(
          selectedIds: selectedIds ?? this.selectedIds,
          lastIndex: lastIndex ?? this.lastIndex);
}

class SelectionNotifier extends StateNotifier<SelectionState> {
  SelectionNotifier() : super(SelectionState());
  void toggle(String id, int index) {
    final currentIds = {...state.selectedIds};
    if (currentIds.contains(id)) {
      currentIds.remove(id);
    } else {
      currentIds.add(id);
    }
    state = state.copyWith(selectedIds: currentIds, lastIndex: index);
  }

  void selectAll(List<String> allIds) {
    if (state.selectedIds.length == allIds.length &&
        allIds.every(state.selectedIds.contains)) {
      clear();
    } else {
      state = state.copyWith(selectedIds: Set.from(allIds));
    }
  }

  void selectRange(int currentIndex, List<String> allIds) {
    if (state.lastIndex == null) {
      toggle(allIds[currentIndex], currentIndex);
      return;
    }
    final start =
        state.lastIndex! < currentIndex ? state.lastIndex! : currentIndex;
    final end =
        state.lastIndex! < currentIndex ? currentIndex : state.lastIndex!;
    final newSelection = <String>{};
    for (int i = start; i <= end; i++) {
      newSelection.add(allIds[i]);
    }
    // アンカー(lastIndex)はここでは更新しない。Ctrl+クリックと違い、
    // Shift+クリックは「その都度、固定アンカーからの範囲で選択し直す」動作にするため。
    state = state.copyWith(selectedIds: newSelection);
  }

  void clear() => state = SelectionState();
}

final selectionProvider =
    StateNotifierProvider<SelectionNotifier, SelectionState>(
        (ref) => SelectionNotifier());
