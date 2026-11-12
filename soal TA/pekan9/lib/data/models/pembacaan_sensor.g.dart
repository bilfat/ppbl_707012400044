// GENERATED CODE - DO NOT MODIFY BY HAND
// Adapter Hive ditulis/disertakan agar proyek dapat langsung dijalankan.
// Jika model diubah, sesuaikan adapter ini atau jalankan build_runner.

part of 'pembacaan_sensor.dart';

class PembacaanSensorAdapter extends TypeAdapter<PembacaanSensor> {
  @override
  final int typeId = 0;

  @override
  PembacaanSensor read(BinaryReader reader) {
    final fieldCount = reader.readByte();
    final fields = <int, dynamic>{};

    for (var i = 0; i < fieldCount; i++) {
      final fieldNumber = reader.readByte();
      fields[fieldNumber] = reader.read();
    }

    return PembacaanSensor(
      id: fields[0] as String,
      jenisSensor: fields[1] as String,
      nilai: (fields[2] as num).toDouble(),
      lokasiPos: fields[3] as String,
      waktu: fields[4] as DateTime,
    );
  }

  @override
  void write(BinaryWriter writer, PembacaanSensor obj) {
    writer
      ..writeByte(5)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.jenisSensor)
      ..writeByte(2)
      ..write(obj.nilai)
      ..writeByte(3)
      ..write(obj.lokasiPos)
      ..writeByte(4)
      ..write(obj.waktu);
  }
}
