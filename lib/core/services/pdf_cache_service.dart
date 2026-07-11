import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;

class PdfCacheService {
  String? _currentFilePath;
  final Set<int> _cachedPages = {};

  /// 先読みを実行するメソッド
  Future<void> precachePages(
      String filePath, int currentPage, int totalPages) async {
    if (_currentFilePath != filePath) {
      _currentFilePath = filePath;
      _cachedPages.clear();
      _clearOldCache();
    }

    // 今のページから前後2ページ（合計5ページ分）を優先的に準備
    final targetPages = [
      currentPage,
      currentPage + 1,
      currentPage + 2,
      currentPage - 1,
    ].where((p) => p >= 0 && p < totalPages).toList();

    for (var pageIdx in targetPages) {
      if (!_cachedPages.contains(pageIdx)) {
        _renderPageToDisk(filePath, pageIdx);
        _cachedPages.add(pageIdx);
      }
    }
  }

  Future<void> _renderPageToDisk(String filePath, int pageIdx) async {
    try {
      final tempDir = await getTemporaryDirectory();
      final outPathBase = p.join(tempDir.path, 'komichi_p_$pageIdx');
      final imageFile = File('$outPathBase.png');

      if (!await imageFile.exists()) {
        await Process.run('pdftoppm', [
          '-png', '-f', '${pageIdx + 1}', '-l', '${pageIdx + 1}', '-singlefile',
          '-scale-to', '1500', // 高画質と速度のバランス
          filePath, outPathBase,
        ]);
      }
    } catch (e) {
      // エラーは無視
    }
  }

  Future<void> _clearOldCache() async {
    try {
      final tempDir = await getTemporaryDirectory();
      final dir = Directory(tempDir.path);
      final files = await dir.list().toList();
      for (var f in files) {
        if (f.path.contains('komichi_p_')) {
          await f.delete();
        }
      }
    } catch (_) {}
  }
}
