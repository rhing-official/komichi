import 'dart:io';
import 'dart:convert';
import 'dart:typed_data';
import 'package:crypto/crypto.dart';
import 'package:file_picker/file_picker.dart';
import 'package:docman/docman.dart';
import 'package:path/path.dart' as p;

// スキャンで見つかった1件分の情報。デスクトップでは実パスをそのまま扱うが、
// AndroidはSAF(content://)のため、フォルダ単位のグルーピング（きょうだい本
// 探索・お気に入りフォルダ・検索）に使う相対パスを別途持たせる
class ScannedFile {
  final String path; // 実パス(desktop) or content:// URI(Android)。Book.filePathに保存する
  final String name; // 拡張子を除いた表示名。Book.titleに使う
  final String ext; // 拡張子（ドット無し・小文字。例: "pdf"）。AndroidではURI文字列の
  // 末尾一致に頼らず、実際のファイル名から判定するためscan時に保持しておく
  final String? relPath; // Android専用：シェルフルートからの相対パス（例: "Sub/name.cbz"）
  const ScannedFile(
      {required this.path,
      required this.name,
      required this.ext,
      this.relPath});
}

class FileService {
  /// Flatpak 内かどうかを確認する
  bool get _isRunningInFlatpak =>
      Platform.environment.containsKey('FLATPAK_ID');

  // Androidではpathがcontent:// URIになり、その末尾(basename)は本来の
  // フォルダ名と一致しないため、選択したフォルダの表示名を別途返す
  Future<({String path, String name})?> pickFolder() async {
    if (Platform.isAndroid) {
      // SAFの文書ピッカー。フォルダ選択と同時に永続的なアクセス権限が付与される
      final dir = await DocMan.pick.directory();
      if (dir == null) return null;
      return (path: dir.uri, name: dir.name);
    }
    String? path;
    // Flatpak 環境では、サンドボックス外の zenity を呼び出す
    if (_isRunningInFlatpak) {
      path = await _pickFolderViaFlatpakSpawn();
    } else {
      // 通常環境では file_picker を使用
      try {
        path = await FilePicker.platform.getDirectoryPath(dialogTitle: 'フォルダを選択');
      } catch (e) {
        path = null;
      }
    }
    if (path == null) return null;
    return (path: path, name: p.basename(path));
  }

  /// flatpak-spawn --host を使って、ホストOS上の zenity を直接呼び出す
  Future<String?> _pickFolderViaFlatpakSpawn() async {
    try {
      final result = await Process.run(
        'flatpak-spawn',
        [
          '--host',
          'zenity',
          '--file-selection',
          '--directory',
          '--title=フォルダを選択',
        ],
      );
      if (result.exitCode == 0) {
        final path = (result.stdout as String).trim();
        return path.isEmpty ? null : path;
      }
      return null;
    } catch (e) {
      // flatpak-spawn が失敗した場合は file_picker にフォールバック
      try {
        return await FilePicker.platform.getDirectoryPath(dialogTitle: 'フォルダを選択');
      } catch (_) {
        return null;
      }
    }
  }

  Future<List<ScannedFile>> scanFolder(String folderPath) async {
    if (Platform.isAndroid) {
      return _scanFolderAndroid(folderPath);
    }
    final dir = Directory(folderPath);
    if (!await dir.exists()) return [];
    final files = <ScannedFile>[];
    try {
      await for (final entity
          in dir.list(recursive: true, followLinks: false)) {
        if (entity is File) {
          final ext = p.extension(entity.path).toLowerCase();
          if (ext == '.pdf' || ext == '.cbz' || ext == '.zip') {
            files.add(ScannedFile(
                path: entity.path,
                name: p.basenameWithoutExtension(entity.path),
                ext: ext.substring(1)));
          }
        }
      }
    } catch (_) {
      // 権限エラーなどでスキャンが途中中断しても、それまでに集めたファイルは返す
    }
    return files;
  }

