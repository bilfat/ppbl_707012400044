import 'package:flutter/material.dart';

class HalamanPengaturan extends StatelessWidget {
  const HalamanPengaturan({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Pengaturan'),
      ),

      body: ListView(
        children: [
          SwitchListTile(
            title: const Text('Notifikasi'),
            subtitle: const Text(
              'Aktifkan notifikasi aplikasi',
            ),
            value: true,
            onChanged: (value) {},
          ),

          const Divider(),

          ListTile(
            leading: const Icon(Icons.language),
            title: const Text('Bahasa'),
            subtitle: const Text('Bahasa Indonesia'),
            onTap: () {},
          ),

          ListTile(
            leading: const Icon(Icons.info_outline),
            title: const Text('Tentang Aplikasi'),
            onTap: () {},
          ),
        ],
      ),
    );
  }
}