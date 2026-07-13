import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/library_provider.dart';
import '../../../core/providers/tab_provider.dart';
import '../../../core/utils/library_search.dart';
import '../../../core/utils/book_path_utils.dart';

// デスクトップのサイドバー検索欄の代替。モバイルではサイドバー自体が無いため、
// ポップアップの検索アイコンから独立した全画面ページとして開く
class MobileSearchScreen extends ConsumerStatefulWidget {
  const MobileSearchScreen({super.key});

  @override
  ConsumerState<MobileSearchScreen> createState() => _MobileSearchScreenState();
}

class _MobileSearchScreenState extends ConsumerState<MobileSearchScreen> {
  final TextEditingController _controller = TextEditingController();
  String _query = '';

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(libraryProvider);
    final results = searchLibrary(state, _query);
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: TextField(
          controller: _controller,
          autofocus: true,
          decoration: const InputDecoration(
              hintText: '書籍・フォルダを検索...', border: InputBorder.none),
          onChanged: (v) => setState(() => _query = v),
        ),
      ),
      body: _query.trim().isEmpty
          ? Center(
              child: Text('キーワードを入力してください',
                  style: TextStyle(color: colorScheme.onSurfaceVariant)))
          : (results.folders.isEmpty && results.books.isEmpty)
              ? Center(
                  child: Text('該当する書籍・フォルダが見つかりません',
                      style: TextStyle(color: colorScheme.onSurfaceVariant)))
              : ListView(children: [
                  for (final (shelf, path) in results.folders)
                    Builder(builder: (context) {
                      final fName = folderDisplayName(path);
                      final relParts =
                          relativeFolderSegments(path, shelf.folderPath);
                      final segments = ['トップ', shelf.name, ...relParts];
                      return ListTile(
                        leading: Icon(Icons.folder, color: colorScheme.onSurface),
                        title: Text(fName, overflow: TextOverflow.ellipsis),
                        onTap: () {
                          ref.read(tabProvider.notifier).navigateTo(shelf.id,
                              path: path, title: fName, segments: segments);
                          Navigator.of(context).pop();
                        },
                      );
                    }),
                  for (final book in results.books)
                    ListTile(
                      leading: book.thumbnailPath != null
                          ? Image.file(File(book.thumbnailPath!),
                              width: 32, height: 44, fit: BoxFit.cover)
                          : Icon(Icons.book, color: colorScheme.onSurface),
                      title: Text(book.title, overflow: TextOverflow.ellipsis),
                      onTap: () {
                        ref
                            .read(tabProvider.notifier)
                            .openBook(book.id, book.title, false);
                        Navigator.of(context).pop();
                      },
                    ),
                ]),
    );
  }
}
