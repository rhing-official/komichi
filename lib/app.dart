import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:window_manager/window_manager.dart';
import 'package:path/path.dart' as p;
import 'features/library/models/shelf.dart';
import 'core/utils/platform_utils.dart';
import 'core/providers/tab_provider.dart';
import 'core/providers/sidebar_focus_provider.dart';
import 'core/providers/sidebar_width_provider.dart';
import 'features/library/views/home_placeholder_screen.dart';
import 'features/library/views/favorites_screen.dart';
import 'features/library/views/shelf_screen.dart';
import 'features/library/widgets/bookshelf_sidebar.dart';
import 'features/viewer/views/viewer_screen.dart';
import 'features/settings/views/settings_screen.dart';
import 'features/viewer/providers/viewer_provider.dart';
import 'features/settings/providers/settings_provider.dart';
import 'features/settings/models/app_settings.dart';
import 'features/library/providers/library_provider.dart';

// Material3のfromSeedはグレー系シードでも内部的に色相を持たせてしまうため、
// 実際に参照している色ロールは明示的にグレースケールへ上書きする
ColorScheme _monochromeScheme(Brightness brightness) {
  final isDark = brightness == Brightness.dark;
  return ColorScheme.fromSeed(seedColor: Colors.grey, brightness: brightness)
      .copyWith(
    primary: isDark ? const Color(0xFFE0E0E0) : const Color(0xFF303030),
    secondary: isDark ? const Color(0xFFBDBDBD) : const Color(0xFF616161),
    surface: isDark ? const Color(0xFF121212) : Colors.white,
    onSurface: isDark ? const Color(0xFFECECEC) : const Color(0xFF1A1A1A),
    surfaceContainerHigh:
        isDark ? const Color(0xFF2A2A2A) : const Color(0xFFE8E8E8),
    surfaceContainerHighest:
        isDark ? const Color(0xFF303030) : const Color(0xFFE0E0E0),
    onSurfaceVariant: isDark ? const Color(0xFFB0B0B0) : const Color(0xFF616161),
    outlineVariant: isDark ? const Color(0xFF424242) : const Color(0xFFD0D0D0),
  );
}

class KomichiApp extends ConsumerWidget {
  const KomichiApp({super.key});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(settingsProvider);
    final themeMode = switch (settings.theme) {
      AppTheme.system => ThemeMode.system,
      AppTheme.light => ThemeMode.light,
      AppTheme.dark => ThemeMode.dark,
    };

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      themeMode: themeMode,
      theme: ThemeData(
        brightness: Brightness.light,
        colorScheme: _monochromeScheme(Brightness.light),
        scaffoldBackgroundColor: Colors.white,
        useMaterial3: true,
        fontFamilyFallback: const ['Noto Sans CJK JP', 'Noto Sans JP', 'Sans-Serif'],
      ),
      darkTheme: ThemeData(
        brightness: Brightness.dark,
        colorScheme: _monochromeScheme(Brightness.dark),
        useMaterial3: true,
        fontFamilyFallback: const ['Noto Sans CJK JP', 'Noto Sans JP', 'Sans-Serif'],
      ),
      home: const TabShell(),
    );
  }
}

class TabShell extends ConsumerStatefulWidget {
  const TabShell({super.key});
  @override
  ConsumerState<TabShell> createState() => _TabShellState();
}

