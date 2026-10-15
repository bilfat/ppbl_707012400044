import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../cubit/favorit_cubit.dart';
import '../cubit/pengajuan_cubit.dart';
import '../navigation/app_routes.dart';

class HalamanLayanan extends StatelessWidget {
  const HalamanLayanan({super.key});

  static const List<Map<String, String>> _perizinan = [
    {'namaLayanan': 'Izin Usaha', 'dinas': 'Dinas Penanaman Modal', 'jamOperasional': 'Senin - Jumat, 08.00 - 15.00', 'keterangan': 'Layanan pengajuan izin usaha bagi masyarakat.'},
    {'namaLayanan': 'Izin Bangunan', 'dinas': 'Dinas PUPR', 'jamOperasional': 'Senin - Jumat, 08.00 - 15.00', 'keterangan': 'Layanan pengurusan izin pembangunan dan bangunan.'},
    {'namaLayanan': 'Izin Reklame', 'dinas': 'Dinas Perizinan', 'jamOperasional': 'Senin - Jumat, 08.00 - 14.00', 'keterangan': 'Layanan pengajuan izin pemasangan reklame.'},
  ];

  static const List<Map<String, String>> _kesehatan = [
    {'namaLayanan': 'Puskesmas', 'dinas': 'Dinas Kesehatan', 'jamOperasional': 'Senin - Sabtu, 08.00 - 16.00', 'keterangan': 'Informasi dan layanan fasilitas kesehatan masyarakat.'},
    {'namaLayanan': 'Vaksinasi', 'dinas': 'Dinas Kesehatan', 'jamOperasional': 'Senin - Jumat, 08.00 - 15.00', 'keterangan': 'Informasi lokasi dan jadwal vaksinasi warga.'},
    {'namaLayanan': 'Ambulans', 'dinas': 'Dinas Kesehatan', 'jamOperasional': '24 Jam', 'keterangan': 'Layanan bantuan transportasi medis darurat.'},
  ];

  static const List<Map<String, String>> _transportasi = [
    {'namaLayanan': 'Bus Kota', 'dinas': 'Dinas Perhubungan', 'jamOperasional': '05.00 - 22.00', 'keterangan': 'Informasi rute dan jadwal bus kota.'},
    {'namaLayanan': 'Parkir Kota', 'dinas': 'Dinas Perhubungan', 'jamOperasional': '06.00 - 22.00', 'keterangan': 'Informasi lokasi dan fasilitas parkir kota.'},
    {'namaLayanan': 'Pengaduan Jalan', 'dinas': 'Dinas Perhubungan', 'jamOperasional': '24 Jam', 'keterangan': 'Layanan pelaporan masalah fasilitas jalan.'},
  ];

  Future<void> _bukaDetail(BuildContext context, Map<String, String> layanan) async {
    final hasil = await Navigator.pushNamed(
      context,
      AppRoutes.detailLayanan,
      arguments: layanan,
    );
    if (!context.mounted) return;
    if (hasil is String) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(hasil)));
    }
  }

  Widget _buatDaftar(BuildContext context, List<Map<String, String>> daftar) {
    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: daftar.length,
      separatorBuilder: (_, __) => const SizedBox(height: 8),
      itemBuilder: (context, index) {
        final layanan = daftar[index];
        final nama = layanan['namaLayanan']!;
        return Card(
          child: BlocBuilder<FavoritCubit, Set<String>>(
            builder: (context, favorit) {
              final isFavorit = favorit.contains(nama);
              return ListTile(
                leading: const CircleAvatar(child: Icon(Icons.miscellaneous_services)),
                title: Text(nama, style: const TextStyle(fontWeight: FontWeight.bold)),
                subtitle: Text(layanan['dinas']!),
                onTap: () => _bukaDetail(context, layanan),
                trailing: Wrap(
                  spacing: 0,
                  children: [
                    IconButton(
                      tooltip: isFavorit ? 'Hapus dari favorit' : 'Tambah ke favorit',
                      icon: Icon(isFavorit ? Icons.favorite : Icons.favorite_border,
                          color: isFavorit ? Colors.red : null),
                      onPressed: () => context.read<FavoritCubit>().toggle(nama),
                    ),
                    IconButton(
                      tooltip: 'Tambah ke keranjang pengajuan',
                      icon: const Icon(Icons.add_shopping_cart),
                      onPressed: () {
                        context.read<PengajuanCubit>().tambah(layanan);
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('$nama ditambahkan ke pengajuan')),
                        );
                      },
                    ),
                  ],
                ),
              );
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
            tabs: [
              Tab(icon: Icon(Icons.description_outlined), text: 'Perizinan'),
              Tab(icon: Icon(Icons.health_and_safety_outlined), text: 'Kesehatan'),
              Tab(icon: Icon(Icons.directions_bus_outlined), text: 'Transportasi'),
            ],
          ),
          Expanded(
            child: TabBarView(
              children: [
                _buatDaftar(context, _perizinan),
                _buatDaftar(context, _kesehatan),
                _buatDaftar(context, _transportasi),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
