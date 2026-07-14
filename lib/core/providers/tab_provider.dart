import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive/hive.dart';
import 'package:uuid/uuid.dart';
import '../../features/library/models/book.dart';
import '../../features/library/models/shelf.dart';
import '../../features/settings/providers/settings_provider.dart';
import '../../features/settings/models/app_settings.dart';

enum _SpecialTabKind { settings, favorites, information }

class TabItem {
  final String id;
  String title;
  String? bookId, shelfId, path;
  List<String> segments;
  List<Map<String, dynamic>> history;
  int historyIndex;
  bool isSettings;
  bool isFavorites;
  bool isInformation;

  TabItem({
    required this.id,
    this.title = 'トップ',
    this.bookId,
    this.shelfId,
    this.path,
    this.segments = const ['トップ'],
    this.history = const [{}],
    this.historyIndex = 0,
    this.isSettings = false,
    this.isFavorites = false,
    this.isInformation = false,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'bookId': bookId,
        'shelfId': shelfId,
        'path': path,
        'segments': segments,
        'history': history,
        'historyIndex': historyIndex,
        'isSettings': isSettings,
        'isFavorites': isFavorites,
        'isInformation': isInformation,
      };

  static TabItem fromJson(Map<String, dynamic> json) => TabItem(
        id: json['id'] as String,
        title: json['title'] as String? ?? 'トップ',
        bookId: json['bookId'] as String?,
        shelfId: json['shelfId'] as String?,
        path: json['path'] as String?,
        segments: (json['segments'] as List?)?.map((e) => e as String).toList() ??
            const ['トップ'],
        history: (json['history'] as List?)
                ?.map((e) => Map<String, dynamic>.from(e as Map))
                .toList() ??
            const [{}],
        historyIndex: json['historyIndex'] as int? ?? 0,
        isSettings: json['isSettings'] as bool? ?? false,
        isFavorites: json['isFavorites'] as bool? ?? false,
        isInformation: json['isInformation'] as bool? ?? false,
      );
}

class TabState {
  final List<TabItem> tabs;
  final int currentIndex;
  TabState({required this.tabs, required this.currentIndex});

  String toJson() => jsonEncode({
        'tabs': tabs.map((t) => t.toJson()).toList(),
        'currentIndex': currentIndex,
      });

  // 保存されたJSONからタブ一式を復元する。参照先の書籍/本棚が既に削除されている
  // タブは復元対象から除外し、全て無効だった場合や解析に失敗した場合はnullを返す
  static TabState? tryFromJson(
    String jsonStr, {
    required bool Function(String) bookExists,
    required bool Function(String) shelfExists,
  }) {
    try {
      final data = jsonDecode(jsonStr) as Map<String, dynamic>;
      final rawTabs = (data['tabs'] as List)
          .map((e) => TabItem.fromJson(Map<String, dynamic>.from(e as Map)))
          .toList();
      final originalCurrentIndex = data['currentIndex'] as int? ?? 0;
      final kept = <TabItem>[];
      int? newCurrentIndex;
      for (var i = 0; i < rawTabs.length; i++) {
        final t = rawTabs[i];
        final valid = (t.bookId == null || bookExists(t.bookId!)) &&
            (t.shelfId == null || shelfExists(t.shelfId!));
        if (valid) {
          if (i == originalCurrentIndex) newCurrentIndex = kept.length;
          kept.add(t);
        }
      }
      if (kept.isEmpty) return null;
      return TabState(
          tabs: kept, currentIndex: (newCurrentIndex ?? 0).clamp(0, kept.length - 1));
    } catch (_) {
      return null;
    }
  }
}

class TabNotifier extends StateNotifier<TabState> {
  final Ref ref;
  TabNotifier(this.ref) : super(_initialState(ref));

