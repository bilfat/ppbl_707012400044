class Layanan {
  final String id;
  final String nama;
  final String bidang;
  final String deskripsi;
  final IconDataPlaceholder icon;

  const Layanan({
    required this.id,
    required this.nama,
    required this.bidang,
    required this.deskripsi,
    required this.icon,
  });
}

// Placeholder tipe ikon agar model tidak bergantung pada Material.
// Ikon aktual dipetakan melalui nama bidang di halaman.
enum IconDataPlaceholder { document, health, transport }
