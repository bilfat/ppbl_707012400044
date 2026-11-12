import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../core/constants/sensor_config.dart';
import '../data/models/pembacaan_sensor.dart';
import '../features/dashboard/pages/dashboard_page.dart';
import '../features/history/pages/riwayat_sensor_page.dart';
import '../features/sensor/cubit/sensor_cubit.dart';
import '../features/settings/cubit/pengaturan_cubit.dart';
import '../features/settings/pages/pengaturan_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _selectedIndex = 0;

  final List<Widget> _pages = const [
    DashboardPage(),
    RiwayatSensorPage(),
    PengaturanPage(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Peringatan Dini Bencana'),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 12),
            child: Center(child: _StatusAppBar()),
          ),
        ],
      ),
      body: IndexedStack(
        index: _selectedIndex,
        children: _pages,
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _selectedIndex,
        onDestinationSelected: (index) {
          setState(() => _selectedIndex = index);
        },
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.dashboard_outlined),
            selectedIcon: Icon(Icons.dashboard),
            label: 'Dashboard',
          ),
          NavigationDestination(
            icon: Icon(Icons.history),
            label: 'Riwayat',
          ),
          NavigationDestination(
            icon: Icon(Icons.tune),
            label: 'Pengaturan',
          ),
        ],
      ),
    );
  }
}

class _StatusAppBar extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<SensorCubit, List<PembacaanSensor>>(
      builder: (context, readings) {
        if (readings.isEmpty) {
          return const Chip(
            label: Text('Belum ada data'),
            visualDensity: VisualDensity.compact,
          );
        }

        final terbaru = readings.first;
        final jenis = jenisSensorDariKey(terbaru.jenisSensor);

        return BlocBuilder<PengaturanCubit, Map<JenisSensor, AmbangBatas>>(
          builder: (context, pengaturan) {
            final ambang = pengaturan[jenis] ??
                AmbangBatas(
                  waspada: jenis.defaultWaspada,
                  siaga: jenis.defaultSiaga,
                );
            final status = hitungStatusSiaga(terbaru.nilai, ambang);

            Color warna;
            switch (status) {
              case StatusSiaga.aman:
                warna = Colors.green;
                break;
              case StatusSiaga.waspada:
                warna = Colors.orange;
                break;
              case StatusSiaga.siaga:
                warna = Colors.red;
                break;
            }

            return Chip(
              avatar: Icon(Icons.circle, size: 10, color: warna),
              label: Text(
                status.label,
                style: TextStyle(
                  color: warna,
                  fontWeight: FontWeight.bold,
                ),
              ),
              backgroundColor: Colors.white,
              visualDensity: VisualDensity.compact,
            );
          },
        );
      },
    );
  }
}
