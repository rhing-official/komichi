import 'dart:io';
import 'package:flutter/services.dart';
import '../../features/settings/models/app_settings.dart';

// 画面の向き固定はAndroid専用機能。デスクトップはウィンドウが自由にリサイズ
// できるフローティングウィンドウであり「端末の向き」という概念自体が無いため、
// Android以外では何もしない
void applyScreenOrientationLock(ScreenOrientationLock lock) {
  if (!Platform.isAndroid) return;
  SystemChrome.setPreferredOrientations([_toDeviceOrientation(lock)]);
}

DeviceOrientation _toDeviceOrientation(ScreenOrientationLock lock) {
  switch (lock) {
    case ScreenOrientationLock.portraitUp:
      return DeviceOrientation.portraitUp;
    case ScreenOrientationLock.landscapeLeft:
      return DeviceOrientation.landscapeLeft;
    case ScreenOrientationLock.landscapeRight:
      return DeviceOrientation.landscapeRight;
    case ScreenOrientationLock.portraitDown:
      return DeviceOrientation.portraitDown;
  }
}
