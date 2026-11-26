// ============================================================
// MODEL BOOK (BUKU SIPUSTAKA)
// ============================================================
// Contoh JSON dari API (tabel books di Laravel):
// {
//   "id": 1,
//   "judul": "Pemrograman Web Modern",
//   "penulis": "Budi Santoso",
//   "penerbit": "Informatika",
//   "tahun_terbit": 2024,
//   "stok": 5,
//   "cover_name": "cover.jpg",
//   "cover_url": "http://10.66.184.110:8000/api/books/1/cover",
//   "created_at": "2026-11-26T10:00:00.000000Z",
//   "updated_at": "2026-11-26T10:00:00.000000Z"
// }
class Book {
  final int id;
  final String judul;
  final String penulis;
  final String penerbit;
  final int tahunTerbit;
  final int stok;
  final String? coverName;
  final String? coverUrl;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  Book({
    required this.id,
    required this.judul,
    required this.penulis,
    required this.penerbit,
    required this.tahunTerbit,
    required this.stok,
    this.coverName,
    this.coverUrl,
    this.createdAt,
    this.updatedAt,
  });

  factory Book.fromJson(Map<String, dynamic> json) {
    return Book(
      id: int.parse(json['id'].toString()),
      judul: json['judul'] ?? '',
      penulis: json['penulis'] ?? '',
      penerbit: json['penerbit'] ?? '',
      tahunTerbit: int.tryParse(json['tahun_terbit'].toString()) ?? 0,
      stok: int.tryParse(json['stok'].toString()) ?? 0,
      coverName: json['cover_name'],
      coverUrl: json['cover_url'],
      createdAt: DateTime.tryParse(json['created_at'] ?? '')?.toLocal(),
      updatedAt: DateTime.tryParse(json['updated_at'] ?? '')?.toLocal(),
    );
  }

  /// Apakah buku memiliki gambar sampul?
  bool get hasCover => coverUrl != null && coverUrl!.isNotEmpty;

  /// URL sampul + parameter versi agar cache diperbarui saat cover diganti
  String get imageUrl =>
      '$coverUrl?v=${updatedAt?.millisecondsSinceEpoch ?? id}';
}
