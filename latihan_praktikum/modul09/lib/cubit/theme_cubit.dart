
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../helpers/pengaturan_helper.dart';

class ThemeCubit extends Cubit<ThemeMode> {
  ThemeCubit() : super(ThemeMode.light);

  // Memuat tema yang sebelumnya tersimpan.
  Future<void> muatTema() async {
    final gelap = await PengaturanHelper.muatTemaGelap();
    emit(gelap ? ThemeMode.dark : ThemeMode.light);
  }

  // Mengubah sekaligus menyimpan tema.
  Future<void> setTemaGelap(bool aktif) async {
    emit(aktif ? ThemeMode.dark : ThemeMode.light);
    await PengaturanHelper.simpanTemaGelap(aktif);
  }

  // Mengganti tema melalui tombol.
  Future<void> toggle() async {
    await setTemaGelap(state != ThemeMode.dark);
  }

  // Mengembalikan tema ke kondisi awal.
  void resetTema() {
    emit(ThemeMode.light);
  }
}
