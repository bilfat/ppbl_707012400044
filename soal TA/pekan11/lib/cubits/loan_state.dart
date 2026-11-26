import '../models/loan.dart';

// ============================================================
// STATE PEMINJAMAN
// ============================================================
class LoanState {
  final List<Loan> loans; // daftar peminjaman milik user login
  final bool isLoading; // sedang mengambil daftar peminjaman
  final bool isSaving; // sedang pinjam / kembalikan / hapus peminjaman
  final String? errorText; // error saat memuat daftar
  final String? message; // pesan untuk SnackBar
  final bool isError; // true = pesan error (merah)

  const LoanState({
    this.loans = const [],
    this.isLoading = false,
    this.isSaving = false,
    this.errorText,
    this.message,
    this.isError = false,
  });
}
