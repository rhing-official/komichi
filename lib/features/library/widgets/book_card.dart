import 'package:flutter/material.dart';
import '../../library/models/book.dart';

class BookCard extends StatelessWidget {
  const BookCard({
    super.key,
    required this.book,
    required this.onTap,
  });

  final Book book;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final progress = book.totalPages > 0
        ? book.lastPage / book.totalPages
        : 0.0;

    return GestureDetector(
      onTap: onTap,
      child: Card(
        clipBehavior: Clip.antiAlias,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // サムネイル領域
            Expanded(
              child: book.thumbnailPath != null
                  ? Image.asset(
                      book.thumbnailPath!,
                      fit: BoxFit.cover,
                    )
                  : Container(
                      color: theme.colorScheme.surface,
                      child: Icon(
                        book.format == BookFormat.pdf
                            ? Icons.picture_as_pdf_outlined
                            : Icons.photo_library_outlined,
                        size: 48,
                        color: theme.colorScheme.secondary,
                      ),
                    ),
            ),

            // タイトル + 進捗バー
            Padding(
              padding: const EdgeInsets.fromLTRB(8, 6, 8, 4),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    book.title,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 4),
                  // 読了フラグ
                  if (book.isFinished)
                    Text(
                      '読了',
                      style: TextStyle(
                        fontSize: 10,
                        color: theme.colorScheme.secondary,
                        fontWeight: FontWeight.bold,
                      ),
                    )
                  else
                    LinearProgressIndicator(
                      value: progress.clamp(0.0, 1.0),
                      minHeight: 3,
                      backgroundColor: theme.colorScheme.surface,
                      color: theme.colorScheme.secondary,
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
