import 'dart:typed_data';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:archive/archive.dart';
import 'package:pdfx/pdfx.dart';
import '../models/read_state.dart';
import '../../library/providers/library_provider.dart';
import '../../library/models/book.dart';
import '../../../core/providers/tab_provider.dart';
import '../../../core/services/file_service.dart';
import '../../../core/utils/sort_utils.dart';
import '../../../core/utils/book_path_utils.dart';

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
  PdfDocument? _pdfDocument;
  // decodeStream()はページ内容を都度この元ストリームから遅延展開するため、
  // decode完了後もビューア終了までクローズしてはいけない
  InputFileStream? _cbzInputStream;
  Uint8List? _currentImageBytes; // ★ 現在の画像データを保持

  bool _initStarted = false;

  ViewerNotifier(this.ref, this.bookId)
      : super(ReadState(
            title: '読み込み中...',
            filePath: '',
            format: BookFormat.pdf,
            isLoading: true));
  // ★_init()はコンストラクタでは呼ばない。ensureActive()経由でタブが実際に
  // 表示された時にだけ呼ぶ。IndexedStackは全タブのウィジェットを同時にbuild
  // するため、コンストラクタで無条件に初期化すると、復元された全てのビューア
  // タブ（表示されていない背景のタブも含む）が起動直後に一斉にファイルを開いて
  // ページ画像をデコードしてしまい、実機でネイティブヒープが1GBを超えて
  // ANR（応答なし）で強制終了される不具合が実機検証で見つかった

  /// タブが実際にアクティブになった時に呼ぶ。二回目以降の呼び出しは無視される
  void ensureActive() {
    if (_initStarted) return;
    _initStarted = true;
    _init();
  }

  Future<void> _init() async {
    try {
      final libraryState = ref.read(libraryProvider);
      final book = libraryState.books.firstWhere((b) => b.id == bookId);
      int total = 0;
      if (book.format == BookFormat.pdf) {
        final file = await FileService.materializeLocalFile(book.filePath);
        _pdfDocument = await PdfDocument.openFile(file.path);
        total = _pdfDocument!.pagesCount;
      } else {
        final file = await FileService.materializeLocalFile(book.filePath);
        _cbzInputStream = InputFileStream(file.path);
        _cachedArchive = ZipDecoder().decodeStream(_cbzInputStream!);
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
      // ensureActive()経由でタブがアクティブになった時にだけここまで到達する
      // ため、ページ画像は即ロードしてよい
      _loadCurrentImage();
    } catch (e) {
      state = state.copyWith(isLoading: false, errorMessage: '読み込み失敗');
    }
  }

  // ★ 画像データを非同期で読み込み、stateを更新する
  Future<void> _loadCurrentImage() async {
    Uint8List? bytes;
    if (state.format == BookFormat.pdf && _pdfDocument != null) {
      // Androidはページの並列レンダリングを許可しないため、render→closeを
      // 必ず順番に完了させる（前のページを閉じる前に次を開かない）
      final page = await _pdfDocument!.getPage(state.currentPage + 1);
      try {
        final image = await page.render(
          width: page.width * 2,
          height: page.height * 2,
          format: PdfPageImageFormat.png,
        );
        bytes = image?.bytes;
      } finally {
        await page.close();
      }
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
            bookFolderKey(b) == bookFolderKey(currentBook))
        .toList()
      ..sort((a, b) => SortUtils.compareBooks(a, b));
    final currentIndex = shelfBooks.indexWhere((b) => b.id == bookId);
    int nextIndex = next ? currentIndex + 1 : currentIndex - 1;
    if (nextIndex >= 0 && nextIndex < shelfBooks.length) {
      final nextBook = shelfBooks[nextIndex];
      ref.read(tabProvider.notifier).openBook(
          nextBook.id, nextBook.title, false,
          currentShelfId: nextBook.shelfId,
          currentPath: bookFolderKey(nextBook));
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

  @override
  void dispose() {
    _pdfDocument?.close();
    _cbzInputStream?.close();
    super.dispose();
  }
}
