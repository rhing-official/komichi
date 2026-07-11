import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/viewer_provider.dart';

class PageSlider extends ConsumerStatefulWidget {
  final String bookId;
  const PageSlider({super.key, required this.bookId});

  @override
  ConsumerState<PageSlider> createState() => _PageSliderState();
}

class _PageSliderState extends ConsumerState<PageSlider> {
  double? _draggingValue;

  @override
  Widget build(BuildContext context) {
    final readState = ref.watch(viewerProvider(widget.bookId));

    if (readState.totalPages <= 1) return const SizedBox.shrink();

    final current = _draggingValue ?? readState.currentPage.toDouble();
    final total = (readState.totalPages - 1).toDouble();

    return Slider(
      value: current.clamp(0, total),
      max: total,
      onChanged: (v) => setState(() => _draggingValue = v),
      onChangeEnd: (v) {
        setState(() => _draggingValue = null);
        ref.read(viewerProvider(widget.bookId).notifier).jumpToPage(v.round());
      },
    );
  }
}
