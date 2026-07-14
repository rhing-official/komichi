import 'package:hive/hive.dart';

part 'app_settings.g.dart';

// ★後方互換のためのみ残置。AppSettingsのフィールドとしては使用しない
// （既存のHiveデータをデコードする際にunknown typeIdエラーを避けるため、
//   TabModeAdapterの登録自体はmain.dartに残す必要がある）
@HiveType(typeId: 3)
enum TabMode {
  @HiveField(0)
  fixedLibrary,
  @HiveField(1)
  independent,
}

@HiveType(typeId: 7)
enum SidebarPosition {
  @HiveField(0)
  left,
  @HiveField(1)
  right,
}

// ★追加：タブバーの配置（top=従来の水平タブ、left/right=垂直タブ）
@HiveType(typeId: 8)
enum TabBarPosition {
  @HiveField(0)
  top,
  @HiveField(1)
  left,
  @HiveField(2)
  right,
}

// ★追加：ページの送り方用
@HiveType(typeId: 4)
enum PageDirection {
  @HiveField(0)
  leftToNext,
  @HiveField(1)
  rightToNext,
}

@HiveType(typeId: 6)
enum AppTheme {
  @HiveField(0)
  system,
  @HiveField(1)
  light,
  @HiveField(2)
  dark,
}

// ★追加：全画面表示のタイミング（onViewerOnly=書籍を開いている間のみ、
// alwaysOnLaunch=起動した瞬間から常に全画面）
@HiveType(typeId: 9)
enum FullscreenBehavior {
  @HiveField(0)
  onViewerOnly,
  @HiveField(1)
  alwaysOnLaunch,
}

// ★追加：垂直タブとサイドバーが同じ辺にある場合、どちらを外側（画面端側）に
// 配置するか
@HiveType(typeId: 10)
enum OuterEdgeElement {
  @HiveField(0)
  verticalTabs,
  @HiveField(1)
  sidebar,
}

// ★追加：起動時にタブの状態をどうするか（resumeLastBook=前回読んでいた
// 書籍のビューワーを自動で開く、alwaysLibrary=常に本棚タブから開始）。
// どちらを選んでも読書履歴（Book.lastPage等）自体はリセットされない
@HiveType(typeId: 11)
enum LaunchTabBehavior {
  @HiveField(0)
  resumeLastBook,
  @HiveField(1)
  alwaysLibrary,
}

// ★追加：中クリックで書籍/フォルダを新しいタブで開いた時、そのまま新しい
// タブへ自動的に切り替えるか、元のタブに留まるか
@HiveType(typeId: 12)
enum MiddleClickTabBehavior {
  @HiveField(0)
  switchToNewTab,
  @HiveField(1)
  stayOnCurrentTab,
}

// ★追加：画面の向き固定（Android専用）。常にこの向きにロックし、端末を
// 傾けても自動回転しない。一度設定すると再起動しても持続する
@HiveType(typeId: 13)
enum ScreenOrientationLock {
  @HiveField(0)
  portraitUp,
  @HiveField(1)
  landscapeLeft,
  @HiveField(2)
  landscapeRight,
  @HiveField(3)
  portraitDown,
}

// ★追加：設定/お気に入りアイコンを押した時の開き方（newTab=専用タブを
// 開く/切り替える【従来の動作】、toggleInPlace=現在のタブ内でその場に
// 切り替え、再度同じアイコンを押すと切り替え前の表示に戻る）
@HiveType(typeId: 14)
enum SettingsFavoritesOpenMode {
  @HiveField(0)
  newTab,
  @HiveField(1)
  toggleInPlace,
}

// ★追加：アプリ表示言語（現時点ではホーム画面・ビューア・設定・サイドバー
// など主要画面のみ対応。それ以外の画面は日本語のまま残る場合がある）
@HiveType(typeId: 15)
enum AppLanguage {
  @HiveField(0)
  ja,
  @HiveField(1)
  en,
}

// モバイル用ナビゲーションポップアップに並べる9アイコンのデフォルト順序
const List<String> kDefaultMobileNavIconOrder = [
  'back',
  'forward',
  'search',
  'tabCount',
  'settings',
  'addFolder',
  'addTab',
  'favorites',
  'information',
];

// ★追加：ポップアップはピクセル幅の都合上、常時表示できるのは
// ハンバーガーメニューを含めて7個（アイコン6個+ハンバーガー）まで。
// そのためデフォルトでは上記のうち6個だけを可視にし、残りはハンバーガー
// メニューへ収納しておく
const List<String> kDefaultMobileNavHiddenIcons = [
  'addTab',
  'favorites',
  'information',
];

@HiveType(typeId: 1)
class AppSettings {
  @HiveField(0, defaultValue: PageDirection.leftToNext)
  final PageDirection pageDirection;

  @HiveField(2, defaultValue: AppTheme.system)
  final AppTheme theme;

  @HiveField(3, defaultValue: SidebarPosition.left)
  final SidebarPosition sidebarPosition;

  // ★終了時に読んでいた書籍。次回起動時にそのビューワーを自動で開くために使う
  @HiveField(4)
  final String? lastOpenBookId;

  @HiveField(5, defaultValue: TabBarPosition.top)
  final TabBarPosition tabBarPosition;

  @HiveField(6, defaultValue: FullscreenBehavior.onViewerOnly)
  final FullscreenBehavior fullscreenBehavior;

  @HiveField(7, defaultValue: OuterEdgeElement.verticalTabs)
  final OuterEdgeElement outerEdgeElement;

  @HiveField(8, defaultValue: LaunchTabBehavior.resumeLastBook)
  final LaunchTabBehavior launchTabBehavior;

