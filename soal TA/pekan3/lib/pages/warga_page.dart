import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/favorit_model.dart';
import 'layanan_page.dart';

class WargaPage extends StatelessWidget {
  const WargaPage({super.key});

  static const semuaLayanan = [
    ...LayananPage.layananPerizinan,
    ...LayananPage.layananKesehatan,
    ...LayananPage.layananTransportasi,
  ];

  @override
  Widget build(BuildContext context) {
    return Consumer<FavoritModel>(
      builder: (
        context,
        favorit,
        child,
      ) {
        final daftarFavorit =
            semuaLayanan
                .where(
                  (layanan) =>
                      favorit.isFavorit(
                    layanan.nama,
                  ),
                )
                .toList();

        return ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Text(
              'Data Warga',
              style: Theme.of(context)
                  .textTheme
                  .headlineSmall,
            ),

            const SizedBox(height: 8),

            const Text(
              'Kelola layanan favorit dan '
              'pengajuan Anda.',
            ),

            const SizedBox(height: 24),

            const Text(
              'Layanan Favorit',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 12),

            if (daftarFavorit.isEmpty)
              const Card(
                child: Padding(
                  padding: EdgeInsets.all(24),
                  child: Column(
                    children: [
                      Icon(
                        Icons.star_border,
                        size: 50,
                      ),
                      SizedBox(height: 12),
                      Text(
                        'Belum ada layanan favorit',
                      ),
                    ],
                  ),
                ),
              ),

            ...daftarFavorit.map(
              (layanan) {
                return Card(
                  child: ListTile(
                    leading: CircleAvatar(
                      child: Icon(
                        layanan.ikon,
                      ),
                    ),
                    title: Text(
                      layanan.nama,
                    ),
                    subtitle: Text(
                      layanan.kategori,
                    ),
                    trailing: const Icon(
                      Icons.star,
                      color: Colors.amber,
                    ),
                    onTap: () {
                      Navigator.pushNamed(
                        context,
                        '/detail',
                        arguments: layanan,
                      );
                    },
                  ),
                );
              },
            ),
          ],
        );
      },
    );
  }
}