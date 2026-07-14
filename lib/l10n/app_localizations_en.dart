// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get settings => 'Settings';

  @override
  String get cancel => 'Cancel';

  @override
  String get delete => 'Delete';

  @override
  String get addFolder => 'Add Folder';

  @override
  String get openInNewTab => 'Open in New Tab';

  @override
  String get addToFavorites => 'Add to Favorites';

  @override
  String get removeFromFavorites => 'Remove from Favorites';

  @override
  String get favorites => 'Favorites';

  @override
  String get noFavoritesYet => 'No favorites yet';

  @override
  String fileCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count files',
      one: '$count file',
    );
    return '$_temp0';
  }

  @override
  String get noShelvesYet => 'No bookshelves added yet';

  @override
  String get topPageTitle => 'Top';

  @override
  String get newTab => 'New Tab';

  @override
  String get information => 'Information';

  @override
  String get appTagline => 'Just you and a book';

  @override
  String versionInfo(String version) {
    return 'Version $version';
  }

  @override
  String get licensesSection => 'Open Source Licenses';

  @override
  String get licensesButton => 'View Licenses';

  @override
  String get shortcutsSection => 'Keyboard Shortcuts';

  @override
  String get shortcutCategoryNavigation => 'Navigation';

  @override
  String get shortcutCategoryTabs => 'Tabs';

  @override
  String get shortcutCategoryScreenFile => 'Screen & Files';

  @override
  String get shortcutCategoryViewer => 'In the Viewer';

  @override
  String get shortcutAltArrow => 'Go back / forward in history';

  @override
  String get shortcutEsc => 'Close the viewer and return to the folder';

  @override
  String get shortcutCtrlTab => 'Switch to the tab on the right / below';

  @override
  String get shortcutCtrlShiftTab => 'Switch to the tab on the left / above';

  @override
  String get shortcutCtrlT => 'Open a new bookshelf tab';

  @override
  String get shortcutCtrlW => 'Close the current tab';

  @override
  String get shortcutMiddleClick =>
      'Close a tab / open a book or folder in a new tab';

  @override
  String get shortcutCtrlI => 'Open settings';

  @override
  String get shortcutCtrlF => 'Open favorites';

  @override
  String get shortcutF1 => 'Open information';

  @override
  String get shortcutCtrlS => 'Focus the sidebar search field';

  @override
  String get shortcutCtrlA => 'Select all items in the current folder';

  @override
  String get shortcutCtrlClick =>
      'Add or remove an individual item from the selection';

  @override
  String get shortcutShiftClick =>
      'Range-select (selects everything from the last click to this one)';

  @override
  String get shortcutF5 => 'Rescan folders and refresh the book list';

  @override
  String get shortcutArrowLeftRight => 'Previous / next page';

  @override
  String get shortcutCtrlArrowLeftRight => 'Go to the first / last page';

  @override
  String get shortcutArrowUpDown =>
      'Open the previous / next book in the same folder';

  @override
  String get shortcutSpace => 'Show or hide the menu bar';

  @override
  String get sidebarSearchHint => 'Search books & folders...';

  @override
  String get noSearchResults => 'No matching books or folders found';

  @override
  String get deleteFolderTitle => 'Delete Folder';

  @override
  String get deleteFolderConfirm => 'Delete all books in this folder?';

  @override
  String get jumpToFirstPage => 'Go to First Page';

  @override
  String get jumpToLastPage => 'Go to Last Page';

  @override
  String get nextBook => 'Next Book';

  @override
  String get previousBook => 'Previous Book';

  @override
  String get orientationPortrait => 'Portrait';

  @override
  String get orientationLandscapeLeft => 'Rotate Left 90°';

  @override
  String get orientationLandscapeRight => 'Rotate Right 90°';

  @override
  String get orientationPortraitDown => '180°';

  @override
  String get navBack => 'Back';

  @override
  String get navForward => 'Forward';

  @override
  String get navSearch => 'Search';

  @override
  String get navAddTab => 'Add Tab';

  @override
  String get navTabList => 'Tabs';

  @override
  String get navMore => 'More';

  @override
  String get pageDirectionSection => 'Page Direction';

  @override
  String get pageDirectionLeftTitle => 'Left-to-Right';

  @override
  String get pageDirectionLeftSubtitle =>
      'Left click / Left arrow key moves to the next page';

  @override
  String get pageDirectionRightTitle => 'Right-to-Left';

  @override
  String get pageDirectionRightSubtitle =>
      'Right click / Right arrow key moves to the next page';

  @override
  String get sidebarPositionSection => 'Sidebar Position';

  @override
  String get sidebarPositionLeft => 'Left';

  @override
  String get sidebarPositionRight => 'Right';

  @override
  String get tabBarPositionSection => 'Tab Bar Position';

  @override
  String get tabBarPositionTop => 'Top (Horizontal Tabs)';

  @override
  String get tabBarPositionLeft => 'Left Edge (Vertical Tabs)';

  @override
  String get tabBarPositionRight => 'Right Edge (Vertical Tabs)';

  @override
  String get tabBarPositionOuterEdgeHint =>
      'When using vertical tabs on the same side as the sidebar, choose which one sits on the outer edge (screen side)';

  @override
  String get outerEdgeVerticalTabs => 'Vertical Tabs on the Outside';

  @override
  String get outerEdgeSidebar => 'Sidebar on the Outside';

  @override
  String get outerEdgeSidebarSubtitle =>
      'Maximizing the sidebar moves the vertical tabs inward to make room';

  @override
  String get fullscreenBehaviorSection => 'Fullscreen Timing';

  @override
  String get fullscreenOnViewerOnly => 'Only While Reading a Book';

  @override
  String get fullscreenOnViewerOnlySubtitle =>
      'Shows a normal window while browsing shelves, etc.';

  @override
  String get fullscreenAlwaysOnLaunch => 'Always Fullscreen from Launch';

  @override
  String get launchTabSection => 'Startup Tab';

  @override
  String get launchTabResumeLastBook => 'Reopen the Last Book You Were Reading';

  @override
  String get launchTabAlwaysLibrary => 'Always Start from the Bookshelf Tab';

  @override
  String get launchTabAlwaysLibrarySubtitle =>
      'Reading progress is kept regardless of this setting';

  @override
  String get settingsFavoritesOpenModeSection =>
      'Settings/Favorites Icon Behavior';

  @override
  String get openModeNewTabSubtitle =>
      'Switches to the existing tab if one is already open';

  @override
  String get openModeToggleInPlace => 'Switch Within the Current Tab';

  @override
  String get openModeToggleInPlaceSubtitle =>
      'Tapping the icon again returns to the page you were viewing before';

  @override
  String get middleClickSection => 'When Opening a New Tab with Middle-Click';

  @override
  String get middleClickSwitchToNewTab => 'Automatically Switch to the New Tab';

  @override
  String get middleClickStayOnCurrentTab => 'Stay on the Current Tab';

  @override
  String get middleClickStayOnCurrentTabSubtitle =>
      'The new tab opens in the background';

  @override
  String get mobileNavIconsSection => 'Navigation Popup Icons';

  @override
  String get mobileNavIconsHint =>
      'Unchecked icons are tucked into the menu on the right of the popup. Drag to reorder';

  @override
  String get themeSection => 'Theme';

  @override
  String get themeSystem => 'Follow System Setting';

  @override
  String get themeLight => 'Light Mode';

  @override
  String get themeDark => 'Dark Mode';

  @override
  String get languageSection => 'Language';

  @override
  String get languageJapanese => '日本語';

  @override
  String get languageEnglish => 'English';
}
