// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'book.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class BookAdapter extends TypeAdapter<Book> {
  @override
  final int typeId = 0;

  @override
  Book read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Book()
      ..id = fields[0] as String
      ..title = fields[1] as String
      ..filePath = fields[2] as String
      ..shelfId = fields[3] as String
      ..format = fields[4] as BookFormat
      ..totalPages = fields[5] as int
      ..lastPage = fields[6] as int
      ..isFinished = fields[7] as bool
      ..addedAt = fields[8] as DateTime
      ..thumbnailPath = fields[9] as String?
      ..isFavorite = fields[10] == null ? false : fields[10] as bool
      ..number = fields[11] as double?
      ..relPath = fields[12] as String?;
  }

  @override
  void write(BinaryWriter writer, Book obj) {
    writer
      ..writeByte(13)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.title)
      ..writeByte(2)
      ..write(obj.filePath)
      ..writeByte(3)
      ..write(obj.shelfId)
      ..writeByte(4)
      ..write(obj.format)
      ..writeByte(5)
      ..write(obj.totalPages)
      ..writeByte(6)
      ..write(obj.lastPage)
      ..writeByte(7)
      ..write(obj.isFinished)
      ..writeByte(8)
      ..write(obj.addedAt)
      ..writeByte(9)
      ..write(obj.thumbnailPath)
      ..writeByte(10)
      ..write(obj.isFavorite)
      ..writeByte(11)
      ..write(obj.number)
      ..writeByte(12)
      ..write(obj.relPath);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is BookAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class BookFormatAdapter extends TypeAdapter<BookFormat> {
  @override
  final int typeId = 2;

  @override
  BookFormat read(BinaryReader reader) {
    switch (reader.readByte()) {
      case 0:
        return BookFormat.pdf;
      case 1:
        return BookFormat.cbz;
      default:
        return BookFormat.pdf;
    }
  }

  @override
  void write(BinaryWriter writer, BookFormat obj) {
    switch (obj) {
      case BookFormat.pdf:
        writer.writeByte(0);
        break;
      case BookFormat.cbz:
        writer.writeByte(1);
        break;
    }
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is BookFormatAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
