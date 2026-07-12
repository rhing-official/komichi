import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path/path.dart' as p;
import '../models/book.dart';
import '../models/shelf.dart';
import '../providers/library_provider.dart';
import '../widgets/read_progress_bar.dart';
import '../../../core/providers/tab_provider.dart';
import '../../../core/utils/sort_utils.dart';

class FavoritesScreen extends ConsumerStatefulWidget {
  final bool isActive;
  const FavoritesScreen({super.key, this.isActive = true});

  @override
  ConsumerState<FavoritesScreen> createState() => _FavoritesScreenState();
}

class _FavoritesScreenState extends ConsumerState<FavoritesScreen> {
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
  void didUpdateWidget(covariant FavoritesScreen oldWidget) {
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
    final state = ref.watch(libraryProvider);
    final favFolders = <(Shelf, String)>[
      for (final s in state.shelves)
        for (final path in s.favoriteFolders) (s, path),
    ]..sort(
        (a, b) => SortUtils.compareNatural(p.basename(a.$2), p.basename(b.$2)));
    final favBooks = state.books.where((b) => b.isFavorite).toList()
      ..sort((a, b) => SortUtils.compareNatural(a.title, b.title));

    final content = (favFolders.isEmpty && favBooks.isEmpty)
        ? Center(
            child: Column(mainAxisSize: MainAxisSize.min, children: [
              Icon(Icons.star_border,
                  size: 64,
                  color:
                      Theme.of(context).colorScheme.primary.withOpacity(0.4)),
              const SizedBox(height: 16),
              Text('お気に入りはまだありません',
                  style: TextStyle(
                      fontSize: 14,
                      color: Theme.of(context)
                          .colorScheme
                          .onSurface
                          .withOpacity(0.6))),
            ]),
          )
        : GridView.builder(
            padding: const EdgeInsets.all(24),
            gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                maxCrossAxisExtent: 220,
                childAspectRatio: 0.7,
                crossAxisSpacing: 20,
                mainAxisSpacing: 20),
            itemCount: favFolders.length + favBooks.length,
            itemBuilder: (context, index) {
              if (index < favFolders.length) {
                final (shelf, path) = favFolders[index];
                return _FavoriteFolderCard(shelf: shelf, path: path);
              }
              return _FavoriteBookCard(
                  book: favBooks[index - favFolders.length]);
            },
          );

    return Focus(
      focusNode: _focusNode,
      autofocus: true,
      onKeyEvent: (node, event) => KeyEventResult.ignored,
      child: Listener(
        behavior: HitTestBehavior.translucent,
        onPointerDown: (_) => _focusNode.requestFocus(),
        child: content,
      ),
    );
  }
}

class _FavoriteFolderCard extends ConsumerStatefulWidget {
  final Shelf shelf;
  final String path;
  const _FavoriteFolderCard({required this.shelf, required this.path});
  @override
  ConsumerState<_FavoriteFolderCard> createState() =>
      _FavoriteFolderCardState();
}

class _FavoriteFolderCardState extends ConsumerState<_FavoriteFolderCard> {
  bool _hover = false;

