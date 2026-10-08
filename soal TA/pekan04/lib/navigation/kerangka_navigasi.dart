import 'package:flutter/material.dart';

import '../pages/warga_page.dart';
import '../pages/chat_page.dart';
import '../pages/lokasi_kantor_page.dart';
import '../pages/statistik_page.dart';

class KerangkaNavigasi extends StatefulWidget {
  const KerangkaNavigasi({super.key});

  @override
  State<KerangkaNavigasi> createState() =>
      _KerangkaNavigasiState();
}

class _KerangkaNavigasiState
    extends State<KerangkaNavigasi> {

  int indeksTerpilih = 0;

  final List<Widget> halaman = const [
    WargaPage(),
    ChatPage(),
    LokasiKantorPage(),
    StatistikPage(),
  ];

  final List<String> judul = [
    'Warga',
    'Tanya Petugas',
    'Lokasi Kantor',
    'Statistik',
  ];

  void pilihHalaman(int index) {
    setState(() {
      indeksTerpilih = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    final lebar =
        MediaQuery.of(context).size.width;

    final layarLebar = lebar >= 600;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          judul[indeksTerpilih],
        ),
      ),

      body: layarLebar
          ? Row(
              children: [
                NavigationRail(
                  selectedIndex: indeksTerpilih,
                  extended: true,
                  onDestinationSelected:
                      pilihHalaman,
                  destinations: const [
                    NavigationRailDestination(
                      icon: Icon(
                        Icons.home_outlined,
                      ),
                      selectedIcon: Icon(
                        Icons.home,
                      ),
                      label: Text('Warga'),
                    ),
                    NavigationRailDestination(
                      icon: Icon(
                        Icons.chat_outlined,
                      ),
                      selectedIcon: Icon(
                        Icons.chat,
                      ),
                      label: Text('Chat'),
                    ),
                    NavigationRailDestination(
                      icon: Icon(
                        Icons.map_outlined,
                      ),
                      selectedIcon: Icon(
                        Icons.map,
                      ),
                      label: Text('Lokasi'),
                    ),
                    NavigationRailDestination(
                      icon: Icon(
                        Icons.bar_chart_outlined,
                      ),
                      selectedIcon: Icon(
                        Icons.bar_chart,
                      ),
                      label: Text('Statistik'),
                    ),
                  ],
                ),

                const VerticalDivider(
                  width: 1,
                ),

                Expanded(
                  child: halaman[indeksTerpilih],
                ),
              ],
            )
          : halaman[indeksTerpilih],

      bottomNavigationBar: layarLebar
          ? null
          : NavigationBar(
              selectedIndex: indeksTerpilih,
              onDestinationSelected:
                  pilihHalaman,
              destinations: const [
                NavigationDestination(
                  icon: Icon(Icons.home_outlined),
                  selectedIcon: Icon(Icons.home),
                  label: 'Warga',
                ),
                NavigationDestination(
                  icon: Icon(Icons.chat_outlined),
                  selectedIcon: Icon(Icons.chat),
                  label: 'Chat',
                ),
                NavigationDestination(
                  icon: Icon(Icons.map_outlined),
                  selectedIcon: Icon(Icons.map),
                  label: 'Lokasi',
                ),
                NavigationDestination(
                  icon: Icon(Icons.bar_chart_outlined),
                  selectedIcon: Icon(Icons.bar_chart),
                  label: 'Statistik',
                ),
              ],
            ),
    );
  }
}