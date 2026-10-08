import 'package:flutter/material.dart';

import '../models/pengajuan_model.dart';

class DetailPengajuanPage extends StatelessWidget {
  final Pengajuan pengajuan;

  const DetailPengajuanPage({
    super.key,
    required this.pengajuan,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Detail Pengajuan'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Card(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Detail Pengajuan',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 20),

                Text('Nama: ${pengajuan.nama}'),
                const SizedBox(height: 10),

                Text('Email: ${pengajuan.email}'),
                const SizedBox(height: 10),

                Text('Bidang: ${pengajuan.bidang}'),
                const SizedBox(height: 10),

                Text('Sesi: ${pengajuan.sesi}'),
                const SizedBox(height: 10),

                Text(
                  'Status: ${pengajuan.selesai ? 'Selesai' : 'Sedang Diproses'}',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: pengajuan.selesai
                        ? Colors.green
                        : Colors.orange,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}