  // SAFのlistDocuments()は直下の子のみを返すため、サブフォルダは自前で再帰する
  Future<List<ScannedFile>> _scanFolderAndroid(String folderUri) async {
    final files = <ScannedFile>[];
    try {
      final root = await DocumentFile.fromUri(folderUri);
      if (root == null || !root.isDirectory) return [];
      await _walkAndroidDir(root, '', files);
    } catch (_) {
      // 権限エラーなどでスキャンが途中中断しても、それまでに集めたファイルは返す
    }
    return files;
  }

  Future<void> _walkAndroidDir(
      DocumentFile dir, String relPrefix, List<ScannedFile> out) async {
    final children = await dir.listDocuments();
    for (final child in children) {
      final rel = relPrefix.isEmpty ? child.name : '$relPrefix/${child.name}';
      if (child.isDirectory) {
        await _walkAndroidDir(child, rel, out);
      } else {
        final ext = p.extension(child.name).toLowerCase();
        if (ext == '.pdf' || ext == '.cbz' || ext == '.zip') {
          out.add(ScannedFile(
              path: child.uri,
              name: p.basenameWithoutExtension(child.name),
              ext: ext.substring(1),
              relPath: rel));
        }
      }
    }
  }

  /// 実パス(desktop)またはcontent:// URI(Android)からバイト列を読み込む
  ///
  /// 注意: Androidでdoc.read()はファイル全体をプラットフォームチャンネル経由で
  /// Uint8Listとして転送するため、大きなPDF/CBZ（数十MB）ではエンコード用の
  /// 直接バイトバッファ確保だけで実質2倍のメモリを要求しOutOfMemoryErrorで
  /// アプリごと落ちる（実機で62冊のPDF小説フォルダを同期中に確認済み）。
  /// ページ描画やZIP展開のように大きい可能性があるファイルには使わず、
  /// 必ずmaterializeLocalFile()経由でローカルFile化してから扱うこと
  static Future<Uint8List> readBytes(String pathOrUri) async {
    if (Platform.isAndroid && pathOrUri.startsWith('content://')) {
      final doc = await DocumentFile.fromUri(pathOrUri);
      final bytes = await doc?.read();
      if (bytes == null) {
        throw FileSystemException('SAF経由でのファイル読み込みに失敗しました', pathOrUri);
      }
      return bytes;
    }
    return File(pathOrUri).readAsBytes();
  }

  /// 実パス(desktop)またはcontent:// URI(Android)を指すローカルの実File化する。
  /// Androidではdocmanのcache()でネイティブ側のストリームコピー（アプリの
  /// キャッシュ領域へディスク間コピー）を行うため、readBytes()と違い
  /// ファイルサイズに関わらずプラットフォームチャンネル越しに巨大なバイト列を
  /// 転送することがなく安全。PDF(pdfx.openFile)やCBZ(archive.InputFileStream)の
  /// ように、ファイルパスから直接ストリーミング処理できる場面で使う
  static Future<File> materializeLocalFile(String pathOrUri) async {
    if (Platform.isAndroid && pathOrUri.startsWith('content://')) {
      final doc = await DocumentFile.fromUri(pathOrUri);
      final cached = await doc?.cache();
      if (cached == null) {
        throw FileSystemException('SAF経由でのファイルキャッシュに失敗しました', pathOrUri);
      }
      return cached;
    }
    return File(pathOrUri);
  }

  Future<bool> moveToTrash(String filePath) async {
    if (Platform.isAndroid) {
      // Androidにはゴミ箱の概念が無いため、SAF経由で直接削除する
      try {
        final doc = await DocumentFile.fromUri(filePath);
        return await doc?.delete() ?? false;
      } catch (_) {
        return false;
      }
    }
    try {
      final result = await Process.run('gio', ['trash', filePath]);
      return result.exitCode == 0;
    } catch (e) {
      try {
        final file = File(filePath);
        if (await file.exists()) await file.delete();
        return true;
      } catch (_) {
        return false;
      }
    }
  }

  String generateShelfId(String folderPath) {
    return md5.convert(utf8.encode(folderPath)).toString();
  }

  String extractBookTitle(String filePath) {
    return p.basenameWithoutExtension(filePath);
  }
}
