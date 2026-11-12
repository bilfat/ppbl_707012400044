import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';

import '../../../core/constants/sensor_config.dart';
import '../../../data/models/pembacaan_sensor.dart';
import '../../sensor/cubit/sensor_cubit.dart';
import '../../../widgets/status_siaga_badge.dart';

class RiwayatSensorPage extends StatelessWidget {
  const RiwayatSensorPage({super.key});

  Future<bool> _konfirmasiHapus(
    BuildContext context,
    PembacaanSensor pembacaan,
  ) async {
    return await showDialog<bool>(
          context: context,
          builder: (dialogContext) => AlertDialog(
            title: const Text('Hapus pembacaan?'),
            content: const Text(
              'Data pembacaan ini akan dihapus dari riwayat lokal.',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(dialogContext, false),
                child: const Text('Batal'),
              ),
              FilledButton(
                onPressed: () => Navigator.pop(dialogContext, true),
                child: const Text('Hapus'),
              ),
            ],
          ),
        ) ??
        false;
  }

  Future<void> _ubahNilai(
    BuildContext context,
    PembacaanSensor pembacaan,
  ) async {
    final controller = TextEditingController(
      text: pembacaan.nilai.toString(),
    );
    String? error;

    final nilaiBaru = await showDialog<double>(
      context: context,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (dialogContext, setDialogState) {
            return AlertDialog(
              title: const Text('Koreksi Nilai Sensor'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Jenis sensor: ${jenisSensorDariKey(pembacaan.jenisSensor).label}',
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: controller,
                    keyboardType: const TextInputType.numberWithOptions(
                      decimal: true,
                    ),
                    decoration: InputDecoration(
                      labelText: 'Nilai baru',
                      suffixText:
                          jenisSensorDariKey(pembacaan.jenisSensor).unit,
                      errorText: error,
                    ),
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(dialogContext),
                  child: const Text('Batal'),
                ),
                FilledButton(
                  onPressed: () {
                    final value = double.tryParse(controller.text.trim());
                    if (value == null || value < 0) {
                      setDialogState(() {
                        error = 'Masukkan angka valid dan tidak negatif.';
                      });
                      return;
                    }
                    Navigator.pop(dialogContext, value);
                  },
                  child: const Text('Simpan'),
                ),
              ],
            );
          },
        );
      },
    );

    controller.dispose();

    if (nilaiBaru != null && context.mounted) {
      await context.read<SensorCubit>().koreksiNilai(
            id: pembacaan.id,
            nilaiBaru: nilaiBaru,
          );
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Nilai pembacaan berhasil dikoreksi.')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<SensorCubit, List<PembacaanSensor>>(
      builder: (context, readings) {
        if (readings.isEmpty) {
          return const Center(
            child: Padding(
              padding: EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.history, size: 56, color: Colors.grey),
                  SizedBox(height: 12),
                  Text(
                    'Belum ada riwayat pembacaan sensor.',
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: 6),
                  Text(
                    'Tambahkan data melalui Input Manual atau Simulasi Sensor.',
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.all(12),
          itemCount: readings.length,
          itemBuilder: (context, index) {
            final item = readings[index];
            final jenis = jenisSensorDariKey(item.jenisSensor);

            return Dismissible(
              key: ValueKey(item.id),
              direction: DismissDirection.endToStart,
              background: Container(
                margin: const EdgeInsets.symmetric(vertical: 6),
                padding: const EdgeInsets.only(right: 20),
                alignment: Alignment.centerRight,
                decoration: BoxDecoration(
                  color: Colors.red,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: const Icon(Icons.delete, color: Colors.white),
              ),
              confirmDismiss: (_) => _konfirmasiHapus(context, item),
              onDismissed: (_) {
                context.read<SensorCubit>().hapusPembacaan(item.id);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Riwayat berhasil dihapus.')),
                );
              },
              child: Card(
                child: Padding(
                  padding: const EdgeInsets.all(14),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Icon(
                            Icons.sensors,
                            color: Color(0xFF145DA0),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              jenis.label,
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          StatusSiagaBadge(
                            jenis: jenis,
                            nilai: item.nilai,
                          ),
                          PopupMenuButton<String>(
                            onSelected: (value) {
                              if (value == 'edit') _ubahNilai(context, item);
                              if (value == 'delete') {
                                _konfirmasiHapus(context, item).then((yes) {
                                  if (yes && context.mounted) {
                                    context
                                        .read<SensorCubit>()
                                        .hapusPembacaan(item.id);
                                  }
                                });
                              }
                            },
                            itemBuilder: (_) => const [
                              PopupMenuItem(
                                value: 'edit',
                                child: Text('Koreksi nilai'),
                              ),
                              PopupMenuItem(
                                value: 'delete',
                                child: Text('Hapus'),
                              ),
                            ],
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        '${item.nilai.toStringAsFixed(1)} ${jenis.unit}',
                        style: const TextStyle(
                          fontSize: 23,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text('Lokasi: ${item.lokasiPos}'),
                      const SizedBox(height: 4),
                      Text(
                        DateFormat('dd MMM yyyy, HH:mm:ss').format(item.waktu),
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }
}
