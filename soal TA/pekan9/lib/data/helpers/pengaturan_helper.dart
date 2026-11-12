import 'package:shared_preferences/shared_preferences.dart';

import '../../core/constants/sensor_config.dart';

class PengaturanHelper {
  PengaturanHelper._();

  static final PengaturanHelper instance = PengaturanHelper._();

  late SharedPreferences _preferences;

  Future<void> init() async {
    _preferences = await SharedPreferences.getInstance();
  }

  String _key(JenisSensor jenis, String kategori) {
    return 'ambang_${jenis.key}_$kategori';
  }

  Future<AmbangBatas> ambangUntuk(JenisSensor jenis) async {
    final waspada = _preferences.getDouble(_key(jenis, 'waspada')) ??
        jenis.defaultWaspada;
    final siaga = _preferences.getDouble(_key(jenis, 'siaga')) ??
        jenis.defaultSiaga;

    return AmbangBatas(waspada: waspada, siaga: siaga);
  }

  Future<void> simpanAmbangBatas({
    required JenisSensor jenis,
    required double waspada,
    required double siaga,
  }) async {
    if (waspada < 0 || siaga < 0 || waspada >= siaga) {
      throw ArgumentError(
        'Nilai Waspada harus positif dan lebih kecil daripada nilai Siaga.',
      );
    }

    await _preferences.setDouble(_key(jenis, 'waspada'), waspada);
    await _preferences.setDouble(_key(jenis, 'siaga'), siaga);
  }

  Future<void> resetAmbangBatas() async {
    for (final jenis in JenisSensor.values) {
      await _preferences.remove(_key(jenis, 'waspada'));
      await _preferences.remove(_key(jenis, 'siaga'));
    }
  }
}
