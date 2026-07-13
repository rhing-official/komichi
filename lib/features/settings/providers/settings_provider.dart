import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive/hive.dart';
import '../models/app_settings.dart';
import '../../../core/utils/screen_orientation_utils.dart';

final settingsProvider =
    StateNotifierProvider<SettingsNotifier, AppSettings>((ref) {
  return SettingsNotifier();
});

class SettingsNotifier extends StateNotifier<AppSettings> {
  SettingsNotifier() : super(AppSettings()) {
    _load();
  }

  Box<AppSettings> get _box => Hive.box<AppSettings>('settings');

  void _load() {
    final data = _box.get('current');
    if (data != null) {
      state = data;
    } else {
      // 保存データが無い初回起動時も、デフォルトの向き固定を即座に適用する
      applyScreenOrientationLock(state.screenOrientationLock);
    }
  }

  // 状態が更新されたらHiveに保存する
  @override
  set state(AppSettings value) {
    super.state = value;
    _box.put('current', value);
    // 画面の向きは「常に固定」の機能のため、設定が読み込まれた/変更された
    // 直後に必ず反映する（Android以外では内部で何もしない）
    applyScreenOrientationLock(value.screenOrientationLock);
  }
}
