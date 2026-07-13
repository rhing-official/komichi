import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path/path.dart' as p;
import '../models/book.dart';
import '../models/shelf.dart';
import '../providers/library_provider.dart';
import '../widgets/read_progress_bar.dart';
import '../../../core/providers/tab_provider.dart';
import '../../../core/providers/selection_provider.dart';
import '../../../core/utils/sort_utils.dart';
import '../../../core/utils/book_path_utils.dart';

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

    final allIds = [
      ...favFolders.map((e) => e.$2),
      ...favBooks.map((b) => b.id),
    ];

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
                return _FavoriteFolderCard(
                    shelf: shelf, path: path, index: index, allIds: allIds);
              }
              return _FavoriteBookCard(
                  book: favBooks[index - favFolders.length],
                  index: index,
                  allIds: allIds);
            },
          );

    return Focus(
      focusNode: _focusNode,
      autofocus: true,
      onKeyEvent: (node, event) {
        if (event is! KeyDownEvent) return KeyEventResult.ignored;
        if (HardwareKeyboard.instance.isControlPressed &&
            event.logicalKey == LogicalKeyboardKey.keyA) {
          ref.read(selectionProvider.notifier).selectAll(allIds);
          return KeyEventResult.handled;
        }
        return KeyEventResult.ignored;
      },
      child: Listener(
        behavior: HitTestBehavior.translucent,
        onPointerDown: (_) => _focusNode.requestFocus(),
        child: content,
      ),
    );
  }
}

// 複数選択中に、選択済みの項目を右クリック（長押し）した場合はこちらを優先する。
// お気に入りタブでは「お気に入り解除」のみ選択中の全項目（本・フォルダ混在）に
// まとめて適用する（削除はここでは扱わない。フォルダ/ファイルの削除は本棚タブの役割）
Future<bool> _showFavBatchMenuIfApplicable({
  required BuildContext context,
  required WidgetRef ref,
  required Offset globalPosition,
  required String itemId,
}) async {
  final selection = ref.read(selectionProvider);
  if (selection.selectedIds.length <= 1 ||
      !selection.selectedIds.contains(itemId)) {
    return false;
  }
  final libState = ref.read(libraryProvider);
  final ids = selection.selectedIds;
  final selectedBooks =
      libState.books.where((b) => ids.contains(b.id)).toList();
  final selectedFolders = <(Shelf, String)>[
    for (final s in libState.shelves)
      for (final path in s.favoriteFolders)
        if (ids.contains(path)) (s, path),
  ];

  final overlay = Overlay.of(context).context.findRenderObject() as RenderBox;
  final selected = await showMenu<String>(
    context: context,
    position: RelativeRect.fromRect(
        globalPosition & const Size(1, 1), Offset.zero & overlay.size),
    items: const [
      PopupMenuItem(value: 'favorite', child: Text('お気に入り解除')),
    ],
  );
  final notifier = ref.read(libraryProvider.notifier);
  switch (selected) {
    case 'favorite':
      for (final b in selectedBooks) {
        await notifier.toggleBookFavorite(b);
      }
      for (final (shelf, path) in selectedFolders) {
        await notifier.toggleFolderFavorite(shelf.id, path, false);
      }
      ref.read(selectionProvider.notifier).clear();
      break;
  }
  return true;
}

class _FavoriteFolderCard extends ConsumerStatefulWidget {
  final Shelf shelf;
  final String path;
  final int index;
  final List<String> allIds;
  const _FavoriteFolderCard(
      {required this.shelf,
      required this.path,
      required this.index,
      required this.allIds});
  @override
  ConsumerState<_FavoriteFolderCard> createState() =>
      _FavoriteFolderCardState();
}

class _FavoriteFolderCardState extends ConsumerState<_FavoriteFolderCard> {
  bool _hover = false;

  Future<void> _showMenu(Offset globalPosition, List<String> segments) async {
    if (await _showFavBatchMenuIfApplicable(
        context: context,
        ref: ref,
        globalPosition: globalPosition,
        itemId: widget.path)) {
      return;
    }
    if (!mounted) return;
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
    final isChecked =
        ref.watch(selectionProvider).selectedIds.contains(widget.path);
    final fName = folderDisplayName(widget.path);
    final relParts = relativeFolderSegments(widget.path, widget.shelf.folderPath);
    final segments = ['トップ', widget.shelf.name, ...relParts];

    final booksInFolder = state.books.where((b) =>
        b.shelfId == widget.shelf.id && bookIsWithinFolder(b, widget.path));
    final sortedBooks = booksInFolder.toList()
      ..sort((a, b) => SortUtils.compareBooks(a, b));
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
                onTap: () {
                  if (HardwareKeyboard.instance.isControlPressed) {
                    ref
                        .read(selectionProvider.notifier)
                        .toggle(widget.path, widget.index);
                  } else if (HardwareKeyboard.instance.isShiftPressed) {
                    ref
                        .read(selectionProvider.notifier)
                        .selectRange(widget.index, widget.allIds);
                  } else {
                    ref.read(tabProvider.notifier).navigateTo(
                        widget.shelf.id,
                        path: widget.path,
                        title: fName,
                        segments: segments);
                  }
                },
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
                  if (_hover || isChecked)
                    Positioned(
                        top: 4,
                        left: 4,
                        child: Checkbox(
                            value: isChecked,
                            onChanged: (_) => ref
                                .read(selectionProvider.notifier)
                                .toggle(widget.path, widget.index))),
                  const Positioned(
                      top: 4,
                      right: 4,
                      child: Icon(Icons.star, color: Colors.amber, size: 18)),
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
  final int index;
  final List<String> allIds;
  const _FavoriteBookCard(
      {required this.book, required this.index, required this.allIds});
  @override
  ConsumerState<_FavoriteBookCard> createState() => _FavoriteBookCardState();
}

class _FavoriteBookCardState extends ConsumerState<_FavoriteBookCard> {
  bool _hover = false;

  Future<void> _showMenu(Offset globalPosition) async {
    if (await _showFavBatchMenuIfApplicable(
        context: context,
        ref: ref,
        globalPosition: globalPosition,
        itemId: widget.book.id)) {
      return;
    }
    if (!mounted) return;
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
    final isChecked =
        ref.watch(selectionProvider).selectedIds.contains(widget.book.id);
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
                  onTap: () {
                    if (HardwareKeyboard.instance.isControlPressed) {
                      ref
                          .read(selectionProvider.notifier)
                          .toggle(widget.book.id, widget.index);
                    } else if (HardwareKeyboard.instance.isShiftPressed) {
                      ref
                          .read(selectionProvider.notifier)
                          .selectRange(widget.index, widget.allIds);
                    } else {
                      ref
                          .read(tabProvider.notifier)
                          .openBook(widget.book.id, widget.book.title, false);
                    }
                  },
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
            if (_hover || isChecked)
              Positioned(
                  top: 4,
                  left: 4,
                  child: Checkbox(
                      value: isChecked,
                      onChanged: (v) => ref
                          .read(selectionProvider.notifier)
                          .toggle(widget.book.id, widget.index))),
            const Positioned(
                top: 4,
                right: 4,
                child: Icon(Icons.star, color: Colors.amber, size: 18)),
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
