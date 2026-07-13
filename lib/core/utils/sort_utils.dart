import '../../features/library/models/book.dart';

class SortUtils {
  static int compareBooks(Book a, Book b) {
    if (a.number != null && b.number != null && a.number != b.number) {
      return a.number!.compareTo(b.number!);
    }
    if (a.number != null && b.number == null) return -1;
    if (a.number == null && b.number != null) return 1;
    final byTitle = compareNatural(a.title, b.title);
    if (byTitle != 0) return byTitle;
    // タイトルが同名の本（別シリーズのフォルダにある巻数のみのファイル名
    // "01.cbz" 等）が多いシェルフでは、ここまでの比較が0を返す（＝厳密な
    // 全順序ではない）ケースが珍しくない。List.sort()は安定ソートを保証
    // しないため、これを放置すると同名グループ内の並び順が実行毎に変わり
    // 得る（表紙スタック先頭の本が起動のたびに違って見える不具合の原因）。
    // filePathで最終的にタイブレークし、常に同じ順序になるようにする
    return a.filePath.compareTo(b.filePath);
  }

  static int _getCharWeight(String char) {
    if (RegExp(r'[0-9]').hasMatch(char)) return 0;
    if (RegExp(r'[a-zA-Z]').hasMatch(char)) return 1;
    if (RegExp(r'[ぁ-ん]').hasMatch(char)) return 2;
    if (RegExp(r'[ァ-ヶー]').hasMatch(char)) return 3;
    return 4;
  }

  static int compareNatural(String a, String b) {
    if (a.isEmpty && b.isEmpty) return 0;
    if (a.isEmpty) return 1;
    if (b.isEmpty) return -1;
    int weightA = _getCharWeight(a[0]);
    int weightB = _getCharWeight(b[0]);
    if (weightA != weightB) return weightA.compareTo(weightB);
    final re = RegExp(r'(\d+)|(\D+)');
    final mA = re.allMatches(a.toLowerCase()).toList();
    final mB = re.allMatches(b.toLowerCase()).toList();
    for (int i = 0; i < mA.length && i < mB.length; i++) {
      final aPart = mA[i].group(0)!;
      final bPart = mB[i].group(0)!;
      if (RegExp(r'\d').hasMatch(aPart) && RegExp(r'\d').hasMatch(bPart)) {
        final aNum = int.parse(aPart);
        final bNum = int.parse(bPart);
        if (aNum != bNum) return aNum.compareTo(bNum);
      } else {
        if (aPart != bPart) return aPart.compareTo(bPart);
      }
    }
    return a.length.compareTo(b.length);
  }
}
