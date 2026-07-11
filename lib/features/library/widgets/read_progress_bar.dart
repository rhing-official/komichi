import 'package:flutter/material.dart';
import '../models/book.dart';

// 書籍カードの下部に重ねて表示する既読フェーダー（丸みを帯びたピル型のゲージ）。
// 未読（一度も開かれていない）は非表示、読書中は緑、読了は赤。
// 色付き部分の長さは既読範囲（lastPage）に応じて可変
class ReadProgressBar extends StatelessWidget {
  final Book book;
  const ReadProgressBar({super.key, required this.book});

  @override
  Widget build(BuildContext context) {
    if (!book.isFinished && book.lastPage <= 0) {
      return const SizedBox.shrink();
    }
    final progress = book.isFinished
        ? 1.0
        : (book.totalPages > 0 ? (book.lastPage + 1) / book.totalPages : 0.0)
            .clamp(0.0, 1.0);
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
          alignment: Alignment.centerLeft,
          widthFactor: progress,
          child: ColoredBox(
            color: book.isFinished ? Colors.red : Colors.green,
          ),
        ),
      ),
    );
  }
}
