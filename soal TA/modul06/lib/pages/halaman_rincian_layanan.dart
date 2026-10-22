import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../cubit/pengajuan_cubit.dart';
import '../models/layanan.dart';

class HalamanRincianLayanan extends StatefulWidget {
  final Layanan layanan;
  const HalamanRincianLayanan({super.key, required this.layanan});

  @override
  State<HalamanRincianLayanan> createState() => _HalamanRincianLayananState();
}

class _HalamanRincianLayananState extends State<HalamanRincianLayanan> {
  bool _sedangMengirim = false;

  Future<void> _ajukan() async {
    if (_sedangMengirim) return;
    setState(() => _sedangMengirim = true);

    // Simulasi proses pengiriman sebelum data dicatat ke Cubit.
    await Future<void>.delayed(const Duration(milliseconds: 900));
    if (!mounted) return;

    context.read<PengajuanCubit>().tambah(widget.layanan.nama);
    setState(() => _sedangMengirim = false);

    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('${widget.layanan.nama} ditambahkan ke pengajuan')),
    );
    Navigator.pop(context, widget.layanan.nama);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(title: const Text('Rincian Layanan')),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Icon(Icons.account_balance_outlined,
              size: 64, color: theme.colorScheme.primary),
          const SizedBox(height: 20),
          Text(widget.layanan.nama, style: theme.textTheme.headlineSmall),
          const SizedBox(height: 8),
          Chip(label: Text(widget.layanan.bidang)),
          const SizedBox(height: 16),
          Text(widget.layanan.deskripsi, style: theme.textTheme.bodyLarge),
          const SizedBox(height: 28),
          FilledButton.icon(
            onPressed: _sedangMengirim ? null : _ajukan,
            icon: _sedangMengirim
                ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(Icons.send),
            label: Text(_sedangMengirim ? 'Mengirim permohonan...' : 'Ajukan Permohonan'),
          ),
        ],
      ),
    );
  }
}
