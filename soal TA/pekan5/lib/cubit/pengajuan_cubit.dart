import 'package:flutter_bloc/flutter_bloc.dart';

class PengajuanCubit extends Cubit<List<Map<String, String>>> {
  PengajuanCubit() : super(const []);

  int get totalPengajuan => state.length;

  void tambah(Map<String, String> layanan) {
    final nama = layanan['namaLayanan'];
    if (nama == null || state.any((item) => item['namaLayanan'] == nama)) {
      return;
    }
    emit([...state, Map<String, String>.from(layanan)]);
  }

  void hapus(String namaLayanan) {
    emit(state
        .where((item) => item['namaLayanan'] != namaLayanan)
        .map((item) => Map<String, String>.from(item))
        .toList());
  }

  void kosongkan() => emit(const []);

  void kirimSemua() => emit(const []);
}
