import 'package:flutter_test/flutter_test.dart';
import 'package:pekan11/models/book.dart';
import 'package:pekan11/models/loan.dart';
import 'package:pekan11/models/user.dart';

void main() {
  test('Model User, Book, dan Loan dapat parsing JSON dengan benar', () {
    final user = User.fromJson({
      'id': 1,
      'name': 'Budi Santoso',
      'email': 'budi@example.com',
    });
    expect(user.id, 1);
    expect(user.name, 'Budi Santoso');

    final book = Book.fromJson({
      'id': 10,
      'judul': 'Pemrograman Flutter',
      'penulis': 'Budi',
      'penerbit': 'Informatika',
      'tahun_terbit': 2025,
      'stok': 5,
      'cover_name': 'cover.png',
      'cover_url': 'http://127.0.0.1:8000/api/books/10/cover',
    });
    expect(book.id, 10);
    expect(book.tahunTerbit, 2025);
    expect(book.hasCover, isTrue);

    final loan = Loan.fromJson({
      'id': 3,
      'book_id': 10,
      'user_id': 1,
      'tanggal_pinjam': '2026-11-26',
      'tanggal_kembali': null,
      'status': 'Dipinjam',
      'book': {
        'id': 10,
        'judul': 'Pemrograman Flutter',
        'penulis': 'Budi',
        'penerbit': 'Informatika',
        'tahun_terbit': 2025,
        'stok': 4,
      },
    });
    expect(loan.id, 3);
    expect(loan.isReturned, isFalse);
    expect(loan.book?.judul, 'Pemrograman Flutter');
  });
}
