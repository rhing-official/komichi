import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/settings_provider.dart';
import '../models/app_settings.dart';

class SettingsScreen extends ConsumerStatefulWidget {
  final bool isActive;
  const SettingsScreen({super.key, this.isActive = true});

  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen> {
  final FocusNode _focusNode = FocusNode();

  @override
  void dispose() {
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.isActive) _focusNode.requestFocus();
    final settings = ref.watch(settingsProvider);
    final notifier = ref.read(settingsProvider.notifier);

    return Focus(
      focusNode: _focusNode,
      autofocus: true,
      onKeyEvent: (node, event) => KeyEventResult.ignored,
      child: Scaffold(
      appBar: AppBar(title: const Text('設定')),
      body: ListView(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child:
                Text('ページの送り方', style: Theme.of(context).textTheme.titleMedium),
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
                notifier.state = settings.copyWith(sidebarPosition: val);
            },
          ),
          RadioListTile<SidebarPosition>(
            title: const Text('右'),
            value: SidebarPosition.right,
            groupValue: settings.sidebarPosition,
            onChanged: (val) {
              if (val != null)
                notifier.state = settings.copyWith(sidebarPosition: val);
            },
          ),
          const Divider(),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child:
                Text('タブバーの配置', style: Theme.of(context).textTheme.titleMedium),
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
                    color: Theme.of(context).colorScheme.onSurfaceVariant)),
          ),
          RadioListTile<OuterEdgeElement>(
            title: const Text('垂直タブを外側に'),
            value: OuterEdgeElement.verticalTabs,
            groupValue: settings.outerEdgeElement,
            onChanged: (val) {
              if (val != null)
                notifier.state = settings.copyWith(outerEdgeElement: val);
            },
          ),
          RadioListTile<OuterEdgeElement>(
            title: const Text('サイドバーを外側に'),
            subtitle: const Text('サイドバーを最大化すると、垂直タブはそれに合わせて内側へ移動します'),
            value: OuterEdgeElement.sidebar,
            groupValue: settings.outerEdgeElement,
            onChanged: (val) {
              if (val != null)
                notifier.state = settings.copyWith(outerEdgeElement: val);
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
                notifier.state = settings.copyWith(fullscreenBehavior: val);
            },
          ),
          RadioListTile<FullscreenBehavior>(
            title: const Text('起動時から常に全画面'),
            value: FullscreenBehavior.alwaysOnLaunch,
            groupValue: settings.fullscreenBehavior,
            onChanged: (val) {
              if (val != null)
                notifier.state = settings.copyWith(fullscreenBehavior: val);
            },
          ),
          const Divider(),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text('テーマ設定', style: Theme.of(context).textTheme.titleMedium),
          ),
          RadioListTile<AppTheme>(
            title: const Text('システム設定に従う'),
            value: AppTheme.system,
            groupValue: settings.theme,
            onChanged: (val) {
              if (val != null) notifier.state = settings.copyWith(theme: val);
            },
          ),
          RadioListTile<AppTheme>(
            title: const Text('ライトモード'),
            value: AppTheme.light,
            groupValue: settings.theme,
            onChanged: (val) {
              if (val != null) notifier.state = settings.copyWith(theme: val);
            },
          ),
          RadioListTile<AppTheme>(
            title: const Text('ダークモード'),
            value: AppTheme.dark,
            groupValue: settings.theme,
            onChanged: (val) {
              if (val != null) notifier.state = settings.copyWith(theme: val);
            },
          ),
        ],
      ),
    ));
  }
}
