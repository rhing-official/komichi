import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_ja.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
      : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
    delegate,
    GlobalMaterialLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
  ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('ja')
  ];

  /// 設定画面のタイトル・ナビゲーションポップアップの設定アイコンラベル
  ///
  /// In ja, this message translates to:
  /// **'設定'**
  String get settings;

  /// No description provided for @cancel.
  ///
  /// In ja, this message translates to:
  /// **'キャンセル'**
  String get cancel;

  /// No description provided for @delete.
  ///
  /// In ja, this message translates to:
  /// **'削除'**
  String get delete;

  /// No description provided for @addFolder.
  ///
  /// In ja, this message translates to:
  /// **'フォルダを追加'**
  String get addFolder;

  /// No description provided for @openInNewTab.
  ///
  /// In ja, this message translates to:
  /// **'別タブで開く'**
  String get openInNewTab;

  /// No description provided for @addToFavorites.
  ///
  /// In ja, this message translates to:
  /// **'お気に入りに追加'**
  String get addToFavorites;

  /// No description provided for @removeFromFavorites.
  ///
  /// In ja, this message translates to:
  /// **'お気に入り解除'**
  String get removeFromFavorites;

  /// No description provided for @favorites.
  ///
  /// In ja, this message translates to:
  /// **'お気に入り'**
  String get favorites;

  /// No description provided for @noFavoritesYet.
  ///
  /// In ja, this message translates to:
  /// **'お気に入りはまだありません'**
  String get noFavoritesYet;

  /// フォルダ/本棚カード右下に表示するファイル数
  ///
  /// In ja, this message translates to:
  /// **'{count} 個のファイル'**
  String fileCount(int count);

  /// No description provided for @noShelvesYet.
  ///
  /// In ja, this message translates to:
  /// **'まだ本棚が追加されていません'**
  String get noShelvesYet;

  /// No description provided for @topPageTitle.
  ///
  /// In ja, this message translates to:
  /// **'トップ'**
  String get topPageTitle;

  /// No description provided for @newTab.
  ///
  /// In ja, this message translates to:
  /// **'新しいタブ'**
  String get newTab;

  /// No description provided for @information.
  ///
  /// In ja, this message translates to:
  /// **'情報'**
  String get information;

  /// No description provided for @appTagline.
  ///
  /// In ja, this message translates to:
  /// **'本と、二人きり'**
  String get appTagline;

  /// 情報タブに表示するアプリのバージョン番号
  ///
  /// In ja, this message translates to:
  /// **'バージョン {version}'**
  String versionInfo(String version);

  /// No description provided for @licensesSection.
  ///
  /// In ja, this message translates to:
  /// **'オープンソースライセンス'**
  String get licensesSection;

  /// No description provided for @licensesButton.
  ///
  /// In ja, this message translates to:
  /// **'ライセンス一覧を表示'**
  String get licensesButton;

  /// No description provided for @shortcutsSection.
  ///
  /// In ja, this message translates to:
  /// **'キーボードショートカット'**
  String get shortcutsSection;

  /// No description provided for @shortcutCategoryNavigation.
  ///
  /// In ja, this message translates to:
  /// **'ナビゲーション'**
  String get shortcutCategoryNavigation;

  /// No description provided for @shortcutCategoryTabs.
  ///
  /// In ja, this message translates to:
  /// **'タブ操作'**
  String get shortcutCategoryTabs;

  /// No description provided for @shortcutCategoryScreenFile.
  ///
  /// In ja, this message translates to:
  /// **'画面・ファイル操作'**
  String get shortcutCategoryScreenFile;

  /// No description provided for @shortcutCategoryViewer.
  ///
  /// In ja, this message translates to:
  /// **'ビューア内'**
  String get shortcutCategoryViewer;

  /// No description provided for @shortcutAltArrow.
  ///
  /// In ja, this message translates to:
  /// **'履歴を戻る / 進む'**
  String get shortcutAltArrow;

  /// No description provided for @shortcutEsc.
  ///
  /// In ja, this message translates to:
  /// **'ビューアを閉じて元のフォルダに戻る'**
  String get shortcutEsc;

  /// No description provided for @shortcutCtrlTab.
  ///
  /// In ja, this message translates to:
  /// **'右 / 下のタブへ切り替え'**
  String get shortcutCtrlTab;

  /// No description provided for @shortcutCtrlShiftTab.
  ///
  /// In ja, this message translates to:
  /// **'左 / 上のタブへ切り替え'**
  String get shortcutCtrlShiftTab;

  /// No description provided for @shortcutCtrlT.
  ///
  /// In ja, this message translates to:
  /// **'新しい本棚タブを開く'**
  String get shortcutCtrlT;

  /// No description provided for @shortcutCtrlW.
  ///
  /// In ja, this message translates to:
  /// **'現在のタブを閉じる'**
  String get shortcutCtrlW;

  /// No description provided for @shortcutMiddleClick.
  ///
  /// In ja, this message translates to:
  /// **'タブを閉じる / 本・フォルダを新しいタブで開く'**
  String get shortcutMiddleClick;

  /// No description provided for @shortcutCtrlI.
  ///
  /// In ja, this message translates to:
  /// **'設定を開く'**
  String get shortcutCtrlI;

  /// No description provided for @shortcutCtrlF.
  ///
  /// In ja, this message translates to:
  /// **'お気に入りを開く'**
  String get shortcutCtrlF;

  /// No description provided for @shortcutF1.
  ///
  /// In ja, this message translates to:
  /// **'情報を開く'**
  String get shortcutF1;

  /// No description provided for @shortcutCtrlS.
  ///
  /// In ja, this message translates to:
  /// **'サイドバーの検索欄にフォーカス'**
  String get shortcutCtrlS;

  /// No description provided for @shortcutCtrlA.
  ///
  /// In ja, this message translates to:
  /// **'表示中のフォルダ / ファイルを全選択'**
  String get shortcutCtrlA;

  /// No description provided for @shortcutCtrlClick.
  ///
  /// In ja, this message translates to:
  /// **'個別選択の追加 / 解除'**
  String get shortcutCtrlClick;

  /// No description provided for @shortcutShiftClick.
  ///
  /// In ja, this message translates to:
  /// **'範囲選択（起点からクリック位置まで全て選択）'**
  String get shortcutShiftClick;

  /// No description provided for @shortcutF5.
  ///
  /// In ja, this message translates to:
  /// **'フォルダを再スキャンして書籍一覧を更新'**
  String get shortcutF5;

  /// No description provided for @shortcutArrowLeftRight.
  ///
  /// In ja, this message translates to:
  /// **'前 / 次ページ'**
  String get shortcutArrowLeftRight;

  /// No description provided for @shortcutCtrlArrowLeftRight.
  ///
  /// In ja, this message translates to:
  /// **'最初 / 最後のページへ'**
  String get shortcutCtrlArrowLeftRight;

  /// No description provided for @shortcutArrowUpDown.
  ///
  /// In ja, this message translates to:
  /// **'同じフォルダ内の前の本 / 次の本を開く'**
  String get shortcutArrowUpDown;

  /// No description provided for @shortcutSpace.
  ///
  /// In ja, this message translates to:
  /// **'メニューバーの表示 / 非表示切り替え'**
  String get shortcutSpace;

  /// No description provided for @sidebarSearchHint.
  ///
  /// In ja, this message translates to:
  /// **'書籍・フォルダを検索...'**
  String get sidebarSearchHint;

  /// No description provided for @noSearchResults.
  ///
  /// In ja, this message translates to:
  /// **'該当する書籍・フォルダが見つかりません'**
  String get noSearchResults;

  /// No description provided for @deleteFolderTitle.
  ///
  /// In ja, this message translates to:
  /// **'フォルダを削除'**
  String get deleteFolderTitle;

  /// No description provided for @deleteFolderConfirm.
  ///
  /// In ja, this message translates to:
  /// **'このフォルダ内のすべての書籍を削除しますか？'**
  String get deleteFolderConfirm;

  /// No description provided for @jumpToFirstPage.
  ///
  /// In ja, this message translates to:
  /// **'最初のページへ'**
  String get jumpToFirstPage;

  /// No description provided for @jumpToLastPage.
  ///
  /// In ja, this message translates to:
  /// **'最後のページへ'**
  String get jumpToLastPage;

  /// No description provided for @nextBook.
  ///
  /// In ja, this message translates to:
  /// **'次の本へ'**
  String get nextBook;

  /// No description provided for @previousBook.
  ///
  /// In ja, this message translates to:
  /// **'前の本へ'**
  String get previousBook;

  /// No description provided for @orientationPortrait.
  ///
  /// In ja, this message translates to:
  /// **'縦'**
  String get orientationPortrait;

  /// No description provided for @orientationLandscapeLeft.
  ///
  /// In ja, this message translates to:
  /// **'左に90度'**
  String get orientationLandscapeLeft;

  /// No description provided for @orientationLandscapeRight.
  ///
  /// In ja, this message translates to:
  /// **'右に90度'**
  String get orientationLandscapeRight;

  /// No description provided for @orientationPortraitDown.
  ///
  /// In ja, this message translates to:
  /// **'180度'**
  String get orientationPortraitDown;

  /// No description provided for @navBack.
  ///
  /// In ja, this message translates to:
  /// **'戻る'**
  String get navBack;

  /// No description provided for @navForward.
  ///
  /// In ja, this message translates to:
  /// **'進む'**
  String get navForward;

  /// No description provided for @navSearch.
  ///
  /// In ja, this message translates to:
  /// **'検索'**
  String get navSearch;

  /// No description provided for @navAddTab.
  ///
  /// In ja, this message translates to:
  /// **'タブ追加'**
  String get navAddTab;

  /// No description provided for @navTabList.
  ///
  /// In ja, this message translates to:
  /// **'タブ一覧'**
  String get navTabList;

  /// No description provided for @navMore.
  ///
  /// In ja, this message translates to:
  /// **'その他'**
  String get navMore;

  /// No description provided for @pageDirectionSection.
  ///
  /// In ja, this message translates to:
  /// **'ページの送り方'**
  String get pageDirectionSection;

  /// No description provided for @pageDirectionLeftTitle.
  ///
  /// In ja, this message translates to:
  /// **'左送り'**
  String get pageDirectionLeftTitle;

  /// No description provided for @pageDirectionLeftSubtitle.
  ///
  /// In ja, this message translates to:
  /// **'左クリック / 左キーで次ページへ移動します'**
  String get pageDirectionLeftSubtitle;

  /// No description provided for @pageDirectionRightTitle.
  ///
  /// In ja, this message translates to:
  /// **'右送り'**
  String get pageDirectionRightTitle;

  /// No description provided for @pageDirectionRightSubtitle.
  ///
  /// In ja, this message translates to:
  /// **'右クリック / 右キーで次ページへ移動します'**
  String get pageDirectionRightSubtitle;

  /// No description provided for @sidebarPositionSection.
  ///
  /// In ja, this message translates to:
  /// **'サイドバーの位置'**
  String get sidebarPositionSection;

  /// No description provided for @sidebarPositionLeft.
  ///
  /// In ja, this message translates to:
  /// **'左'**
  String get sidebarPositionLeft;

  /// No description provided for @sidebarPositionRight.
  ///
  /// In ja, this message translates to:
  /// **'右'**
  String get sidebarPositionRight;

  /// No description provided for @tabBarPositionSection.
  ///
  /// In ja, this message translates to:
  /// **'タブバーの配置'**
  String get tabBarPositionSection;

  /// No description provided for @tabBarPositionTop.
  ///
  /// In ja, this message translates to:
  /// **'上部（水平タブ）'**
  String get tabBarPositionTop;

  /// No description provided for @tabBarPositionLeft.
  ///
  /// In ja, this message translates to:
  /// **'左端（垂直タブ）'**
  String get tabBarPositionLeft;

  /// No description provided for @tabBarPositionRight.
  ///
  /// In ja, this message translates to:
  /// **'右端（垂直タブ）'**
  String get tabBarPositionRight;

  /// No description provided for @tabBarPositionOuterEdgeHint.
  ///
  /// In ja, this message translates to:
  /// **'垂直タブ使用時、サイドバーと同じ辺にある場合にどちらを外側（画面端側）に配置するか'**
  String get tabBarPositionOuterEdgeHint;

  /// No description provided for @outerEdgeVerticalTabs.
  ///
  /// In ja, this message translates to:
  /// **'垂直タブを外側に'**
  String get outerEdgeVerticalTabs;

  /// No description provided for @outerEdgeSidebar.
  ///
  /// In ja, this message translates to:
  /// **'サイドバーを外側に'**
  String get outerEdgeSidebar;

  /// No description provided for @outerEdgeSidebarSubtitle.
  ///
  /// In ja, this message translates to:
  /// **'サイドバーを最大化すると、垂直タブはそれに合わせて内側へ移動します'**
  String get outerEdgeSidebarSubtitle;

  /// No description provided for @fullscreenBehaviorSection.
  ///
  /// In ja, this message translates to:
  /// **'全画面表示のタイミング'**
  String get fullscreenBehaviorSection;

  /// No description provided for @fullscreenOnViewerOnly.
  ///
  /// In ja, this message translates to:
  /// **'書籍を開いている間のみ'**
  String get fullscreenOnViewerOnly;

  /// No description provided for @fullscreenOnViewerOnlySubtitle.
  ///
  /// In ja, this message translates to:
  /// **'本棚などを見ている間はウィンドウ表示にします'**
  String get fullscreenOnViewerOnlySubtitle;

  /// No description provided for @fullscreenAlwaysOnLaunch.
  ///
  /// In ja, this message translates to:
  /// **'起動時から常に全画面'**
  String get fullscreenAlwaysOnLaunch;

  /// No description provided for @launchTabSection.
  ///
  /// In ja, this message translates to:
  /// **'起動時のタブ'**
  String get launchTabSection;

  /// No description provided for @launchTabResumeLastBook.
  ///
  /// In ja, this message translates to:
  /// **'前回読んでいたタブを再度開く'**
  String get launchTabResumeLastBook;

  /// No description provided for @launchTabAlwaysLibrary.
  ///
  /// In ja, this message translates to:
  /// **'常にトップページから始める'**
  String get launchTabAlwaysLibrary;

  /// No description provided for @launchTabAlwaysLibrarySubtitle.
  ///
  /// In ja, this message translates to:
  /// **'読書の進捗はこの設定に関わらず保持されます'**
  String get launchTabAlwaysLibrarySubtitle;

  /// No description provided for @settingsFavoritesOpenModeSection.
  ///
  /// In ja, this message translates to:
  /// **'設定・お気に入りアイコンの動作'**
  String get settingsFavoritesOpenModeSection;

  /// No description provided for @openModeNewTabSubtitle.
  ///
  /// In ja, this message translates to:
  /// **'既に開いていればそのタブに切り替えます'**
  String get openModeNewTabSubtitle;

  /// No description provided for @openModeToggleInPlace.
  ///
  /// In ja, this message translates to:
  /// **'現在のタブ内で切り替える'**
  String get openModeToggleInPlace;

  /// No description provided for @openModeToggleInPlaceSubtitle.
  ///
  /// In ja, this message translates to:
  /// **'もう一度アイコンをタップすると、切り替え前に表示していたページに戻ります'**
  String get openModeToggleInPlaceSubtitle;

  /// No description provided for @middleClickSection.
  ///
  /// In ja, this message translates to:
  /// **'ミドルクリックで新しいタブを開いた時'**
  String get middleClickSection;

  /// No description provided for @middleClickSwitchToNewTab.
  ///
  /// In ja, this message translates to:
  /// **'新しいタブに自動的に切り替える'**
  String get middleClickSwitchToNewTab;

  /// No description provided for @middleClickStayOnCurrentTab.
  ///
  /// In ja, this message translates to:
  /// **'元のタブに留まる'**
  String get middleClickStayOnCurrentTab;

  /// No description provided for @middleClickStayOnCurrentTabSubtitle.
  ///
  /// In ja, this message translates to:
  /// **'新しいタブはバックグラウンドで開かれます'**
  String get middleClickStayOnCurrentTabSubtitle;

  /// No description provided for @mobileNavIconsSection.
  ///
  /// In ja, this message translates to:
  /// **'ナビゲーションポップアップの表示アイコン'**
  String get mobileNavIconsSection;

  /// No description provided for @mobileNavIconsHint.
  ///
  /// In ja, this message translates to:
  /// **'チェックを外したアイコンはポップアップ右端のメニューに収納されます。ドラッグで並び順を変更できます'**
  String get mobileNavIconsHint;

  /// No description provided for @themeSection.
  ///
  /// In ja, this message translates to:
  /// **'テーマ設定'**
  String get themeSection;

  /// No description provided for @themeSystem.
  ///
  /// In ja, this message translates to:
  /// **'システム設定に従う'**
  String get themeSystem;

  /// No description provided for @themeLight.
  ///
  /// In ja, this message translates to:
  /// **'ライトモード'**
  String get themeLight;

  /// No description provided for @themeDark.
  ///
  /// In ja, this message translates to:
  /// **'ダークモード'**
  String get themeDark;

  /// No description provided for @languageSection.
  ///
  /// In ja, this message translates to:
  /// **'言語'**
  String get languageSection;

  /// No description provided for @languageJapanese.
  ///
  /// In ja, this message translates to:
  /// **'日本語'**
  String get languageJapanese;

  /// No description provided for @languageEnglish.
  ///
  /// In ja, this message translates to:
  /// **'English'**
  String get languageEnglish;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'ja'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'ja':
      return AppLocalizationsJa();
  }

  throw FlutterError(
      'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
      'an issue with the localizations generation tool. Please file an issue '
      'on GitHub with a reproducible sample app and the gen-l10n configuration '
      'that was used.');
}
