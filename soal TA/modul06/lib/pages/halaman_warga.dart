import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../cubit/favorit_cubit.dart';
import '../cubit/pengajuan_cubit.dart';
import '../cubit/theme_cubit.dart';
import '../data/data_layanan.dart';
import '../models/layanan.dart';

class HalamanWarga extends StatelessWidget {
  const HalamanWarga({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(title: const Text('Warga')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text('Pengaturan Tampilan', style: theme.textTheme.titleLarge),
          Card(
            child: BlocBuilder<ThemeCubit, ThemeMode>(
              builder: (context, mode) => SwitchListTile(
                secondary: Icon(mode == ThemeMode.dark ? Icons.dark_mode : Icons.light_mode),
                title: const Text('Mode gelap'),
                subtitle: Text(mode == ThemeMode.dark ? 'Aktif' : 'Nonaktif'),
                value: mode == ThemeMode.dark,
                onChanged: (_) => context.read<ThemeCubit>().toggle(),
              ),
            ),
          ),
          const SizedBox(height: 16),
          Text('Layanan Favorit', style: theme.textTheme.titleLarge),
          const SizedBox(height: 8),
          BlocBuilder<FavoritCubit, Set<String>>(
            builder: (context, favorit) {
              final daftarFavorit = daftarLayanan
                  .where((layanan) => favorit.contains(layanan.nama))
                  .toList();
              if (daftarFavorit.isEmpty) {
                return const Card(
                  child: Padding(
                    padding: EdgeInsets.all(18),
                    child: Text('Belum ada layanan favorit. Buka menu Layanan dan tekan ikon bintang.'),
                  ),
                );
              }
              return Column(
                children: daftarFavorit
                    .map((layanan) => _BarisLayanan(
                          layanan: layanan,
                          trailing: IconButton(
                            tooltip: 'Hapus favorit',
                            icon: const Icon(Icons.star),
                            onPressed: () => context.read<FavoritCubit>().batalTandai(layanan.nama),
                          ),
                        ))
                    .toList(),
              );
            },
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: Text('Keranjang Pengajuan', style: theme.textTheme.titleLarge),
              ),
              BlocSelector<PengajuanCubit, List<String>, int>(
                selector: (daftar) => daftar.length,
                builder: (context, total) => Chip(label: Text('$total layanan')),
              ),
            ],
          ),
          const SizedBox(height: 8),
          BlocBuilder<PengajuanCubit, List<String>>(
            builder: (context, pengajuan) {
              if (pengajuan.isEmpty) {
                return const Card(
                  child: Padding(
                    padding: EdgeInsets.all(18),
                    child: Text('Belum ada layanan dalam keranjang pengajuan.'),
                  ),
                );
              }
              return Column(
                children: [
                  ...pengajuan.map((nama) {
                    final layanan = daftarLayanan.firstWhere(
                      (item) => item.nama == nama,
                      orElse: () => Layanan(
                        id: nama,
                        nama: nama,
                        bidang: 'Layanan publik',
                        deskripsi: '',
                        icon: IconDataPlaceholder.document,
                      ),
                    );
                    return _BarisLayanan(
                      layanan: layanan,
                      trailing: IconButton(
                        tooltip: 'Hapus pengajuan',
                        icon: const Icon(Icons.delete_outline),
                        onPressed: () => context.read<PengajuanCubit>().hapus(nama),
                      ),
                    );
                  }),
                  const SizedBox(height: 8),
                  FilledButton.icon(
                    onPressed: () {
                      context.read<PengajuanCubit>().kirimSemua();
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Pengajuan berhasil dikirim (simulasi).')),
                      );
                    },
                    icon: const Icon(Icons.send),
                    label: const Text('Kirim Semua Pengajuan'),
                  ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }
}

class _BarisLayanan extends StatelessWidget {
  final Layanan layanan;
  final Widget? trailing;

  const _BarisLayanan({required this.layanan, this.trailing});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        leading: const CircleAvatar(child: Icon(Icons.assignment_outlined)),
        title: Text(layanan.nama),
        subtitle: Text(layanan.bidang),
        trailing: trailing,
      ),
    );
  }
}
