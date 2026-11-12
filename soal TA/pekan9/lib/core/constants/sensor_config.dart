enum JenisSensor {
  ketinggianAir,
  pergeseranTanah,
  curahHujan,
}

extension JenisSensorInfo on JenisSensor {
  String get key => name;

  String get label {
    switch (this) {
      case JenisSensor.ketinggianAir:
        return 'Ketinggian Air';
      case JenisSensor.pergeseranTanah:
        return 'Pergeseran Tanah';
      case JenisSensor.curahHujan:
        return 'Curah Hujan';
    }
  }

  String get unit {
    switch (this) {
      case JenisSensor.ketinggianAir:
        return 'cm';
      case JenisSensor.pergeseranTanah:
        return 'mm';
      case JenisSensor.curahHujan:
        return 'mm/jam';
    }
  }

  String get deskripsi {
    switch (this) {
      case JenisSensor.ketinggianAir:
        return 'Memantau kenaikan ketinggian air sungai.';
      case JenisSensor.pergeseranTanah:
        return 'Memantau perubahan posisi/pergeseran tanah.';
      case JenisSensor.curahHujan:
        return 'Memantau intensitas curah hujan.';
    }
  }

  // Nilai berikut hanya nilai awal untuk demonstrasi praktikum.
  // Ambang operasional nyata wajib ditetapkan berdasarkan kajian teknis BPBD.
  double get defaultWaspada {
    switch (this) {
      case JenisSensor.ketinggianAir:
        return 100;
      case JenisSensor.pergeseranTanah:
        return 10;
      case JenisSensor.curahHujan:
        return 50;
    }
  }

  double get defaultSiaga {
    switch (this) {
      case JenisSensor.ketinggianAir:
        return 150;
      case JenisSensor.pergeseranTanah:
        return 20;
      case JenisSensor.curahHujan:
        return 100;
    }
  }
}

JenisSensor jenisSensorDariKey(String key) {
  return JenisSensor.values.firstWhere(
    (jenis) => jenis.key == key,
    orElse: () => JenisSensor.ketinggianAir,
  );
}

class AmbangBatas {
  const AmbangBatas({
    required this.waspada,
    required this.siaga,
  });

  final double waspada;
  final double siaga;
}

enum StatusSiaga {
  aman,
  waspada,
  siaga,
}

extension StatusSiagaInfo on StatusSiaga {
  String get label {
    switch (this) {
      case StatusSiaga.aman:
        return 'Aman';
      case StatusSiaga.waspada:
        return 'Waspada';
      case StatusSiaga.siaga:
        return 'Siaga';
    }
  }
}

StatusSiaga hitungStatusSiaga(double nilai, AmbangBatas ambang) {
  if (nilai >= ambang.siaga) return StatusSiaga.siaga;
  if (nilai >= ambang.waspada) return StatusSiaga.waspada;
  return StatusSiaga.aman;
}
