import 'package:flutter/material.dart';

class BerandaPage extends StatelessWidget {
  const BerandaPage({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Selamat Datang 👋',
            style: Theme.of(context)
                .textTheme
                .headlineMedium,
          ),

          const SizedBox(height: 8),

          const Text(
            'Nusantara Cerdas Mobile',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),

          const SizedBox(height: 24),

          Card(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment:
                    CrossAxisAlignment.start,
                children: [
                  const Icon(
                    Icons.location_city,
                    size: 50,
                  ),

                  const SizedBox(height: 16),

                  Text(
                    'Layanan Publik Digital',
                    style: Theme.of(context)
                        .textTheme
                        .titleLarge,
                  ),

                  const SizedBox(height: 8),

                  const Text(
                    'Akses berbagai layanan warga '
                    'dengan mudah melalui '
                    'Nusantara Cerdas Mobile.',
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 16),

          Card(
            child: ListTile(
              leading: const Icon(
                Icons.info_outline,
              ),
              title: const Text(
                'Informasi',
              ),
              subtitle: const Text(
                'Gunakan menu Layanan untuk '
                'melihat layanan yang tersedia.',
              ),
            ),
          ),
        ],
      ),
    );
  }
}