class _TabShellState extends ConsumerState<TabShell> {
  final FocusNode _focusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    // アプリ全体のショートカットはフォーカスツリー(Focus.onKeyEvent)ではなく
    // グローバルハンドラで処理する。フォーカスツリー経由だと、フォーカス中の
    // ウィジェットが破棄されてフォーカスがルートに落ちた際にキーイベントが
    // 届かなくなり、ショートカットが全滅するため
    HardwareKeyboard.instance.addHandler(_onGlobalKey);
    // 起動直後の全画面化。ref.listen(tabProvider,...)は状態の「変化」にしか
    // 反応しないため、起動時点で既に書籍が開いている（前回終了時の書籍を
    // 自動再開した）場合や「常に全画面」設定の場合はここで明示的に適用する
    if (!isDesktopPlatform) return;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final settings = ref.read(settingsProvider);
      final tabState = ref.read(tabProvider);
      final isBookOpen = tabState.tabs[tabState.currentIndex].bookId != null;
      windowManager.setFullScreen(
          settings.fullscreenBehavior == FullscreenBehavior.alwaysOnLaunch ||
              isBookOpen);
    });
  }

  @override
  void dispose() {
    HardwareKeyboard.instance.removeHandler(_onGlobalKey);
    _focusNode.dispose();
    super.dispose();
  }

  bool _onGlobalKey(KeyEvent event) {
    if (event is! KeyDownEvent) return false;
    final key = event.logicalKey;
    final isCtrl = HardwareKeyboard.instance.isControlPressed;
    final isAlt = HardwareKeyboard.instance.isAltPressed;
    final isShift = HardwareKeyboard.instance.isShiftPressed;
    final notifier = ref.read(tabProvider.notifier);
    final tabState = ref.read(tabProvider);

    if (isCtrl && key == LogicalKeyboardKey.tab) {
      isShift ? notifier.previousTab() : notifier.nextTab();
      return true;
    }

    if (isAlt) {
      if (key == LogicalKeyboardKey.arrowLeft) {
        notifier.undo();
        return true;
      }
      if (key == LogicalKeyboardKey.arrowRight) {
        notifier.redo();
        return true;
      }
    }

    // マウスボタンやブラウザキーへの対応
    if (key == LogicalKeyboardKey.browserBack ||
        key == LogicalKeyboardKey.goBack) {
      notifier.undo();
      return true;
    }
    if (key == LogicalKeyboardKey.browserForward) {
      notifier.redo();
      return true;
    }

    if (isCtrl) {
      if (key == LogicalKeyboardKey.keyI) {
        notifier.openSettings();
        return true;
      }
      if (key == LogicalKeyboardKey.keyW) {
        notifier.closeTab(tabState.currentIndex);
        return true;
      }
      if (key == LogicalKeyboardKey.keyF) {
        notifier.openFavorites();
        return true;
      }
      if (key == LogicalKeyboardKey.keyS) {
        ref.read(sidebarFocusRequestProvider.notifier).state++;
        return true;
      }
      if (key == LogicalKeyboardKey.keyT) {
        notifier.addLibraryTab();
        return true;
      }
    }
    if (key == LogicalKeyboardKey.f5) {
      _syncFiles();
      return true;
    }
    return false;
  }

  Future<void> _syncFiles() async {
    debugPrint('[Sync] F5が押されました');
    final result = await ref.read(libraryProvider.notifier).syncAll();
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(result.added == 0 && result.removed == 0
          ? '変更はありませんでした'
          : '更新しました（追加${result.added}件 / 削除${result.removed}件）'),
      duration: const Duration(seconds: 2),
    ));
  }

  @override
  Widget build(BuildContext context) {
    final tabState = ref.watch(tabProvider);
    final notifier = ref.read(tabProvider.notifier);
    final currentTab = tabState.tabs[tabState.currentIndex];
    final settings = ref.watch(settingsProvider);
    final colorScheme = Theme.of(context).colorScheme;
    final isBookOpen = currentTab.bookId != null;
    final bookShowUI = isBookOpen
        ? ref.watch(viewerProvider(currentTab.bookId!)).showUI
        : true;
    // ビューアを開いている間は常に全画面かつ本文を動かさず、タブバー・サイドバーは
    // 本文の上に重ねるオーバーレイとして描画する。表示/非表示(Space)は
    // オーバーレイの不透明度(0 or 0.85)だけを切り替える
    final dimChrome = isBookOpen && bookShowUI;

    // フルスクリーン切り替えの監視をサイドエフェクトとして分離。
    // 「常に全画面」設定時は書籍を開いていなくても全画面を維持する
    // （window_managerはデスクトップ専用のためAndroid等では何もしない）
    if (isDesktopPlatform) {
      ref.listen(tabProvider, (previous, next) {
        final isBookOpen = next.tabs[next.currentIndex].bookId != null;
        windowManager.setFullScreen(
            settings.fullscreenBehavior == FullscreenBehavior.alwaysOnLaunch ||
                isBookOpen);
      });
      ref.listen(settingsProvider, (previous, next) {
        if (previous?.fullscreenBehavior == next.fullscreenBehavior) return;
        final isBookOpen = tabState.tabs[tabState.currentIndex].bookId != null;
        windowManager.setFullScreen(
            next.fullscreenBehavior == FullscreenBehavior.alwaysOnLaunch ||
                isBookOpen);
      });
    }

    final tabBarPos = settings.tabBarPosition;
    final isVerticalTabs = tabBarPos != TabBarPosition.top;
    // 垂直タブ使用時は水平タブの列（AppBarのタブ行）自体を廃止し、
    // パスバーの高さだけを上部に確保して表示領域を広げる
    final chromeBarHeight = isVerticalTabs ? _kPathBarHeight : _kChromeBarHeight;

    return Listener(
      onPointerDown: (event) {
        // bit 3 (8), bit 7 (128) -> Back
        if ((event.buttons & 8) != 0 || (event.buttons & 128) != 0) {
          if (currentTab.bookId != null) {
            notifier.closeBook(currentTab);
          } else {
            notifier.undo();
          }
        }
        // bit 4 (16), bit 8 (256) -> Forward
        else if ((event.buttons & 16) != 0 || (event.buttons & 256) != 0) {
          notifier.redo();
        }
      },
      // アプリ全体のショートカットは_onGlobalKey（HardwareKeyboardハンドラ）で
      // 処理する。このFocusはフォーカススコープの起点としてのみ残している
      child: Focus(
        focusNode: _focusNode,
        autofocus: true,
        child: Scaffold(
          appBar: isBookOpen
              ? null
              : PreferredSize(
                  preferredSize: Size.fromHeight(chromeBarHeight),
                  child: _GlassPanel(
                    child: isVerticalTabs
                        ? const _PathBar(showWindowControls: true)
                        : _buildChromeBar(tabState, notifier, colorScheme),
                  ),
                ),
          body: isBookOpen
              ? Stack(children: [
                  _MainArea(
                      tabState: tabState,
                      tabNotifier: notifier,
                      sidebarPosition: settings.sidebarPosition,
                      tabBarPosition: tabBarPos,
                      outerEdge: settings.outerEdgeElement,
                      overlayMode: true,
                      dimChrome: dimChrome,
                      chromeBarHeight: chromeBarHeight),
                  Positioned(
                    top: 0,
                    left: 0,
                    right: 0,
                    child: IgnorePointer(
                      ignoring: !dimChrome,
                      child: Opacity(
                        opacity: dimChrome ? 0.85 : 0.0,
                        child: SizedBox(
                            height: chromeBarHeight,
                            child: _GlassPanel(
                              borderRadius: const BorderRadius.vertical(
                                  bottom: Radius.circular(18)),
                              child: isVerticalTabs
                                  ? const _PathBar(showWindowControls: true)
                                  : _buildChromeBar(
                                      tabState, notifier, colorScheme),
                            )),
                      ),
                    ),
                  ),
                ])
              : _MainArea(
                  tabState: tabState,
                  tabNotifier: notifier,
                  sidebarPosition: settings.sidebarPosition,
                  tabBarPosition: tabBarPos,
                  outerEdge: settings.outerEdgeElement,
                  overlayMode: false),
        ),
      ),
    );
  }

  Widget _buildChromeBar(
      TabState tabState, TabNotifier notifier, ColorScheme colorScheme) {
    return Column(children: [
      AppBar(
        toolbarHeight: 38,
        backgroundColor: Colors.transparent,
        elevation: 0,
        titleSpacing: 0,
        title: GestureDetector(
          onPanStart:
              isDesktopPlatform ? (_) => windowManager.startDragging() : null,
          behavior: HitTestBehavior.translucent,
          child: Row(children: [
            const SizedBox(width: 8),
            Flexible(
                child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(children: [
                      ...tabState.tabs
                          .asMap()
                          .entries
                          .map((e) =>
                              _TabWidget(item: e.value, index: e.key))
                          .toList(),
                    ]))),
            IconButton(
                icon: Icon(Icons.add, size: 20, color: colorScheme.onSurface),
                onPressed: notifier.addLibraryTab),
          ]),
        ),
        actions: isDesktopPlatform
            ? [
                IconButton(
                    icon: Icon(Icons.remove,
                        size: 18, color: colorScheme.onSurface),
                    onPressed: () => windowManager.minimize()),
                IconButton(
                    icon: Icon(Icons.crop_square,
                        size: 16, color: colorScheme.onSurface),
                    onPressed: () async {
                      if (await windowManager.isMaximized()) {
                        await windowManager.unmaximize();
                      } else {
                        await windowManager.maximize();
                      }
                    }),
                IconButton(
                    icon: Icon(Icons.close,
                        size: 18, color: colorScheme.onSurface),
                    onPressed: () => windowManager.close()),
              ]
            : null,
      ),
      const _PathBar(),
    ]);
  }
}

