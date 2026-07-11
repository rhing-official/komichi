import 'package:hive_flutter/hive_flutter.dart';
import 'package:path_provider/path_provider.dart';

import '../../features/library/models/book.dart';
import '../../features/settings/models/app_settings.dart';

Future<void> initHive() async {
  final dir = await getApplicationDocumentsDirectory();
  await Hive.initFlutter(dir.path);

  Hive.registerAdapter(BookAdapter());
  Hive.registerAdapter(BookFormatAdapter());
  Hive.registerAdapter(AppSettingsAdapter());

  await Hive.openBox<Book>('books');
  await Hive.openBox<AppSettings>('settings');
}
