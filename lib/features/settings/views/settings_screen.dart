import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/settings_provider.dart';
import '../models/app_settings.dart';
import '../../../core/utils/platform_utils.dart';
import '../../../core/widgets/mobile_nav_popup.dart';
import '../../../l10n/app_localizations.dart';

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
    final loc = AppLocalizations.of(context)!;

    return Focus(
        focusNode: _focusNode,
        autofocus: true,
        onKeyEvent: (node, event) => KeyEventResult.ignored,
        child: Listener(
            behavior: HitTestBehavior.translucent,
            onPointerDown: (_) => _focusNode.requestFocus(),
            child: Scaffold(
              appBar: AppBar(title: Text(loc.settings)),
              body: ListView(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Text(loc.pageDirectionSection,
                        style: Theme.of(context).textTheme.titleMedium),
                  ),
                  RadioListTile<PageDirection>(
                    title: Text(loc.pageDirectionLeftTitle),
                    subtitle: Text(loc.pageDirectionLeftSubtitle),
                    value: PageDirection.leftToNext,
                    groupValue: settings.pageDirection,
                    onChanged: (val) {
                      if (val != null)
                        notifier.state = settings.copyWith(pageDirection: val);
                    },
                  ),
                  RadioListTile<PageDirection>(
                    title: Text(loc.pageDirectionRightTitle),
                    subtitle: Text(loc.pageDirectionRightSubtitle),
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
                      child: Text(loc.sidebarPositionSection,
                          style: Theme.of(context).textTheme.titleMedium),
                    ),
                    RadioListTile<SidebarPosition>(
                      title: Text(loc.sidebarPositionLeft),
                      value: SidebarPosition.left,
                      groupValue: settings.sidebarPosition,
                      onChanged: (val) {
                        if (val != null)
                          notifier.state =
                              settings.copyWith(sidebarPosition: val);
                      },
                    ),
                    RadioListTile<SidebarPosition>(
                      title: Text(loc.sidebarPositionRight),
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
                      child: Text(loc.tabBarPositionSection,
                          style: Theme.of(context).textTheme.titleMedium),
                    ),
                    RadioListTile<TabBarPosition>(
                      title: Text(loc.tabBarPositionTop),
                      value: TabBarPosition.top,
                      groupValue: settings.tabBarPosition,
                      onChanged: (val) {
                        if (val != null)
                          notifier.state = settings.copyWith(tabBarPosition: val);
                      },
                    ),
                    RadioListTile<TabBarPosition>(
                      title: Text(loc.tabBarPositionLeft),
                      value: TabBarPosition.left,
                      groupValue: settings.tabBarPosition,
                      onChanged: (val) {
                        if (val != null)
                          notifier.state = settings.copyWith(tabBarPosition: val);
                      },
                    ),
                    RadioListTile<TabBarPosition>(
                      title: Text(loc.tabBarPositionRight),
                      value: TabBarPosition.right,
                      groupValue: settings.tabBarPosition,
                      onChanged: (val) {
                        if (val != null)
                          notifier.state = settings.copyWith(tabBarPosition: val);
                      },
                    ),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(16, 4, 16, 12),
                      child: Text(loc.tabBarPositionOuterEdgeHint,
                          style: TextStyle(
                              fontSize: 12,
                              color: Theme.of(context)
                                  .colorScheme
                                  .onSurfaceVariant)),
                    ),
                    RadioListTile<OuterEdgeElement>(
                      title: Text(loc.outerEdgeVerticalTabs),
                      value: OuterEdgeElement.verticalTabs,
                      groupValue: settings.outerEdgeElement,
                      onChanged: (val) {
                        if (val != null)
                          notifier.state =
                              settings.copyWith(outerEdgeElement: val);
                      },
                    ),
                    RadioListTile<OuterEdgeElement>(
                      title: Text(loc.outerEdgeSidebar),
                      subtitle: Text(loc.outerEdgeSidebarSubtitle),
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
                      child: Text(loc.fullscreenBehaviorSection,
                          style: Theme.of(context).textTheme.titleMedium),
                    ),
                    RadioListTile<FullscreenBehavior>(
                      title: Text(loc.fullscreenOnViewerOnly),
                      subtitle: Text(loc.fullscreenOnViewerOnlySubtitle),
                      value: FullscreenBehavior.onViewerOnly,
                      groupValue: settings.fullscreenBehavior,
                      onChanged: (val) {
                        if (val != null)
                          notifier.state =
                              settings.copyWith(fullscreenBehavior: val);
                      },
                    ),
                    RadioListTile<FullscreenBehavior>(
                      title: Text(loc.fullscreenAlwaysOnLaunch),
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
                    child: Text(loc.launchTabSection,
                        style: Theme.of(context).textTheme.titleMedium),
                  ),
                  RadioListTile<LaunchTabBehavior>(
                    title: Text(loc.launchTabResumeLastBook),
                    value: LaunchTabBehavior.resumeLastBook,
                    groupValue: settings.launchTabBehavior,
                    onChanged: (val) {
                      if (val != null)
                        notifier.state =
                            settings.copyWith(launchTabBehavior: val);
                    },
                  ),
                  RadioListTile<LaunchTabBehavior>(
                    title: Text(loc.launchTabAlwaysLibrary),
                    subtitle: Text(loc.launchTabAlwaysLibrarySubtitle),
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
                    child: Text(loc.settingsFavoritesOpenModeSection,
                        style: Theme.of(context).textTheme.titleMedium),
                  ),
                  RadioListTile<SettingsFavoritesOpenMode>(
                    title: Text(loc.openInNewTab),
                    subtitle: Text(loc.openModeNewTabSubtitle),
                    value: SettingsFavoritesOpenMode.newTab,
                    groupValue: settings.settingsFavoritesOpenMode,
                    onChanged: (val) {
                      if (val != null)
                        notifier.state =
                            settings.copyWith(settingsFavoritesOpenMode: val);
                    },
                  ),
                  RadioListTile<SettingsFavoritesOpenMode>(
                    title: Text(loc.openModeToggleInPlace),
                    subtitle: Text(loc.openModeToggleInPlaceSubtitle),
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
                      child: Text(loc.middleClickSection,
                          style: Theme.of(context).textTheme.titleMedium),
                    ),
                    RadioListTile<MiddleClickTabBehavior>(
                      title: Text(loc.middleClickSwitchToNewTab),
                      value: MiddleClickTabBehavior.switchToNewTab,
                      groupValue: settings.middleClickTabBehavior,
                      onChanged: (val) {
                        if (val != null)
                          notifier.state =
                              settings.copyWith(middleClickTabBehavior: val);
                      },
                    ),
                    RadioListTile<MiddleClickTabBehavior>(
                      title: Text(loc.middleClickStayOnCurrentTab),
                      subtitle: Text(loc.middleClickStayOnCurrentTabSubtitle),
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
                      child: Text(loc.mobileNavIconsSection,
                          style: Theme.of(context).textTheme.titleMedium),
                    ),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
                      child: Text(loc.mobileNavIconsHint,
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
                    child: Text(loc.themeSection,
                        style: Theme.of(context).textTheme.titleMedium),
                  ),
                  RadioListTile<AppTheme>(
                    title: Text(loc.themeSystem),
                    value: AppTheme.system,
                    groupValue: settings.theme,
                    onChanged: (val) {
                      if (val != null)
                        notifier.state = settings.copyWith(theme: val);
                    },
                  ),
                  RadioListTile<AppTheme>(
                    title: Text(loc.themeLight),
                    value: AppTheme.light,
                    groupValue: settings.theme,
                    onChanged: (val) {
                      if (val != null)
                        notifier.state = settings.copyWith(theme: val);
                    },
                  ),
                  RadioListTile<AppTheme>(
                    title: Text(loc.themeDark),
                    value: AppTheme.dark,
                    groupValue: settings.theme,
                    onChanged: (val) {
                      if (val != null)
                        notifier.state = settings.copyWith(theme: val);
                    },
                  ),
                  const Divider(),
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Text(loc.languageSection,
                        style: Theme.of(context).textTheme.titleMedium),
                  ),
                  RadioListTile<AppLanguage>(
                    title: Text(loc.languageJapanese),
                    value: AppLanguage.ja,
                    groupValue: settings.language,
                    onChanged: (val) {
                      if (val != null)
                        notifier.state = settings.copyWith(language: val);
                    },
                  ),
                  RadioListTile<AppLanguage>(
                    title: Text(loc.languageEnglish),
                    value: AppLanguage.en,
                    groupValue: settings.language,
                    onChanged: (val) {
                      if (val != null)
                        notifier.state = settings.copyWith(language: val);
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
    final order = settings.effectiveMobileNavIconOrder;
    final hidden = settings.effectiveMobileNavHiddenIcons.toSet();
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
            secondary: Icon(mobileNavIconMeta(context, id).$1),
            title: Text(mobileNavIconMeta(context, id).$2),
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
