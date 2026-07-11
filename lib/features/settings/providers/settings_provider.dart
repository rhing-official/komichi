import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive/hive.dart';
import '../models/app_settings.dart';

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
    if (data != null) state = data;
  }

  // 状態が更新されたらHiveに保存する
  @override
  set state(AppSettings value) {
    super.state = value;
    _box.put('current', value);
  }
}
