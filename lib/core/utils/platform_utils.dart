import 'dart:io';

// window_manager パッケージは Windows/Linux/macOS 専用でAndroidには実装がなく、
// ガードなしで呼ぶと MissingPluginException で落ちる。カスタムタイトルバーや
// フルスクリーン制御などデスクトップ専用の処理はこのフラグでガードする
final bool isDesktopPlatform =
    Platform.isWindows || Platform.isLinux || Platform.isMacOS;

// タブバー・サイドバー・パスバーの代わりに1枚のナビゲーションポップアップへ
// 集約したモバイル専用UI（MobileShell）を使うかどうかの判定に使う
final bool isMobilePlatform = Platform.isAndroid || Platform.isIOS;
