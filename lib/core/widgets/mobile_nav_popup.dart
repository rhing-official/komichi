import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/tab_provider.dart';
import '../../features/library/providers/library_provider.dart';
import '../../features/library/views/mobile_search_screen.dart';
import '../../features/library/views/mobile_tab_switcher.dart';
import '../../features/settings/providers/settings_provider.dart';
import '../../l10n/app_localizations.dart';
import 'glass_panel.dart';

const double kMobileNavPopupHeight = 52;

// アイコンID→(アイコン, ラベル)。設定画面の表示/並べ替えリストと、
// ポップアップ本体([MobileNavIconRow])の両方から参照する共通定義。
// ラベルは表示言語設定に応じて切り替えるため、constマップではなくcontext
// 引数を取る関数にしてある
(IconData, String) mobileNavIconMeta(BuildContext context, String id) {
  final loc = AppLocalizations.of(context)!;
  return switch (id) {
    'back' => (Icons.arrow_back, loc.navBack),
    'forward' => (Icons.arrow_forward, loc.navForward),
    'search' => (Icons.search, loc.navSearch),
    'addTab' => (Icons.add, loc.navAddTab),
    'tabCount' => (Icons.tab_outlined, loc.navTabList),
    'favorites' => (Icons.star, loc.favorites),
    'settings' => (Icons.settings, loc.settings),
    'information' => (Icons.info_outline, loc.information),
    'addFolder' => (Icons.create_new_folder, loc.addFolder),
    _ => throw ArgumentError('unknown nav icon id: $id'),
  };
}

class _NavAction {
  final IconData icon;
  final String label;
  final VoidCallback? onPressed;
  final Widget? badge;
  const _NavAction(
      {required this.icon, required this.label, this.onPressed, this.badge});
}

// タブバー・サイドバー・パスバーの機能をここへ集約するモバイル専用ポップアップ。
// 表示するアイコンの並び順・非表示にするアイコンは設定画面から変更でき、
// 非表示にしたものは右端のハンバーガーメニューへ収納される。
// 本棚表示中はこのGlassPanel入りの独立したピルとして下部に常駐させ、ビューア
// 表示中は[MobileNavIconRow]だけをビューア自身のページ送りパネルに埋め込み、
// 2枚のガラスパネルが重なって見えないようにする
class MobileNavPopup extends StatelessWidget {
  const MobileNavPopup({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      minimum: const EdgeInsets.fromLTRB(12, 0, 12, 8),
      child: RepaintBoundary(
        child: ClipRRect(
          borderRadius: BorderRadius.circular(28),
          child: GlassPanel(
            borderRadius: BorderRadius.circular(28),
            child: const SizedBox(
              height: kMobileNavPopupHeight,
              child: MobileNavIconRow(),
            ),
          ),
        ),
      ),
    );
  }
}

// 8アイコン+ハンバーガーの横並び本体。背景・余白を持たないため、呼び出し側
// （本棚用の[MobileNavPopup]、ビューア用の統合パネル）が任意の背景に埋め込める
class MobileNavIconRow extends ConsumerWidget {
  final Color? iconColor;
  const MobileNavIconRow({super.key, this.iconColor});