class _MainArea extends ConsumerStatefulWidget {
  final TabState tabState;
  final TabNotifier tabNotifier;
  final SidebarPosition sidebarPosition;
  final TabBarPosition tabBarPosition;
  // 垂直タブとサイドバーが同じ辺にある場合、どちらを外側（画面端側）に配置するか
  final OuterEdgeElement outerEdge;
  final bool overlayMode;
  final bool dimChrome;
  // ビューア重ね表示時にサイドバー・垂直タブが避けるべき上部チロム（タブバー等）の高さ
  final double chromeBarHeight;
  const _MainArea(
      {required this.tabState,
      required this.tabNotifier,
      required this.sidebarPosition,
      required this.tabBarPosition,
      required this.outerEdge,
      required this.overlayMode,
      this.dimChrome = false,
      this.chromeBarHeight = _kChromeBarHeight});

  @override
  ConsumerState<_MainArea> createState() => _MainAreaState();
}

// サイドバーは普段は畳んだ細いバー（設定アイコンだけ見える幅）として表示し、
// ポインターが触れている間だけ幅いっぱいに開く（コンテンツの上に重ねて表示。レイアウトは動かさない）
const double _kSidebarCollapsedWidth = 44;
const double _kChromeBarHeight = 72;
const double _kPathBarHeight = 34;
// 垂直タブ使用時、サイドバーよりも外側（画面端側）に表示するタブ帯の幅
const double _kVerticalTabWidth = 200;

