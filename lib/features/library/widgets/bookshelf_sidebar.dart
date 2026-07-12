import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path/path.dart' as p;
import '../models/shelf.dart';
import '../providers/library_provider.dart';
import '../../../core/providers/tab_provider.dart';
import '../../../core/providers/sidebar_focus_provider.dart';
import '../../../core/utils/library_search.dart';
import '../../settings/providers/settings_provider.dart';
import '../../settings/models/app_settings.dart';

class BookshelfSidebar extends ConsumerStatefulWidget {
  const BookshelfSidebar({super.key});
  @override
  ConsumerState<BookshelfSidebar> createState() => _BookshelfSidebarState();
}

class _BookshelfSidebarState extends ConsumerState<BookshelfSidebar> {
  final FocusNode _searchFocusNode = FocusNode();
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void dispose() {
    _searchFocusNode.dispose();
    _searchController.dispose();
    super.dispose();
  }

  void _clearSearch() {
    _searchController.clear();
    setState(() => _searchQuery = '');
  }

  @override
  Widget build(BuildContext context) {
    ref.listen(sidebarFocusRequestProvider, (previous, next) {
      // FocusNode.hasFocus がエンジン側の実際のウィンドウフォーカスと
      // ズレて古い状態のまま張り付くことがあるため、一度明示的に
      // unfocus してから次フレームで改めて requestFocus する
      _searchFocusNode.unfocus();
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _searchFocusNode.requestFocus();
      });
    });

    final state = ref.watch(libraryProvider);
    final notifier = ref.read(libraryProvider.notifier);
    final isSearching = _searchQuery.trim().isNotEmpty;
    final results = searchLibrary(state, _searchQuery);
    final searchResults = results.books;
    final folderSearchResults = results.folders;

    final favFolders = <(Shelf, String)>[
      for (final s in state.shelves)
        for (final path in s.favoriteFolders) (s, path),
    ];
    final favBooks = state.books.where((b) => b.isFavorite).toList();
    final hasFavorites = favFolders.isNotEmpty || favBooks.isNotEmpty;

    final colorScheme = Theme.of(context).colorScheme;
    return Material(
      type: MaterialType.transparency,
      child: Column(children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(12, 12, 12, 8),
          child: TextField(
            focusNode: _searchFocusNode,
            controller: _searchController,
            decoration: InputDecoration(
                hintText: '書籍・フォルダを検索...',
                prefixIcon: const Icon(Icons.search, size: 18),
                suffixIcon: isSearching
                    ? IconButton(
                        icon: const Icon(Icons.clear, size: 18),
                        onPressed: _clearSearch,
                      )
                    : null,
                filled: true,
                fillColor:
                    Theme.of(context).colorScheme.surface.withValues(alpha: 0.5),
                border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(30),
                    borderSide: BorderSide.none),
                contentPadding: EdgeInsets.zero,
                isDense: true),
            onChanged: (v) => setState(() => _searchQuery = v),
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
          child: SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              icon: const Icon(Icons.create_new_folder, size: 18),
              label: const Text('フォルダを追加'),
              style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  side: BorderSide(color: colorScheme.outlineVariant),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(6))),
              onPressed:
                  state.isLoading ? null : () => notifier.addShelf(context),
            ),
          ),
        ),
        Expanded(
          child: isSearching
              ? ((searchResults.isEmpty && folderSearchResults.isEmpty)
                  ? Center(
                      child: Text('該当する書籍・フォルダが見つかりません',
                          style: TextStyle(
                              fontSize: 12, color: colorScheme.onSurfaceVariant)),
                    )
                  : ListView.builder(
                      itemCount:
                          folderSearchResults.length + searchResults.length,
                      itemBuilder: (context, index) {
                        if (index < folderSearchResults.length) {
                          final (s, path) = folderSearchResults[index];
                          final fName = p.basename(path);
                          final rel = p.relative(path, from: s.folderPath);
                          final relParts =
                              rel == '.' ? <String>[] : rel.split(p.separator);
                          final segments = ['トップ', s.name, ...relParts];
                          return Listener(
                            onPointerDown: (e) {
                              if (e.buttons == 4) {
                                ref.read(tabProvider.notifier).navigateTo(s.id,
                                    path: path,
                                    title: fName,
                                    segments: segments,
                                    openInNewTab: true);
                              }
                            },
                            child: ListTile(
                              dense: true,
                              leading: Icon(Icons.folder,
                                  color: colorScheme.onSurface, size: 20),
                              title:
                                  Text(fName, overflow: TextOverflow.ellipsis),
                              onTap: () => ref.read(tabProvider.notifier).navigateTo(
                                  s.id,
                                  path: path,
                                  title: fName,
                                  segments: segments),
                            ),
                          );
                        }
                        final b = searchResults[index - folderSearchResults.length];
                        return Listener(
                          onPointerDown: (e) {
                            if (e.buttons == 4) {
                              ref
                                  .read(tabProvider.notifier)
                                  .openBook(b.id, b.title, true);
                            }
                          },
                          child: ListTile(
                            dense: true,
                            leading: b.thumbnailPath != null
                                ? Image.file(File(b.thumbnailPath!),
                                    width: 24, height: 32, fit: BoxFit.cover)
                                : Icon(Icons.book,
                                    color: colorScheme.onSurface, size: 20),
                            title:
                                Text(b.title, overflow: TextOverflow.ellipsis),
                            onTap: () => ref
                                .read(tabProvider.notifier)
                                .openBook(b.id, b.title, false),
                          ),
                        );
                      },
                    ))
              : (hasFavorites
                  ? ListView.builder(
                      itemCount: favFolders.length + favBooks.length,
                      itemBuilder: (context, index) {
                        if (index < favFolders.length) {
                          final (s, path) = favFolders[index];
                          final fName = p.basename(path);
                          final rel = p.relative(path, from: s.folderPath);
                          final relParts =
                              rel == '.' ? <String>[] : rel.split(p.separator);
                          final segments = ['トップ', s.name, ...relParts];
                          return Listener(
                            onPointerDown: (e) {
                              if (e.buttons == 4) {
                                ref.read(tabProvider.notifier).navigateTo(s.id,
                                    path: path,
                                    title: fName,
                                    segments: segments,
                                    openInNewTab: true);
                              }
                            },
                            child: ListTile(
                              dense: true,
                              leading: Icon(Icons.folder,
                                  color: colorScheme.onSurface, size: 20),
                              title:
                                  Text(fName, overflow: TextOverflow.ellipsis),
                              onTap: () => ref.read(tabProvider.notifier).navigateTo(
                                  s.id,
                                  path: path,
                                  title: fName,
                                  segments: segments),
                            ),
                          );
                        }
                        final b = favBooks[index - favFolders.length];
                        return Listener(
                          onPointerDown: (e) {
                            if (e.buttons == 4) {
                              ref
                                  .read(tabProvider.notifier)
                                  .openBook(b.id, b.title, true);
                            }
                          },
                          child: ListTile(
                            dense: true,
                            leading: b.thumbnailPath != null
                                ? Image.file(File(b.thumbnailPath!),
                                    width: 24, height: 32, fit: BoxFit.cover)
                                : Icon(Icons.book,
                                    color: colorScheme.onSurface, size: 20),
                            title:
                                Text(b.title, overflow: TextOverflow.ellipsis),
                            onTap: () => ref
                                .read(tabProvider.notifier)
                                .openBook(b.id, b.title, false),
                          ),
                        );
                      },
                    )
                  : Center(
                      child: Text('お気に入りはまだありません',
                          style: TextStyle(
                              fontSize: 12, color: colorScheme.onSurfaceVariant)),
                    )),
        ),
        Divider(height: 1, color: colorScheme.outlineVariant),
        SafeArea(
          top: false,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: Builder(builder: (context) {
              final isLeft = ref.watch(settingsProvider).sidebarPosition ==
                  SidebarPosition.left;
              final settingsButton = IconButton(
                icon: const Icon(Icons.settings, size: 20),
                color: colorScheme.onSurfaceVariant,
                onPressed: () => ref.read(tabProvider.notifier).openSettings(),
              );
              final favoritesButton = IconButton(
                icon: const Icon(Icons.star, size: 20),
                color: colorScheme.onSurfaceVariant,
                onPressed: () => ref.read(tabProvider.notifier).openFavorites(),
              );
              return Row(
                mainAxisAlignment:
                    isLeft ? MainAxisAlignment.start : MainAxisAlignment.end,
                children: isLeft
                    ? [settingsButton, favoritesButton]
                    : [favoritesButton, settingsButton],
              );
            }),
          ),
        ),
      ]),
    );
  }
}
