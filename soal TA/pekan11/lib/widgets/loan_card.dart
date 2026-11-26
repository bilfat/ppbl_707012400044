import 'package:flutter/material.dart';
import '../config/app_theme.dart';
import '../models/loan.dart';
import '../utils/helpers.dart';

/// Kartu untuk menampilkan satu riwayat peminjaman milik pengguna login.
class LoanCard extends StatelessWidget {
  final Loan loan;
  final VoidCallback onTap;
  final VoidCallback? onReturnTap;
  final VoidCallback onDeleteTap;

  const LoanCard({
    super.key,
    required this.loan,
    required this.onTap,
    required this.onReturnTap,
    required this.onDeleteTap,
  });

  @override
  Widget build(BuildContext context) {
    final isReturned = loan.isReturned;
    final statusColor = isReturned ? AppColors.success : AppColors.warning;
    final bookTitle = loan.book?.judul ?? 'Buku #${loan.bookId}';
    final bookAuthor = loan.book?.penulis ?? '-';

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
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 48,
                      height: 48,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: statusColor.withValues(alpha: 0.14),
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: Icon(
                        isReturned
                            ? Icons.assignment_turned_in_rounded
                            : Icons.auto_stories_rounded,
                        color: statusColor,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            bookTitle,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontSize: 15.5,
                              fontWeight: FontWeight.bold,
                              color: AppColors.textDark,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            '$bookAuthor • Pinjaman #${loan.id}',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontSize: 12.5,
                              color: AppColors.textGrey,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: statusColor.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        loan.status,
                        style: TextStyle(
                          color: statusColor,
                          fontSize: 11.5,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    const Icon(Icons.calendar_today_rounded,
                        size: 14, color: AppColors.textGrey),
                    const SizedBox(width: 5),
                    Text(
                      'Pinjam: ${formatTanggalPendek(loan.tanggalPinjam)}',
                      style: const TextStyle(
                          fontSize: 12, color: AppColors.textGrey),
                    ),
                    if (loan.tanggalKembali != null) ...[
                      const SizedBox(width: 12),
                      const Icon(Icons.event_available_rounded,
                          size: 14, color: AppColors.success),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          'Kembali: ${formatTanggalPendek(loan.tanggalKembali)}',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                              fontSize: 12, color: AppColors.success),
                        ),
                      ),
                    ],
                  ],
                ),
                const Divider(height: 22),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton.icon(
                      onPressed: onDeleteTap,
                      icon: const Icon(Icons.delete_outline_rounded, size: 18),
                      label: const Text('Hapus'),
                      style: TextButton.styleFrom(
                        foregroundColor: AppColors.danger,
                      ),
                    ),
                    if (!isReturned && onReturnTap != null) ...[
                      const SizedBox(width: 8),
                      FilledButton.icon(
                        onPressed: onReturnTap,
                        icon: const Icon(Icons.assignment_return_rounded,
                            size: 18),
                        label: const Text('Kembalikan'),
                        style: FilledButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