// Apple Liquid Glass 風のすりガラス背景。裏の内容をぼかしつつ半透明の色味を
// 重ね、外側の角を丸め、上端にハイライトの縁取りを入れることでガラスの
// 質感を表現する。中身（BookshelfSidebar等）は自身の背景を透明にしておくこと
class _GlassPanel extends StatelessWidget {
  final Widget child;
  final BorderRadius borderRadius;
  const _GlassPanel({required this.child, this.borderRadius = BorderRadius.zero});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final tint = isDark
        ? Colors.white.withValues(alpha: 0.08)
        : Colors.white.withValues(alpha: 0.55);
    final borderColor = isDark
        ? Colors.white.withValues(alpha: 0.14)
        : Colors.white.withValues(alpha: 0.7);
    return ClipRRect(
      borderRadius: borderRadius,
      child: BackdropFilter(
        filter: ui.ImageFilter.blur(sigmaX: 24, sigmaY: 24),
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: tint,
            borderRadius: borderRadius,
            border: Border.all(color: borderColor, width: 1),
            boxShadow: [
              BoxShadow(
                  color: Colors.black.withValues(alpha: isDark ? 0.4 : 0.12),
                  blurRadius: 20,
                  offset: const Offset(0, 4)),
            ],
          ),
          child: child,
        ),
      ),
    );
  }
}

// サイドバー・垂直タブ用の背景専用レイヤー（childを持たない）。
// ガラス効果(BackdropFilter)はスライド中の毎フレーム再計算が非常に重いため、
// スライド中はブラー無しの不透明背景に切り替える。切り替えはこのウィジェットの
// 「内部」で行うことが重要：型の異なるラッパー（_GlassPanel等）でコンテンツを
// 包み替えると、コンテンツのサブツリーごと再マウントされて状態（サイドバーの
// 検索欄のFocusNode等）が破棄されてしまう
class _PanelBackground extends StatelessWidget {
  final bool glass;
  final BorderRadius borderRadius;
  const _PanelBackground(
      {required this.glass, this.borderRadius = BorderRadius.zero});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    if (!glass) {
      return DecoratedBox(
        decoration: BoxDecoration(
            color: theme.colorScheme.surfaceContainerHighest,
            borderRadius: borderRadius),
        child: const SizedBox.expand(),
      );
    }
    final isDark = theme.brightness == Brightness.dark;
    final tint = isDark
        ? Colors.white.withValues(alpha: 0.08)
        : Colors.white.withValues(alpha: 0.55);
    final borderColor = isDark
        ? Colors.white.withValues(alpha: 0.14)
        : Colors.white.withValues(alpha: 0.7);
    return BackdropFilter(
      filter: ui.ImageFilter.blur(sigmaX: 24, sigmaY: 24),
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: tint,
          borderRadius: borderRadius,
          border: Border.all(color: borderColor, width: 1),
        ),
        child: const SizedBox.expand(),
      ),
    );
  }
}

