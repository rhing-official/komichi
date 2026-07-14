import 'package:flutter/widgets.dart';
import '../../l10n/app_localizations.dart';

// タブバー（水平/垂直/モバイルのタブ一覧シート）に表示するタブ名を言語設定に
// 合わせて訳す。TabItem.titleは内部的には常に日本語のセンチネル値
// （'トップ'/'設定'/'お気に入り'/'情報'）を持つため、ここでは表示直前にのみ
// 変換し、本棚名・書籍名などの実データはそのまま返す
String tabDisplayTitle(BuildContext context, String title) {
  final loc = AppLocalizations.of(context)!;
  switch (title) {
    case 'トップ':
      return loc.topPageTitle;
    case '設定':
      return loc.settings;
    case 'お気に入り':
      return loc.favorites;
    case '情報':
      return loc.information;
    default:
      return title;
  }
}
