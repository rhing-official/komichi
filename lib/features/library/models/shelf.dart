import 'package:hive/hive.dart';

part 'shelf.g.dart';

@HiveType(typeId: 5)
class Shelf extends HiveObject {
  @HiveField(0)
  final String id;
  @HiveField(1)
  final String name;
  @HiveField(2)
  final String folderPath;
  @HiveField(3)
  int bookCount;
  @HiveField(4, defaultValue: false)
  bool isFavorite;
  @HiveField(5, defaultValue: <String>[])
  List<String> favoriteFolders;

  Shelf({
    required this.id,
    required this.name,
    required this.folderPath,
    this.bookCount = 0,
    this.isFavorite = false,
    List<String>? favoriteFolders,
  }) : favoriteFolders = favoriteFolders ?? [];
}
