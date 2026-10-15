import 'package:flutter/material.dart';

class HalamanRiwayatLaporan
    extends StatelessWidget {
  const HalamanRiwayatLaporan({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Riwayat Laporan',
        ),
      ),

      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Card(
            child: ListTile(
              leading: const CircleAvatar(
                child: Icon(
                  Icons.check,
                ),
              ),

              title: const Text(
                'Lampu Jalan Mati',
              ),

              subtitle: const Text(
                'Status: Selesai',
              ),

              trailing: const Icon(
                Icons.chevron_right,
              ),
            ),
          ),

          Card(
            child: ListTile(
              leading: const CircleAvatar(
                child: Icon(
                  Icons.pending,
                ),
              ),

              title: const Text(
                'Jalan Rusak',
              ),

              subtitle: const Text(
                'Status: Diproses',
              ),

              trailing: const Icon(
                Icons.chevron_right,
              ),
            ),
          ),

          Card(
            child: ListTile(
              leading: const CircleAvatar(
                child: Icon(
                  Icons.check_circle_outline,
                ),
              ),

              title: const Text(
                'Sampah Menumpuk',
              ),

              subtitle: const Text(
                'Status: Selesai',
              ),

              trailing: const Icon(
                Icons.chevron_right,
              ),
            ),
          ),
        ],
      ),

      // Floating Action Button
      floatingActionButton:
          FloatingActionButton(
        onPressed: () {
          ScaffoldMessenger.of(context)
              .showSnackBar(
            const SnackBar(
              content: Text(
                'Form laporan baru dibuka.',
              ),
            ),
          );
        },
        child: const Icon(
          Icons.add,
        ),
      ),

      // BottomAppBar
      bottomNavigationBar:
          BottomAppBar(
        shape:
            const CircularNotchedRectangle(),

        notchMargin: 8,

        child: SizedBox(
          height: 60,

          child: Row(
            mainAxisAlignment:
                MainAxisAlignment.spaceAround,

            children: [
              IconButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                icon: const Icon(
                  Icons.home_outlined,
                ),
                tooltip: 'Beranda',
              ),

              IconButton(
                onPressed: () {
                  ScaffoldMessenger.of(context)
                      .showSnackBar(
                    const SnackBar(
                      content: Text(
                        'Daftar laporan aktif.',
                      ),
                    ),
                  );
                },
                icon: const Icon(
                  Icons.assignment_outlined,
                ),
                tooltip: 'Laporan',
              ),

              const SizedBox(
                width: 48,
              ),

              IconButton(
                onPressed: () {
                  ScaffoldMessenger.of(context)
                      .showSnackBar(
                    const SnackBar(
                      content: Text(
                        'Profil warga.',
                      ),
                    ),
                  );
                },
                icon: const Icon(
                  Icons.person_outline,
                ),
                tooltip: 'Profil',
              ),
            ],
          ),
        ),
      ),
    );
  }
}