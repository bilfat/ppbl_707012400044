import 'package:flutter/material.dart';

class HalamanProfile extends StatelessWidget {
  const HalamanProfile({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const CircleAvatar(
              radius: 50,
              child: Icon(
                Icons.person,
                size: 50,
              ),
            ),

            const SizedBox(height: 20),

            const Text(
              'Profil Mahasiswa',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 10),

            const Text(
              'Nama: Mahasiswa',
              style: TextStyle(fontSize: 16),
            ),

            const SizedBox(height: 5),

            const Text(
              'Program Studi: Sistem Informasi Kota Cerdas',
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}