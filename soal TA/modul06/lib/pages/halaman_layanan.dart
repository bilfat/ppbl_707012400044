import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../cubit/favorit_cubit.dart';
import '../data/data_layanan.dart';
import '../models/layanan.dart';
import 'halaman_rincian_layanan.dart';

class HalamanLayanan extends StatefulWidget {
  const HalamanLayanan({super.key});

  @override
  State<HalamanLayanan> createState() => _HalamanLayananState();
}

class _HalamanLayananState extends State<HalamanLayanan>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;
  final _bidang = const ['Semua', 'Perizinan', 'Kesehatan', 'Transportasi'];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: _bidang.length, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  IconData _ikon(Layanan layanan) {
    switch (layanan.icon) {
      case IconDataPlaceholder.document:
        return Icons.description_outlined;
      case IconDataPlaceholder.health:
        return Icons.health_and_safety_outlined;
      case IconDataPlaceholder.transport:
        return Icons.directions_bus_outlined;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Layanan Publik'),
        bottom: TabBar(
          controller: _tabController,
          isScrollable: true,
          tabs: _bidang.map((bidang) => Tab(text: bidang)).toList(),
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: _bidang.map((bidang) {
          final layanan = daftarLayanan
              .where((item) => bidang == 'Semua' || item.bidang == bidang)
              .toList();
          return ListView.builder(
            padding: const EdgeInsets.symmetric(vertical: 8),
            itemCount: layanan.length,
            itemBuilder: (context, index) {
              final item = layanan[index];
              return BlocBuilder<FavoritCubit, Set<String>>(
                builder: (context, favorit) {
                  final isFavorit = favorit.contains(item.nama);
                  return Card(
                    child: ListTile(
                      leading: CircleAvatar(
                        child: Icon(_ikon(item)),
                      ),
                      title: Text(item.nama),
                      subtitle: Text(item.bidang),
                      onTap: () => Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => HalamanRincianLayanan(layanan: item),
                        ),
                      ),
                      trailing: IconButton(
                        tooltip: isFavorit ? 'Hapus dari favorit' : 'Tandai favorit',
                        icon: Icon(
                          isFavorit ? Icons.star : Icons.star_border,
                          color: isFavorit
                              ? Theme.of(context).colorScheme.primary
                              : Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                        onPressed: () => context.read<FavoritCubit>().toggle(item.nama),
                      ),
                    ),
                  );
                },
              );
            },
          );
        }).toList(),
      ),
    );
  }
}
