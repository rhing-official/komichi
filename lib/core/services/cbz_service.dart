import 'dart:convert';
import 'dart:io';
import 'package:archive/archive.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

class CbzService {
  static const _supportedExtensions = ['.png', '.jpg', '.jpeg', '.webp'];

  /// CBZ内のComicInfo.xmlから<Number>タグの値を読み取る（無ければnull）
  Future<double?> readComicInfoNumber(String filePath) async {
    try {
      final bytes = await File(filePath).readAsBytes();
      final archive = ZipDecoder().decodeBytes(bytes);
      final entry = archive.files.firstWhere(
        (f) => f.isFile && p.basename(f.name).toLowerCase() == 'comicinfo.xml',
      );
      final xmlContent = utf8.decode(entry.content as List<int>);
      final match =
          RegExp(r'<Number>(.*?)</Number>', dotAll: true).firstMatch(xmlContent);
      if (match == null) return null;
      return double.tryParse(match.group(1)!.trim());
    } catch (_) {
      return null;
    }
  }

  /// CBZファイルをtempディレクトリに展開し、展開先パスを返す
  Future<String> extractCbz(String filePath) async {
    final tempDir = await getTemporaryDirectory();
    final bookName = p.basenameWithoutExtension(filePath);
    final extractDir = Directory(p.join(tempDir.path, 'cbz_cache', bookName));

    // 既に展開済みなら再利用
    if (await extractDir.exists()) {
      final images = await getImageList(extractDir.path);
      if (images.isNotEmpty) return extractDir.path;
    }

    await extractDir.create(recursive: true);

    // archive 3.x: ファイルをバイト列として読み込んでデコード
    final bytes = await File(filePath).readAsBytes();
    final archive = ZipDecoder().decodeBytes(bytes);

    for (final file in archive.files) {
      if (!file.isFile) continue;
      final ext = p.extension(file.name).toLowerCase();
      if (!_supportedExtensions.contains(ext)) continue;

      final outPath = p.join(extractDir.path, p.basename(file.name));
      final outFile = File(outPath);
      await outFile.writeAsBytes(file.content as List<int>);
    }

    return extractDir.path;
  }

  /// 展開先ディレクトリから画像ファイルをソートして返す
  Future<List<String>> getImageList(String extractedPath) async {
    final dir = Directory(extractedPath);
    if (!await dir.exists()) return [];

    final files = <String>[];
    await for (final entity in dir.list()) {
      if (entity is File) {
        final ext = p.extension(entity.path).toLowerCase();
        if (_supportedExtensions.contains(ext)) {
          files.add(entity.path);
        }
      }
    }

    files.sort((a, b) => p.basename(a).compareTo(p.basename(b)));
    return files;
  }

  /// 現在ページの前後2枚を先読み
  Future<void> preloadImages(List<String> paths, int currentIndex) async {
    final start = (currentIndex - 2).clamp(0, paths.length - 1);
    final end = (currentIndex + 2).clamp(0, paths.length - 1);
    for (int i = start; i <= end; i++) {
      await File(paths[i]).exists();
    }
  }

  /// 指定した本のキャッシュを削除
  Future<void> clearCache(String bookName) async {
    final tempDir = await getTemporaryDirectory();
    final cacheDir = Directory(p.join(tempDir.path, 'cbz_cache', bookName));
    if (await cacheDir.exists()) {
      await cacheDir.delete(recursive: true);
    }
  }

  /// 全CBZキャッシュを削除
  Future<void> clearAllCache() async {
    final tempDir = await getTemporaryDirectory();
    final cacheDir = Directory(p.join(tempDir.path, 'cbz_cache'));
    if (await cacheDir.exists()) {
      await cacheDir.delete(recursive: true);
    }
  }
}
