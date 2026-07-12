import 'package:flutter/material.dart';
import '../providers/tab_provider.dart';
import '../../features/library/views/favorites_screen.dart';
import '../../features/library/views/home_placeholder_screen.dart';
import '../../features/library/views/shelf_screen.dart';
import '../../features/settings/views/settings_screen.dart';
import '../../features/viewer/views/viewer_screen.dart';

// タブの中身（設定・お気に入り・ビューア・本棚・新規タブのプレースホルダー）を
// 出し分けるロジック。デスクトップ(TabShell/_MainArea)・モバイル(MobileShell)
// の両方から共通で呼ばれる
Widget buildTabContent(TabItem tab, bool isActive) {
  if (tab.isSettings) return SettingsScreen(isActive: isActive);
  if (tab.isFavorites) return FavoritesScreen(isActive: isActive);
  if (tab.bookId != null) {
    return ViewerScreen(bookId: tab.bookId!, isActive: isActive);
  }
  if (tab.shelfId != null) {
    return ShelfScreen(shelfId: tab.shelfId!, isActive: isActive);
  }
  return HomePlaceholderScreen(isActive: isActive);
}
