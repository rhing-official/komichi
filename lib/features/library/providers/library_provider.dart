import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive/hive.dart';
import 'package:uuid/uuid.dart';
import 'package:path/path.dart' as p;
import '../models/book.dart';
import '../models/shelf.dart';
import '../../../core/services/file_service.dart';
import '../../../core/services/thumbnail_service.dart';
import '../../../core/services/cbz_service.dart';
import '../../../core/utils/sort_utils.dart';

class LibraryState {
  final List<Book> books;
  final List<Shelf> shelves;
  final bool isLoading;
  const LibraryState(
      {this.books = const [], this.shelves = const [], this.isLoading = false});
  LibraryState copyWith(
          {List<Book>? books, List<Shelf>? shelves, bool? isLoading}) =>
      LibraryState(
          books: books ?? this.books,
          shelves: shelves ?? this.shelves,
          isLoading: isLoading ?? this.isLoading);
}

class LibraryNotifier extends StateNotifier<LibraryState> {
  final Ref ref;
  LibraryNotifier(this.ref) : super(const LibraryState()) {
    _init();
  }
  final _fileService = FileService();
  final _thumbnailService = ThumbnailService();
  final _cbzService = CbzService();
  final _uuid = const Uuid();

  void _init() async {
    await _load();
    await syncAll();
  }

  Future<void> _load() async {
    if (!Hive.isBoxOpen('books') || !Hive.isBoxOpen('shelves')) return;
    final books = Hive.box<Book>('books').values.toList();
    final shelves = Hive.box<Shelf>('shelves').values.toList();
    books.sort((a, b) => SortUtils.compareNatural(a.title, b.title));
    shelves.sort((a, b) => SortUtils.compareNatural(a.name, b.name));
    state = state.copyWith(books: books, shelves: shelves);
  }

  Future<void> syncAll() async {
    if (!Hive.isBoxOpen('books')) return;
    final bookBox = Hive.box<Book>('books');
    final shelfBox = Hive.box<Shelf>('shelves');
    for (final shelf in shelfBox.values.toList()) {
      try {
        final actualFiles = await _fileService.scanFolder(shelf.folderPath);
        final dbBooks =
            bookBox.values.where((b) => b.shelfId == shelf.id).toList();
        for (final fPath in actualFiles) {
          if (!dbBooks.any((b) => b.filePath == fPath)) {
            final bId = _uuid.v4();
            final thumb =
                await _thumbnailService.generateThumbnail(fPath, bId);
            final format =
                fPath.endsWith('.pdf') ? BookFormat.pdf : BookFormat.cbz;
            final number = format == BookFormat.cbz
                ? await _cbzService.readComicInfoNumber(fPath)
                : null;
            final book = Book()
              ..id = bId
              ..title = p.basenameWithoutExtension(fPath)
              ..filePath = fPath
              ..shelfId = shelf.id
              ..thumbnailPath = thumb
              ..addedAt = DateTime.now()
              ..format = format
              ..totalPages = 0
              ..lastPage = 0
              ..isFinished = false
              ..number = number;
            await bookBox.put(bId, book);
          }
        }
        for (final dbBook in dbBooks) {
          if (!actualFiles.contains(dbBook.filePath)) {
            await bookBox.delete(dbBook.id);
          } else if (dbBook.format == BookFormat.cbz &&
              dbBook.number == null) {
            dbBook.number =
                await _cbzService.readComicInfoNumber(dbBook.filePath);
            await dbBook.save();
          }
        }
      } catch (_) {
        // 1つの本棚の同期に失敗しても、他の本棚の同期と再読み込みは継続する
      }
    }
    await _load();
  }

  // 読書履歴（どこまで読んだか）のみを保存する。いつ読んだかの日時は記録しない
  Future<void> updateReadProgress(
      String bookId, int lastPage, bool isFinished) async {
    final book = Hive.box<Book>('books').get(bookId);
    if (book == null) return;
    if (book.lastPage == lastPage && book.isFinished == isFinished) return;
    book.lastPage = lastPage;
    book.isFinished = isFinished;
    await book.save();
    state = state.copyWith(books: List.of(state.books));
  }

  Future<void> toggleBookFavorite(Book book) async {
    book.isFavorite = !book.isFavorite;
    await book.save();
    _load();
  }

  Future<void> toggleShelfFavorite(Shelf shelf) async {
    shelf.isFavorite = !shelf.isFavorite;
    await shelf.save();
    _load();
  }

  Future<void> removeBook(String id) async {
    final book = Hive.box<Book>('books').get(id);
    if (book != null) {
      await _fileService.moveToTrash(book.filePath);
      await Hive.box<Book>('books').delete(id);
    }
    _load();
  }

  Future<void> removeShelf(String id) async {
    await Hive.box<Shelf>('shelves').delete(id);
    _load();
  }

  Future<void> toggleFolderFavorite(
      String shelfId, String folderPath, bool favorite) async {
    final bookBox = Hive.box<Book>('books');
    final books = bookBox.values
        .where((b) =>
            b.shelfId == shelfId &&
            (b.filePath == folderPath ||
                b.filePath.startsWith(folderPath + p.separator)))
        .toList();
    for (var b in books) {
      b.isFavorite = favorite;
      await b.save();
    }
    final shelf = Hive.box<Shelf>('shelves').get(shelfId);
    if (shelf != null) {
      final favs = List<String>.from(shelf.favoriteFolders);
      if (favorite) {
        if (!favs.contains(folderPath)) favs.add(folderPath);
      } else {
        favs.remove(folderPath);
      }
      shelf.favoriteFolders = favs;
      await shelf.save();
    }
    _load();
  }

  Future<void> removeFolder(String shelfId, String folderPath) async {
    final bookBox = Hive.box<Book>('books');
    final books = bookBox.values
        .where((b) =>
            b.shelfId == shelfId &&
            (b.filePath == folderPath ||
                b.filePath.startsWith(folderPath + p.separator)))
        .toList();
    for (var b in books) {
      await removeBook(b.id);
    }
    _load();
  }

  Future<void> addShelf(BuildContext context) async {
    if (state.isLoading) return;
    state = state.copyWith(isLoading: true);
    try {
      final path = await _fileService.pickFolder();
      if (path == null) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('フォルダ選択がキャンセルされました')),
          );
        }
        return;
      }
      final shelfId = _fileService.generateShelfId(path);
      final shelf =
          Shelf(id: shelfId, name: p.basename(path), folderPath: path);
      await Hive.box<Shelf>('shelves').put(shelfId, shelf);
      await syncAll();
      
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('フォルダを追加しました: ${shelf.name}')),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('エラーが発生しました: $e')),
        );
      }
    } finally {
      state = state.copyWith(isLoading: false);
    }
  }
}

final libraryProvider = StateNotifierProvider<LibraryNotifier, LibraryState>(
    (ref) => LibraryNotifier(ref));
