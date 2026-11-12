import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';

import '../../../core/constants/sensor_config.dart';
import '../../../data/models/pembacaan_sensor.dart';
import '../../../features/sensor/cubit/sensor_cubit.dart';
import '../../../features/sensor/pages/tambah_pembacaan_page.dart';
import '../../../widgets/status_siaga_badge.dart';

class DashboardPage extends StatelessWidget {
  const DashboardPage({super.key});

  PembacaanSensor? _terbaruUntuk(
    List<PembacaanSensor> readings,
    JenisSensor jenis,
  ) {
    for (final reading in readings) {
      if (reading.jenisSensor == jenis.key) return reading;
    }
    return null;
  }

  Future<void> _simulasikan(BuildContext context) async {
    final random = Random();
    final jenis = JenisSensor.values[random.nextInt(JenisSensor.values.length)];

    double nilai;
    switch (jenis) {
      case JenisSensor.ketinggianAir:
        nilai = random.nextDouble() * 190;
        break;
      case JenisSensor.pergeseranTanah:
        nilai = random.nextDouble() * 27;
        break;
      case JenisSensor.curahHujan:
        nilai = random.nextDouble() * 130;
        break;
    }

    final pembacaan = PembacaanSensor(
      id: DateTime.now().microsecondsSinceEpoch.toString(),
      jenisSensor: jenis.key,
      nilai: double.parse(nilai.toStringAsFixed(1)),
      lokasiPos: 'Pos Pemantauan Utama',
      waktu: DateTime.now(),
    );

    await context.read<SensorCubit>().tambahPembacaan(pembacaan);
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Pembacaan simulasi berhasil disimpan.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<SensorCubit, List<PembacaanSensor>>(
      builder: (context, readings) {
        return ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Card(
              child: Padding(
                padding: const EdgeInsets.all(18),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Row(
                      children: [
                        Icon(Icons.shield_outlined, color: Color(0xFF145DA0)),
                        SizedBox(width: 8),
                        Text(
                          'Pemantauan Sensor AIoT',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Pantau pembacaan sensor, simpan riwayat, dan periksa '
                      'status berdasarkan ambang batas yang telah diatur.',
                    ),
                    const SizedBox(height: 16),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        FilledButton.icon(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => const TambahPembacaanPage(),
                              ),
                            );
                          },
                          icon: const Icon(Icons.add),
                          label: const Text('Input Manual'),
                        ),
                        OutlinedButton.icon(
                          onPressed: () => _simulasikan(context),
                          icon: const Icon(Icons.sensors),
                          label: const Text('Simulasi Sensor'),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'Status Sensor Terbaru',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 8),
            for (final jenis in JenisSensor.values)
              _KartuSensor(
                jenis: jenis,
                pembacaan: _terbaruUntuk(readings, jenis),
              ),
            const SizedBox(height: 12),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(14),
                child: Row(
                  children: [
                    const Icon(Icons.storage, color: Color(0xFF145DA0)),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        '${readings.length} pembacaan tersimpan secara lokal menggunakan Hive.',
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}

class _KartuSensor extends StatelessWidget {
  const _KartuSensor({
    required this.jenis,
    required this.pembacaan,
  });

  final JenisSensor jenis;
  final PembacaanSensor? pembacaan;

  @override
  Widget build(BuildContext context) {
    final data = pembacaan;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.sensors, color: Color(0xFF145DA0)),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    jenis.label,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
                if (data != null)
                  StatusSiagaBadge(jenis: jenis, nilai: data.nilai),
              ],
            ),
            const SizedBox(height: 8),
            if (data == null)
              const Text('Belum ada pembacaan sensor.')
            else ...[
              Text(
                '${data.nilai.toStringAsFixed(1)} ${jenis.unit}',
                style: const TextStyle(
                  fontSize: 25,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text('Lokasi: ${data.lokasiPos}'),
              Text(
                'Waktu: ${DateFormat('dd MMM yyyy, HH:mm:ss').format(data.waktu)}',
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ],
          ],
        ),
      ),
    );
  }
}
