class Kontak {
  final int? id;
  final String nama;
  final String telepon;

  const Kontak({
    this.id,
    required this.nama,
    required this.telepon,
  });

  Map<String, Object?> toMap() => {
        'nama': nama,
        'telepon': telepon,
      };

  factory Kontak.fromMap(Map<String, Object?> map) {
    return Kontak(
      id: map['id'] as int?,
      nama: map['nama'] as String,
      telepon: map['telepon'] as String,
    );
  }
}
