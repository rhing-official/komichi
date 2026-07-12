import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/book.dart';
import '../../settings/providers/settings_provider.dart';
import '../../settings/models/app_settings.dart';

// 書籍カードの下部に重ねて表示する既読フェーダー（丸みを帯びたピル型のゲージ）。
// 未読（一度も開かれていない）は非表示、読書中は緑、読了は赤。
// 色付き部分の長さは既読範囲（lastPage）に応じて可変。
// ページ送り方向設定と揃え、右送り（左→次）なら左から右へ、左送り（右→次）
// なら右から左へ緑が伸びていく（＝実際のページがめくられていく向きと一致させる）
class ReadProgressBar extends ConsumerWidget {
  final Book book;
  const ReadProgressBar({super.key, required this.book});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (!book.isFinished && book.lastPage <= 0) {
      return const SizedBox.shrink();
    }
    final progress = book.isFinished
        ? 1.0
        : (book.totalPages > 0 ? (book.lastPage + 1) / book.totalPages : 0.0)
            .clamp(0.0, 1.0);
    final isLeftToNext =
        ref.watch(settingsProvider).pageDirection == PageDirection.leftToNext;
    const height = 14.0;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      child: Container(
        height: height,
        decoration: BoxDecoration(
          color: Colors.black,
          borderRadius: BorderRadius.circular(height / 2),
          border: Border.all(color: Colors.white, width: 2),
        ),
        clipBehavior: Clip.antiAlias,
        child: FractionallySizedBox(
          alignment: isLeftToNext ? Alignment.centerRight : Alignment.centerLeft,
          widthFactor: progress,
          child: ColoredBox(
            color: book.isFinished ? Colors.red : Colors.green,
          ),
        ),
      ),
    );
  }
}
