import 'dart:io';
import 'dart:convert';
import 'package:crypto/crypto.dart';
import 'package:file_picker/file_picker.dart';
import 'package:path/path.dart' as p;

class FileService {
  /// Flatpak 内かどうかを確認する
  bool get _isRunningInFlatpak =>
      Platform.environment.containsKey('FLATPAK_ID');

  Future<String?> pickFolder() async {
    // Flatpak 環境では、サンドボックス外の zenity を呼び出す
    if (_isRunningInFlatpak) {
      return await _pickFolderViaFlatpakSpawn();
    }
    // 通常環境では file_picker を使用
    try {
      return await FilePicker.platform.getDirectoryPath(dialogTitle: 'フォルダを選択');
    } catch (e) {
      return null;
    }
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

  Future<List<String>> scanFolder(String folderPath) async {
    final dir = Directory(folderPath);
    if (!await dir.exists()) return [];
    final files = <String>[];
    try {
      await for (final entity
          in dir.list(recursive: true, followLinks: false)) {
        if (entity is File) {
          final ext = p.extension(entity.path).toLowerCase();
          if (ext == '.pdf' || ext == '.cbz') files.add(entity.path);
        }
      }
    } catch (_) {
      // 権限エラーなどでスキャンが途中中断しても、それまでに集めたファイルは返す
    }
    return files;
  }

  Future<bool> moveToTrash(String filePath) async {
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
