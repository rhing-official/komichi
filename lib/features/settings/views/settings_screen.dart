import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/settings_provider.dart';
import '../models/app_settings.dart';
import '../../../core/utils/platform_utils.dart';
import '../../../core/widgets/mobile_nav_popup.dart';

class SettingsScreen extends ConsumerStatefulWidget {
  final bool isActive;
  const SettingsScreen({super.key, this.isActive = true});

  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen> {
  final FocusNode _focusNode = FocusNode();

  // フォーカスはタブがアクティブになった時と画面内クリック時のみ取得する。
  // buildのたびにrequestFocusすると、サイドバーの検索欄など他所にフォーカスが
  // ある状態でも、無関係な再ビルドのたびにフォーカスを奪ってしまう
  @override
  void initState() {
    super.initState();
    if (widget.isActive) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) _focusNode.requestFocus();
      });
    }
  }

  @override
  void didUpdateWidget(covariant SettingsScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (!oldWidget.isActive && widget.isActive) _focusNode.requestFocus();
  }

  @override
  void dispose() {
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final settings = ref.watch(settingsProvider);
    final notifier = ref.read(settingsProvider.notifier);

    return Focus(
        focusNode: _focusNode,
        autofocus: true,
        onKeyEvent: (node, event) => KeyEventResult.ignored,
        child: Listener(
            behavior: HitTestBehavior.translucent,
            onPointerDown: (_) => _focusNode.requestFocus(),
            child: Scaffold(
              appBar: AppBar(title: const Text('設定')),
              body: ListView(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Text('ページの送り方',
                        style: Theme.of(context).textTheme.titleMedium),
                  ),
                  RadioListTile<PageDirection>(
                    title: const Text('左送り'),
                    subtitle: const Text('左クリック / 左キーで次ページへ移動します'),
                    value: PageDirection.leftToNext,
                    groupValue: settings.pageDirection,
                    onChanged: (val) {
                      if (val != null)
                        notifier.state = settings.copyWith(pageDirection: val);
                    },
                  ),
                  RadioListTile<PageDirection>(
                    title: const Text('右送り'),
                    subtitle: const Text('右クリック / 右キーで次ページへ移動します'),
                    value: PageDirection.rightToNext,
                    groupValue: settings.pageDirection,
                    onChanged: (val) {
                      if (val != null)
                        notifier.state = settings.copyWith(pageDirection: val);
                    },
                  ),
                  if (!isMobilePlatform) ...[
                    const Divider(),
                    Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Text('サイドバーの位置',
                          style: Theme.of(context).textTheme.titleMedium),
                    ),
                    RadioListTile<SidebarPosition>(
                      title: const Text('左'),
                      value: SidebarPosition.left,
                      groupValue: settings.sidebarPosition,
                      onChanged: (val) {
                        if (val != null)
                          notifier.state =
                              settings.copyWith(sidebarPosition: val);
                      },
                    ),
                    RadioListTile<SidebarPosition>(
                      title: const Text('右'),
                      value: SidebarPosition.right,
                      groupValue: settings.sidebarPosition,
                      onChanged: (val) {
                        if (val != null)
                          notifier.state =
                              settings.copyWith(sidebarPosition: val);
                      },
                    ),
                    const Divider(),
                    Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Text('タブバーの配置',
                          style: Theme.of(context).textTheme.titleMedium),
                    ),
                    RadioListTile<TabBarPosition>(
                      title: const Text('上部（水平タブ）'),
                      value: TabBarPosition.top,
                      groupValue: settings.tabBarPosition,
                      onChanged: (val) {
                        if (val != null)
                          notifier.state = settings.copyWith(tabBarPosition: val);
                      },
                    ),
                    RadioListTile<TabBarPosition>(
                      title: const Text('左端（垂直タブ）'),
                      value: TabBarPosition.left,
                      groupValue: settings.tabBarPosition,
                      onChanged: (val) {
                        if (val != null)
                          notifier.state = settings.copyWith(tabBarPosition: val);
                      },
                    ),
                    RadioListTile<TabBarPosition>(
                      title: const Text('右端（垂直タブ）'),
                      value: TabBarPosition.right,
                      groupValue: settings.tabBarPosition,
                      onChanged: (val) {
                        if (val != null)
                          notifier.state = settings.copyWith(tabBarPosition: val);
                      },
                    ),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(16, 4, 16, 12),
                      child: Text('垂直タブ使用時、サイドバーと同じ辺にある場合にどちらを外側（画面端側）に配置するか',
                          style: TextStyle(
                              fontSize: 12,
                              color: Theme.of(context)
                                  .colorScheme
                                  .onSurfaceVariant)),
                    ),
                    RadioListTile<OuterEdgeElement>(
                      title: const Text('垂直タブを外側に'),
                      value: OuterEdgeElement.verticalTabs,
                      groupValue: settings.outerEdgeElement,
                      onChanged: (val) {
                        if (val != null)
                          notifier.state =
                              settings.copyWith(outerEdgeElement: val);
                      },
                    ),
                    RadioListTile<OuterEdgeElement>(
                      title: const Text('サイドバーを外側に'),
                      subtitle: const Text('サイドバーを最大化すると、垂直タブはそれに合わせて内側へ移動します'),
                      value: OuterEdgeElement.sidebar,
                      groupValue: settings.outerEdgeElement,
                      onChanged: (val) {
                        if (val != null)
                          notifier.state =
                              settings.copyWith(outerEdgeElement: val);
                      },
                    ),
                    const Divider(),
                    Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Text('全画面表示のタイミング',
                          style: Theme.of(context).textTheme.titleMedium),
                    ),
                    RadioListTile<FullscreenBehavior>(
                      title: const Text('書籍を開いている間のみ'),
                      subtitle: const Text('本棚などを見ている間はウィンドウ表示にします'),
                      value: FullscreenBehavior.onViewerOnly,
                      groupValue: settings.fullscreenBehavior,
                      onChanged: (val) {
                        if (val != null)
                          notifier.state =
                              settings.copyWith(fullscreenBehavior: val);
                      },
                    ),
                    RadioListTile<FullscreenBehavior>(
                      title: const Text('起動時から常に全画面'),
                      value: FullscreenBehavior.alwaysOnLaunch,
                      groupValue: settings.fullscreenBehavior,
                      onChanged: (val) {
                        if (val != null)
                          notifier.state =
                              settings.copyWith(fullscreenBehavior: val);
                      },
                    ),
                  ],
                  const Divider(),
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Text('起動時のタブ',
                        style: Theme.of(context).textTheme.titleMedium),
                  ),
                  RadioListTile<LaunchTabBehavior>(
                    title: const Text('前回読んでいた書籍を再度開く'),
                    value: LaunchTabBehavior.resumeLastBook,
                    groupValue: settings.launchTabBehavior,
                    onChanged: (val) {
                      if (val != null)
                        notifier.state =
                            settings.copyWith(launchTabBehavior: val);
                    },
                  ),
                  RadioListTile<LaunchTabBehavior>(
                    title: const Text('常に本棚タブから始める'),
                    subtitle: const Text('読書履歴（どこまで読んだか）はこの設定に関わらず保持されます'),
                    value: LaunchTabBehavior.alwaysLibrary,
                    groupValue: settings.launchTabBehavior,
                    onChanged: (val) {
                      if (val != null)
                        notifier.state =
                            settings.copyWith(launchTabBehavior: val);
                    },
                  ),
                  const Divider(),
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Text('設定・お気に入りアイコンの動作',
                        style: Theme.of(context).textTheme.titleMedium),
                  ),
                  RadioListTile<SettingsFavoritesOpenMode>(
                    title: const Text('別タブで開く'),
                    subtitle: const Text('既に開いていればそのタブに切り替えます'),
                    value: SettingsFavoritesOpenMode.newTab,
                    groupValue: settings.settingsFavoritesOpenMode,
                    onChanged: (val) {
                      if (val != null)
                        notifier.state =
                            settings.copyWith(settingsFavoritesOpenMode: val);
                    },
                  ),
                  RadioListTile<SettingsFavoritesOpenMode>(
                    title: const Text('現在のタブ内で切り替える'),
                    subtitle: const Text('もう一度アイコンをタップすると、切り替え前に表示していたページに戻ります'),
                    value: SettingsFavoritesOpenMode.toggleInPlace,
                    groupValue: settings.settingsFavoritesOpenMode,
                    onChanged: (val) {
                      if (val != null)
                        notifier.state =
                            settings.copyWith(settingsFavoritesOpenMode: val);
                    },
                  ),
                  if (!isMobilePlatform) ...[
                    const Divider(),
                    Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Text('中クリックで新しいタブを開いた時',
                          style: Theme.of(context).textTheme.titleMedium),
                    ),
                    RadioListTile<MiddleClickTabBehavior>(
                      title: const Text('新しいタブに自動的に切り替える'),
                      value: MiddleClickTabBehavior.switchToNewTab,
                      groupValue: settings.middleClickTabBehavior,
                      onChanged: (val) {
                        if (val != null)
                          notifier.state =
                              settings.copyWith(middleClickTabBehavior: val);
                      },
                    ),
                    RadioListTile<MiddleClickTabBehavior>(
                      title: const Text('元のタブに留まる'),
                      subtitle: const Text('新しいタブはバックグラウンドで開かれます'),
                      value: MiddleClickTabBehavior.stayOnCurrentTab,
                      groupValue: settings.middleClickTabBehavior,
                      onChanged: (val) {
                        if (val != null)
                          notifier.state =
                              settings.copyWith(middleClickTabBehavior: val);
                      },
                    ),
                  ],
                  if (isMobilePlatform) ...[
                    const Divider(),
                    Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Text('ナビゲーションポップアップの表示アイコン',
                          style: Theme.of(context).textTheme.titleMedium),
                    ),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
                      child: Text('チェックを外したアイコンはポップアップ右端のメニューに収納されます。ドラッグで並び順を変更できます',
                          style: TextStyle(
                              fontSize: 12,
                              color: Theme.of(context)
                                  .colorScheme
                                  .onSurfaceVariant)),
                    ),
                    _MobileNavIconSettingsList(
                        settings: settings, notifier: notifier),
                  ],
                  const Divider(),
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Text('テーマ設定',
                        style: Theme.of(context).textTheme.titleMedium),
                  ),
                  RadioListTile<AppTheme>(
                    title: const Text('システム設定に従う'),
                    value: AppTheme.system,
                    groupValue: settings.theme,
                    onChanged: (val) {
                      if (val != null)
                        notifier.state = settings.copyWith(theme: val);
                    },
                  ),
                  RadioListTile<AppTheme>(
                    title: const Text('ライトモード'),
                    value: AppTheme.light,
                    groupValue: settings.theme,
                    onChanged: (val) {
                      if (val != null)
                        notifier.state = settings.copyWith(theme: val);
                    },
                  ),
                  RadioListTile<AppTheme>(
                    title: const Text('ダークモード'),
                    value: AppTheme.dark,
                    groupValue: settings.theme,
                    onChanged: (val) {
                      if (val != null)
                        notifier.state = settings.copyWith(theme: val);
                    },
                  ),
                ],
              ),
            )));
  }
}

