import 'package:flutter/material.dart';

import '../navigation/app_routes.dart';

class HalamanLayanan extends StatefulWidget {
  const HalamanLayanan({super.key});

  @override
  State<HalamanLayanan> createState() =>
      _HalamanLayananState();
}

class _HalamanLayananState
    extends State<HalamanLayanan> {
  // =========================
  // DATA LAYANAN
  // =========================

  final List<Map<String, String>>
      _perizinan = [
    {
      'namaLayanan': 'Izin Usaha',
      'dinas': 'Dinas Penanaman Modal',
      'jamOperasional':
          'Senin - Jumat, 08.00 - 15.00',
      'keterangan':
          'Layanan pengajuan izin usaha bagi masyarakat.',
    },
    {
      'namaLayanan': 'Izin Bangunan',
      'dinas': 'Dinas PUPR',
      'jamOperasional':
          'Senin - Jumat, 08.00 - 15.00',
      'keterangan':
          'Layanan pengurusan izin pembangunan dan bangunan.',
    },
    {
      'namaLayanan': 'Izin Reklame',
      'dinas': 'Dinas Perizinan',
      'jamOperasional':
          'Senin - Jumat, 08.00 - 14.00',
      'keterangan':
          'Layanan pengajuan izin pemasangan reklame.',
    },
  ];

  final List<Map<String, String>>
      _kesehatan = [
    {
      'namaLayanan': 'Puskesmas',
      'dinas': 'Dinas Kesehatan',
      'jamOperasional':
          'Senin - Sabtu, 08.00 - 16.00',
      'keterangan':
          'Informasi dan layanan fasilitas kesehatan masyarakat.',
    },
    {
      'namaLayanan': 'Vaksinasi',
      'dinas': 'Dinas Kesehatan',
      'jamOperasional':
          'Senin - Jumat, 08.00 - 15.00',
      'keterangan':
          'Informasi lokasi dan jadwal vaksinasi warga.',
    },
    {
      'namaLayanan': 'Ambulans',
      'dinas': 'Dinas Kesehatan',
      'jamOperasional':
          '24 Jam',
      'keterangan':
          'Layanan bantuan transportasi medis darurat.',
    },
  ];

  final List<Map<String, String>>
      _transportasi = [
    {
      'namaLayanan': 'Bus Kota',
      'dinas': 'Dinas Perhubungan',
      'jamOperasional':
          '05.00 - 22.00',
      'keterangan':
          'Informasi rute dan jadwal bus kota.',
    },
    {
      'namaLayanan': 'Parkir Kota',
      'dinas': 'Dinas Perhubungan',
      'jamOperasional':
          '06.00 - 22.00',
      'keterangan':
          'Informasi lokasi dan fasilitas parkir kota.',
    },
    {
      'namaLayanan': 'Pengaduan Jalan',
      'dinas': 'Dinas Perhubungan',
      'jamOperasional':
          '24 Jam',
      'keterangan':
          'Layanan pelaporan masalah fasilitas jalan.',
    },
  ];

  // =========================
  // BUKA DETAIL
  // =========================

  Future<void> _bukaDetail(
    Map<String, String> layanan,
  ) async {
    final hasil = await Navigator.pushNamed(
      context,
      AppRoutes.detailLayanan,
      arguments: layanan,
    );

    if (!mounted) return;

    if (hasil is String) {
      ScaffoldMessenger.of(context)
          .showSnackBar(
        SnackBar(
          content: Text(hasil),
        ),
      );
    }
  }

  // =========================
  // LIST LAYANAN
  // =========================

  Widget _buatDaftar(
    List<Map<String, String>> daftar,
  ) {
    return ListView.separated(
      padding: const EdgeInsets.all(16),

      itemCount: daftar.length,

      separatorBuilder:
          (context, index) =>
              const SizedBox(height: 8),

      itemBuilder:
          (context, index) {
        final layanan = daftar[index];

        return Card(
          child: ListTile(
            leading: const CircleAvatar(
              child: Icon(
                Icons.miscellaneous_services,
              ),
            ),

            title: Text(
              layanan['namaLayanan']!,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
              ),
            ),

            subtitle: Text(
              layanan['dinas']!,
            ),

            trailing: const Icon(
              Icons.chevron_right,
            ),

            onTap: () {
              _bukaDetail(layanan);
            },
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,

      child: Column(
        children: [
          const TabBar(
            isScrollable: false,

            tabs: [
              Tab(
                icon: Icon(
                  Icons.description_outlined,
                ),
                text: 'Perizinan',
              ),

              Tab(
                icon: Icon(
                  Icons.health_and_safety_outlined,
                ),
                text: 'Kesehatan',
              ),

              Tab(
                icon: Icon(
                  Icons.directions_bus_outlined,
                ),
                text: 'Transportasi',
              ),
            ],
          ),

          Expanded(
            child: TabBarView(
              children: [
                _buatDaftar(_perizinan),
                _buatDaftar(_kesehatan),
                _buatDaftar(_transportasi),
              ],
            ),
          ),
        ],
      ),
    );
  }
}