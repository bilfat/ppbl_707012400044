import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/pengajuan_model.dart';

class WargaPage extends StatelessWidget {
  const WargaPage({super.key});

  @override
  Widget build(BuildContext context) {
    final model = context.watch<PengajuanModel>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Nusantara Cerdas'),
      ),

      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.pushNamed(
            context,
            '/pengajuan',
          );
        },
        icon: const Icon(Icons.add),
        label: const Text('Pengajuan Baru'),
      ),

      body: model.daftarPengajuan.isEmpty
          ? const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.assignment_outlined,
                    size: 80,
                  ),
                  SizedBox(height: 16),
                  Text(
                    'Belum ada pengajuan',
                    style: TextStyle(
                      fontSize: 18,
                    ),
                  ),
                ],
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: model.daftarPengajuan.length,
              itemBuilder: (context, index) {
                final pengajuan = model.daftarPengajuan[index];

                return GestureDetector(
                  onTap: () {
                    Navigator.pushNamed(
                      context,
                      '/detail-pengajuan',
                      arguments: pengajuan,
                    );
                  },

                  onLongPress: () {
                    model.tandaiSelesai(
                      pengajuan.id,
                    );

                    ScaffoldMessenger.of(context)
                        .showSnackBar(
                      const SnackBar(
                        content: Text(
                          'Pengajuan ditandai selesai',
                        ),
                      ),
                    );
                  },

                  child: Card(
                    margin: const EdgeInsets.only(
                      bottom: 12,
                    ),
                    child: ListTile(
                      leading: CircleAvatar(
                        child: Icon(
                          pengajuan.selesai
                              ? Icons.check
                              : Icons.assignment,
                        ),
                      ),
                      title: Text(
                        pengajuan.bidang,
                      ),
                      subtitle: Text(
                        '${pengajuan.nama}\nSesi ${pengajuan.sesi}',
                      ),
                      isThreeLine: true,
                      trailing: pengajuan.selesai
                          ? const Chip(
                              label: Text('Selesai'),
                            )
                          : const Chip(
                              label: Text('Proses'),
                            ),
                    ),
                  ),
                );
              },
            ),
    );
  }
}