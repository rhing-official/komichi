import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive/hive.dart';
import 'package:uuid/uuid.dart';
import '../../features/library/models/book.dart';
import '../../features/settings/providers/settings_provider.dart';

class TabItem {
  final String id;
  String title;
  String? bookId, shelfId, path;
  List<String> segments;
  List<Map<String, dynamic>> history;
  int historyIndex;
  bool isSettings;
  bool isFavorites;

  TabItem({
    required this.id,
    this.title = '本棚',
    this.bookId,
    this.shelfId,
    this.path,
    this.segments = const ['トップ'],
    this.history = const [{}],
    this.historyIndex = 0,
    this.isSettings = false,
    this.isFavorites = false,
  });
}

class TabState {
  final List<TabItem> tabs;
  final int currentIndex;
  TabState({required this.tabs, required this.currentIndex});
}

class TabNotifier extends StateNotifier<TabState> {
  final Ref ref;
  TabNotifier(this.ref) : super(_initialState(ref));

  // 起動時：終了時に読んでいた書籍があれば、そのビューワーを最初のタブとして開く
  static TabState _initialState(Ref ref) {
    final bookId = ref.read(settingsProvider).lastOpenBookId;
    if (bookId != null && Hive.isBoxOpen('books')) {
      final book = Hive.box<Book>('books').get(bookId);
      if (book != null) {
        return TabState(tabs: [
          TabItem(
              id: 'root',
              title: book.title,
              bookId: book.id,
              shelfId: book.shelfId,
              segments: ['トップ', book.title])
        ], currentIndex: 0);
      }
    }
    return TabState(tabs: [TabItem(id: 'root')], currentIndex: 0);
  }

  // 現在フォーカス中のタブが開いている書籍を、次回起動時の自動再開用に保存する。
  // 書籍を閉じた（現在のタブが書籍でなくなった）場合は保存内容もクリアする
  @override
  set state(TabState value) {
    super.state = value;
    final bookId = value.tabs[value.currentIndex].bookId;
    final settingsNotifier = ref.read(settingsProvider.notifier);
    if (ref.read(settingsProvider).lastOpenBookId != bookId) {
      settingsNotifier.state = bookId == null
          ? ref.read(settingsProvider).copyWith(clearLastOpenBookId: true)
          : ref.read(settingsProvider).copyWith(lastOpenBookId: bookId);
    }
  }

  void resetTabs() =>
      state = TabState(tabs: [TabItem(id: 'root')], currentIndex: 0);

  void selectTab(int i) => state = TabState(tabs: state.tabs, currentIndex: i);
  void nextTab() => selectTab((state.currentIndex + 1) % state.tabs.length);
  void previousTab() => selectTab(
      (state.currentIndex - 1 + state.tabs.length) % state.tabs.length);

  void addLibraryTab() {
    state = TabState(
        tabs: [...state.tabs, TabItem(id: const Uuid().v4())],
        currentIndex: state.tabs.length);
  }

  void openSettings() {
    final idx = state.tabs.indexWhere((t) => t.isSettings);
    if (idx != -1) return selectTab(idx);
    state = TabState(tabs: [
      ...state.tabs,
      TabItem(
          id: const Uuid().v4(),
          title: '設定',
          isSettings: true,
          segments: ['トップ', '設定'])
    ], currentIndex: state.tabs.length);
  }

  void openFavorites() {
    final idx = state.tabs.indexWhere((t) => t.isFavorites);
    if (idx != -1) return selectTab(idx);
    state = TabState(tabs: [
      ...state.tabs,
      TabItem(
          id: const Uuid().v4(),
          title: 'お気に入り',
          isFavorites: true,
          segments: ['トップ', 'お気に入り'])
    ], currentIndex: state.tabs.length);
  }

