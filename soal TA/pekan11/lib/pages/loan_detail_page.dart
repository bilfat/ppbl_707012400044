import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../config/app_theme.dart';
import '../cubits/book_cubit.dart';
import '../cubits/loan_cubit.dart';
import '../cubits/loan_state.dart';
import '../models/loan.dart';
import '../utils/helpers.dart';
import '../widgets/gradient_button.dart';

// ============================================================
// HALAMAN DETAIL PEMINJAMAN  (GET / PATCH / DELETE /api/loans/{id})
// ============================================================
class LoanDetailPage extends StatefulWidget {
  final Loan loan;

  const LoanDetailPage({super.key, required this.loan});

  @override
  State<LoanDetailPage> createState() => _LoanDetailPageState();
}

class _LoanDetailPageState extends State<LoanDetailPage> {
  DateTime _returnDate = DateTime.now();

  Future<void> _returnBook(Loan current) async {
    final success = await context.read<LoanCubit>().returnLoan(
          current.id,
          tanggalKembali: toApiDate(_returnDate),
        );
    if (success && mounted) {
      await context.read<BookCubit>().loadBooks();
    }
  }

  Future<void> _confirmDelete(Loan current) async {
    final yakin = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        icon: const Icon(Icons.delete_forever_rounded,
            color: AppColors.danger, size: 48),
        title: const Text('Hapus Peminjaman?'),
        content: Text(
          'Peminjaman #${current.id} akan dihapus permanen.',
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

    if (yakin != true || !mounted) return;
    final success = await context.read<LoanCubit>().deleteLoan(current.id);
    if (success && mounted) {
      await context.read<BookCubit>().loadBooks();
      if (mounted) Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<LoanCubit, LoanState>(
      builder: (context, state) {
        final current = state.loans.firstWhere(
          (l) => l.id == widget.loan.id,
          orElse: () => widget.loan,
        );
        final topPadding = MediaQuery.of(context).padding.top;
        final bookTitle = current.book?.judul ?? 'Buku #${current.bookId}';

        return Scaffold(
          body: Column(
            children: [
              // Header gradasi
              Container(
                width: double.infinity,
                padding: EdgeInsets.fromLTRB(12, topPadding + 8, 12, 26),
                decoration: const BoxDecoration(
                  gradient: AppColors.mainGradient,
                  borderRadius:
                      BorderRadius.vertical(bottom: Radius.circular(32)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Material(
                          color: Colors.white.withValues(alpha: 0.2),
                          shape: const CircleBorder(),
                          child: IconButton(
                            icon: const Icon(Icons.arrow_back_rounded,
                                color: Colors.white),
                            onPressed: () => Navigator.pop(context),
                          ),
                        ),
                        const Spacer(),
                        Material(
                          color: Colors.white.withValues(alpha: 0.2),
                          shape: const CircleBorder(),
                          child: IconButton(
                            icon: const Icon(Icons.delete_rounded,
                                color: Colors.white),
                            onPressed: () => _confirmDelete(current),
                          ),
                        ),
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
                            children: [
                              _Chip(text: 'Pinjaman #${current.id}'),
                              _Chip(text: current.status),
                            ],
                          ),
                          const SizedBox(height: 12),
                          Text(
                            bookTitle,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                              height: 1.3,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              if (state.isSaving) const LinearProgressIndicator(),
              Expanded(
                child: RefreshIndicator(
                  onRefresh: () =>
                      context.read<LoanCubit>().loadLoanDetail(current.id),
                  child: ListView(
                    padding: const EdgeInsets.all(20),
                    children: [
                      // Info peminjaman
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
                                Icon(Icons.receipt_long_rounded,
                                    color: AppColors.primary),
                                SizedBox(width: 8),
                                Text(
                                  'Detail Peminjaman',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: AppColors.textDark,
                                  ),
                                ),
                              ],
                            ),
                            const Divider(height: 26),
                            _RowInfo(label: 'Judul Buku', value: bookTitle),
                            if (current.book != null)
                              _RowInfo(
                                  label: 'Penulis',
                                  value: current.book!.penulis),
                            _RowInfo(
                              label: 'Tanggal Pinjam',
                              value: formatTanggalPendek(current.tanggalPinjam),
                            ),
                            _RowInfo(
                              label: 'Tanggal Kembali',
                              value: current.tanggalKembali != null
                                  ? formatTanggalPendek(current.tanggalKembali)
                                  : 'Belum dikembalikan',
                            ),
                            _RowInfo(
                              label: 'Status',
                              value: current.status,
                              valueColor: current.isReturned
                                  ? AppColors.success
                                  : AppColors.warning,
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Kartu pengembalian jika masih Dipinjam
                      if (!current.isReturned)
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
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              const Row(
                                children: [
                                  Icon(Icons.assignment_return_rounded,
                                      color: AppColors.primary),
                                  SizedBox(width: 8),
                                  Text(
                                    'Pengembalian Buku',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: AppColors.textDark,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 14),
                              InkWell(
                                borderRadius: BorderRadius.circular(16),
                                onTap: () async {
                                  final picked = await showDatePicker(
                                    context: context,
                                    initialDate: _returnDate,
                                    firstDate: DateTime(2020),
                                    lastDate: DateTime(2030),
                                  );
                                  if (picked != null) {
                                    setState(() => _returnDate = picked);
                                  }
                                },
                                child: Container(
                                  padding: const EdgeInsets.all(14),
                                  decoration: BoxDecoration(
                                    color: AppColors.background,
                                    borderRadius: BorderRadius.circular(16),
                                  ),
                                  child: Row(
                                    children: [
                                      const Icon(Icons.event_available_rounded,
                                          color: AppColors.primary),
                                      const SizedBox(width: 12),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            const Text(
                                              'Tanggal Kembali',
                                              style: TextStyle(
                                                fontSize: 12,
                                                color: AppColors.textGrey,
                                              ),
                                            ),
                                            Text(
                                              formatTanggalPendek(
                                                  toApiDate(_returnDate)),
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
                              const SizedBox(height: 18),
                              GradientButton(
                                text: 'Tandai Dikembalikan',
                                icon: Icons.check_circle_rounded,
                                isLoading: state.isSaving,
                                onPressed: () => _returnBook(current),
                              ),
                            ],
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _RowInfo extends StatelessWidget {
  final String label;
  final String value;
  final Color? valueColor;

  const _RowInfo({
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
            width: 125,
            child: Text(label, style: const TextStyle(color: AppColors.textGrey)),
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

class _Chip extends StatelessWidget {
  final String text;

  const _Chip({required this.text});

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
