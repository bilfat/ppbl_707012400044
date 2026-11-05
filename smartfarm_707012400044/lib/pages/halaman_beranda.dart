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
          Text('Selamat Datang, di SmartFarm!', style: theme.textTheme.headlineSmall),
          const SizedBox(height: 8),
           Text('Aplikasi Monitoring Pertanian Cerdas', style: theme.textTheme.headlineSmall),
          const SizedBox(height: 8),
          Text(
            'Alikasi untuk mencatat kondisi lahan kelompok tani makmur, agar kebutuhan penyiraman dapat diketahui lebih cepat.',
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
                        Text('Sistem : Smart Farming', style: TextStyle(fontWeight: FontWeight.bold)),
                        SizedBox(height: 4),
                        Text('Monitoring kebutuhan penyiraman berdasarkan kelembapan tanah 3 parameter : kelembapan tanah, suhu udaara, dan kelembapan udara.'),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 8),
         
          
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
