// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Japanese (`ja`).
class AppLocalizationsJa extends AppLocalizations {
  AppLocalizationsJa([String locale = 'ja']) : super(locale);

  @override
  String get settings => '設定';

  @override
  String get cancel => 'キャンセル';

  @override
  String get delete => '削除';

  @override
  String get addFolder => 'フォルダを追加';

  @override
  String get openInNewTab => '別タブで開く';

  @override
  String get addToFavorites => 'お気に入りに追加';

  @override
  String get removeFromFavorites => 'お気に入り解除';

  @override
  String get favorites => 'お気に入り';

  @override
  String get noFavoritesYet => 'お気に入りはまだありません';

  @override
  String fileCount(int count) {
    return '$count 個のファイル';
  }

  @override
  String get noShelvesYet => 'まだ本棚が追加されていません';

  @override
  String get topPageTitle => 'トップ';

  @override
  String get newTab => '新しいタブ';

  @override
  String get information => '情報';

  @override
  String get appTagline => '本と、二人きり';

  @override
  String versionInfo(String version) {
    return 'バージョン $version';
  }

  @override
  String get licensesSection => 'オープンソースライセンス';

  @override
  String get licensesButton => 'ライセンス一覧を表示';

  @override
  String get shortcutsSection => 'キーボードショートカット';

  @override
  String get shortcutCategoryNavigation => 'ナビゲーション';

  @override
  String get shortcutCategoryTabs => 'タブ操作';

  @override
  String get shortcutCategoryScreenFile => '画面・ファイル操作';

  @override
  String get shortcutCategoryViewer => 'ビューア内';

  @override
  String get shortcutAltArrow => '履歴を戻る / 進む';

  @override
  String get shortcutEsc => 'ビューアを閉じて元のフォルダに戻る';

  @override
  String get shortcutCtrlTab => '右 / 下のタブへ切り替え';

  @override
  String get shortcutCtrlShiftTab => '左 / 上のタブへ切り替え';

  @override
  String get shortcutCtrlT => '新しい本棚タブを開く';

  @override
  String get shortcutCtrlW => '現在のタブを閉じる';

  @override
  String get shortcutMiddleClick => 'タブを閉じる / 本・フォルダを新しいタブで開く';

  @override
  String get shortcutCtrlI => '設定を開く';

  @override
  String get shortcutCtrlF => 'お気に入りを開く';

  @override
  String get shortcutF1 => '情報を開く';

  @override
  String get shortcutCtrlS => 'サイドバーの検索欄にフォーカス';

  @override
  String get shortcutCtrlA => '表示中のフォルダ / ファイルを全選択';

  @override
  String get shortcutCtrlClick => '個別選択の追加 / 解除';

  @override
  String get shortcutShiftClick => '範囲選択（起点からクリック位置まで全て選択）';

  @override
  String get shortcutF5 => 'フォルダを再スキャンして書籍一覧を更新';

  @override
  String get shortcutArrowLeftRight => '前 / 次ページ';

  @override
  String get shortcutCtrlArrowLeftRight => '最初 / 最後のページへ';

  @override
  String get shortcutArrowUpDown => '同じフォルダ内の前の本 / 次の本を開く';

  @override
  String get shortcutSpace => 'メニューバーの表示 / 非表示切り替え';

  @override
  String get sidebarSearchHint => '書籍・フォルダを検索...';

  @override
  String get noSearchResults => '該当する書籍・フォルダが見つかりません';

  @override
  String get deleteFolderTitle => 'フォルダを削除';

  @override
  String get deleteFolderConfirm => 'このフォルダ内のすべての書籍を削除しますか？';

  @override
  String get jumpToFirstPage => '最初のページへ';

  @override
  String get jumpToLastPage => '最後のページへ';

  @override
  String get nextBook => '次の本へ';

  @override
  String get previousBook => '前の本へ';

  @override
  String get orientationPortrait => '縦';

  @override
  String get orientationLandscapeLeft => '左に90度';