class _MainAreaState extends ConsumerState<_MainArea>
    with SingleTickerProviderStateMixin {
  bool _hover = false;
  bool _keyboardExpanded = false;
  late final AnimationController _expandAnim = AnimationController(
      vsync: this, duration: const Duration(milliseconds: 220));

  // リサイズ中フラグはガラス⇔軽量背景の切り替えに使うが、リサイズの開始/終了は
  // アニメーションのティックを伴わない（既に全展開状態のまま起きる）ため、
  // ValueNotifierにしてAnimatedBuilderのListenable.mergeで監視する
  final ValueNotifier<bool> _resizingN = ValueNotifier(false);

  void _syncExpandAnim() {
    final next = _hover || _resizingN.value || _keyboardExpanded;
    next ? _expandAnim.forward() : _expandAnim.reverse();
  }

  // ★setStateは呼ばない。ホバーのたびにbuild全体（IndexedStack内の全タブ画面）が
  // 再ビルドされると、その巨大な1フレームが時間ベースの220msスライドをほぼ
  // 食い尽くして「アニメーション無しで切り替わる」ように見えるため、
  // 描画の更新はAnimationController／ValueNotifierのティックだけで行う
  void _setHover(bool v) {
    _hover = v;
    _syncExpandAnim();
  }

  void _setResizing(bool v) {
    _resizingN.value = v;
    _syncExpandAnim();
  }

  void _setKeyboardExpanded(bool v) {
    _keyboardExpanded = v;
    _syncExpandAnim();
  }

  @override
  void dispose() {
    _expandAnim.dispose();
    _resizingN.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    ref.listen(sidebarFocusRequestProvider, (previous, next) {
      _setKeyboardExpanded(true);
    });

    final stack = IndexedStack(
        index: widget.tabState.currentIndex,
        children: widget.tabState.tabs.asMap().entries.map<Widget>((entry) {
          final tab = entry.value;
          final isActive = entry.key == widget.tabState.currentIndex;
          if (tab.isSettings) return SettingsScreen(isActive: isActive);
          if (tab.isFavorites) return FavoritesScreen(isActive: isActive);
          if (tab.bookId != null) {
            return ViewerScreen(bookId: tab.bookId!, isActive: isActive);
          }
          if (tab.shelfId != null) {
            return ShelfScreen(shelfId: tab.shelfId!, isActive: isActive);
          }
          return HomePlaceholderScreen(isActive: isActive);
        }).toList());

    final chromeOpacity =
        !widget.overlayMode ? 1.0 : (widget.dimChrome ? 0.85 : 0.0);
    final chromeInteractive = !widget.overlayMode || widget.dimChrome;
    final isLeft = widget.sidebarPosition == SidebarPosition.left;
    final colorScheme = Theme.of(context).colorScheme;

    // 垂直タブとサイドバーの位置関係を計算する。両者が同じ辺にある場合のみ、
    // 設定に応じてどちらを外側（画面端側）にするかを切り替える。異なる辺に
    // ある場合はそれぞれ自分の辺の端に独立して配置する
    final isVerticalTabs = widget.tabBarPosition != TabBarPosition.top;
    final verticalTabsLeft = widget.tabBarPosition == TabBarPosition.left;
    final tabsOnSidebarSide = isVerticalTabs && verticalTabsLeft == isLeft;
    final sidebarIsOuter =
        !tabsOnSidebarSide || widget.outerEdge == OuterEdgeElement.sidebar;
    // サイドバーが内側にある場合に垂直タブが避けるべき固定オフセット
    // （サイドバーの畳んだ/展開幅への追従分はAnimatedBuilder内で毎ティック計算する）
    final sidebarInset =
        tabsOnSidebarSide && !sidebarIsOuter ? _kVerticalTabWidth : 0.0;

    // 通常表示（ビューア重ね表示でない）時にメインコンテンツが避けるべき
    // 左右の実幅。サイドバーの畳んだ幅・垂直タブの幅は、どちらが外側かに
    // 関わらず両方とも実スペースとして常に確保する
    final leftReserved = (isLeft ? _kSidebarCollapsedWidth : 0.0) +
        (isVerticalTabs && verticalTabsLeft ? _kVerticalTabWidth : 0.0);
    final rightReserved = (!isLeft ? _kSidebarCollapsedWidth : 0.0) +
        (isVerticalTabs && !verticalTabsLeft ? _kVerticalTabWidth : 0.0);

    final chromeTop = widget.overlayMode ? widget.chromeBarHeight : 0.0;
    final chromeBottom = widget.overlayMode ? kViewerBottomMenuHeight : 0.0;
    final libraryState = ref.watch(libraryProvider);
    final favFolders = <(Shelf, String)>[
      for (final s in libraryState.shelves)
        for (final path in s.favoriteFolders) (s, path),
    ];
    final favBooks = libraryState.books.where((b) => b.isFavorite).toList();

    final railRadius = BorderRadius.horizontal(
      right: isLeft ? const Radius.circular(18) : Radius.zero,
      left: isLeft ? Radius.zero : const Radius.circular(18),
    );

    final collapsedRail = SafeArea(
        top: false,
        child: Column(children: [
          const SizedBox(height: 6),
          IconButton(
            icon: const Icon(Icons.search, size: 20),
            color: colorScheme.onSurfaceVariant,
            onPressed: () {
              _setHover(true);
              WidgetsBinding.instance.addPostFrameCallback((_) {
                ref.read(sidebarFocusRequestProvider.notifier).state++;
              });
            },
          ),
          IconButton(
            icon: const Icon(Icons.create_new_folder, size: 20),
            color: colorScheme.onSurfaceVariant,
            onPressed: libraryState.isLoading
                ? null
                : () => ref.read(libraryProvider.notifier).addShelf(context),
          ),
          Divider(
              height: 9, indent: 8, endIndent: 8, color: colorScheme.outlineVariant),
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(vertical: 2),
              itemCount: favFolders.length + favBooks.length,
              itemBuilder: (context, i) {
                if (i < favFolders.length) {
                  final (s, path) = favFolders[i];
                  final fName = p.basename(path);
                  final rel = p.relative(path, from: s.folderPath);
                  final relParts =
                      rel == '.' ? <String>[] : rel.split(p.separator);
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 3),
                    child: Center(
                      child: SizedBox(
                        width: 32,
                        height: 32,
                        child: IconButton(
                          padding: EdgeInsets.zero,
                          iconSize: 18,
                          tooltip: fName,
                          icon: const Icon(Icons.folder),
                          color: colorScheme.onSurfaceVariant,
                          onPressed: () => ref.read(tabProvider.notifier).navigateTo(
                              s.id,
                              path: path,
                              title: fName,
                              segments: ['トップ', s.name, ...relParts]),
                        ),
                      ),
                    ),
                  );
                }
                final b = favBooks[i - favFolders.length];
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 3),
                  child: Center(
                    child: SizedBox(
                      width: 32,
                      height: 32,
                      child: IconButton(
                        padding: EdgeInsets.zero,
                        iconSize: 18,
                        tooltip: b.title,
                        icon: const Icon(Icons.book),
                        color: colorScheme.onSurfaceVariant,
                        onPressed: () => ref
                            .read(tabProvider.notifier)
                            .openBook(b.id, b.title, false),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          Divider(
              height: 9, indent: 8, endIndent: 8, color: colorScheme.outlineVariant),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 4),
            child: IconButton(
              icon: Icon(
                  isLeft
                      ? Icons.keyboard_double_arrow_right
                      : Icons.keyboard_double_arrow_left,
                  size: 20),
              color: colorScheme.onSurfaceVariant,
              onPressed: () => _setHover(true),
            ),
          ),
        ]));

    final expandedContent = Row(children: isLeft
        ? [
            const Expanded(child: BookshelfSidebar()),
            _SidebarResizeHandle(
                sidebarPosition: widget.sidebarPosition,
                onResizingChanged: _setResizing),
          ]
        : [
            _SidebarResizeHandle(
                sidebarPosition: widget.sidebarPosition,
                onResizingChanged: _setResizing),
            const Expanded(child: BookshelfSidebar()),
          ]);

    return Stack(children: [
      Positioned(
        top: 0,
        bottom: 0,
        left: widget.overlayMode ? 0 : leftReserved,
        right: widget.overlayMode ? 0 : rightReserved,
        child: Listener(
          onPointerDown: (_) {
            if (_keyboardExpanded) _setKeyboardExpanded(false);
          },
          child: stack,
        ),
      ),
      // サイドバー・垂直タブ帯はAnimationControllerで駆動する。ガラス効果
      // (BackdropFilter)はスライド中は外し、静止した時だけ有効にすることで、
      // 高コストなブラーの毎フレーム再計算による大幅なフレーム落ちを防ぐ。
      // サイドバー幅のwatchはこのConsumer内に閉じ込め、リサイズドラッグ中も
      // 外側（IndexedStack内の全タブ画面）が再ビルドされないようにする
      Positioned.fill(
        child: Consumer(builder: (context, ref, _) {
          final width = ref.watch(sidebarWidthProvider);
          return AnimatedBuilder(
            animation: Listenable.merge([_expandAnim, _resizingN]),
            builder: (context, _) {
              // ★buildのローカル変数を参照すると次のsetStateまで値が固定される
              // ため、ホバー状態等はここで毎ティック、フィールドから再計算する
              final t = _expandAnim.value;
              final expandedNow =
                  _hover || _resizingN.value || _keyboardExpanded;
              final atRest = t == 0.0 || t == 1.0;
              final glassEnabled = atRest && !_resizingN.value;
              final sidebarEffectiveWidth =
                  ui.lerpDouble(_kSidebarCollapsedWidth, width, t)!;
              final tabStripInset = tabsOnSidebarSide && sidebarIsOuter
                  ? sidebarEffectiveWidth
                  : 0.0;
              final panelPos = ui.lerpDouble(-width, sidebarInset, t)!;

              // 背景（ガラス⇔軽量）の切替は_PanelBackground内部で行い、childの
              // ツリー位置と型は常に不変に保つ。ラッパーの型ごと差し替えると
              // BookshelfSidebar等が再マウントされ、検索欄のフォーカスや
              // スクロール位置が破棄されてしまう
              Widget panel(Widget child, BorderRadius radius) =>
                  RepaintBoundary(
                    child: ClipRRect(
                      borderRadius: radius,
                      child: Stack(fit: StackFit.expand, children: [
                        _PanelBackground(glass: glassEnabled, borderRadius: radius),
                        child,
                      ]),
                    ),
                  );

              return Stack(children: [
                // 畳んだサイドバーは常時マウントし、境界の細い帯として固定表示する。
                // 展開が進むにつれ不透明度0までクロスフェードする
                Positioned(
                  top: chromeTop,
                  bottom: chromeBottom,
                  left: isLeft ? sidebarInset : null,
                  right: isLeft ? null : sidebarInset,
                  width: _kSidebarCollapsedWidth,
                  child: MouseRegion(
                    onEnter: (_) => _setHover(true),
                    onExit: (_) => _setHover(false),
                    child: IgnorePointer(
                      ignoring: !chromeInteractive || expandedNow,
                      child: Opacity(
                        opacity: chromeOpacity * (1 - t),
                        child: panel(collapsedRail, railRadius),
                      ),
                    ),
                  ),
                ),
                // 展開時のパネルは、畳んだ帯の上に幅いっぱいスライドして重なる
                Positioned(
                  top: chromeTop,
                  bottom: chromeBottom,
                  left: isLeft ? panelPos : null,
                  right: isLeft ? null : panelPos,
                  width: width,
                  child: MouseRegion(
                    onEnter: (_) => _setHover(true),
                    onExit: (_) => _setHover(false),
                    child: IgnorePointer(
                      ignoring: !chromeInteractive,
                      child: Opacity(
                        opacity: chromeOpacity,
                        child: panel(expandedContent, railRadius),
                      ),
                    ),
                  ),
                ),
                // 垂直タブ帯。サイドバーと同じ辺にある場合、設定に応じて外側/内側の
                // 位置を切り替え、サイドバーが展開している間はその実効幅に追従して動く
                if (isVerticalTabs)
                  Positioned(
                    top: chromeTop,
                    bottom: chromeBottom,
                    left: verticalTabsLeft ? tabStripInset : null,
                    right: verticalTabsLeft ? null : tabStripInset,
                    width: _kVerticalTabWidth,
                    child: IgnorePointer(
                      ignoring: !chromeInteractive,
                      child: Opacity(
                        opacity: chromeOpacity,
                        child: panel(
                          _VerticalTabStrip(
                              tabState: widget.tabState,
                              notifier: widget.tabNotifier),
                          BorderRadius.horizontal(
                            right: verticalTabsLeft
                                ? const Radius.circular(18)
                                : Radius.zero,
                            left: verticalTabsLeft
                                ? Radius.zero
                                : const Radius.circular(18),
                          ),
                        ),
                      ),
                    ),
                  ),
              ]);
            },
          );
        }),
      ),
    ]);
  }
}

