import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/constants/sensor_config.dart';
import '../cubit/pengaturan_cubit.dart';

class PengaturanPage extends StatelessWidget {
  const PengaturanPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<PengaturanCubit, Map<JenisSensor, AmbangBatas>>(
      builder: (context, pengaturan) {
        if (pengaturan.length != JenisSensor.values.length) {
          return const Center(child: CircularProgressIndicator());
        }

        return ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(Icons.info_outline, color: Color(0xFF145DA0)),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        'Atur nilai ambang Waspada dan Siaga untuk setiap sensor. '
                        'Pengaturan disimpan menggunakan SharedPreferences.',
                      ),
                    ),
                  ],
                ),
              ),
            ),
            for (final jenis in JenisSensor.values)
              _FormAmbangBatas(
                key: ValueKey(jenis.key),
                jenis: jenis,
                ambang: pengaturan[jenis]!,
                onSimpan: (waspada, siaga) async {
                  try {
                    await context.read<PengaturanCubit>().simpan(
                          jenis: jenis,
                          waspada: waspada,
                          siaga: siaga,
                        );
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            'Ambang ${jenis.label} berhasil disimpan.',
                          ),
                        ),
                      );
                    }
                  } catch (error) {
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Gagal menyimpan: $error')),
                      );
                    }
                  }
                },
              ),
            const SizedBox(height: 8),
            OutlinedButton.icon(
              onPressed: () async {
                await context.read<PengaturanCubit>().resetKeDefault();
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Ambang batas dikembalikan ke nilai awal.'),
                    ),
                  );
                }
              },
              icon: const Icon(Icons.restart_alt),
              label: const Text('Kembalikan Nilai Awal'),
            ),
          ],
        );
      },
    );
  }
}

class _FormAmbangBatas extends StatefulWidget {
  const _FormAmbangBatas({
    super.key,
    required this.jenis,
    required this.ambang,
    required this.onSimpan,
  });

  final JenisSensor jenis;
  final AmbangBatas ambang;
  final Future<void> Function(double waspada, double siaga) onSimpan;

  @override
  State<_FormAmbangBatas> createState() => _FormAmbangBatasState();
}

class _FormAmbangBatasState extends State<_FormAmbangBatas> {
  late final TextEditingController _waspadaController;
  late final TextEditingController _siagaController;
  String? _error;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    _waspadaController = TextEditingController(
      text: widget.ambang.waspada.toString(),
    );
    _siagaController = TextEditingController(
      text: widget.ambang.siaga.toString(),
    );
  }

  @override
  void didUpdateWidget(covariant _FormAmbangBatas oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.ambang.waspada != widget.ambang.waspada) {
      _waspadaController.text = widget.ambang.waspada.toString();
    }
    if (oldWidget.ambang.siaga != widget.ambang.siaga) {
      _siagaController.text = widget.ambang.siaga.toString();
    }
  }

  @override
  void dispose() {
    _waspadaController.dispose();
    _siagaController.dispose();
    super.dispose();
  }

  Future<void> _simpan() async {
    final waspada = double.tryParse(_waspadaController.text.trim());
    final siaga = double.tryParse(_siagaController.text.trim());

    if (waspada == null || siaga == null || waspada < 0 || siaga < 0) {
      setState(() => _error = 'Masukkan angka valid dan tidak negatif.');
      return;
    }

    if (waspada >= siaga) {
      setState(() => _error = 'Nilai Waspada harus lebih kecil dari Siaga.');
      return;
    }

    setState(() {
      _error = null;
      _saving = true;
    });

    try {
      await widget.onSimpan(waspada, siaga);
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              widget.jenis.label,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              '${widget.jenis.deskripsi} Satuan: ${widget.jenis.unit}.',
              style: Theme.of(context).textTheme.bodySmall,
            ),
            const SizedBox(height: 14),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _waspadaController,
                    keyboardType: const TextInputType.numberWithOptions(
                      decimal: true,
                    ),
                    decoration: InputDecoration(
                      labelText: 'Waspada (${widget.jenis.unit})',
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: TextField(
                    controller: _siagaController,
                    keyboardType: const TextInputType.numberWithOptions(
                      decimal: true,
                    ),
                    decoration: InputDecoration(
                      labelText: 'Siaga (${widget.jenis.unit})',
                    ),
                  ),
                ),
              ],
            ),
            if (_error != null) ...[
              const SizedBox(height: 8),
              Text(
                _error!,
                style: const TextStyle(color: Colors.red),
              ),
            ],
            const SizedBox(height: 12),
            Align(
              alignment: Alignment.centerRight,
              child: FilledButton.icon(
                onPressed: _saving ? null : _simpan,
                icon: const Icon(Icons.save),
                label: Text(_saving ? 'Menyimpan...' : 'Simpan Ambang'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
