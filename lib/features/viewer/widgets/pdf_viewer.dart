import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/viewer_provider.dart';

class PdfViewer extends ConsumerWidget {
  final String filePath;
  final int currentPage;
  const PdfViewer(
      {super.key, required this.filePath, required this.currentPage});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // ViewerProvider経由で画像を取得
    final bytes = ref
        .watch(viewerProvider(filePath.split('/').last).notifier)
        .currentImageBytes;
    if (bytes != null)
      return Image.memory(bytes,
          fit: BoxFit.contain,
          width: double.infinity,
          height: double.infinity,
          gaplessPlayback: true);
    return const Center(
        child: CircularProgressIndicator(color: Colors.white24));
  }
}
