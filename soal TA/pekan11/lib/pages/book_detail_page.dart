import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../config/app_theme.dart';
import '../cubits/auth_cubit.dart';
import '../cubits/book_cubit.dart';
import '../cubits/book_state.dart';
import '../cubits/loan_cubit.dart';
import '../cubits/loan_state.dart';
import '../models/book.dart';
import '../utils/helpers.dart';
import '../widgets/attachment_tile.dart';
import '../widgets/gradient_button.dart';
import 'book_form_page.dart';
import 'login_page.dart';

// ============================================================
// HALAMAN DETAIL BUKU  (GET /api/books/{id})
// ============================================================
// Detail buku dapat dilihat tanpa login.
// Tombol Ubah, Hapus, dan Pinjam Buku hanya muncul setelah login.
class BookDetailPage extends StatelessWidget {
  final Book book;

  const BookDetailPage({super.key, required this.book});

  Future<void> _confirmDelete(BuildContext context, Book current) async {
    final yakin = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        icon: const Icon(Icons.delete_forever_rounded,
            color: AppColors.danger, size: 48),
        title: const Text('Hapus Buku?'),
        content: Text(
          '"${current.judul}" akan dihapus permanen.',
          textAlign: TextAlign.center,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('Batal'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: AppColors.danger),
            onPressed: () => Navigator.pop(dialogContext, true),
            child: const Text('Hapus'),
          ),
        ],
      ),
    );

    if (yakin != true || !context.mounted) return;
    final success = await context.read<BookCubit>().deleteBook(current.id);
    if (success && context.mounted) Navigator.pop(context);
  }

  Future<void> _showBorrowSheet(BuildContext context, Book current) async {
    DateTime selectedDate = DateTime.now();

    final confirmedDate = await showModalBottomSheet<DateTime>(
      context: context,
      backgroundColor: Colors.white,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      builder: (sheetContext) {
        return StatefulBuilder(
          builder: (sheetContext, setSheetState) {
            return Padding(
              padding: const EdgeInsets.fromLTRB(24, 14, 24, 32),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Center(
                    child: Container(
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(
                        color: Colors.grey.shade300,
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  const Text(
                    'Pinjam Buku',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textDark,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    '${current.judul} (Stok tersedia: ${current.stok})',
                    style: const TextStyle(color: AppColors.textGrey),
                  ),
                  const SizedBox(height: 20),
                  InkWell(
                    borderRadius: BorderRadius.circular(16),
                    onTap: () async {
                      final picked = await showDatePicker(
                        context: sheetContext,
                        initialDate: selectedDate,
                        firstDate: DateTime(2020),
                        lastDate: DateTime(2030),
                      );
                      if (picked != null) {
                        setSheetState(() => selectedDate = picked);
                      }
                    },
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: AppColors.background,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.calendar_today_rounded,
                              color: AppColors.primary),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'Tanggal Pinjam',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: AppColors.textGrey,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  formatTanggalPendek(toApiDate(selectedDate)),
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: AppColors.textDark,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const Icon(Icons.edit_calendar_rounded,
                              color: AppColors.primary),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 22),
                  GradientButton(
                    text: 'Konfirmasi Peminjaman',
                    icon: Icons.bookmark_add_rounded,
                    onPressed: () => Navigator.pop(sheetContext, selectedDate),
                  ),
                ],
              ),
            );
          },
        );
      },
    );

    if (confirmedDate == null || !context.mounted) return;
    final success = await context.read<LoanCubit>().createLoan(
          bookId: current.id,
          tanggalPinjam: toApiDate(confirmedDate),
        );
    if (success && context.mounted) {
      await context.read<BookCubit>().loadBookDetail(current.id);
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<BookCubit, BookState>(
      builder: (context, state) {
        final current = state.books.firstWhere(
          (b) => b.id == book.id,
          orElse: () => book,
        );
        final isLoggedIn = context.watch<AuthCubit>().state.isLoggedIn;
        final isLoanSaving = context.watch<LoanCubit>().state.isSaving;

        return Scaffold(
          body: Column(
            children: [
              _buildHeader(context, current, isLoggedIn),
              if (state.isSaving || isLoanSaving)
                const LinearProgressIndicator(),
              Expanded(child: _buildContent(context, current, isLoggedIn)),
            ],
          ),
        );
      },
    );
  }

  Widget _buildHeader(BuildContext context, Book current, bool isLoggedIn) {
    final topPadding = MediaQuery.of(context).padding.top;
    return Container(
      width: double.infinity,
      padding: EdgeInsets.fromLTRB(12, topPadding + 8, 12, 26),
      decoration: const BoxDecoration(
        gradient: AppColors.mainGradient,
        borderRadius: BorderRadius.vertical(bottom: Radius.circular(32)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              _CircleButton(
                icon: Icons.arrow_back_rounded,
                onTap: () => Navigator.pop(context),
              ),
              const Spacer(),
              // Ubah dan hapus buku hanya muncul setelah login
              if (isLoggedIn) ...[
                _CircleButton(
                  icon: Icons.edit_rounded,
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => BookFormPage(book: current),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                _CircleButton(
                  icon: Icons.delete_rounded,
                  onTap: () => _confirmDelete(context, current),
                ),
              ],
            ],
          ),
          const SizedBox(height: 16),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Wrap(
                  spacing: 8,
                  runSpacing: 6,
                  children: [
                    _Label(text: 'Buku #${current.id}'),
                    _Label(
                      text: current.stok > 0
                          ? 'Stok: ${current.stok}'
                          : 'Stok Habis',
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Text(
                  current.judul,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 23,
                    fontWeight: FontWeight.bold,
                    height: 1.3,
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    const Icon(Icons.person_outline_rounded,
                        size: 15, color: Colors.white70),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        current.penulis,
                        style: const TextStyle(color: Colors.white70),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContent(BuildContext context, Book current, bool isLoggedIn) {
    return RefreshIndicator(
      onRefresh: () => context.read<BookCubit>().loadBookDetail(current.id),
      child: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          // Kartu sampul buku (dari GET /api/books/{id}/cover)
          if (current.hasCover) ...[
            _buildCoverSection(current),
            const SizedBox(height: 16),
          ],

          // Kartu informasi detail buku
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(24),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.05),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Row(
                  children: [
                    Icon(Icons.info_outline_rounded, color: AppColors.primary),
                    SizedBox(width: 8),
                    Text(
                      'Detail Buku',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: AppColors.textDark,
                      ),
                    ),
                  ],
                ),
                const Divider(height: 26),
                _DetailRow(label: 'Penulis', value: current.penulis),
                _DetailRow(label: 'Penerbit', value: current.penerbit),
                _DetailRow(
                    label: 'Tahun Terbit', value: '${current.tahunTerbit}'),
                _DetailRow(
                  label: 'Stok Tersedia',
                  value: '${current.stok} eksemplar',
                  valueColor:
                      current.stok > 0 ? AppColors.success : AppColors.danger,
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),

          // Tombol Pinjam Buku / Login
          if (isLoggedIn)
            BlocBuilder<LoanCubit, LoanState>(
              builder: (context, loanState) {
                return GradientButton(
                  text: current.stok > 0
                      ? 'Pinjam Buku Ini'
                      : 'Pinjam (Stok Habis)',
                  icon: Icons.bookmark_add_rounded,
                  isLoading: loanState.isSaving,
                  onPressed: () => _showBorrowSheet(context, current),
                );
              },
            )
          else
            OutlinedButton.icon(
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const LoginPage()),
              ),
              icon: const Icon(Icons.login_rounded),
              label: const Text('Login untuk Meminjam atau Mengelola Buku'),
              style: OutlinedButton.styleFrom(
                foregroundColor: AppColors.primary,
                padding: const EdgeInsets.symmetric(vertical: 16),
                side: const BorderSide(color: AppColors.primary, width: 1.5),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
            ),
          const SizedBox(height: 16),
          Center(
            child: Text(
              'Terakhir diubah: ${formatTanggal(current.updatedAt)}',
              style: const TextStyle(color: AppColors.textGrey, fontSize: 12),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCoverSection(Book current) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Row(
            children: [
              Icon(Icons.image_rounded, color: AppColors.primary),
              SizedBox(width: 8),
              Text(
                'Sampul Buku',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: AppColors.textDark,
                ),
              ),
            ],
          ),
          const Divider(height: 26),
          Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: GestureDetector(
              onTap: () => openUrl(current.coverUrl!),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: Image.network(
                  current.imageUrl,
                  height: 240,
                  fit: BoxFit.cover,
                  loadingBuilder: (context, child, progress) {
                    if (progress == null) return child;
                    return const SizedBox(
                      height: 240,
                      child: Center(child: CircularProgressIndicator()),
                    );
                  },
                  errorBuilder: (_, __, ___) => const SizedBox(
                    height: 120,
                    child: Center(
                      child: Icon(Icons.broken_image_rounded,
                          size: 48, color: AppColors.textGrey),
                    ),
                  ),
                ),
              ),
            ),
          ),
          AttachmentTile(
            fileName: current.coverName ?? 'sampul.jpg',
            subtitle: 'Ketuk untuk membuka sampul',
            onTap: () => openUrl(current.coverUrl!),
            trailing: const Icon(Icons.open_in_new_rounded,
                color: AppColors.primary),
          ),
        ],
      ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  final String label;
  final String value;
  final Color? valueColor;

  const _DetailRow({
    required this.label,
    required this.value,
    this.valueColor,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 115,
            child: Text(
              label,
              style: const TextStyle(color: AppColors.textGrey),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: TextStyle(
                fontWeight: FontWeight.w600,
                color: valueColor ?? AppColors.textDark,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _CircleButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;

  const _CircleButton({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white.withValues(alpha: 0.2),
      shape: const CircleBorder(),
      child: IconButton(
        icon: Icon(icon, color: Colors.white),
        onPressed: onTap,
      ),
    );
  }
}

class _Label extends StatelessWidget {
  final String text;

  const _Label({required this.text});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        text,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 12,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
