import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'models/favorit_model.dart';
import 'models/pengajuan_model.dart';

import 'pages/beranda_page.dart';
import 'pages/detail_layanan_page.dart';
import 'pages/layanan_page.dart';
import 'pages/warga_page.dart';

void main() {
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) => FavoritModel(),
        ),

        ChangeNotifierProvider(
          create: (_) => PengajuanModel(),
        ),
      ],
      child: const NusantaraCerdasApp(),
    ),
  );
}

class NusantaraCerdasApp extends StatelessWidget {
  const NusantaraCerdasApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,

      title: 'Nusantara Cerdas Mobile',

      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.blue,
        ),
        useMaterial3: true,
      ),

      initialRoute: '/',

      routes: {
        '/': (context) =>
            const HalamanUtama(),

        '/detail': (context) =>
            const DetailLayananPage(),
      },
    );
  }
}

class HalamanUtama extends StatefulWidget {
  const HalamanUtama({
    super.key,
  });

  @override
  State<HalamanUtama> createState() =>
      _HalamanUtamaState();
}

class _HalamanUtamaState
    extends State<HalamanUtama> {
  int _selectedIndex = 0;

  final List<Widget> _pages = const [
    BerandaPage(),
    LayananPage(),
    WargaPage(),
  ];

  void _ubahHalaman(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (
        context,
        constraints,
      ) {
        final bool layarLebar =
            constraints.maxWidth >= 800;

        return Scaffold(

          // =========================
          // APP BAR
          // =========================
          appBar: AppBar(
            title: const Text(
              'Nusantara Cerdas Mobile',
            ),
          ),

          // =========================
          // NAVIGATION DRAWER
          // =========================
          drawer: NavigationDrawer(
            selectedIndex: _selectedIndex,

            onDestinationSelected: (
              index,
            ) {
              Navigator.pop(context);

              setState(() {
                _selectedIndex = index;
              });
            },

            children: const [
              Padding(
                padding: EdgeInsets.fromLTRB(
                  24,
                  24,
                  24,
                  16,
                ),
                child: Text(
                  'Nusantara Cerdas',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight:
                        FontWeight.bold,
                  ),
                ),
              ),

              NavigationDrawerDestination(
                icon: Icon(
                  Icons.home_outlined,
                ),
                selectedIcon: Icon(
                  Icons.home,
                ),
                label: Text(
                  'Beranda',
                ),
              ),

              NavigationDrawerDestination(
                icon: Icon(
                  Icons
                      .miscellaneous_services_outlined,
                ),
                selectedIcon: Icon(
                  Icons.miscellaneous_services,
                ),
                label: Text(
                  'Layanan',
                ),
              ),

              NavigationDrawerDestination(
                icon: Icon(
                  Icons.person_outline,
                ),
                selectedIcon: Icon(
                  Icons.person,
                ),
                label: Text(
                  'Warga',
                ),
              ),
            ],
          ),

          // =========================
          // BODY
          // =========================
          body: Row(
            children: [

              // =====================
              // NAVIGATION RAIL
              // LAYAR LEBAR
              // =====================
              if (layarLebar)
                NavigationRail(
                  selectedIndex:
                      _selectedIndex,

                  onDestinationSelected:
                      _ubahHalaman,

                  labelType:
                      NavigationRailLabelType
                          .all,

                  destinations: const [
                    NavigationRailDestination(
                      icon: Icon(
                        Icons.home_outlined,
                      ),
                      selectedIcon: Icon(
                        Icons.home,
                      ),
                      label: Text(
                        'Beranda',
                      ),
                    ),

                    NavigationRailDestination(
                      icon: Icon(
                        Icons
                            .miscellaneous_services_outlined,
                      ),
                      selectedIcon: Icon(
                        Icons
                            .miscellaneous_services,
                      ),
                      label: Text(
                        'Layanan',
                      ),
                    ),

                    NavigationRailDestination(
                      icon:
                          PengajuanBadgeIcon(
                        icon:
                            Icons.person_outline,
                      ),
                      selectedIcon:
                          PengajuanBadgeIcon(
                        icon:
                            Icons.person,
                      ),
                      label: Text(
                        'Warga',
                      ),
                    ),
                  ],
                ),

              // =====================
              // ISI HALAMAN
              // =====================
              Expanded(
                child: IndexedStack(
                  index: _selectedIndex,
                  children: _pages,
                ),
              ),
            ],
          ),

          // =========================
          // NAVIGATION BAR
          // LAYAR KECIL
          // =========================
          bottomNavigationBar:
              layarLebar
                  ? null
                  : NavigationBar(
                      selectedIndex:
                          _selectedIndex,

                      onDestinationSelected:
                          _ubahHalaman,

                      destinations: const [
                        NavigationDestination(
                          icon: Icon(
                            Icons
                                .home_outlined,
                          ),
                          selectedIcon:
                              Icon(
                            Icons.home,
                          ),
                          label: 'Beranda',
                        ),

                        NavigationDestination(
                          icon: Icon(
                            Icons
                                .miscellaneous_services_outlined,
                          ),
                          selectedIcon:
                              Icon(
                            Icons
                                .miscellaneous_services,
                          ),
                          label: 'Layanan',
                        ),

                        NavigationDestination(
                          icon:
                              PengajuanBadgeIcon(
                            icon: Icons
                                .person_outline,
                          ),
                          selectedIcon:
                              PengajuanBadgeIcon(
                            icon:
                                Icons.person,
                          ),
                          label: 'Warga',
                        ),
                      ],
                    ),
        );
      },
    );
  }
}


// =====================================================
// BADGE JUMLAH PENGAJUAN
// =====================================================

class PengajuanBadgeIcon
    extends StatelessWidget {
  final IconData icon;

  const PengajuanBadgeIcon({
    super.key,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {

    final total =
        context.select<
            PengajuanModel,
            int
        >(
      (model) =>
          model.totalPengajuan,
    );

    return Badge(
      isLabelVisible: total > 0,

      label: Text(
        '$total',
      ),

      child: Icon(
        icon,
      ),
    );
  }
}