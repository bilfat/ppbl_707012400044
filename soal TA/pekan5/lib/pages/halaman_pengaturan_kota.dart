import 'package:flutter/material.dart';

class HalamanPengaturanKota
    extends StatelessWidget {
  const HalamanPengaturanKota({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Pengaturan Kota',
        ),
      ),

      body: ListView(
        children: [
          SwitchListTile(
            value: true,
            onChanged: (value) {},
            title: const Text(
              'Notifikasi Layanan',
            ),
            subtitle: const Text(
              'Terima informasi layanan publik.',
            ),
          ),

          SwitchListTile(
            value: true,
            onChanged: (value) {},
            title: const Text(
              'Notifikasi Laporan',
            ),
            subtitle: const Text(
              'Terima perkembangan laporan warga.',
            ),
          ),

          ListTile(
            leading: const Icon(
              Icons.location_on_outlined,
            ),
            title: const Text(
              'Wilayah Kota',
            ),
            subtitle: const Text(
              'Nusantara',
            ),
          ),
        ],
      ),
    );
  }
}