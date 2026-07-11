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

  AppSettings({
    this.pageDirection = PageDirection.leftToNext,
    this.theme = AppTheme.system,
    this.sidebarPosition = SidebarPosition.left,
    this.lastOpenBookId,
    this.tabBarPosition = TabBarPosition.top,
    this.fullscreenBehavior = FullscreenBehavior.onViewerOnly,
    this.outerEdgeElement = OuterEdgeElement.verticalTabs,
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
    );
  }
}
