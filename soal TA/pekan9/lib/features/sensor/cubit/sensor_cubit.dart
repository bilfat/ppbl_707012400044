import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hive/hive.dart';

import '../../../data/models/pembacaan_sensor.dart';

class SensorCubit extends Cubit<List<PembacaanSensor>> {
  SensorCubit(this._box) : super(const []);

  final Box<PembacaanSensor> _box;

  List<PembacaanSensor> _dataTerbaru() {
    final data = _box.values.toList()
      ..sort((a, b) => b.waktu.compareTo(a.waktu));
    return data;
  }

  Future<void> muatRiwayat() async {
    emit(_dataTerbaru());
  }

  Future<void> tambahPembacaan(PembacaanSensor pembacaan) async {
    await _box.put(pembacaan.id, pembacaan);
    emit(_dataTerbaru());
  }

  Future<void> koreksiNilai({
    required String id,
    required double nilaiBaru,
  }) async {
    final dataLama = _box.get(id);
    if (dataLama == null) return;

    final dataDiperbarui = PembacaanSensor(
      id: dataLama.id,
      jenisSensor: dataLama.jenisSensor,
      nilai: nilaiBaru,
      lokasiPos: dataLama.lokasiPos,
      waktu: dataLama.waktu,
    );

    await _box.put(id, dataDiperbarui);
    emit(_dataTerbaru());
  }

  Future<void> hapusPembacaan(String id) async {
    await _box.delete(id);
    emit(_dataTerbaru());
  }
}
