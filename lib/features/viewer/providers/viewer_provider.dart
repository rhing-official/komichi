import 'dart:io';
import 'dart:typed_data';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:archive/archive.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import '../models/read_state.dart';
import '../../library/providers/library_provider.dart';
import '../../library/models/book.dart';
import '../../../core/providers/tab_provider.dart';
import '../../../core/utils/sort_utils.dart';

final viewerProvider =
    StateNotifierProvider.family<ViewerNotifier, ReadState, String>(
        (ref, bookId) {
  return ViewerNotifier(ref, bookId);
});

class ViewerNotifier extends StateNotifier<ReadState> {
  final Ref ref;
  final String bookId;
  Archive? _cachedArchive;
  List<ArchiveFile>? _sortedImages;
  Uint8List? _currentImageBytes; // ★ 現在の画像データを保持

  ViewerNotifier(this.ref, this.bookId)
      : super(ReadState(
            title: '読み込み中...',
            filePath: '',
            format: BookFormat.pdf,
            isLoading: true)) {
    _init();
  }

  Future<void> _init() async {
    try {
      final libraryState = ref.read(libraryProvider);
      final book = libraryState.books.firstWhere((b) => b.id == bookId);
      int total = 0;
      if (book.format == BookFormat.pdf) {
        final result = await Process.run('pdfinfo', [book.filePath]);
        final regExp = RegExp(r'Pages:\s+(\d+)');
        final match = regExp.firstMatch(result.stdout.toString());
        total = int.parse(match?.group(1) ?? '0');
      } else {
        final bytes = await File(book.filePath).readAsBytes();
        _cachedArchive = ZipDecoder().decodeBytes(bytes);
        _sortedImages = _cachedArchive!.files
            .where((f) => f.isFile && _isImage(f.name))
            .toList();
        _sortedImages!.sort((a, b) {
          final aName = a.name.toLowerCase();
          final bName = b.name.toLowerCase();
          return aName.length != bName.length
              ? aName.length.compareTo(bName.length)
              : aName.compareTo(bName);
        });
        total = _sortedImages!.length;
      }
      // 前回の続きから再開する（未読/初回はlastPage=0なので先頭から）
      final resumePage = total > 0 ? book.lastPage.clamp(0, total - 1) : 0;
      state = state.copyWith(
          title: book.title,
          filePath: book.filePath,
          format: book.format,
          totalPages: total,
          currentPage: resumePage,
          isLoading: false);
      // totalPagesはビューアでしか算出できないため、ここで初めてBookへ保存する。
      // これを保存しないと本棚のフェーダーが常に「進捗0%」表示になってしまう
      ref.read(libraryProvider.notifier).updateReadProgress(
          bookId, resumePage, book.isFinished,
          totalPages: total);
      _loadCurrentImage(); // 初回ロード
    } catch (e) {
      state = state.copyWith(isLoading: false, errorMessage: '読み込み失敗');
    }
  }

  // ★ 画像データを非同期で読み込み、stateを更新する
  Future<void> _loadCurrentImage() async {
    Uint8List? bytes;
    if (state.format == BookFormat.pdf) {
      final tempDir = await getTemporaryDirectory();
      final outPathBase =
          p.join(tempDir.path, 'komichi_p_${state.currentPage}');
      final imageFile = File('$outPathBase.png');
      if (!await imageFile.exists()) {
        await Process.run('pdftoppm', [
          '-png',
          '-f',
          '${state.currentPage + 1}',
          '-l',
          '${state.currentPage + 1}',
          '-singlefile',
          '-scale-to',
          '2000',
          state.filePath,
          outPathBase
        ]);
      }
      bytes = await imageFile.readAsBytes();
    } else if (_sortedImages != null) {
      bytes = _sortedImages![state.currentPage].content;
    }
    _currentImageBytes = bytes;
    state = state.copyWith(); // リビルド通知
  }

  Uint8List? get currentImageBytes => _currentImageBytes;

  bool _isImage(String name) {
    final n = name.toLowerCase();
    return n.endsWith('.jpg') ||
        n.endsWith('.jpeg') ||
        n.endsWith('.png') ||
        n.endsWith('.webp');
  }

  void switchBook(bool next) {
    final libraryState = ref.read(libraryProvider);
    final currentBook = libraryState.books.firstWhere((b) => b.id == bookId);
    final shelfBooks = libraryState.books
        .where((b) =>
            b.shelfId == currentBook.shelfId &&
            p.dirname(b.filePath) == p.dirname(currentBook.filePath))
        .toList()
      ..sort((a, b) => SortUtils.compareBooks(a, b));
    final currentIndex = shelfBooks.indexWhere((b) => b.id == bookId);
    int nextIndex = next ? currentIndex + 1 : currentIndex - 1;
    if (nextIndex >= 0 && nextIndex < shelfBooks.length) {
      final nextBook = shelfBooks[nextIndex];
      ref.read(tabProvider.notifier).openBook(
          nextBook.id, nextBook.title, false,
          currentShelfId: nextBook.shelfId,
          currentPath: p.dirname(nextBook.filePath));
    }
  }

  void nextPage() => jumpToPage(state.currentPage + 1);
  void previousPage() => jumpToPage(state.currentPage - 1);
  void jumpToPage(int page) {
    if (state.totalPages > 0) {
      final clamped = page.clamp(0, state.totalPages - 1);
      state = state.copyWith(currentPage: clamped);
      _loadCurrentImage();
      ref.read(libraryProvider.notifier).updateReadProgress(
          bookId, clamped, clamped >= state.totalPages - 1);
    }
  }

  void toggleUI() => state = state.copyWith(showUI: !state.showUI);
}