class _SidebarResizeHandle extends ConsumerWidget {
  final SidebarPosition sidebarPosition;
  final ValueChanged<bool> onResizingChanged;
  const _SidebarResizeHandle(
      {required this.sidebarPosition, required this.onResizingChanged});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return MouseRegion(
      cursor: SystemMouseCursors.resizeLeftRight,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onHorizontalDragStart: (_) => onResizingChanged(true),
        onHorizontalDragEnd: (_) => onResizingChanged(false),
        onHorizontalDragCancel: () => onResizingChanged(false),
        onHorizontalDragUpdate: (details) {
          final sign = sidebarPosition == SidebarPosition.left ? 1 : -1;
          final current = ref.read(sidebarWidthProvider);
          ref.read(sidebarWidthProvider.notifier).state =
              (current + details.delta.dx * sign)
                  .clamp(kSidebarMinWidth, kSidebarMaxWidth);
        },
        child: SizedBox(
            width: 6,
            child: VerticalDivider(
                width: 1, color: Theme.of(context).colorScheme.outlineVariant)),
      ),
    );
  }
}

class _PathBar extends ConsumerWidget {
  // 垂直タブ使用時は水平タブの列自体を廃止するため、ウィンドウのドラッグ領域と
  // 最小化/最大化/閉じるボタンをこのバーに統合して表示する
  final bool showWindowControls;
  const _PathBar({this.showWindowControls = false});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tabState = ref.watch(tabProvider);
    final tab = tabState.tabs[tabState.currentIndex];
    final notifier = ref.read(tabProvider.notifier);
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
        height: 34,
        padding: const EdgeInsets.only(left: 16),
        decoration: showWindowControls
            ? null
            : BoxDecoration(
                border: Border(
                    bottom:
                        BorderSide(color: colorScheme.outlineVariant, width: 1))),
        child: Row(children: [
          IconButton(
              icon: const Icon(Icons.arrow_back, size: 18),
              onPressed: tab.historyIndex > 0 ? notifier.undo : null),
          IconButton(
              icon: const Icon(Icons.arrow_forward, size: 18),
              onPressed: tab.historyIndex < tab.history.length - 1
                  ? notifier.redo
                  : null),
          const SizedBox(width: 8),
          Expanded(
            child: GestureDetector(
              onPanStart: showWindowControls && isDesktopPlatform
                  ? (_) => windowManager.startDragging()
                  : null,
              behavior: HitTestBehavior.translucent,
              child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(children: [
                    ...tab.segments.asMap().entries.map((e) {
                      final idx = e.key;
                      return InkWell(
                        onTap: () {
                          if (idx == 0) {
                            notifier.navigateTo(null, segments: ['トップ']);
                          } else if (idx < tab.segments.length - 1) {
                            final newSegs = tab.segments.sublist(0, idx + 1);
                            if (idx == 1) {
                              notifier.navigateTo(tab.shelfId,
                                  title: e.value, segments: newSegs);
                            }
                          }
                        },
                        child: Text("${e.value}  /  ",
                            style: TextStyle(
                                color: colorScheme.onSurfaceVariant,
                                fontSize: 13,
                                fontWeight: FontWeight.w500)),
                      );
                    }),
                  ])),
            ),
          ),
          if (showWindowControls && isDesktopPlatform) ...[
            IconButton(
                icon: Icon(Icons.remove, size: 16, color: colorScheme.onSurface),
                onPressed: () => windowManager.minimize()),
            IconButton(
                icon: Icon(Icons.crop_square,
                    size: 14, color: colorScheme.onSurface),
                onPressed: () async {
                  if (await windowManager.isMaximized()) {
                    await windowManager.unmaximize();
                  } else {
                    await windowManager.maximize();
                  }
                }),
            IconButton(
                icon: Icon(Icons.close, size: 16, color: colorScheme.onSurface),
                onPressed: () => windowManager.close()),
          ],
        ]));
  }
}

