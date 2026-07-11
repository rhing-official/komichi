import 'dart:io';

// window_manager パッケージは Windows/Linux/macOS 専用でAndroidには実装がなく、
// ガードなしで呼ぶと MissingPluginException で落ちる。カスタムタイトルバーや
// フルスクリーン制御などデスクトップ専用の処理はこのフラグでガードする
final bool isDesktopPlatform =
    Platform.isWindows || Platform.isLinux || Platform.isMacOS;
