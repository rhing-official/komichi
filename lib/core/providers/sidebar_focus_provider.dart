import 'package:flutter_riverpod/flutter_riverpod.dart';

// カウンタをインクリメントすることでサイドバー検索欄へのフォーカスを要求するシグナル
final sidebarFocusRequestProvider = StateProvider<int>((ref) => 0);
