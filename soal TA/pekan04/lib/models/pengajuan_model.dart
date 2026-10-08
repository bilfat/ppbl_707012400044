import 'package:flutter/foundation.dart';

class Pengajuan {
  final String id;
  final String nama;
  final String email;
  final String bidang;
  final String sesi;
  bool selesai;

  Pengajuan({
    required this.id,
    required this.nama,
    required this.email,
    required this.bidang,
    required this.sesi,
    this.selesai = false,
  });
}

class PengajuanModel extends ChangeNotifier {
  final List<Pengajuan> _daftarPengajuan = [];

  List<Pengajuan> get daftarPengajuan =>
      List.unmodifiable(_daftarPengajuan);

  void tambahPengajuan(Pengajuan pengajuan) {
    _daftarPengajuan.add(pengajuan);
    notifyListeners();
  }

  void tandaiSelesai(String id) {
    final index = _daftarPengajuan.indexWhere(
      (pengajuan) => pengajuan.id == id,
    );

    if (index != -1) {
      _daftarPengajuan[index].selesai = true;
      notifyListeners();
    }
  }

  int jumlahBidang(String bidang) {
    return _daftarPengajuan
        .where((pengajuan) => pengajuan.bidang == bidang)
        .length;
  }
}