import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../cubit/favorit_cubit.dart';
import '../data/data_layanan.dart';
import '../models/layanan.dart';
import 'halaman_rincian.dart';

class HalamanMonitoring extends StatefulWidget {
  const HalamanMonitoring({super.key});

  @override
  State<HalamanMonitoring> createState() => HalamanMonitoringState();
}

class HalamanMonitoringState extends State<HalamanMonitoring>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;
  final _bidang = const ['Semua', 'Garut Kota', 'Tarogong Kaler', 'Semarang'];

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


  

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Riwayat Monitoring'),
        bottom: TabBar(
          controller: _tabController,
          isScrollable: true,
          tabs: _bidang.map((bidang) => Tab(text: bidang)).toList(),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.pushNamed(
            context,
            '/pengajuan',
          );
        },
        icon: const Icon(Icons.add),
        label: const Text('Monitoring Baru'),
      ),
      body: TabBarView(
        controller: _tabController,
        children: _bidang.map((bidang) {
          final layanan = daftarLayanan
              .where((item) => bidang == 'Semua' || item.Lokasi == bidang)
              .toList();
          return ListView.builder(
            padding: const EdgeInsets.symmetric(vertical: 8),
            itemCount: layanan.length,
            itemBuilder: (context, index) {
              final item = layanan[index];
              return BlocBuilder<FavoritCubit, Set<String>>(
                builder: (context, favorit) {
                  final isFavorit = favorit.contains(item.);
                  return Card(
                    child: ListTile(
                     
                      title: Text(item.Lokasi),
                      subtitle: Text(item.Lokasi),
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
                        onPressed: () => context.read<FavoritCubit>().toggle(item.Lokasi),
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
