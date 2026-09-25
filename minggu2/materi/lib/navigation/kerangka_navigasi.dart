import 'package:flutter/material.dart';

import '../pages/halaman_beranda.dart';
import '../pages/halaman_jadwal.dart';
import '../pages/halaman_profile.dart';
import '../pages/halaman_pengaturan.dart';
import 'app_routes.dart';

class KerangkaNavigasi extends StatefulWidget {
  const KerangkaNavigasi({super.key});

  @override
  State<KerangkaNavigasi> createState() => _KerangkaNavigasiState();
}

class _KerangkaNavigasiState extends State<KerangkaNavigasi> {
  int _selectedIndex = 0;

  final List<Widget> _pages = const [
    HalamanBeranda(),
    HalamanJadwal(),
    HalamanProfile(),
  ];

  final List<String> _titles = const [
    'Beranda',
    'Jadwal',
    'Profil',
  ];

  void _ubahHalaman(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  // Drawer untuk layar sempit
  Widget _buatDrawer() {
    return NavigationDrawer(
      selectedIndex: _selectedIndex,
      onDestinationSelected: (index) {
        Navigator.pop(context);

        if (index < 3) {
          _ubahHalaman(index);
        }
      },
      children: [
        const Padding(
          padding: EdgeInsets.fromLTRB(28, 32, 16, 20),
          child: Icon(
            Icons.school,
            size: 48,
          ),
        ),

        NavigationDrawerDestination(
          icon: const Icon(Icons.home_outlined),
          selectedIcon: const Icon(Icons.home),
          label: const Text('Beranda'),
        ),

        NavigationDrawerDestination(
          icon: const Icon(Icons.calendar_month_outlined),
          selectedIcon: const Icon(Icons.calendar_month),
          label: const Text('Jadwal'),
        ),

        NavigationDrawerDestination(
          icon: const Icon(Icons.person_outline),
          selectedIcon: const Icon(Icons.person),
          label: const Text('Profil'),
        ),

        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 16),
          child: Divider(),
        ),

        NavigationDrawerDestination(
          icon: const Icon(Icons.settings_outlined),
          selectedIcon: const Icon(Icons.settings),
          label: const Text('Pengaturan'),
        ),
      ],
    );
  }

  // Drawer permanen untuk layar lebar
  Widget _buatNavigationDrawerLebar() {
    return NavigationDrawer(
      selectedIndex: _selectedIndex,
      onDestinationSelected: (index) {
        if (index < 3) {
          _ubahHalaman(index);
        } else if (index == 3) {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const HalamanPengaturan(),
            ),
          );
        }
      },
      children: [
        const Padding(
          padding: EdgeInsets.fromLTRB(28, 30, 16, 30),
          child: Icon(
            Icons.school,
            size: 48,
          ),
        ),

        NavigationDrawerDestination(
          icon: const Icon(Icons.home_outlined),
          selectedIcon: const Icon(Icons.home),
          label: const Text('Beranda'),
        ),

        NavigationDrawerDestination(
          icon: const Icon(Icons.calendar_month_outlined),
          selectedIcon: const Icon(Icons.calendar_month),
          label: const Text('Jadwal'),
        ),

        NavigationDrawerDestination(
          icon: const Icon(Icons.person_outline),
          selectedIcon: const Icon(Icons.person),
          label: const Text('Profil'),
        ),

        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 16),
          child: Divider(),
        ),

        NavigationDrawerDestination(
          icon: const Icon(Icons.settings_outlined),
          selectedIcon: const Icon(Icons.settings),
          label: const Text('Pengaturan'),
        ),
      ],
    );
  }

  // NavigationBar untuk layar sempit
  Widget _buatNavigationBar() {
    return NavigationBar(
      selectedIndex: _selectedIndex,
      onDestinationSelected: _ubahHalaman,
      destinations: const [
        NavigationDestination(
          icon: Icon(Icons.home_outlined),
          selectedIcon: Icon(Icons.home),
          label: 'Beranda',
        ),
        NavigationDestination(
          icon: Icon(Icons.calendar_month_outlined),
          selectedIcon: Icon(Icons.calendar_month),
          label: 'Jadwal',
        ),
        NavigationDestination(
          icon: Icon(Icons.person_outline),
          selectedIcon: Icon(Icons.person),
          label: 'Profil',
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        // Batas layar untuk menentukan adaptif
        final bool layarLebar = constraints.maxWidth >= 700;

        if (layarLebar) {
          
          return Scaffold(
            body: Row(
              children: [
                SizedBox(
                  width: 250,
                  child: _buatNavigationDrawerLebar(),
                ),

                const VerticalDivider(
                  width: 1,
                  thickness: 1,
                ),

                Expanded(
                  child: Scaffold(
                    appBar: AppBar(
                      title: Text(_titles[_selectedIndex]),
                    ),
                    body: _pages[_selectedIndex],
                  ),
                ),
              ],
            ),
          );
        }

        
        return Scaffold(
          appBar: AppBar(
            title: Text(_titles[_selectedIndex]),
            leading: Builder(
              builder: (context) {
                return IconButton(
                  icon: const Icon(Icons.menu),
                  onPressed: () {
                    Scaffold.of(context).openDrawer();
                  },
                );
              },
            ),
          ),

          drawer: _buatDrawer(),

          body: _pages[_selectedIndex],

          bottomNavigationBar: _buatNavigationBar(),
        );
      },
    );
  }
}