class _TabWidget extends ConsumerWidget {
  final TabItem item;
  final int index;
  const _TabWidget({required this.item, required this.index});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final active = ref.watch(tabProvider).currentIndex == index;
    final tabNotifier = ref.read(tabProvider.notifier);
    final colorScheme = Theme.of(context).colorScheme;
    return Listener(
      behavior: HitTestBehavior.translucent,
      onPointerDown: (e) {
        if (e.buttons == 4) tabNotifier.closeTab(index);
      },
      child: GestureDetector(
        onTap: () => tabNotifier.selectTab(index),
        child: Container(
          height: 30,
          margin: const EdgeInsets.only(top: 4, right: 4),
          padding: const EdgeInsets.symmetric(horizontal: 10),
          decoration: BoxDecoration(
              color: active
                  ? colorScheme.surface
                  : colorScheme.onSurface.withOpacity(0.06),
              borderRadius:
                  const BorderRadius.vertical(top: Radius.circular(6))),
          child: Row(mainAxisSize: MainAxisSize.min, children: [
            ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 140),
                child: Text(item.title,
                    style: TextStyle(
                        fontSize: 11,
                        color: active
                            ? colorScheme.onSurface
                            : colorScheme.onSurfaceVariant,
                        fontWeight:
                            active ? FontWeight.bold : FontWeight.normal),
                    overflow: TextOverflow.ellipsis)),
            const SizedBox(width: 6),
            GestureDetector(
                onTap: () => tabNotifier.closeTab(index),
                child: Icon(Icons.close, size: 13, color: colorScheme.onSurfaceVariant)),
          ]),
        ),
      ),
    );
  }
}

