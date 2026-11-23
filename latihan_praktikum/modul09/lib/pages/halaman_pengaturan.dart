
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../cubit/theme_cubit.dart';
import '../helpers/pengaturan_helper.dart';

class HalamanPengaturan extends StatefulWidget {
  const HalamanPengaturan({super.key});

  @override
  State<HalamanPengaturan> createState() =>
      _HalamanPengaturanState();
}

class _HalamanPengaturanState extends State<HalamanPengaturan> {
  final controllerNama = TextEditingController();

  @override
  void initState() {
    super.initState();
    _muatPengaturan();
  }

  Future<void> _muatPengaturan() async {
    final nama = await PengaturanHelper.muatNamaPelanggan();

    if (!mounted) return;

    setState(() {
      controllerNama.text = nama;
    });
  }

  Future<void> _resetPengaturan() async {
    await PengaturanHelper.resetSemua();

    if (!mounted) return;

    context.read<ThemeCubit>().resetTema();

    setState(() {
      controllerNama.clear();
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Pengaturan berhasil direset'),
      ),
    );
  }

  @override
  void dispose() {
    controllerNama.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Pengaturan'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            BlocBuilder<ThemeCubit, ThemeMode>(
              builder: (context, themeMode) {
                final temaGelap = themeMode == ThemeMode.dark;

                return Row(
                  children: [
                    const Text('Mode Gelap'),
                    const Spacer(),
                    Switch(
                      value: temaGelap,
                      onChanged: (nilai) async {
                        await context
                            .read<ThemeCubit>()
                            .setTemaGelap(nilai);
                      },
                    ),
                  ],
                );
              },
            ),
            const SizedBox(height: 16),
            TextField(
              controller: controllerNama,
              decoration: const InputDecoration(
                labelText: 'Nama Pelanggan',
                border: OutlineInputBorder(),
              ),
              onChanged: (nilai) async {
                await PengaturanHelper
                    .simpanNamaPelanggan(nilai);
              },
            ),
            const SizedBox(height: 24),
            OutlinedButton.icon(
              onPressed: _resetPengaturan,
              icon: const Icon(Icons.restore),
              label: const Text('Reset Pengaturan'),
            ),
          ],
        ),
      ),
    );
  }
}
