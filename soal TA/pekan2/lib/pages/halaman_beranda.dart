import 'package:flutter/material.dart';

import '../navigation/app_routes.dart';

class HalamanBeranda extends StatelessWidget {
  const HalamanBeranda({super.key});

  @override
  Widget build(BuildContext context) {
    final List<Map<String, dynamic>> pilar =
        [
      {
        'nama': 'Smart Governance',
        'icon': Icons.account_balance,
      },
      {
        'nama': 'Smart Branding',
        'icon': Icons.campaign,
      },
      {
        'nama': 'Smart Economy',
        'icon': Icons.trending_up,
      },
      {
        'nama': 'Smart Living',
        'icon': Icons.home,
      },
      {
        'nama': 'Smart Society',
        'icon': Icons.groups,
      },
      {
        'nama': 'Smart Environment',
        'icon': Icons.eco,
      },
    ];

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        const Text(
          'Nusantara Cerdas',
          style: TextStyle(
            fontSize: 26,
            fontWeight: FontWeight.bold,
          ),
        ),

        const SizedBox(height: 8),

        const Text(
          'Portal layanan warga dan informasi '
          'Smart City Nusantara.',
        ),

        const SizedBox(height: 24),

        const Text(
          'Enam Pilar Smart City',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),

        const SizedBox(height: 12),

        GridView.builder(
          shrinkWrap: true,
          physics:
              const NeverScrollableScrollPhysics(),
          itemCount: pilar.length,

          gridDelegate:
              const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            childAspectRatio: 1.4,
          ),

          itemBuilder: (context, index) {
            return Card(
              child: Padding(
                padding:
                    const EdgeInsets.all(12),
                child: Column(
                  mainAxisAlignment:
                      MainAxisAlignment.center,
                  children: [
                    Icon(
                      pilar[index]['icon'],
                      size: 36,
                    ),

                    const SizedBox(height: 8),

                    Text(
                      pilar[index]['nama'],
                      textAlign:
                          TextAlign.center,
                      style: const TextStyle(
                        fontWeight:
                            FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),

        const SizedBox(height: 24),

        // Tombol untuk pengujian route salah
        OutlinedButton.icon(
          onPressed: () {
            Navigator.pushNamed(
              context,
              '/route-yang-tidak-ada',
            );
          },
          icon: const Icon(
            Icons.warning_outlined,
          ),
          label: const Text(
            'Uji Route Tidak Dikenal',
          ),
        ),
      ],
    );
  }
}