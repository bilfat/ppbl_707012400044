import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../cubit/pengajuan_cubit.dart';

class HalamanDetailLayanan extends StatefulWidget {
  const HalamanDetailLayanan({
    super.key,
    required this.namaLayanan,
    required this.dinas,
    required this.jamOperasional,
    required this.keterangan,
  });

  final String namaLayanan;
  final String dinas;
  final String jamOperasional;
  final String keterangan;

  @override
  State<HalamanDetailLayanan> createState() => _HalamanDetailLayananState();
}

class _HalamanDetailLayananState extends State<HalamanDetailLayanan> {
  bool _sedangMengirim = false;

  Future<void> _ajukanPermohonan() async {
    if (_sedangMengirim) return;
    setState(() => _sedangMengirim = true);

    // Simulasi proses pengiriman sebelum data masuk ke state pengajuan.
    await Future<void>.delayed(const Duration(milliseconds: 900));
    if (!mounted) return;

    context.read<PengajuanCubit>().tambah({
      'namaLayanan': widget.namaLayanan,
      'dinas': widget.dinas,
      'jamOperasional': widget.jamOperasional,
      'keterangan': widget.keterangan,
    });

    Navigator.pop(context, 'Permohonan ${widget.namaLayanan} berhasil ditambahkan ke daftar pengajuan');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Detail Layanan')),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(widget.namaLayanan, style: const TextStyle(fontSize: 26, fontWeight: FontWeight.bold)),
            const SizedBox(height: 24),
            _informasi(Icons.account_balance, 'Dinas Penanggung Jawab', widget.dinas),
            _informasi(Icons.access_time, 'Jam Operasional', widget.jamOperasional),
            _informasi(Icons.info_outline, 'Keterangan', widget.keterangan),
            const Spacer(),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _sedangMengirim ? null : _ajukanPermohonan,
                icon: _sedangMengirim
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.send),
                label: Text(_sedangMengirim ? 'Sedang mengirim...' : 'Ajukan Permohonan'),
              ),
            ),
            const SizedBox(height: 8),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton(
                onPressed: _sedangMengirim ? null : () => Navigator.pop(context),
                child: const Text('Kembali'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _informasi(IconData icon, String judul, String isi) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(judul, style: const TextStyle(fontWeight: FontWeight.bold)),
                const SizedBox(height: 4),
                Text(isi),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
