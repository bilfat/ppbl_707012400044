import 'book.dart';

// ============================================================
// MODEL LOAN (PEMINJAMAN BUKU)
// ============================================================
// Contoh JSON dari API (tabel loans di Laravel):
// {
//   "id": 1,
//   "book_id": 2,
//   "user_id": 1,
//   "tanggal_pinjam": "2026-11-26",
//   "tanggal_kembali": null,
//   "status": "Dipinjam",
//   "book": { ... },
//   "created_at": "2026-11-26T10:00:00.000000Z",
//   "updated_at": "2026-11-26T10:00:00.000000Z"
// }
class Loan {
  final int id;
  final int bookId;
  final int userId;
  final String tanggalPinjam;
  final String? tanggalKembali;
  final String status;
  final Book? book;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  Loan({
    required this.id,
    required this.bookId,
    required this.userId,
    required this.tanggalPinjam,
    this.tanggalKembali,
    required this.status,
    this.book,
    this.createdAt,
    this.updatedAt,
  });

  factory Loan.fromJson(Map<String, dynamic> json) {
    return Loan(
      id: int.parse(json['id'].toString()),
      bookId: int.parse(json['book_id'].toString()),
      userId: int.parse(json['user_id'].toString()),
      tanggalPinjam: json['tanggal_pinjam']?.toString() ?? '',
      tanggalKembali: json['tanggal_kembali']?.toString(),
      status: json['status']?.toString() ?? 'Dipinjam',
      book: json['book'] is Map<String, dynamic>
          ? Book.fromJson(json['book'] as Map<String, dynamic>)
          : null,
      createdAt: DateTime.tryParse(json['created_at'] ?? '')?.toLocal(),
      updatedAt: DateTime.tryParse(json['updated_at'] ?? '')?.toLocal(),
    );
  }

  /// Apakah buku sudah dikembalikan?
  bool get isReturned => status == 'Dikembalikan';
}
