import 'package:flutter/material.dart';

class HalamanJadwal extends StatelessWidget {
  const HalamanJadwal({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        const Text(
          'Jadwal',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),

        const SizedBox(height: 20),

        Card(
          child: ListTile(
            leading: const Icon(Icons.calendar_today),
            title: const Text('Pemrograman Perangkat Bergerak'),
            subtitle: const Text('08.00 - 10.00'),
          ),
        ),

        Card(
          child: ListTile(
            leading: const Icon(Icons.calendar_today),
            title: const Text('Basis Data'),
            subtitle: const Text('10.00 - 12.00'),
          ),
        ),

        Card(
          child: ListTile(
            leading: const Icon(Icons.calendar_today),
            title: const Text('Analisis Data'),
            subtitle: const Text('13.00 - 15.00'),
          ),
        ),
      ],
    );
  }
}