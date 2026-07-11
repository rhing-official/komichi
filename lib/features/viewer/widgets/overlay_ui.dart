import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/viewer_provider.dart';
import 'page_slider.dart';

class OverlayUi extends ConsumerWidget {
  final String bookId;
  final VoidCallback onBack;

  const OverlayUi({super.key, required this.bookId, required this.onBack});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // 正しい呼び出し方
    final readState = ref.watch(viewerProvider(bookId));

    if (!readState.showUI) return const SizedBox.shrink();

    return Stack(
      children: [
        Positioned(
          top: 0,
          left: 0,
          right: 0,
          child: Container(
            color: Colors.black54,
            child: AppBar(
              backgroundColor: Colors.transparent,
              elevation: 0,
              title: Text(readState.title,
                  style: const TextStyle(color: Colors.white)),
              leading: IconButton(
                icon: const Icon(Icons.arrow_back, color: Colors.white),
                onPressed: onBack,
              ),
            ),
          ),
        ),
        Positioned(
          bottom: 0,
          left: 0,
          right: 0,
          child: Container(
            color: Colors.black54,
            padding: const EdgeInsets.all(16),
            child: PageSlider(bookId: bookId),
          ),
        ),
      ],
    );
  }
}