  // ★終了時に開いていたタブ全体（本棚・書籍・設定・お気に入りタブと現在の
  // 選択状態）をJSON文字列として保存し、次回起動時に「前回のタブを復元」で
  // 使う。ネストしたリスト/マップを含むためHiveの独自型ではなくJSONで保持する
  @HiveField(9)
  final String? savedTabsJson;

  @HiveField(10, defaultValue: MiddleClickTabBehavior.switchToNewTab)
  final MiddleClickTabBehavior middleClickTabBehavior;

  // ★追加：モバイル用ナビゲーションポップアップのアイコン表示順・非表示集合
  @HiveField(13, defaultValue: kDefaultMobileNavIconOrder)
  final List<String> mobileNavIconOrder;

  @HiveField(14, defaultValue: kDefaultMobileNavHiddenIcons)
  final List<String> mobileNavHiddenIcons;

  @HiveField(15, defaultValue: ScreenOrientationLock.portraitUp)
  final ScreenOrientationLock screenOrientationLock;

  @HiveField(16, defaultValue: SettingsFavoritesOpenMode.newTab)
  final SettingsFavoritesOpenMode settingsFavoritesOpenMode;

  @HiveField(17, defaultValue: AppLanguage.ja)
  final AppLanguage language;

  // mobileNavIconOrderは新規インストール時のみkDefaultMobileNavIconOrderが
  // 初期値として使われるため、既にHiveへ保存済みの環境でアイコンを追加すると
  // 既存ユーザーの保存済みリストには含まれず、設定画面から永久に表示できなく
  // なってしまう。表示・並べ替え時はこちらを使い、保存済みリストに無い新しい
  // アイコンIDを末尾に補完する
  List<String> get effectiveMobileNavIconOrder => [
        ...mobileNavIconOrder,
        for (final id in kDefaultMobileNavIconOrder)
          if (!mobileNavIconOrder.contains(id)) id,
      ];

  // 上記effectiveMobileNavIconOrderで補完された（＝ユーザーがまだ一度も
  // 選んだことがない）新規アイコンは、ポップアップのピクセル幅が限られている
  // ため、勝手に可視状態で追加すると行が溢れてしまう。ユーザーの保存済み
  // hiddenIconsに含まれていない場合でも「まだ選んだことが無い新規アイコン」
  // は安全側でデフォルト非表示（ハンバーガー行き）として扱う
  List<String> get effectiveMobileNavHiddenIcons => [
        ...mobileNavHiddenIcons,
        for (final id in kDefaultMobileNavIconOrder)
          if (!mobileNavIconOrder.contains(id) &&
              !mobileNavHiddenIcons.contains(id))
            id,
      ];

  AppSettings({
    this.pageDirection = PageDirection.leftToNext,
    this.theme = AppTheme.system,
    this.sidebarPosition = SidebarPosition.left,
    this.lastOpenBookId,
    this.tabBarPosition = TabBarPosition.top,
    this.fullscreenBehavior = FullscreenBehavior.onViewerOnly,
    this.outerEdgeElement = OuterEdgeElement.verticalTabs,
    this.launchTabBehavior = LaunchTabBehavior.resumeLastBook,
    this.savedTabsJson,
    this.middleClickTabBehavior = MiddleClickTabBehavior.switchToNewTab,
    this.mobileNavIconOrder = kDefaultMobileNavIconOrder,
    this.mobileNavHiddenIcons = kDefaultMobileNavHiddenIcons,
    this.screenOrientationLock = ScreenOrientationLock.portraitUp,
    this.settingsFavoritesOpenMode = SettingsFavoritesOpenMode.newTab,
    this.language = AppLanguage.ja,
  });

  AppSettings copyWith({
    PageDirection? pageDirection,
    AppTheme? theme,
    SidebarPosition? sidebarPosition,
    String? lastOpenBookId,
    bool clearLastOpenBookId = false,
    TabBarPosition? tabBarPosition,
    FullscreenBehavior? fullscreenBehavior,
    OuterEdgeElement? outerEdgeElement,
    LaunchTabBehavior? launchTabBehavior,
    String? savedTabsJson,
    MiddleClickTabBehavior? middleClickTabBehavior,
    List<String>? mobileNavIconOrder,
    List<String>? mobileNavHiddenIcons,
    ScreenOrientationLock? screenOrientationLock,
    SettingsFavoritesOpenMode? settingsFavoritesOpenMode,
    AppLanguage? language,
  }) {
    return AppSettings(
      pageDirection: pageDirection ?? this.pageDirection,
      theme: theme ?? this.theme,
      sidebarPosition: sidebarPosition ?? this.sidebarPosition,
      lastOpenBookId: clearLastOpenBookId
          ? null
          : (lastOpenBookId ?? this.lastOpenBookId),
      tabBarPosition: tabBarPosition ?? this.tabBarPosition,
      fullscreenBehavior: fullscreenBehavior ?? this.fullscreenBehavior,
      outerEdgeElement: outerEdgeElement ?? this.outerEdgeElement,
      launchTabBehavior: launchTabBehavior ?? this.launchTabBehavior,
      savedTabsJson: savedTabsJson ?? this.savedTabsJson,
      middleClickTabBehavior:
          middleClickTabBehavior ?? this.middleClickTabBehavior,
      mobileNavIconOrder: mobileNavIconOrder ?? this.mobileNavIconOrder,
      mobileNavHiddenIcons: mobileNavHiddenIcons ?? this.mobileNavHiddenIcons,
      screenOrientationLock:
          screenOrientationLock ?? this.screenOrientationLock,
      settingsFavoritesOpenMode:
          settingsFavoritesOpenMode ?? this.settingsFavoritesOpenMode,
      language: language ?? this.language,
    );
  }
}
