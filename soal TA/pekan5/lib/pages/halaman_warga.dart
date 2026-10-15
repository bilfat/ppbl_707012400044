import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../cubit/favorit_cubit.dart';
import '../cubit/pengajuan_cubit.dart';
import '../navigation/app_routes.dart';

class HalamanWarga extends StatelessWidget {
  const HalamanWarga({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Text('Layanan Favorit', style: Theme.of(context).textTheme.titleLarge),
        const SizedBox(height: 8),
        BlocBuilder<FavoritCubit, Set<String>>(
          builder: (context, favorit) {
            if (favorit.isEmpty) {
              return const Card(
                child: Padding(
                  padding: EdgeInsets.all(16),
                  child: Text('Belum ada layanan favorit. Tandai layanan melalui halaman Layanan.'),
                ),
              );
            }
            return Column(
              children: favorit.map((nama) {
                return Card(
                  child: ListTile(
                    leading: const Icon(Icons.favorite, color: Colors.red),
                    title: Text(nama),
                    trailing: IconButton(
                      tooltip: 'Hapus favorit',
                      icon: const Icon(Icons.favorite_border),
                      onPressed: () => context.read<FavoritCubit>().batalTandai(nama),
                    ),
                  ),
                );
              }).toList(),
            );
          },
        ),
        const SizedBox(height: 24),
        Row(
          children: [
            Expanded(
              child: Text('Keranjang Pengajuan', style: Theme.of(context).textTheme.titleLarge),
            ),
            BlocSelector<PengajuanCubit, List<Map<String, String>>, int>(
              selector: (items) => items.length,
              builder: (context, total) => Chip(label: Text('$total layanan')),
            ),
          ],
        ),
        const SizedBox(height: 8),
        BlocBuilder<PengajuanCubit, List<Map<String, String>>>(
          builder: (context, pengajuan) {
            if (pengajuan.isEmpty) {
              return const Card(
                child: Padding(
                  padding: EdgeInsets.all(16),
                  child: Text('Keranjang pengajuan masih kosong. Tambahkan layanan dari halaman Layanan.'),
                ),
              );
            }

            return Column(
              children: [
                ...pengajuan.map((layanan) {
                  final nama = layanan['namaLayanan'] ?? 'Layanan';
                  return Card(
                    child: ListTile(
                      leading: const Icon(Icons.assignment_outlined),
                      title: Text(nama),
                      subtitle: Text(layanan['dinas'] ?? ''),
                      trailing: IconButton(
                        tooltip: 'Hapus dari pengajuan',
                        icon: const Icon(Icons.delete_outline),
                        onPressed: () => context.read<PengajuanCubit>().hapus(nama),
                      ),
                    ),
                  );
                }),
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  child: FilledButton.icon(
                    onPressed: () {
                      final jumlah = pengajuan.length;
                      context.read<PengajuanCubit>().kirimSemua();
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('$jumlah permohonan berhasil dikirim (simulasi).')),
                      );
                    },
                    icon: const Icon(Icons.send),
                    label: const Text('Kirim Semua Permohonan'),
                  ),
                ),
              ],
            );
          },
        ),
        const SizedBox(height: 24),
        OutlinedButton.icon(
          onPressed: () => Navigator.pushNamed(context, AppRoutes.riwayatLaporan),
          icon: const Icon(Icons.history),
          label: const Text('Lihat Riwayat Laporan'),
        ),
      ],
    );
  }
}