  @override
  String get orientationLandscapeRight => '右に90度';

  @override
  String get orientationPortraitDown => '180度';

  @override
  String get navBack => '戻る';

  @override
  String get navForward => '進む';

  @override
  String get navSearch => '検索';

  @override
  String get navAddTab => 'タブ追加';

  @override
  String get navTabList => 'タブ一覧';

  @override
  String get navMore => 'その他';

  @override
  String get pageDirectionSection => 'ページの送り方';

  @override
  String get pageDirectionLeftTitle => '左送り';

  @override
  String get pageDirectionLeftSubtitle => '左クリック / 左キーで次ページへ移動します';

  @override
  String get pageDirectionRightTitle => '右送り';

  @override
  String get pageDirectionRightSubtitle => '右クリック / 右キーで次ページへ移動します';

  @override
  String get sidebarPositionSection => 'サイドバーの位置';

  @override
  String get sidebarPositionLeft => '左';

  @override
  String get sidebarPositionRight => '右';

  @override
  String get tabBarPositionSection => 'タブバーの配置';

  @override
  String get tabBarPositionTop => '上部（水平タブ）';

  @override
  String get tabBarPositionLeft => '左端（垂直タブ）';

  @override
  String get tabBarPositionRight => '右端（垂直タブ）';

  @override
  String get tabBarPositionOuterEdgeHint =>
      '垂直タブ使用時、サイドバーと同じ辺にある場合にどちらを外側（画面端側）に配置するか';

  @override
  String get outerEdgeVerticalTabs => '垂直タブを外側に';

  @override
  String get outerEdgeSidebar => 'サイドバーを外側に';

  @override
  String get outerEdgeSidebarSubtitle => 'サイドバーを最大化すると、垂直タブはそれに合わせて内側へ移動します';

  @override
  String get fullscreenBehaviorSection => '全画面表示のタイミング';

  @override
  String get fullscreenOnViewerOnly => '書籍を開いている間のみ';

  @override
  String get fullscreenOnViewerOnlySubtitle => '本棚などを見ている間はウィンドウ表示にします';

  @override
  String get fullscreenAlwaysOnLaunch => '起動時から常に全画面';

  @override
  String get launchTabSection => '起動時のタブ';

  @override
  String get launchTabResumeLastBook => '前回読んでいたタブを再度開く';

  @override
  String get launchTabAlwaysLibrary => '常にトップページから始める';

  @override
  String get launchTabAlwaysLibrarySubtitle => '読書の進捗はこの設定に関わらず保持されます';

  @override
  String get settingsFavoritesOpenModeSection => '設定・お気に入りアイコンの動作';

  @override
  String get openModeNewTabSubtitle => '既に開いていればそのタブに切り替えます';

  @override
  String get openModeToggleInPlace => '現在のタブ内で切り替える';

  @override
  String get openModeToggleInPlaceSubtitle =>
      'もう一度アイコンをタップすると、切り替え前に表示していたページに戻ります';

  @override
  String get middleClickSection => 'ミドルクリックで新しいタブを開いた時';

  @override
  String get middleClickSwitchToNewTab => '新しいタブに自動的に切り替える';

  @override
  String get middleClickStayOnCurrentTab => '元のタブに留まる';

  @override
  String get middleClickStayOnCurrentTabSubtitle => '新しいタブはバックグラウンドで開かれます';

  @override
  String get mobileNavIconsSection => 'ナビゲーションポップアップの表示アイコン';

  @override
  String get mobileNavIconsHint =>
      'チェックを外したアイコンはポップアップ右端のメニューに収納されます。ドラッグで並び順を変更できます';

  @override
  String get themeSection => 'テーマ設定';

  @override
  String get themeSystem => 'システム設定に従う';

  @override
  String get themeLight => 'ライトモード';

  @override
  String get themeDark => 'ダークモード';

  @override
  String get languageSection => '言語';

  @override
  String get languageJapanese => '日本語';

  @override
  String get languageEnglish => 'English';
}
