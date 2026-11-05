class Layanan {
  final String Lokasi;
  final String namaTanaman;
  final String kelembapanTanah;
  final String suhuUdara;

  final String kelembapaUdara;
  final String namaOperator;


  const Layanan({
    required this.Lokasi,
    required this.namaTanaman,
    required this.kelembapanTanah,
    required this.suhuUdara,
    required this.kelembapaUdara,
    required this.namaOperator,
  });
}

// Placeholder tipe ikon agar model tidak bergantung pada Material.
// Ikon aktual dipetakan melalui nama bidang di halaman.
enum IconDataPlaceholder { document, health, transport }