  Future<void> _showMenu(Offset globalPosition, List<String> segments) async {
    final overlay = Overlay.of(context).context.findRenderObject() as RenderBox;
    final selected = await showMenu<String>(
      context: context,
      position: RelativeRect.fromRect(
          globalPosition & const Size(1, 1), Offset.zero & overlay.size),
      items: const [
        PopupMenuItem(value: 'favorite', child: Text('お気に入り解除')),
        PopupMenuItem(value: 'newtab', child: Text('別タブで開く')),
      ],
    );
    if (!mounted) return;
    switch (selected) {
      case 'favorite':
        ref
            .read(libraryProvider.notifier)
            .toggleFolderFavorite(widget.shelf.id, widget.path, false);
        break;
      case 'newtab':
        ref.read(tabProvider.notifier).navigateTo(widget.shelf.id,
            path: widget.path,
            title: p.basename(widget.path),
            segments: segments,
            openInNewTab: true);
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final state = ref.watch(libraryProvider);
    final fName = p.basename(widget.path);
    final rel = p.relative(widget.path, from: widget.shelf.folderPath);
    final relParts = rel == '.' ? <String>[] : rel.split(p.separator);
    final segments = ['トップ', widget.shelf.name, ...relParts];

    final booksInFolder = state.books.where((b) =>
        b.shelfId == widget.shelf.id &&
        (b.filePath == widget.path ||
            b.filePath.startsWith(widget.path + p.separator)));
    final sortedBooks = booksInFolder.toList()
      ..sort((a, b) => SortUtils.compareNatural(a.title, b.title));
    final thumbBooks = sortedBooks.take(5).toList().reversed.toList();

    return MouseRegion(
      onEnter: (_) => setState(() => _hover = true),
      onExit: (_) => setState(() => _hover = false),
      child: Column(children: [
        Expanded(
            child: Card(
          shape: const RoundedRectangleBorder(),
          clipBehavior: Clip.antiAlias,
          color: colorScheme.surfaceContainerHighest,
          elevation: _hover ? 1 : 0,
          child: Listener(
            onPointerDown: (e) {
              if (e.buttons == 4) {
                ref.read(tabProvider.notifier).navigateTo(widget.shelf.id,
                    path: widget.path,
                    title: fName,
                    segments: segments,
                    openInNewTab: true);
              }
            },
            child: GestureDetector(
              onSecondaryTapDown: (d) => _showMenu(d.globalPosition, segments),
              onLongPressStart: (d) => _showMenu(d.globalPosition, segments),
              child: InkWell(
                onTap: () => ref.read(tabProvider.notifier).navigateTo(
                    widget.shelf.id,
                    path: widget.path,
                    title: fName,
                    segments: segments),
                child: Stack(children: [
                  if (thumbBooks.isEmpty)
                    Center(
                        child: Icon(Icons.folder,
                            size: 64, color: colorScheme.onSurfaceVariant))
                  else
                    ...thumbBooks.asMap().entries.map((entry) {
                      final i = entry.key;
                      final b = entry.value;
                      return Positioned(
                        top: 0,
                        bottom: 0,
                        left: i * 8.0,
                        right: (thumbBooks.length - 1 - i) * 8.0,
                        child: b.thumbnailPath != null
                            ? Image.file(File(b.thumbnailPath!),
                                fit: BoxFit.cover,
                                color: i < thumbBooks.length - 1
                                    ? Colors.black.withOpacity(0.3)
                                    : null,
                                colorBlendMode: i < thumbBooks.length - 1
                                    ? BlendMode.darken
                                    : null)
                            : Container(
                                color: colorScheme.surfaceContainerHigh),
                      );
                    }),
                  if (booksInFolder.isNotEmpty)
                    Positioned(
                      bottom: 8,
                      left: (thumbBooks.length - 1) * 8.0 + 8.0,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: Colors.black.withOpacity(0.8),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          '${booksInFolder.length} 個のファイル',
                          style: const TextStyle(
                              color: Colors.white,
                              fontSize: 10,
                              fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                ]),
              ),
            ),
          ),
        )),
        Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4.0, vertical: 4.0),
            child: Tooltip(
              message: fName,
              child: SizedBox(
                height: 48,
                child: Text(fName,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                        fontSize: 13, fontWeight: FontWeight.w500, height: 1.1),
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis),
              ),
            )),
      ]),
    );
  }
}

class _FavoriteBookCard extends ConsumerStatefulWidget {
  final Book book;
  const _FavoriteBookCard({required this.book});
  @override
  ConsumerState<_FavoriteBookCard> createState() => _FavoriteBookCardState();
}

class _FavoriteBookCardState extends ConsumerState<_FavoriteBookCard> {
  bool _hover = false;

  Future<void> _showMenu(Offset globalPosition) async {
    final overlay = Overlay.of(context).context.findRenderObject() as RenderBox;
    final selected = await showMenu<String>(
      context: context,
      position: RelativeRect.fromRect(
          globalPosition & const Size(1, 1), Offset.zero & overlay.size),
      items: const [
        PopupMenuItem(value: 'favorite', child: Text('お気に入り解除')),
        PopupMenuItem(value: 'newtab', child: Text('別タブで開く')),
      ],
    );
    if (!mounted) return;
    switch (selected) {
      case 'favorite':
        ref.read(libraryProvider.notifier).toggleBookFavorite(widget.book);
        break;
      case 'newtab':
        ref
            .read(tabProvider.notifier)
            .openBook(widget.book.id, widget.book.title, true);
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _hover = true),
      onExit: (_) => setState(() => _hover = false),
      child: Column(children: [
        Expanded(
            child: Card(
          shape: const RoundedRectangleBorder(),
          clipBehavior: Clip.antiAlias,
          elevation: _hover ? 1 : 0,
          child: Stack(children: [
            Listener(
              onPointerDown: (e) {
                if (e.buttons == 4) {
                  ref
                      .read(tabProvider.notifier)
                      .openBook(widget.book.id, widget.book.title, true);
                }
              },
              child: GestureDetector(
                onSecondaryTapDown: (d) => _showMenu(d.globalPosition),
                onLongPressStart: (d) => _showMenu(d.globalPosition),
                child: InkWell(
                  onTap: () => ref
                      .read(tabProvider.notifier)
                      .openBook(widget.book.id, widget.book.title, false),
                  child: widget.book.thumbnailPath != null
                      ? Image.file(File(widget.book.thumbnailPath!),
                          fit: BoxFit.contain,
                          width: double.infinity,
                          height: double.infinity)
                      : const Center(child: Icon(Icons.book, size: 64)),
                ),
              ),
            ),
            Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                child: ReadProgressBar(book: widget.book)),
          ]),
        )),
        Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4.0, vertical: 4.0),
            child: Tooltip(
              message: widget.book.title,
              child: SizedBox(
                height: 48,
                child: Text(widget.book.title,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                        fontSize: 13, fontWeight: FontWeight.w500, height: 1.1),
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis),
              ),
            )),
      ]),
    );
  }
}
