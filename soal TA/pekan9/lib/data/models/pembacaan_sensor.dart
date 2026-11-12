import 'package:hive/hive.dart';

part 'pembacaan_sensor.g.dart';

@HiveType(typeId: 0)
class PembacaanSensor extends HiveObject {
  PembacaanSensor({
    required this.id,
    required this.jenisSensor,
    required this.nilai,
    required this.lokasiPos,
    required this.waktu,
  });

  @HiveField(0)
  final String id;

  // Menyimpan key enum, misalnya: ketinggianAir, pergeseranTanah, curahHujan.
  @HiveField(1)
  final String jenisSensor;

  @HiveField(2)
  final double nilai;

  @HiveField(3)
  final String lokasiPos;

  @HiveField(4)
  final DateTime waktu;
}
