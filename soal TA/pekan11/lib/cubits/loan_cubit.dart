import 'package:flutter_bloc/flutter_bloc.dart';
import '../models/loan.dart';
import '../services/api_service.dart';
import '../utils/helpers.dart';
import 'loan_state.dart';

// ============================================================
// LOAN CUBIT (CRUD PEMINJAMAN SIPUSTAKA)
// ============================================================
// Pola setiap fungsi: loading -> try -> emit data / emit error
class LoanCubit extends Cubit<LoanState> {
  final ApiService api;

  LoanCubit(this.api) : super(const LoanState());

  /// Kosongkan daftar peminjaman (saat logout)
  void clearLoans() {
    emit(const LoanState());
  }

  /// READ: ambil daftar peminjaman milik pengguna login (GET /loans)
  Future<void> loadLoans() async {
    emit(LoanState(loans: state.loans, isLoading: true));
    try {
      final loans = await api.getLoans();
      emit(LoanState(loans: loans));
    } on ApiException catch (e) {
      emit(LoanState(loans: state.loans, errorText: e.message));
    }
  }

  /// READ: ambil satu peminjaman berdasarkan ID (GET /loans/{id})
  /// Jika bukan milik pengguna login, Laravel mengembalikan 403 Forbidden.
  Future<Loan?> loadLoanDetail(int id) async {
    emit(LoanState(loans: state.loans, isLoading: true));
    try {
      final loan = await api.getLoan(id);
      emit(LoanState(loans: _replaceLoan(loan)));
      return loan;
    } on ApiException catch (e) {
      emit(LoanState(loans: state.loans, message: e.message, isError: true));
      return null;
    }
  }

  /// CREATE: meminjam buku (POST /loans)
  Future<bool> createLoan({
    required int bookId,
    required String tanggalPinjam,
  }) async {
    emit(LoanState(loans: state.loans, isSaving: true));
    try {
      final newLoan = await api.createLoan(
        bookId: bookId,
        tanggalPinjam: tanggalPinjam,
      );
      emit(LoanState(
        loans: [newLoan, ...state.loans],
        message: 'Buku berhasil dipinjam!',
      ));
      return true;
    } on ApiException catch (e) {
      emit(LoanState(loans: state.loans, message: e.message, isError: true));
      return false;
    }
  }

  /// UPDATE: mengembalikan buku atau mengubah peminjaman (PATCH /loans/{id})
  Future<bool> updateLoan(
    int id, {
    String? status,
    String? tanggalPinjam,
    String? tanggalKembali,
  }) async {
    emit(LoanState(loans: state.loans, isSaving: true));
    try {
      final updated = await api.updateLoan(
        id,
        status: status,
        tanggalPinjam: tanggalPinjam,
        tanggalKembali: tanggalKembali,
      );
      final msg = updated.isReturned
          ? 'Buku berhasil dikembalikan'
          : 'Peminjaman berhasil diperbarui';
      emit(LoanState(
        loans: _replaceLoan(updated),
        message: msg,
      ));
      return true;
    } on ApiException catch (e) {
      emit(LoanState(loans: state.loans, message: e.message, isError: true));
      return false;
    }
  }

  /// Shortcut untuk mengubah status peminjaman menjadi "Dikembalikan"
  Future<bool> returnLoan(int id, {String? tanggalKembali}) {
    return updateLoan(
      id,
      status: 'Dikembalikan',
      tanggalKembali: tanggalKembali ?? toApiDate(DateTime.now()),
    );
  }

  /// DELETE: hapus peminjaman milik sendiri (DELETE /loans/{id})
  Future<bool> deleteLoan(int id) async {
    emit(LoanState(loans: state.loans, isSaving: true));
    try {
      await api.deleteLoan(id);
      emit(LoanState(
        loans: state.loans.where((l) => l.id != id).toList(),
        message: 'Peminjaman berhasil dihapus',
      ));
      return true;
    } on ApiException catch (e) {
      emit(LoanState(loans: state.loans, message: e.message, isError: true));
      return false;
    }
  }

  List<Loan> _replaceLoan(Loan newLoan) {
    final exists = state.loans.any((l) => l.id == newLoan.id);
    if (!exists) return [newLoan, ...state.loans];
    return state.loans.map((l) => l.id == newLoan.id ? newLoan : l).toList();
  }
}
