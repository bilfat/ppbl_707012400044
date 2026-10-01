import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/pengajuan_model.dart';
import 'layanan_page.dart';

class DetailLayananPage extends StatefulWidget {
  const DetailLayananPage({super.key});

  @override
  State<DetailLayananPage> createState() =>
      _DetailLayananPageState();
}

class _DetailLayananPageState
    extends State<DetailLayananPage> {
  bool _sedangMengirim = false;

  Future<void> _ajukanPermohonan(
    Layanan layanan,
  ) async {
    setState(() {
      _sedangMengirim = true;
    });

    await Future.delayed(
      const Duration(seconds: 2),
    );

    if (!mounted) return;

    context
        .read<PengajuanModel>()
        .tambahPengajuan(
          layanan.nama,
        );

    setState(() {
      _sedangMengirim = false;
    });

    Navigator.pop(
      context,
      true,
    );
  }

  @override
  Widget build(BuildContext context) {
    final layanan =
        ModalRoute.of(context)!
                .settings
                .arguments
            as Layanan;

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Detail Layanan',
        ),
      ),

      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment:
              CrossAxisAlignment.start,
          children: [
            Center(
              child: Icon(
                layanan.ikon,
                size: 80,
              ),
            ),

            const SizedBox(height: 24),

            Text(
              layanan.nama,
              style: Theme.of(context)
                  .textTheme
                  .headlineSmall,
            ),

            const SizedBox(height: 8),

            Chip(
              label: Text(
                layanan.kategori,
              ),
            ),

            const SizedBox(height: 16),

            Text(
              layanan.deskripsi,
              style: const TextStyle(
                fontSize: 16,
              ),
            ),

            const Spacer(),

            SizedBox(
              width: double.infinity,
              child: FilledButton(
                onPressed: _sedangMengirim
                    ? null
                    : () {
                        _ajukanPermohonan(
                          layanan,
                        );
                      },
                child: _sedangMengirim
                    ? const Row(
                        mainAxisAlignment:
                            MainAxisAlignment.center,
                        children: [
                          SizedBox(
                            width: 20,
                            height: 20,
                            child:
                                CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          ),
                          SizedBox(width: 12),
                          Text(
                            'Mengirim...',
                          ),
                        ],
                      )
                    : const Text(
                        'Ajukan Permohonan',
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}