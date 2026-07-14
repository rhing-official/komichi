import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/providers/tab_provider.dart';
import '../../../core/utils/tab_title_utils.dart';
import '../../../l10n/app_localizations.dart';

// デスクトップのタブバー・垂直タブ帯の代替。モバイルでは常時表示のタブ列を
// 持たず、ポップアップの「現在のタブ数」アイコンからこのボトムシートを開いて
// タブの切替・追加・削除を行う
class MobileTabSwitcher extends ConsumerWidget {
  const MobileTabSwitcher({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tabState = ref.watch(tabProvider);
    final notifier = ref.read(tabProvider.notifier);
    final colorScheme = Theme.of(context).colorScheme;

    return SafeArea(
      top: false,
      child: Column(mainAxisSize: MainAxisSize.min, children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 4, 16, 8),
          child: Row(children: [
            Text('タブ (${tabState.tabs.length})',
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          ]),
        ),
        Flexible(
          child: ListView.builder(
            shrinkWrap: true,
            itemCount: tabState.tabs.length,
            itemBuilder: (context, index) {
              final tab = tabState.tabs[index];
              final active = index == tabState.currentIndex;
              return ListTile(
                selected: active,
                selectedTileColor: colorScheme.surfaceContainerHighest,
                leading: Icon(
                    tab.isSettings
                        ? Icons.settings
                        : tab.isFavorites
                            ? Icons.star
                            : tab.bookId != null
                                ? Icons.book
                                : Icons.folder,
                    color: colorScheme.onSurfaceVariant),
                title: Text(tabDisplayTitle(context, tab.title),
                    overflow: TextOverflow.ellipsis),
                trailing: IconButton(
                  icon: const Icon(Icons.close, size: 18),
                  onPressed: () => notifier.closeTab(index),
                ),
                onTap: () {
                  notifier.selectTab(index);
                  Navigator.of(context).pop();
                },
              );
            },
          ),
        ),
        ListTile(
          leading: Icon(Icons.add, color: colorScheme.onSurface),
          title: Text(AppLocalizations.of(context)!.newTab),
          onTap: () {
            notifier.addLibraryTab();
            Navigator.of(context).pop();
          },
        ),
      ]),
    );
  }
}
