import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/viewer_provider.dart';

class CbzViewer extends ConsumerWidget {
  final String bookId;
  final int currentPage;
  const CbzViewer({super.key, required this.bookId, required this.currentPage});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final bytes = ref.watch(viewerProvider(bookId).notifier).currentImageBytes;
    if (bytes != null)
      return Image.memory(bytes,
          fit: BoxFit.contain,
          width: double.infinity,
          height: double.infinity,
          gaplessPlayback: true,
          filterQuality: FilterQuality.medium);
    return const Center(
        child: CircularProgressIndicator(color: Colors.white24));
  }
}
