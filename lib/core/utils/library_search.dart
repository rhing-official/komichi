import '../../features/library/models/book.dart';
import '../../features/library/models/shelf.dart';
import '../../features/library/providers/library_provider.dart';
import 'sort_utils.dart';
import 'book_path_utils.dart';

typedef LibrarySearchResults = ({
  List<Book> books,
  List<(Shelf, String)> folders,
});

// 書籍タイトル・フォルダ名を対象にライブラリ全体を検索する。デスクトップの
// サイドバー検索・モバイルの検索画面の両方から呼ばれる共通ロジック
LibrarySearchResults searchLibrary(LibraryState state, String rawQuery) {
  final query = rawQuery.trim().toLowerCase();
  if (query.isEmpty) return (books: <Book>[], folders: <(Shelf, String)>[]);

  final books = state.books
      .where((b) => b.title.toLowerCase().contains(query))
      .toList()
    ..sort((a, b) => SortUtils.compareNatural(a.title, b.title));

  final folders = <(Shelf, String)>[];
  for (final shelf in state.shelves) {
    final paths = <String>{};
    for (final b in state.books.where((b) => b.shelfId == shelf.id)) {
      paths.addAll(ancestorFolders(b, shelf.folderPath));
    }
    for (final path in paths) {
      if (folderDisplayName(path).toLowerCase().contains(query)) {
        folders.add((shelf, path));
      }
    }
  }
  folders.sort((a, b) =>
      SortUtils.compareNatural(folderDisplayName(a.$2), folderDisplayName(b.$2)));

  return (books: books, folders: folders);
}
