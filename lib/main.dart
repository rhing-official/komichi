import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:path_provider/path_provider.dart';
import 'package:window_manager/window_manager.dart';
import 'package:flutter/gestures.dart';

import 'app.dart';
import 'core/utils/platform_utils.dart';
import 'features/library/models/book.dart';
import 'features/library/models/shelf.dart';
import 'features/settings/models/app_settings.dart';

void main() async {
  // 1. Flutterとウィンドウ管理の初期化
  WidgetsFlutterBinding.ensureInitialized();
  // window_managerはAndroidに実装がないため、デスクトップ環境の時だけ初期化する
  if (isDesktopPlatform) await windowManager.ensureInitialized();

  // 2. データベース（Hive）を「待機して」確実に準備する
  try {
    final appDir = await getApplicationSupportDirectory();
    await Hive.initFlutter(appDir.path);

    // アダプター登録
    if (!Hive.isAdapterRegistered(0)) Hive.registerAdapter(BookAdapter());
    if (!Hive.isAdapterRegistered(1))
      Hive.registerAdapter(AppSettingsAdapter());
    if (!Hive.isAdapterRegistered(2)) Hive.registerAdapter(BookFormatAdapter());
    if (!Hive.isAdapterRegistered(3)) Hive.registerAdapter(TabModeAdapter());
    if (!Hive.isAdapterRegistered(4))
      Hive.registerAdapter(PageDirectionAdapter());
    if (!Hive.isAdapterRegistered(5)) Hive.registerAdapter(ShelfAdapter());
    if (!Hive.isAdapterRegistered(6)) Hive.registerAdapter(AppThemeAdapter());
    if (!Hive.isAdapterRegistered(7))
      Hive.registerAdapter(SidebarPositionAdapter());
    if (!Hive.isAdapterRegistered(8))
      Hive.registerAdapter(TabBarPositionAdapter());
    if (!Hive.isAdapterRegistered(9))
      Hive.registerAdapter(FullscreenBehaviorAdapter());
    if (!Hive.isAdapterRegistered(10))
      Hive.registerAdapter(OuterEdgeElementAdapter());
    if (!Hive.isAdapterRegistered(11))
      Hive.registerAdapter(LaunchTabBehaviorAdapter());

    // ★ ここで全てのBoxが開くのを確実に待つ（これがエラーの解決策）
    await Future.wait([
      Hive.openBox<Book>('books'),
      Hive.openBox<AppSettings>('settings'),
      Hive.openBox<Shelf>('shelves'),
    ]);
    print('--- Hive Ready ---');
  } catch (e) {
    debugPrint('Hive Init Error: $e');
  }

  // 3. ウィンドウを表示する準備（デスクトップ環境のみ）
  if (isDesktopPlatform) {
    WindowOptions windowOptions = const WindowOptions(
      size: Size(1280, 720),
      center: true,
      backgroundColor: Colors.transparent,
      skipTaskbar: false,
      titleBarStyle: TitleBarStyle.hidden,
    );

    windowManager.waitUntilReadyToShow(windowOptions, () async {
      await windowManager.show();
      await windowManager.focus();
    });
  }

// ミドルクリックオートスクロールを無効化（警告回避のためシグネチャを明示）
  GestureBinding.instance?.pointerRouter.addGlobalRoute((PointerEvent event) {});

  // 4. アプリ起動
  runApp(
    const ProviderScope(
      child: KomichiApp(),
    ),
  );
}