// モバイルのナビゲーションポップアップに並べるアイコンの表示/非表示・並び順を
// 設定するリスト。チェックを外すとpopup右端のハンバーガーメニューへ収納され、
// ドラッグで並び順を変更できる
class _MobileNavIconSettingsList extends StatelessWidget {
  final AppSettings settings;
  final SettingsNotifier notifier;
  const _MobileNavIconSettingsList(
      {required this.settings, required this.notifier});

  @override
  Widget build(BuildContext context) {
    final order = settings.mobileNavIconOrder;
    final hidden = settings.mobileNavHiddenIcons.toSet();
    return ReorderableListView(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      onReorder: (oldIndex, newIndex) {
        final newOrder = List<String>.from(order);
        if (newIndex > oldIndex) newIndex -= 1;
        final id = newOrder.removeAt(oldIndex);
        newOrder.insert(newIndex, id);
        notifier.state = settings.copyWith(mobileNavIconOrder: newOrder);
      },
      children: [
        for (final id in order)
          CheckboxListTile(
            key: ValueKey(id),
            secondary: Icon(kMobileNavIconMeta[id]!.$1),
            title: Text(kMobileNavIconMeta[id]!.$2),
            value: !hidden.contains(id),
            onChanged: (checked) {
              final newHidden = Set<String>.from(hidden);
              checked == true ? newHidden.remove(id) : newHidden.add(id);
              notifier.state =
                  settings.copyWith(mobileNavHiddenIcons: newHidden.toList());
            },
          ),
      ],
    );
  }
}
