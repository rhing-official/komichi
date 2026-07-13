import 'dart:io';
import 'package:path/path.dart' as p;
import '../../features/library/models/book.dart';
import '../../features/library/models/shelf.dart';

// フォルダ単位のグルーピング（きょうだい本探索・お気に入りフォルダ・検索・
// フォルダ削除）に使う値を、プラットフォームに応じて統一的に取り出す。
// デスクトップではBook.filePathが実パスなのでそのままdirname等が使えるが、
// AndroidではfilePathがSAFのcontent:// URIになり意味を持たないため、
// シェルフルートからの相対パス(Book.relPath)を使う。
//
// TabItem.pathやShelf.favoriteFoldersに保存される「フォルダを指す文字列」は、
// デスクトップでは実パス、Androidではrelet相当の相対パスであり、
// どちらもプラットフォーム内で一貫して使われる前提

/// 本が属するフォルダを示すキー（同じフォルダの本同士は同じ値になる。
/// switchBook()のきょうだい本探索に使う）
String bookFolderKey(Book book) {
  if (Platform.isAndroid && book.relPath != null) {
    final dir = p.dirname(book.relPath!);
    // シェルフルート直下の本はp.dirnameが"."を返すが、他の関数群と合わせて
    // ルートは空文字列で表す
    return dir == '.' ? '' : dir;
  }
  return p.dirname(book.filePath);
}

/// 本がcurrentPath直下（フォルダを介さず）にあるかどうかを判定する
/// （ShelfScreenでの本一覧絞り込みに使う）
bool bookIsAtFolder(Book book, String currentPath) =>
    bookFolderKey(book) == currentPath;

/// currentPath直下に見えるべきサブフォルダのパスを返す（bookがcurrentPath
/// 自身にある場合はnull）。ShelfScreenのフォルダ一覧生成に使う
String? immediateChildFolder(Book book, String currentPath) {
  final dir = bookFolderKey(book);
  if (dir == currentPath) return null;
  if (Platform.isAndroid && book.relPath != null) {
    final isDescendant =
        currentPath.isEmpty ? dir.isNotEmpty : dir.startsWith('$currentPath/');
    if (!isDescendant) return null;
    final remainder =
        currentPath.isEmpty ? dir : dir.substring(currentPath.length + 1);
    final firstSegment = remainder.split('/').first;
    return currentPath.isEmpty ? firstSegment : '$currentPath/$firstSegment';
  }
  if (!dir.startsWith(currentPath + p.separator)) return null;
  final rel = p.relative(dir, from: currentPath).split(p.separator).first;
  return p.join(currentPath, rel);
}

/// 指定したフォルダ（またはその配下）に属する本かどうかを判定する
/// （removeFolder()のフォルダ配下一括削除に使う）
bool bookIsWithinFolder(Book book, String folderPath) {
  if (Platform.isAndroid && book.relPath != null) {
    return book.relPath == folderPath ||
        book.relPath!.startsWith('$folderPath/');
  }
  return book.filePath == folderPath ||
      book.filePath.startsWith(folderPath + p.separator);
}

/// 本からシェルフルートまでの、全ての祖先フォルダのパスを列挙する
/// （フォルダ名の部分一致検索に使う。bookshelf_sidebar/library_searchで使用）
List<String> ancestorFolders(Book book, String shelfRootPath) {
  final result = <String>[];
  if (Platform.isAndroid && book.relPath != null) {
    var dir = p.dirname(book.relPath!);
    while (dir != '.' && dir.isNotEmpty) {
      result.add(dir);
      dir = p.dirname(dir);
    }
    return result;
  }
  var dir = p.dirname(book.filePath);
  while (dir != shelfRootPath && p.isWithin(shelfRootPath, dir)) {
    result.add(dir);
    dir = p.dirname(dir);
  }
  return result;
}

/// フォルダパスを、シェルフルートからの相対セグメント（パンくず用）に分解する
List<String> relativeFolderSegments(String folderPath, String shelfRootPath) {
  if (Platform.isAndroid) {
    // Android上ではfolderPath自体が既にシェルフルートからの相対パス
    if (folderPath.isEmpty || folderPath == '.') return [];
    return folderPath.split('/');
  }
  final rel = p.relative(folderPath, from: shelfRootPath);
  return rel == '.' ? [] : rel.split(p.separator);
}

/// フォルダの表示名（パンくずのラベル）を取り出す
String folderDisplayName(String folderPath) {
  if (Platform.isAndroid) {
    return folderPath.split('/').last;
  }
  return p.basename(folderPath);
}

/// シェルフ自体（ルート）を指す「パス文字列」。ShelfScreenのcurrentPath初期値や、
/// 本棚を(サブフォルダではなく)ルートから開く際のnavigateTo(path: ...)に使う。
/// デスクトップではshelf.folderPath自身がそのままルートを表すが、Androidでは
/// folderPathがSAFのcontent:// URIになり、relPathベースの相対パス体系
/// （ルート = 空文字列）とは別物のため、Android専用に空文字列を返す
String shelfRootPath(Shelf shelf) {
  if (Platform.isAndroid) return '';
  return shelf.folderPath;
}
