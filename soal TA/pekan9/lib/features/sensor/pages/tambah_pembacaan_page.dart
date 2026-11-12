import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/constants/sensor_config.dart';
import '../../../data/models/pembacaan_sensor.dart';
import '../cubit/sensor_cubit.dart';

class TambahPembacaanPage extends StatefulWidget {
  const TambahPembacaanPage({super.key});

  @override
  State<TambahPembacaanPage> createState() => _TambahPembacaanPageState();
}

class _TambahPembacaanPageState extends State<TambahPembacaanPage> {
  final _formKey = GlobalKey<FormState>();
  final _nilaiController = TextEditingController();
  final _lokasiController = TextEditingController();

  JenisSensor _jenisSensor = JenisSensor.ketinggianAir;

  @override
  void dispose() {
    _nilaiController.dispose();
    _lokasiController.dispose();
    super.dispose();
  }

  Future<void> _simpan() async {
    if (!_formKey.currentState!.validate()) return;

    final pembacaan = PembacaanSensor(
      id: DateTime.now().microsecondsSinceEpoch.toString(),
      jenisSensor: _jenisSensor.key,
      nilai: double.parse(_nilaiController.text.trim()),
      lokasiPos: _lokasiController.text.trim(),
      waktu: DateTime.now(),
    );

    await context.read<SensorCubit>().tambahPembacaan(pembacaan);

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Pembacaan sensor berhasil disimpan.')),
      );
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Input Pembacaan Sensor')),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            const Text(
              'Masukkan data pembacaan sensor. Data akan disimpan ke Hive '
              'beserta waktu pencatatannya.',
            ),
            const SizedBox(height: 20),
            DropdownButtonFormField<JenisSensor>(
              value: _jenisSensor,
              decoration: const InputDecoration(
                labelText: 'Jenis Sensor',
                prefixIcon: Icon(Icons.sensors),
              ),
              items: JenisSensor.values.map((jenis) {
                return DropdownMenuItem(
                  value: jenis,
                  child: Text(jenis.label),
                );
              }).toList(),
              onChanged: (value) {
                if (value != null) setState(() => _jenisSensor = value);
              },
            ),
            const SizedBox(height: 14),
            TextFormField(
              controller: _nilaiController,
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
              ),
              decoration: InputDecoration(
                labelText: 'Nilai Pembacaan',
                suffixText: _jenisSensor.unit,
                prefixIcon: const Icon(Icons.analytics_outlined),
              ),
              validator: (value) {
                final parsed = double.tryParse((value ?? '').trim());
                if (parsed == null || parsed < 0) {
                  return 'Masukkan angka yang valid dan tidak negatif.';
                }
                return null;
              },
            ),
            const SizedBox(height: 14),
            TextFormField(
              controller: _lokasiController,
              decoration: const InputDecoration(
                labelText: 'Lokasi Pos Pemantauan',
                prefixIcon: Icon(Icons.location_on_outlined),
                hintText: 'Contoh: Pos Sungai A',
              ),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Lokasi pos pemantauan wajib diisi.';
                }
                return null;
              },
            ),
            const SizedBox(height: 22),
            FilledButton.icon(
              onPressed: _simpan,
              icon: const Icon(Icons.save),
              label: const Text('Simpan Pembacaan'),
            ),
          ],
        ),
      ),
    );
  }
}
