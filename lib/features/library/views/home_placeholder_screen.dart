import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/shelf.dart';
import '../providers/library_provider.dart';
import '../../../core/providers/tab_provider.dart';
import '../../../core/providers/selection_provider.dart';
import '../../../core/utils/sort_utils.dart';
import '../../../core/utils/book_path_utils.dart';
import '../../../l10n/app_localizations.dart';

class HomePlaceholderScreen extends ConsumerStatefulWidget {
  final bool isActive;
  const HomePlaceholderScreen({super.key, this.isActive = true});
  @override
  ConsumerState<HomePlaceholderScreen> createState() =>
      _HomePlaceholderScreenState();
}

class _HomePlaceholderScreenState extends ConsumerState<HomePlaceholderScreen> {
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
  void didUpdateWidget(covariant HomePlaceholderScreen oldWidget) {
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
    final shelves = [...state.shelves]
      ..sort((a, b) => SortUtils.compareNatural(a.name, b.name));
    final allIds = shelves.map((s) => s.id).toList();

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
        child: shelves.isEmpty
            ? Center(
                child: Column(mainAxisSize: MainAxisSize.min, children: [
                  Icon(Icons.menu_book,
                      size: 64,
                      color: Theme.of(context)
                          .colorScheme
                          .primary
                          .withOpacity(0.4)),
                  const SizedBox(height: 16),
                  Text(AppLocalizations.of(context)!.noShelvesYet,
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
                itemCount: shelves.length,
                itemBuilder: (context, index) => _ShelfCard(
                    shelf: shelves[index], index: index, allIds: allIds),
              ),
      ),
    );
  }
}

class _ShelfCard extends ConsumerStatefulWidget {
  final Shelf shelf;
  final int index;
  final List<String> allIds;
  const _ShelfCard(
      {required this.shelf, required this.index, required this.allIds});
  @override
  ConsumerState<_ShelfCard> createState() => _ShelfCardState();
}

class _ShelfCardState extends ConsumerState<_ShelfCard> {
  bool _hover = false;

  Future<void> _showShelfMenu(Offset globalPosition) async {
    final loc = AppLocalizations.of(context)!;
    final overlay = Overlay.of(context).context.findRenderObject() as RenderBox;
    final selected = await showMenu<String>(
      context: context,
      position: RelativeRect.fromRect(
          globalPosition & const Size(1, 1), Offset.zero & overlay.size),
      items: [
        PopupMenuItem(
            value: 'favorite',
            child: Text(widget.shelf.isFavorite
                ? loc.removeFromFavorites
                : loc.addToFavorites)),
        PopupMenuItem(value: 'newtab', child: Text(loc.openInNewTab)),
        PopupMenuItem(value: 'delete', child: Text(loc.delete)),
      ],
    );
    if (!mounted) return;
    switch (selected) {
      case 'favorite':
        ref.read(libraryProvider.notifier).toggleShelfFavorite(widget.shelf);
        break;
      case 'delete':
        ref.read(libraryProvider.notifier).removeShelf(widget.shelf.id);
        break;
      case 'newtab':
        ref.read(tabProvider.notifier).navigateTo(widget.shelf.id,
            path: shelfRootPath(widget.shelf),
            title: widget.shelf.name,
            segments: ['トップ', widget.shelf.name],
            openInNewTab: true);
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final state = ref.watch(libraryProvider);
    final isChecked =
        ref.watch(selectionProvider).selectedIds.contains(widget.shelf.id);
    final booksInShelf = state.books
        .where((b) => b.shelfId == widget.shelf.id)
        .toList()
      ..sort((a, b) => SortUtils.compareBooks(a, b));
    final thumbBooks = booksInShelf.take(5).toList().reversed.toList();

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
                    path: shelfRootPath(widget.shelf),
                    title: widget.shelf.name,
                    segments: ['トップ', widget.shelf.name],
                    openInNewTab: true);
              }
            },
            child: GestureDetector(
              onSecondaryTapDown: (details) =>
                  _showShelfMenu(details.globalPosition),
              onLongPressStart: (details) =>
                  _showShelfMenu(details.globalPosition),
              child: InkWell(
                onTap: () {
                  if (HardwareKeyboard.instance.isControlPressed) {
                    ref
                        .read(selectionProvider.notifier)
                        .toggle(widget.shelf.id, widget.index);
                  } else if (HardwareKeyboard.instance.isShiftPressed) {
                    ref
                        .read(selectionProvider.notifier)
                        .selectRange(widget.index, widget.allIds);
                  } else {
                    ref.read(tabProvider.notifier).navigateTo(widget.shelf.id,
                        path: shelfRootPath(widget.shelf),
                        title: widget.shelf.name,
                        segments: ['トップ', widget.shelf.name]);
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
                  if (booksInShelf.isNotEmpty)
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
                          AppLocalizations.of(context)!
                              .fileCount(booksInShelf.length),
                          style: const TextStyle(
                              color: Colors.white,
                              fontSize: 10,
                              fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                  if (widget.shelf.isFavorite)
                    const Positioned(
                        top: 4,
                        right: 4,
                        child: Icon(Icons.star, color: Colors.white, size: 18)),
                  if (_hover || isChecked)
                    Positioned(
                        top: 4,
                        left: 4,
                        child: Checkbox(
                            value: isChecked,
                            onChanged: (_) => ref
                                .read(selectionProvider.notifier)
                                .toggle(widget.shelf.id, widget.index))),
                ]),
              ),
            ),
          ),
        )),
        Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4.0, vertical: 4.0),
            child: Tooltip(
              message: widget.shelf.name,
              child: SizedBox(
                height: 48,
                child: Text(widget.shelf.name,
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
