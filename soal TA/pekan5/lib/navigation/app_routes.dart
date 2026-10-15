import 'package:flutter/material.dart';

import '../pages/halaman_detail_layanan.dart';
import '../pages/halaman_pengaturan_kota.dart';
import '../pages/halaman_riwayat_laporan.dart';
import '../pages/halaman_tentang_aplikasi.dart';
import 'kerangka_navigasi.dart';

class AppRoutes {
  static const String beranda = '/';
  static const String pengaturanKota = '/pengaturan-kota';
  static const String tentangAplikasi = '/tentang-aplikasi';
  static const String riwayatLaporan = '/riwayat-laporan';
  static const String detailLayanan = '/detail-layanan';

  static Map<String, WidgetBuilder> daftarRoute() {
    return {
      beranda: (context) => const KerangkaNavigasi(),
      pengaturanKota: (context) => const HalamanPengaturanKota(),
      tentangAplikasi: (context) => const HalamanTentangAplikasi(),
      riwayatLaporan: (context) => const HalamanRiwayatLaporan(),
    };
  }

  static Route<dynamic>? bentukRoute(RouteSettings settings) {
    if (settings.name == detailLayanan) {
      final data = settings.arguments as Map<String, String>?;

      return MaterialPageRoute(
        builder: (context) => HalamanDetailLayanan(
          namaLayanan: data?['namaLayanan'] ?? 'Layanan Tidak Diketahui',
          dinas: data?['dinas'] ?? 'Dinas Tidak Diketahui',
          jamOperasional: data?['jamOperasional'] ?? 'Tidak tersedia',
          keterangan: data?['keterangan'] ?? 'Tidak ada keterangan.',
        ),
      );
    }

    return null;
  }

  static Route<dynamic> routeTidakDikenal(RouteSettings settings) {
    return MaterialPageRoute(
      builder: (context) {
        return Scaffold(
          appBar: AppBar(
            title: const Text('Route Tidak Ditemukan'),
          ),
          body: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  Icons.error_outline,
                  size: 70,
                  color: Colors.red,
                ),
                const SizedBox(height: 16),
                const Text(
                  'Halaman Tidak Ditemukan',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Route "${settings.name}" tidak terdaftar.',
                ),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: () {
                    Navigator.pushNamedAndRemoveUntil(
                      context,
                      AppRoutes.beranda,
                      (route) => false,
                    );
                  },
                  child: const Text('Kembali ke Beranda'),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}