  _NavAction _actionFor(BuildContext context, WidgetRef ref, String id) {
    final tabState = ref.watch(tabProvider);
    final tabNotifier = ref.read(tabProvider.notifier);
    final tab = tabState.tabs[tabState.currentIndex];
    final libraryState = ref.watch(libraryProvider);

    final (icon, label) = mobileNavIconMeta(context, id);
    switch (id) {
      case 'back':
        return _NavAction(
            icon: icon,
            label: label,
            onPressed: tab.historyIndex > 0 ? tabNotifier.undo : null);
      case 'forward':
        return _NavAction(
            icon: icon,
            label: label,
            onPressed: tab.historyIndex < tab.history.length - 1
                ? tabNotifier.redo
                : null);
      case 'search':
        return _NavAction(
            icon: icon,
            label: label,
            onPressed: () => Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const MobileSearchScreen())));
      case 'addTab':
        return _NavAction(
            icon: icon, label: label, onPressed: tabNotifier.addLibraryTab);
      case 'tabCount':
        return _NavAction(
          icon: icon,
          label: '$label (${tabState.tabs.length})',
          badge: _CountBadge(count: tabState.tabs.length),
          onPressed: () => showModalBottomSheet(
              context: context,
              showDragHandle: true,
              builder: (_) => const MobileTabSwitcher()),
        );
      case 'favorites':
        return _NavAction(
            icon: icon,
            label: label,
            onPressed: tabNotifier.openOrToggleFavorites);
      case 'settings':
        return _NavAction(
            icon: icon,
            label: label,
            onPressed: tabNotifier.openOrToggleSettings);
      case 'information':
        return _NavAction(
            icon: icon,
            label: label,
            onPressed: tabNotifier.openOrToggleInformation);
      case 'addFolder':
        return _NavAction(
          icon: icon,
          label: label,
          onPressed: libraryState.isLoading
              ? null
              : () => ref.read(libraryProvider.notifier).addShelf(context),
        );
    }
    throw ArgumentError('unknown nav icon id: $id');
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(settingsProvider);
    final hidden = settings.effectiveMobileNavHiddenIcons.toSet();
    final order = settings.effectiveMobileNavIconOrder;
    final visibleIds = order.where((id) => !hidden.contains(id)).toList();
    final hiddenIds = order.where((id) => hidden.contains(id)).toList();
    final color = iconColor ?? Theme.of(context).colorScheme.onSurface;
    final tabNotifier = ref.read(tabProvider.notifier);

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        for (final id in visibleIds)
          id == 'tabCount'
              ? GestureDetector(
                  // タブ数アイコン上のスワイプでタブ切り替え。左スワイプで
                  // 前のタブ、右スワイプで次のタブへジャンプする
                  onHorizontalDragEnd: (details) {
                    final velocity = details.primaryVelocity ?? 0;
                    if (velocity < 0) {
                      tabNotifier.previousTab();
                    } else if (velocity > 0) {
                      tabNotifier.nextTab();
                    }
                  },
                  child: _NavIconButton(
                      action: _actionFor(context, ref, id), color: color),
                )
              : _NavIconButton(
                  action: _actionFor(context, ref, id), color: color),
        if (hiddenIds.isNotEmpty)
          _HamburgerButton(
              hiddenIds: hiddenIds,
              actionFor: (id) => _actionFor(context, ref, id),
              color: color),
      ],
    );
  }
}

class _NavIconButton extends StatelessWidget {
  final _NavAction action;
  final Color color;
  const _NavIconButton({required this.action, required this.color});

  @override
  Widget build(BuildContext context) {
    final icon = Icon(action.icon, size: 22, color: color);
    return IconButton(
      tooltip: action.label,
      icon: action.badge == null
          ? icon
          : Stack(clipBehavior: Clip.none, children: [
              icon,
              Positioned(right: -4, top: -4, child: action.badge!),
            ]),
      onPressed: action.onPressed,
    );
  }
}

class _CountBadge extends StatelessWidget {
  final int count;
  const _CountBadge({required this.count});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 4),
      constraints: const BoxConstraints(minWidth: 15, minHeight: 15),
      decoration: BoxDecoration(
          color: colorScheme.inverseSurface, borderRadius: BorderRadius.circular(8)),
      child: Text('$count',
          textAlign: TextAlign.center,
          style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.bold,
              color: colorScheme.onInverseSurface)),
    );
  }
}

class _HamburgerButton extends StatelessWidget {
  final List<String> hiddenIds;
  final _NavAction Function(String id) actionFor;
  final Color color;
  const _HamburgerButton(
      {required this.hiddenIds, required this.actionFor, required this.color});

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<String>(
      tooltip: AppLocalizations.of(context)!.navMore,
      icon: Icon(Icons.menu, size: 22, color: color),
      itemBuilder: (context) => [
        for (final id in hiddenIds)
          PopupMenuItem<String>(
            value: id,
            child: Builder(builder: (context) {
              final a = actionFor(id);
              return Row(children: [
                Icon(a.icon, size: 18),
                const SizedBox(width: 12),
                Text(a.label),
              ]);
            }),
          ),
      ],
      onSelected: (id) => actionFor(id).onPressed?.call(),
    );
  }
}
