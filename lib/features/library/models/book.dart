import 'package:hive/hive.dart';

part 'book.g.dart';

@HiveType(typeId: 2)
enum BookFormat {
  @HiveField(0)
  pdf,
  @HiveField(1)
  cbz,
}

@HiveType(typeId: 0)
class Book extends HiveObject {
  @HiveField(0)
  late String id;

  @HiveField(1)
  late String title;

  @HiveField(2)
  late String filePath;

  @HiveField(3)
  late String shelfId;

  @HiveField(4)
  late BookFormat format;

  @HiveField(5)
  late int totalPages;

  @HiveField(6)
  late int lastPage;

  @HiveField(7)
  late bool isFinished;

  @HiveField(8)
  late DateTime addedAt;

  @HiveField(9)
  String? thumbnailPath;

  @HiveField(10, defaultValue: false)
  bool isFavorite = false; // ★お気に入り追加

  @HiveField(11)
  double? number; // ComicInfo.xml の <Number>（巻数順ソート用）
}