  // 起動時：設定が「前回のタブを復元」かつ終了時に読んでいた書籍があれば、
  // そのビューワーを最初のタブとして開く。「常に本棚タブ」設定の場合は、
  // 書籍を開かず常に素の本棚タブから始める（読書履歴自体は別途Book側に
  // 保存されており、この設定の影響を受けない）
  static TabState _initialState(Ref ref) {
    final settings = ref.read(settingsProvider);
    if (settings.launchTabBehavior == LaunchTabBehavior.resumeLastBook &&
        Hive.isBoxOpen('books') &&
        Hive.isBoxOpen('shelves')) {
      final savedJson = settings.savedTabsJson;
      if (savedJson != null) {
        final restored = TabState.tryFromJson(
          savedJson,
          bookExists: (id) => Hive.box<Book>('books').containsKey(id),
          shelfExists: (id) => Hive.box<Shelf>('shelves').containsKey(id),
        );
        if (restored != null) return restored;
      }
      // 後方互換：まだsavedTabsJsonを持たない（旧バージョンの）データの場合、
      // 前回開いていた書籍1件だけでも復元する
      final bookId = settings.lastOpenBookId;
      if (bookId != null) {
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
    }
    return TabState(tabs: [TabItem(id: 'root')], currentIndex: 0);
  }

  // 開いているタブ全体（本棚・書籍・設定・お気に入りタブと選択状態）を、次回
  // 起動時の復元用にJSONとして保存する。読書履歴（Book.lastPage等）はここでは
  // 一切触らないため、「常に本棚タブから始める」設定に切り替えても影響しない
  @override
  set state(TabState value) {
    super.state = value;
    final bookId = value.tabs[value.currentIndex].bookId;
    final settingsNotifier = ref.read(settingsProvider.notifier);
    final settings = ref.read(settingsProvider);
    final newJson = value.toJson();
    if (settings.lastOpenBookId != bookId || settings.savedTabsJson != newJson) {
      settingsNotifier.state = settings.copyWith(
        lastOpenBookId: bookId,
        clearLastOpenBookId: bookId == null,
        savedTabsJson: newJson,
      );
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

  void openInformation() {
    final idx = state.tabs.indexWhere((t) => t.isInformation);
    if (idx != -1) return selectTab(idx);
    state = TabState(tabs: [
      ...state.tabs,
      TabItem(
          id: const Uuid().v4(),
          title: '情報',
          isInformation: true,
          segments: ['トップ', '情報'])
    ], currentIndex: state.tabs.length);
  }

  // 設定/お気に入り/情報アイコンが押された時の実際の窓口。設定の
  // settingsFavoritesOpenModeに応じて「専用タブを開く/切り替える」
  // （従来の挙動）と「現在のタブ内でその場に切り替え、再度押すと戻る」を
  // 切り替える
  void openOrToggleSettings() {
    ref.read(settingsProvider).settingsFavoritesOpenMode ==
            SettingsFavoritesOpenMode.toggleInPlace
        ? _toggleInPlace(kind: _SpecialTabKind.settings)
        : openSettings();
  }

  void openOrToggleFavorites() {
    ref.read(settingsProvider).settingsFavoritesOpenMode ==
            SettingsFavoritesOpenMode.toggleInPlace
        ? _toggleInPlace(kind: _SpecialTabKind.favorites)
        : openFavorites();
  }

  void openOrToggleInformation() {
    ref.read(settingsProvider).settingsFavoritesOpenMode ==
            SettingsFavoritesOpenMode.toggleInPlace
        ? _toggleInPlace(kind: _SpecialTabKind.information)
        : openInformation();
  }

  // 現在のタブ内で設定/お気に入り/情報とその手前の表示を行き来するトグル。
  // navigateTo()/openBook()と同じ「現在位置以降の履歴を切り詰めてpush」
  // パターンで積むため、既にpush済み（isSettings/isFavorites/isInformation
  // がtrue）の状態でもう一度呼ばれたら、単にundo()でひとつ前の履歴に戻れば
  // よい。ただし、openSettings()/openFavorites()/openInformation()
  // （専用タブを開く従来動作）で作られたタブは常にhistoryIndex=0
  // （履歴を積まない）のままisSettings等がtrueになっているため、そのような
  // タブでトグルモードに切り替えて押した場合はundo()の戻り先が無く無反応に
  // なってしまう。この場合は「戻る先が無い＝このタブに元々何も
  // 表示されていなかった」とみなし、本棚のトップへ遷移させる
  void _toggleInPlace({required _SpecialTabKind kind}) {
    final current = state.tabs[state.currentIndex];
    final alreadyThere = switch (kind) {
      _SpecialTabKind.settings => current.isSettings,
      _SpecialTabKind.favorites => current.isFavorites,
      _SpecialTabKind.information => current.isInformation,
    };
    if (alreadyThere) {
      if (current.historyIndex > 0) {
        undo();
      } else {
        navigateTo(null, segments: const ['トップ']);
      }
      return;
    }
    final newTabs = [...state.tabs];
    final newHistory = List<Map<String, dynamic>>.from(
        current.history.sublist(0, current.historyIndex + 1));
    final title = switch (kind) {
      _SpecialTabKind.settings => '設定',
      _SpecialTabKind.favorites => 'お気に入り',
      _SpecialTabKind.information => '情報',
    };
    newHistory.add({
      'isSettings': kind == _SpecialTabKind.settings,
      'isFavorites': kind == _SpecialTabKind.favorites,
      'isInformation': kind == _SpecialTabKind.information,
      'title': title,
      'segments': ['トップ', title],
    });
    newTabs[state.currentIndex] = TabItem(
        id: current.id,
        title: title,
        isSettings: kind == _SpecialTabKind.settings,
        isFavorites: kind == _SpecialTabKind.favorites,
        isInformation: kind == _SpecialTabKind.information,
        segments: ['トップ', title],
        history: newHistory,
        historyIndex: newHistory.length - 1);
    state = TabState(tabs: newTabs, currentIndex: state.currentIndex);
  }

  void navigateTo(String? shelfId,
      {String? path,
      String? title,
      List<String>? segments,
      bool openInNewTab = false}) {
    if (openInNewTab) {
      final stay = ref.read(settingsProvider).middleClickTabBehavior ==
          MiddleClickTabBehavior.stayOnCurrentTab;
      state = TabState(tabs: [
        ...state.tabs,
        TabItem(
            id: const Uuid().v4(),
            title: title ?? 'トップ',
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
      ], currentIndex: stay ? state.currentIndex : state.tabs.length);
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
        title: title ?? 'トップ',
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
      final stay = ref.read(settingsProvider).middleClickTabBehavior ==
          MiddleClickTabBehavior.stayOnCurrentTab;
      state = TabState(tabs: [
        ...state.tabs,
        TabItem(
            id: const Uuid().v4(),
            title: title,
            bookId: bookId,
            shelfId: currentShelfId,
            path: currentPath,
            segments: finalSegments)
      ], currentIndex: stay ? state.currentIndex : state.tabs.length);
    } else {
      final newTabs = [...state.tabs];
      final current = newTabs[state.currentIndex];
      final resolvedShelfId = currentShelfId ?? current.shelfId;
      final resolvedPath = currentPath ?? current.path;
      // navigateTo()同様、本を開く操作もタブ内履歴に積む。これにより
      // ビューアの「戻る/進む」アイコン（undo/redo）が他のページと同じように
      // 反応するようになる（積まないと戻り先が無く常に無効化されたままだった）
      final newHistory = List<Map<String, dynamic>>.from(
          current.history.sublist(0, current.historyIndex + 1));
      newHistory.add({
        'shelfId': resolvedShelfId,
        'path': resolvedPath,
        'title': title,
        'segments': finalSegments,
        'bookId': bookId,
      });
      newTabs[state.currentIndex] = TabItem(
          id: current.id,
          title: title,
          bookId: bookId,
          shelfId: resolvedShelfId,
          path: resolvedPath,
          segments: finalSegments,
          history: newHistory,
          historyIndex: newHistory.length - 1);
      state = TabState(tabs: newTabs, currentIndex: state.currentIndex);
    }
  }

  void closeBook(TabItem currentTab) {
    final newSegs = List<String>.from(currentTab.segments);
    if (newSegs.length > 1) newSegs.removeLast();
    navigateTo(currentTab.shelfId,
        path: currentTab.path,
        title: currentTab.path?.split('/').last ?? 'トップ',
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
        title: h['title'] ?? 'トップ',
        shelfId: h['shelfId'],
        path: h['path'],
        segments: h['segments'] ?? ['トップ'],
        bookId: h['bookId'],
        isSettings: h['isSettings'] ?? false,
        isFavorites: h['isFavorites'] ?? false,
        isInformation: h['isInformation'] ?? false,
        history: state.tabs[state.currentIndex].history,
        historyIndex: idx);
    state = TabState(tabs: newTabs, currentIndex: state.currentIndex);
  }
}

final tabProvider =
    StateNotifierProvider<TabNotifier, TabState>((ref) => TabNotifier(ref));
