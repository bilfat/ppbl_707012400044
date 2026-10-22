import 'package:flutter/material.dart';

class HalamanBeranda extends StatelessWidget {
  const HalamanBeranda({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Beranda'),
        actions: const [Padding(padding: EdgeInsets.all(12), child: Icon(Icons.notifications_none))],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text('Selamat Datang, Warga!', style: theme.textTheme.headlineSmall),
          const SizedBox(height: 8),
          Text(
            'Akses informasi dan layanan publik dalam satu aplikasi.',
            style: theme.textTheme.bodyLarge,
          ),
          const SizedBox(height: 20),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Row(
                children: [
                  CircleAvatar(
                    backgroundColor: theme.colorScheme.primaryContainer,
                    child: Icon(Icons.account_balance, color: theme.colorScheme.onPrimaryContainer),
                  ),
                  const SizedBox(width: 16),
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Layanan Pemerintah Kota', style: TextStyle(fontWeight: FontWeight.bold)),
                        SizedBox(height: 4),
                        Text('Temukan layanan Perizinan, Kesehatan, dan Transportasi.'),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 8),
          Text('Pintasan', style: theme.textTheme.titleLarge),
          const SizedBox(height: 8),
          const Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _Pintasan(icon: Icons.description_outlined, label: 'Perizinan'),
              _Pintasan(icon: Icons.health_and_safety_outlined, label: 'Kesehatan'),
              _Pintasan(icon: Icons.directions_bus_outlined, label: 'Transportasi'),
            ],
          ),
        ],
      ),
    );
  }
}

class _Pintasan extends StatelessWidget {
  final IconData icon;
  final String label;
  const _Pintasan({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Chip(avatar: Icon(icon, size: 18), label: Text(label));
  }
}
