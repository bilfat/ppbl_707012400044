import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/favorit_model.dart';

class Layanan {
  final String nama;
  final String kategori;
  final String deskripsi;
  final IconData ikon;

  const Layanan({
    required this.nama,
    required this.kategori,
    required this.deskripsi,
    required this.ikon,
  });
}

class LayananPage extends StatelessWidget {
  const LayananPage({super.key});

  static const List<Layanan> layananPerizinan = [
    Layanan(
      nama: 'Perizinan Usaha',
      kategori: 'Perizinan',
      deskripsi:
          'Pengajuan izin usaha secara digital.',
      ikon: Icons.business,
    ),
    Layanan(
      nama: 'Kartu Identitas',
      kategori: 'Perizinan',
      deskripsi:
          'Pengurusan kartu identitas warga.',
      ikon: Icons.badge,
    ),
  ];

  static const List<Layanan> layananKesehatan = [
    Layanan(
      nama: 'Pendaftaran Puskesmas',
      kategori: 'Kesehatan',
      deskripsi:
          'Pendaftaran layanan kesehatan '
          'di puskesmas.',
      ikon: Icons.local_hospital,
    ),
    Layanan(
      nama: 'Vaksinasi Warga',
      kategori: 'Kesehatan',
      deskripsi:
          'Informasi dan pengajuan vaksinasi.',
      ikon: Icons.vaccines,
    ),
  ];

  static const List<Layanan> layananTransportasi = [
    Layanan(
      nama: 'Kartu Transportasi',
      kategori: 'Transportasi',
      deskripsi:
          'Pengajuan kartu transportasi warga.',
      ikon: Icons.directions_bus,
    ),
    Layanan(
      nama: 'Izin Parkir',
      kategori: 'Transportasi',
      deskripsi:
          'Pengajuan izin parkir kendaraan.',
      ikon: Icons.local_parking,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Column(
        children: [
          const TabBar(
            tabs: [
              Tab(
                text: 'Perizinan',
              ),
              Tab(
                text: 'Kesehatan',
              ),
              Tab(
                text: 'Transportasi',
              ),
            ],
          ),

          Expanded(
            child: TabBarView(
              children: [
                _DaftarLayanan(
                  layanan: layananPerizinan,
                ),
                _DaftarLayanan(
                  layanan: layananKesehatan,
                ),
                _DaftarLayanan(
                  layanan: layananTransportasi,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _DaftarLayanan extends StatelessWidget {
  final List<Layanan> layanan;

  const _DaftarLayanan({
    required this.layanan,
  });

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: layanan.length,
      separatorBuilder: (_, __) {
        return const SizedBox(height: 12);
      },
      itemBuilder: (context, index) {
        return _KartuLayanan(
          layanan: layanan[index],
        );
      },
    );
  }
}

class _KartuLayanan extends StatelessWidget {
  final Layanan layanan;

  const _KartuLayanan({
    required this.layanan,
  });

  @override
  Widget build(BuildContext context) {
    final favorit =
        context.watch<FavoritModel>();

    final sedangFavorit =
        favorit.isFavorit(layanan.nama);

    return Card(
      child: ListTile(
        leading: CircleAvatar(
          child: Icon(layanan.ikon),
        ),

        title: Text(
          layanan.nama,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),

        subtitle: Text(layanan.deskripsi),

        trailing: IconButton(
          onPressed: () {
            final model =
                context.read<FavoritModel>();

            if (model.isFavorit(layanan.nama)) {
              model.batalTandai(
                layanan.nama,
              );
            } else {
              model.tandai(
                layanan.nama,
              );
            }
          },
          icon: Icon(
            sedangFavorit
                ? Icons.star
                : Icons.star_border,
          ),
          color: sedangFavorit
              ? Colors.amber
              : Colors.grey,
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
  }
}