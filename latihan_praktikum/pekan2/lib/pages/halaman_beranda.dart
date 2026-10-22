import 'package:flutter/material.dart';

import '../navigation/app_routes.dart';

class HalamanBeranda extends StatelessWidget {
  const HalamanBeranda({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.home,
              size: 80,
              color: Color(0xFF4F5BD5),
            ),

            const SizedBox(height: 20),

            const Text(
              'Belum ada data yang dikirim balik.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 16,
              ),
            ),

            const SizedBox(height: 24),

            // Tombol Named Route
            FilledButton.icon(
              onPressed: () {
                Navigator.pushNamed(
                  context,
                  AppRoutes.detail,
                );
              },
              icon: const Icon(Icons.arrow_forward),
              label: const Text(
                'Buka Detail lewat Named Route',
              ),
            ),

            const SizedBox(height: 12),

            // Tombol route salah
            OutlinedButton(
              onPressed: () {
                Navigator.pushNamed(
                  context,
                  AppRoutes.routeSalah,
                );
              },
              child: const Text(
                'Uji Route Salah',
              ),
            ),
          ],
        ),
      ),
    );
  }
}