  void navigateTo(String? shelfId,
      {String? path,
      String? title,
      List<String>? segments,
      bool openInNewTab = false}) {
    if (openInNewTab) {
      state = TabState(tabs: [
        ...state.tabs,
        TabItem(
            id: const Uuid().v4(),
            title: title ?? '本棚',
            shelfId: shelfId,
            path: path,
            segments: segments ?? ['トップ'],
            history: [
              {
                'shelfId': shelfId,
                'path': path,
                'title': title,
                'segments': segments
              }
            ],
            historyIndex: 0)
      ], currentIndex: state.tabs.length);
      return;
    }
    final newTabs = [...state.tabs];
    final current = newTabs[state.currentIndex];
    final newHistory = List<Map<String, dynamic>>.from(
        current.history.sublist(0, current.historyIndex + 1));
    newHistory.add({
      'shelfId': shelfId,
      'path': path,
      'title': title,
      'segments': segments
    });
    newTabs[state.currentIndex] = TabItem(
        id: current.id,
        title: title ?? '本棚',
        shelfId: shelfId,
        path: path,
        segments: segments ?? ['トップ'],
        history: newHistory,
        historyIndex: newHistory.length - 1,
        bookId: null);
    state = TabState(tabs: newTabs, currentIndex: state.currentIndex);
  }

  void openBook(String bookId, String title, bool openInNewTab,
      {String? currentShelfId, String? currentPath, List<String>? segments}) {
    final existingIndex = state.tabs.indexWhere((t) => t.bookId == bookId);
    if (existingIndex != -1) return selectTab(existingIndex);
    final finalSegments = segments ?? ['トップ', title];

    if (openInNewTab) {
      state = TabState(tabs: [
        ...state.tabs,
        TabItem(
            id: const Uuid().v4(),
            title: title,
            bookId: bookId,
            shelfId: currentShelfId,
            path: currentPath,
            segments: finalSegments)
      ], currentIndex: state.tabs.length);
    } else {
      final newTabs = [...state.tabs];
      newTabs[state.currentIndex] = TabItem(
          id: state.tabs[state.currentIndex].id,
          title: title,
          bookId: bookId,
          shelfId: currentShelfId ?? state.tabs[state.currentIndex].shelfId,
          path: currentPath ?? state.tabs[state.currentIndex].path,
          segments: finalSegments,
          history: state.tabs[state.currentIndex].history,
          historyIndex: state.tabs[state.currentIndex].historyIndex);
      state = TabState(tabs: newTabs, currentIndex: state.currentIndex);
    }
  }

  void closeBook(TabItem currentTab) {
    final newSegs = List<String>.from(currentTab.segments);
    if (newSegs.length > 1) newSegs.removeLast();
    navigateTo(currentTab.shelfId,
        path: currentTab.path,
        title: currentTab.path?.split('/').last ?? '本棚',
        segments: newSegs);
  }

  void closeTab(int index) {
    final newTabs = [...state.tabs]..removeAt(index);
    if (newTabs.isEmpty) {
      resetTabs();
    } else {
      state = TabState(
          tabs: newTabs,
          currentIndex: (index <= state.currentIndex)
              ? (state.currentIndex - 1).clamp(0, newTabs.length - 1)
              : state.currentIndex);
    }
  }

  void undo() {
    final current = state.tabs[state.currentIndex];
    if (current.historyIndex > 0)
      _apply(
          current.history[current.historyIndex - 1], current.historyIndex - 1);
  }

  void redo() {
    final current = state.tabs[state.currentIndex];
    if (current.historyIndex < current.history.length - 1)
      _apply(
          current.history[current.historyIndex + 1], current.historyIndex + 1);
  }

  void _apply(Map<String, dynamic> h, int idx) {
    final newTabs = [...state.tabs];
    newTabs[state.currentIndex] = TabItem(
        id: state.tabs[state.currentIndex].id,
        title: h['title'] ?? '本棚',
        shelfId: h['shelfId'],
        path: h['path'],
        segments: h['segments'] ?? ['トップ'],
        bookId: h['bookId'],
        history: state.tabs[state.currentIndex].history,
        historyIndex: idx);
    state = TabState(tabs: newTabs, currentIndex: state.currentIndex);
  }
}

final tabProvider =
    StateNotifierProvider<TabNotifier, TabState>((ref) => TabNotifier(ref));
