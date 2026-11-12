import 'package:hive_flutter/hive_flutter.dart';

import '../models/pembacaan_sensor.dart';

class HiveHelper {
  HiveHelper._();

  static final HiveHelper instance = HiveHelper._();

  late Box<PembacaanSensor> pembacaanSensorBox;

  Future<void> init() async {
    await Hive.initFlutter();

    if (!Hive.isAdapterRegistered(0)) {
      Hive.registerAdapter(PembacaanSensorAdapter());
    }

    pembacaanSensorBox = await Hive.openBox<PembacaanSensor>(
      'pembacaanSensorBox',
    );
  }
}
