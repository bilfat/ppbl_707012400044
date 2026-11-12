import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/constants/sensor_config.dart';
import '../../../data/helpers/pengaturan_helper.dart';

class PengaturanCubit extends Cubit<Map<JenisSensor, AmbangBatas>> {
  PengaturanCubit(this._helper) : super(const {});

  final PengaturanHelper _helper;

  Future<void> muatPengaturan() async {
    final hasil = <JenisSensor, AmbangBatas>{};

    for (final jenis in JenisSensor.values) {
      hasil[jenis] = await _helper.ambangUntuk(jenis);
    }

    emit(Map.unmodifiable(hasil));
  }

  Future<void> simpan({
    required JenisSensor jenis,
    required double waspada,
    required double siaga,
  }) async {
    await _helper.simpanAmbangBatas(
      jenis: jenis,
      waspada: waspada,
      siaga: siaga,
    );

    final hasil = Map<JenisSensor, AmbangBatas>.from(state);
    hasil[jenis] = AmbangBatas(waspada: waspada, siaga: siaga);
    emit(Map.unmodifiable(hasil));
  }

  Future<void> resetKeDefault() async {
    await _helper.resetAmbangBatas();
    await muatPengaturan();
  }
}
