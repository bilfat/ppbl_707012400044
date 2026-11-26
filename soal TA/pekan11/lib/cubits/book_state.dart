import '../models/book.dart';

// ============================================================
// STATE BUKU
// ============================================================
class BookState {
  final List<Book> books; // daftar buku
  final bool isLoading; // sedang memuat daftar buku
  final bool isSaving; // sedang tambah / ubah / hapus buku
  final String? errorText; // error saat memuat daftar (tampil di layar)
  final String? message; // pesan untuk SnackBar
  final bool isError; // true = pesan error (merah)

  const BookState({
    this.books = const [],
    this.isLoading = false,
    this.isSaving = false,
    this.errorText,
    this.message,
    this.isError = false,
  });
}