// 垂直タブ帯。サイドバーよりも外側（画面端側）に、タブを縦一列に並べて表示する
class _VerticalTabStrip extends StatelessWidget {
  final TabState tabState;
  final TabNotifier notifier;
  const _VerticalTabStrip({required this.tabState, required this.notifier});

  @override
  Widget build(BuildContext context) {
    return Material(
      type: MaterialType.transparency,
      child: SizedBox(
        width: _kVerticalTabWidth,
        child: Column(children: [
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(vertical: 4),
              // 末尾に「新しいタブ」の追加行を1件足して表示する
              itemCount: tabState.tabs.length + 1,
              itemBuilder: (context, index) {
                if (index == tabState.tabs.length) {
                  return _NewTabButton(notifier: notifier);
                }
                return _VerticalTabWidget(
                    item: tabState.tabs[index], index: index, notifier: notifier);
              },
            ),
          ),
        ]),
      ),
    );
  }
}

// 垂直タブ帯の末尾（開いているタブの下）に表示する新規タブ追加行
class _NewTabButton extends StatelessWidget {
  final TabNotifier notifier;
  const _NewTabButton({required this.notifier});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return InkWell(
      onTap: notifier.addLibraryTab,
      borderRadius: BorderRadius.circular(6),
      child: Container(
        height: 36,
        margin: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
        padding: const EdgeInsets.symmetric(horizontal: 10),
        child: Row(children: [
          Icon(Icons.add, size: 18, color: colorScheme.onSurfaceVariant),
          const SizedBox(width: 8),
          Text('新しいタブ',
              style: TextStyle(fontSize: 12, color: colorScheme.onSurfaceVariant)),
        ]),
      ),
    );
  }
}

class _VerticalTabWidget extends ConsumerWidget {
  final TabItem item;
  final int index;
  final TabNotifier notifier;
  const _VerticalTabWidget(
      {required this.item, required this.index, required this.notifier});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final active = ref.watch(tabProvider).currentIndex == index;
    final colorScheme = Theme.of(context).colorScheme;
    return Listener(
      behavior: HitTestBehavior.translucent,
      onPointerDown: (e) {
        if (e.buttons == 4) notifier.closeTab(index);
      },
      child: GestureDetector(
        onTap: () => notifier.selectTab(index),
        child: Container(
          height: 36,
          margin: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
          padding: const EdgeInsets.symmetric(horizontal: 10),
          decoration: BoxDecoration(
              color: active
                  ? colorScheme.surface
                  : colorScheme.onSurface.withOpacity(0.06),
              borderRadius: BorderRadius.circular(6)),
          child: Row(children: [
            Expanded(
                child: Text(item.title,
                    style: TextStyle(
                        fontSize: 12,
                        color: active
                            ? colorScheme.onSurface
                            : colorScheme.onSurfaceVariant,
                        fontWeight:
                            active ? FontWeight.bold : FontWeight.normal),
                    overflow: TextOverflow.ellipsis)),
            const SizedBox(width: 4),
            GestureDetector(
                onTap: () => notifier.closeTab(index),
                child: Icon(Icons.close,
                    size: 13, color: colorScheme.onSurfaceVariant)),
          ]),
        ),
      ),
    );
  }
}
