import 'package:flutter/material.dart';

import '../models/pengajuan_model.dart';
import '../pages/detail_pengajuan_page.dart';
import 'kerangka_navigasi.dart';
import '../pages/pengajuan_page.dart';

class AppRoutes {
  static const String beranda = '/';
  static const String pengajuan = '/pengajuan';
  static const String detailPengajuan =
      '/detail-pengajuan';

  static Map<String, WidgetBuilder> daftarRoute() {
    return {
      beranda: (context) =>
          const KerangkaNavigasi(),

      pengajuan: (context) =>
          const PengajuanPage(),
    };
  }

  static Route<dynamic>? bentukRoute(
    RouteSettings settings,
  ) {
    if (settings.name == detailPengajuan) {
      final pengajuan =
          settings.arguments as Pengajuan;

      return MaterialPageRoute(
        builder: (context) =>
            DetailPengajuanPage(
          pengajuan: pengajuan,
        ),
      );
    }

    return null;
  }

  static Route<dynamic> routeTidakDikenal(
    RouteSettings settings,
  ) {
    return MaterialPageRoute(
      builder: (context) => Scaffold(
        appBar: AppBar(
          title: const Text('Route Tidak Ditemukan'),
        ),
        body: Center(
          child: Text(
            'Route ${settings.name} belum tersedia.',
          ),
        ),
      ),
    );
  }
}