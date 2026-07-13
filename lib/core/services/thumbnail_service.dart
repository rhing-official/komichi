import 'dart:io';
import 'package:archive/archive.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:pdfx/pdfx.dart';
import 'file_service.dart';

class ThumbnailService {
  // ext: 拡張子（ドット無し・小文字。例: "pdf"）。呼び出し側(scanFolder結果)で
  // 既に判明している値を渡す。AndroidではfilePathがcontent:// URIになり、
  // 文字列末尾一致でのフォーマット判定に頼るのは本来避けたいため
  Future<String?> generateThumbnail(
      String filePath, String bookId, String ext) async {
    try {
      final cacheDir = await getApplicationSupportDirectory();
      final thumbDir =
          Directory(p.join(cacheDir.path, 'komichi', 'thumbnails'));

      if (!await thumbDir.exists()) {
        await thumbDir.create(recursive: true);
      }

      final thumbPath = p.join(thumbDir.path, '$bookId.png');
      final thumbFile = File(thumbPath);

      if (await thumbFile.exists()) return thumbPath;

      if (ext == 'pdf') {
        return await _generatePdfThumbnail(filePath, thumbFile, thumbPath);
      } else if (ext == 'cbz') {
        final file = await FileService.materializeLocalFile(filePath);
        final stream = InputFileStream(file.path);
        try {
          final archive = ZipDecoder().decodeStream(stream);
          final imageFiles = archive.files.where((f) {
            final name = f.name.toLowerCase();
            return f.isFile &&
                (name.endsWith('.jpg') ||
                    name.endsWith('.png') ||
                    name.endsWith('.jpeg'));
          }).toList()
            ..sort((a, b) => a.name.compareTo(b.name));

          if (imageFiles.isNotEmpty) {
            await thumbFile.writeAsBytes(imageFiles.first.content);
            return thumbPath;
          }
        } finally {
          await stream.close();
        }
      }
    } catch (e) {
      print('[Thumbnail] 致命的エラー: $e');
    }
    return null;
  }

  Future<String?> _generatePdfThumbnail(
      String filePath, File thumbFile, String thumbPath) async {
    // pdfxでPDFの1ページ目をレンダリングする（poppler-utilsに依存せず
    // Android/Windows含む全プラットフォームで動作する）
    PdfDocument? document;
    PdfPage? page;
    try {
      final file = await FileService.materializeLocalFile(filePath);
      document = await PdfDocument.openFile(file.path);
      page = await document.getPage(1);
      final image = await page.render(
        width: page.width * 2,
        height: page.height * 2,
        format: PdfPageImageFormat.png,
      );
      if (image == null) return null;
      await thumbFile.writeAsBytes(image.bytes);
      return thumbPath;
    } catch (e) {
      print('[Thumbnail] PDF表紙生成エラー: $e');
      return null;
    } finally {
      await page?.close();
      await document?.close();
    }
  }
}
