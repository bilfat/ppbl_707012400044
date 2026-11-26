import 'package:flutter/material.dart';
import '../config/app_theme.dart';
import '../models/book.dart';

/// Kartu untuk menampilkan satu buku pada katalog halaman utama.
class BookCard extends StatelessWidget {
  final Book book;
  final VoidCallback onTap;

  const BookCard({
    super.key,
    required this.book,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final color = AppColors.cardColors[book.id % AppColors.cardColors.length];
    final initial = book.judul.isEmpty ? '?' : book.judul[0].toUpperCase();
    final isAvailable = book.stok > 0;

    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(20),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Thumbnail sampul atau kotak huruf pertama judul
                _buildCoverThumb(color, initial),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        book.judul,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 15.5,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textDark,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        book.penulis,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 13,
                          color: AppColors.textGrey,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        '${book.penerbit} • ${book.tahunTerbit}',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 12,
                          color: AppColors.textGrey,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              color: (isAvailable
                                      ? AppColors.success
                                      : AppColors.danger)
                                  .withValues(alpha: 0.14),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(
                              isAvailable
                                  ? 'Stok: ${book.stok}'
                                  : 'Stok Habis',
                              style: TextStyle(
                                fontSize: 11.5,
                                fontWeight: FontWeight.bold,
                                color: isAvailable
                                    ? AppColors.success
                                    : AppColors.danger,
                              ),
                            ),
                          ),
                          if (book.hasCover) ...[
                            const SizedBox(width: 8),
                            const Icon(
                              Icons.image_rounded,
                              size: 15,
                              color: AppColors.primary,
                            ),
                          ],
                          const Spacer(),
                          Text(
                            '#${book.id}',
                            style: const TextStyle(
                              fontSize: 12,
                              color: AppColors.textGrey,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCoverThumb(Color color, String initial) {
    if (book.hasCover) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(14),
        child: Image.network(
          book.imageUrl,
          width: 60,
          height: 82,
          fit: BoxFit.cover,
          errorBuilder: (_, __, ___) => _fallbackBox(color, initial),
        ),
      );
    }
    return _fallbackBox(color, initial);
  }

  Widget _fallbackBox(Color color, String initial) {
    return Container(
      width: 60,
      height: 82,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Text(
        initial,
        style: TextStyle(
          color: color,
          fontSize: 24,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}
