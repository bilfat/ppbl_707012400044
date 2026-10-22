import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../cubit/pengajuan_cubit.dart';
import '../pages/halaman_beranda.dart';
import '../pages/halaman_layanan.dart';
import '../pages/halaman_warga.dart';

class KerangkaUtama extends StatefulWidget {
  const KerangkaUtama({super.key});

  @override
  State<KerangkaUtama> createState() => _KerangkaUtamaState();
}

class _KerangkaUtamaState extends State<KerangkaUtama> {
  int _indeks = 0;

  final _halaman = const [
    HalamanBeranda(),
    HalamanLayanan(),
    HalamanWarga(),
  ];

  void _pilihHalaman(int indeks) {
    setState(() => _indeks = indeks);
    Navigator.of(context).maybePop();
  }

  NavigationDestination _tujuanWargaDenganBadge() {
  return NavigationDestination(
    icon: BlocSelector<PengajuanCubit, List<String>, int>(
      selector: (daftar) => daftar.length,
      builder: (context, total) => Badge(
        isLabelVisible: total > 0,
        label: Text('$total'),
        child: const Icon(Icons.people_alt_outlined),
      ),
    ),
    selectedIcon: BlocSelector<PengajuanCubit, List<String>, int>(
      selector: (daftar) => daftar.length,
      builder: (context, total) => Badge(
        isLabelVisible: total > 0,
        label: Text('$total'),
        child: const Icon(Icons.people_alt),
      ),
    ),
    label: 'Warga',
  );
}

  @override
  Widget build(BuildContext context) {
    final destinations = <NavigationDestination>[
      const NavigationDestination(
        icon: Icon(Icons.home_outlined),
        selectedIcon: Icon(Icons.home),
        label: 'Beranda',
      ),
      const NavigationDestination(
        icon: Icon(Icons.miscellaneous_services_outlined),
        selectedIcon: Icon(Icons.miscellaneous_services),
        label: 'Layanan',
      ),
      _tujuanWargaDenganBadge(),
    ];

    return LayoutBuilder(
      builder: (context, constraints) {
        final lebar = constraints.maxWidth;
        final lebarLuas = lebar >= 800;
        final lebarSedang = lebar >= 600;

        if (lebarLuas) {
          return Scaffold(
            body: Row(
              children: [
                NavigationRail(
                  extended: true,
                  selectedIndex: _indeks,
                  onDestinationSelected: _pilihHalaman,
                  leading: const Padding(
                    padding: EdgeInsets.symmetric(vertical: 20),
                    child: Icon(Icons.location_city, size: 34),
                  ),
                  destinations: const [
                    NavigationRailDestination(
                      icon: Icon(Icons.home_outlined),
                      selectedIcon: Icon(Icons.home),
                      label: Text('Beranda'),
                    ),
                    NavigationRailDestination(
                      icon: Icon(Icons.miscellaneous_services_outlined),
                      selectedIcon: Icon(Icons.miscellaneous_services),
                      label: Text('Layanan'),
                    ),
                    NavigationRailDestination(
                      icon: Icon(Icons.people_alt_outlined),
                      selectedIcon: Icon(Icons.people_alt),
                      label: Text('Warga'),
                    ),
                  ],
                ),
                const VerticalDivider(width: 1),
                Expanded(child: _halaman[_indeks]),
              ],
            ),
          );
        }

        if (lebarSedang) {
          return Scaffold(
            body: Row(
              children: [
                NavigationRail(
                  selectedIndex: _indeks,
                  onDestinationSelected: _pilihHalaman,
                  labelType: NavigationRailLabelType.all,
                  destinations: const [
                    NavigationRailDestination(
                      icon: Icon(Icons.home_outlined),
                      selectedIcon: Icon(Icons.home),
                      label: Text('Beranda'),
                    ),
                    NavigationRailDestination(
                      icon: Icon(Icons.miscellaneous_services_outlined),
                      selectedIcon: Icon(Icons.miscellaneous_services),
                      label: Text('Layanan'),
                    ),
                    NavigationRailDestination(
                      icon: Icon(Icons.people_alt_outlined),
                      selectedIcon: Icon(Icons.people_alt),
                      label: Text('Warga'),
                    ),
                  ],
                ),
                const VerticalDivider(width: 1),
                Expanded(child: _halaman[_indeks]),
              ],
            ),
          );
        }

        return Scaffold(
          drawer: NavigationDrawer(
            selectedIndex: _indeks,
            onDestinationSelected: _pilihHalaman,
            children: const [
              Padding(
                padding: EdgeInsets.fromLTRB(28, 24, 16, 12),
                child: Text('Nusantara Cerdas Mobile',
                    style: TextStyle(fontWeight: FontWeight.bold)),
              ),
              NavigationDrawerDestination(
                icon: Icon(Icons.home_outlined),
                label: Text('Beranda'),
              ),
              NavigationDrawerDestination(
                icon: Icon(Icons.miscellaneous_services_outlined),
                label: Text('Layanan'),
              ),
              NavigationDrawerDestination(
                icon: Icon(Icons.people_alt_outlined),
                label: Text('Warga'),
              ),
            ],
          ),
          body: _halaman[_indeks],
          bottomNavigationBar: NavigationBar(
            selectedIndex: _indeks,
            onDestinationSelected: (i) => setState(() => _indeks = i),
            destinations: destinations,
          ),
        );
      },
    );
  }
}
