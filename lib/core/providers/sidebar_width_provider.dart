import 'package:flutter_riverpod/flutter_riverpod.dart';

const double kSidebarDefaultWidth = 260;
const double kSidebarMinWidth = 180;
const double kSidebarMaxWidth = 480;

// セッション内のみ保持（アプリ再起動でデフォルト幅に戻る）
final sidebarWidthProvider =
    StateProvider<double>((ref) => kSidebarDefaultWidth);
