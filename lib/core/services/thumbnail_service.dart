import 'dart:io';
import 'dart:typed_data';
import 'package:archive/archive.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

class ThumbnailService {
  Future<String?> generateThumbnail(String filePath, String bookId) async {
    try {
      final ext = p.extension(filePath).toLowerCase();
      final cacheDir = await getApplicationSupportDirectory();
      final thumbDir =
          Directory(p.join(cacheDir.path, 'komichi', 'thumbnails'));

      if (!await thumbDir.exists()) {
        await thumbDir.create(recursive: true);
      }

      final thumbPath = p.join(thumbDir.path, '$bookId.png');
      final thumbFile = File(thumbPath);

      if (await thumbFile.exists()) return thumbPath;

      if (ext == '.pdf') {
        print('[Thumbnail] LinuxシステムコマンドでPDFを処理中: $filePath');

        // pdftoppm を使って1ページ目をPNGとして出力
        // -f 1 (1ページ目から), -l 1 (1ページ目まで), -singlefile (1つだけ出力)
        final result = await Process.run('pdftoppm', [
          '-png',
          '-f', '1',
          '-l', '1',
          '-singlefile',
          filePath,
          p.join(thumbDir.path, bookId), // 拡張子はpdftoppmが自動で付ける
        ]);

        if (result.exitCode == 0) {
          print('[Thumbnail] PDF表紙生成成功');
          return thumbPath;
        } else {
          print('[Thumbnail] pdftoppmエラー: ${result.stderr}');
        }
      } else if (ext == '.cbz') {
        // CBZの処理は現状のままでOK
        final bytes = await File(filePath).readAsBytes();
        final archive = ZipDecoder().decodeBytes(bytes);
        final imageFiles = archive.files.where((f) {
          final name = f.name.toLowerCase();
          return f.isFile &&
              (name.endsWith('.jpg') ||
                  name.endsWith('.png') ||
                  name.endsWith('.jpeg'));
        }).toList()
          ..sort((a, b) => a.name.compareTo(b.name));

        if (imageFiles.isNotEmpty) {
          await thumbFile.writeAsBytes(imageFiles.first.content as Uint8List);
          return thumbPath;
        }
      }
    } catch (e) {
      print('[Thumbnail] 致命的エラー: $e');
    }
    return null;
  }
}
