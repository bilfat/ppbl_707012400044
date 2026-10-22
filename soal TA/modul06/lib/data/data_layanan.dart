import '../models/layanan.dart';

const daftarLayanan = <Layanan>[
  Layanan(
    id: 'izin-ktp',
    nama: 'Pengurusan KTP',
    bidang: 'Perizinan',
    deskripsi: 'Informasi dan pengajuan administrasi Kartu Tanda Penduduk.',
    icon: IconDataPlaceholder.document,
  ),
  Layanan(
    id: 'izin-usaha',
    nama: 'Izin Usaha Mikro',
    bidang: 'Perizinan',
    deskripsi: 'Layanan informasi pengurusan izin usaha mikro.',
    icon: IconDataPlaceholder.document,
  ),
  Layanan(
    id: 'konsultasi',
    nama: 'Konsultasi Kesehatan',
    bidang: 'Kesehatan',
    deskripsi: 'Informasi konsultasi kesehatan untuk warga.',
    icon: IconDataPlaceholder.health,
  ),
  Layanan(
    id: 'vaksin',
    nama: 'Jadwal Vaksinasi',
    bidang: 'Kesehatan',
    deskripsi: 'Informasi jadwal dan lokasi vaksinasi.',
    icon: IconDataPlaceholder.health,
  ),
  Layanan(
    id: 'angkutan',
    nama: 'Informasi Transportasi',
    bidang: 'Transportasi',
    deskripsi: 'Informasi rute dan layanan transportasi umum.',
    icon: IconDataPlaceholder.transport,
  ),
  Layanan(
    id: 'uji-kendaraan',
    nama: 'Uji Kelayakan Kendaraan',
    bidang: 'Transportasi',
    deskripsi: 'Informasi persyaratan uji kelayakan kendaraan.',
    icon: IconDataPlaceholder.transport,
  ),
];
