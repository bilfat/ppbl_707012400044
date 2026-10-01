import 'package:flutter/material.dart';

class HalamanTentangAplikasi
    extends StatelessWidget {
  const HalamanTentangAplikasi({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Tentang Aplikasi',
        ),
      ),

      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment:
              MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.location_city,
              size: 80,
            ),

            const SizedBox(height: 20),

            const Text(
              'Nusantara Cerdas Mobile',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),

            const SizedBox(height: 12),

            const Text(
              'Aplikasi purwarupa layanan warga '
              'Smart City Nusantara.',
              textAlign: TextAlign.center,
            ),

            const SizedBox(height: 12),

            const Text(
              'Versi 1.0.0',
            ),
          ],
        ),
      ),
    );
  }
}