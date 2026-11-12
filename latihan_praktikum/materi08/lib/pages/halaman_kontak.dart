
import 'package:flutter/material.dart';
import '../models/kontak.dart';
import '../db/database_helper.dart';

class HalamanKontak extends StatefulWidget {
  const HalamanKontak({super.key});

  @override
  State<HalamanKontak> createState() => _HalamanKontakState();
}

class _HalamanKontakState extends State<HalamanKontak> {
  List<Kontak> daftarKontak = [];

  @override
  void initState() {
    super.initState();
    tampilkanKontak();
  }

  Future<void> tampilkanKontak() async {
    daftarKontak = await DatabaseHelper.instance.getKontak();

    setState(() {});
  }

  void bukaForm({Kontak? kontak}) {
    TextEditingController namaController =
        TextEditingController(text: kontak?.nama ?? '');

    TextEditingController teleponController =
        TextEditingController(text: kontak?.telepon ?? '');

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: Row(
            children: [
              const Icon(Icons.person_add, color: Color.fromARGB(255, 223, 160, 12)),
              const SizedBox(width: 10),
              Text(
                kontak == null ? 'Tambah Kontak Baru' : 'Edit Kontak',
                style: const TextStyle(fontSize: 18),
              ),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: namaController,
                decoration: const InputDecoration(
                  labelText: 'Nama Lengkap',
                  hintText: 'Contoh: Ahmad Fauzi',
                  prefixIcon: Icon(Icons.person),
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 15),
              TextField(
                controller: teleponController,
                keyboardType: TextInputType.phone,
                decoration: const InputDecoration(
                  labelText: 'Nomor Telepon',
                  hintText: '08xxxxxxxxxx',
                  prefixIcon: Icon(Icons.phone),
                  border: OutlineInputBorder(),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text('Batal'),
            ),
            ElevatedButton.icon(
              onPressed: () async {
                if (namaController.text.isEmpty ||
                    teleponController.text.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Nama dan nomor telepon harus diisi'),
                    ),
                  );
                  return;
                }

                final nama = namaController.text.trim();
                final telepon = teleponController.text.trim();

                if (nama.isEmpty || telepon.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Nama dan nomor telepon harus diisi'),
                    ),
                  );
                  return;
                }

                final data = Kontak(
                  id: kontak?.id,
                  nama: nama,
                  telepon: telepon,
                );

                try {
                  if (kontak == null) {
                    await DatabaseHelper.instance.tambahKontak(data);
                  } else {
                    await DatabaseHelper.instance.editKontak(data);
                  }

                  if (!mounted) return;
                  Navigator.pop(context);
                  await tampilkanKontak();
                  ScaffoldMessenger.of(this.context).showSnackBar(
                    SnackBar(
                      content: Text(
                        kontak == null
                            ? 'Kontak berhasil disimpan'
                            : 'Kontak berhasil diperbarui',
                      ),
                    ),
                  );
                } catch (e) {
                  if (!mounted) return;
                  ScaffoldMessenger.of(this.context).showSnackBar(
                    SnackBar(content: Text('Gagal menyimpan kontak: $e')),
                  );
                }
              },
              icon: const Icon(Icons.save),
              label: const Text('Simpan'),
            ),
          ],
        );
      },
    );
  }

  void konfirmasiHapus(Kontak kontak) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Hapus Kontak'),
          content: Text(
            'Apakah kamu yakin ingin menghapus ${kontak.nama}?',
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text('Batal'),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
              ),
              onPressed: () async {
                try {
                  await DatabaseHelper.instance.hapusKontak(kontak.id!);
                  if (!mounted) return;
                  Navigator.pop(context);
                  await tampilkanKontak();
                  ScaffoldMessenger.of(this.context).showSnackBar(
                    const SnackBar(content: Text('Kontak berhasil dihapus')),
                  );
                } catch (e) {
                  if (!mounted) return;
                  ScaffoldMessenger.of(this.context).showSnackBar(
                    SnackBar(content: Text('Gagal menghapus kontak: $e')),
                  );
                }
              },
              child: const Text('Hapus'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(255, 232, 159, 2),
        foregroundColor: Colors.white,
        title: const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Kontak Nomor HP',
              style: TextStyle(fontSize: 18),
            ),
            Text(
              'daftar nama dan kontak',
              style: TextStyle(fontSize: 12),
            ),
          ],
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 15),
            child: OutlinedButton(
              onPressed: () {
                bukaForm();
              },
              style: OutlinedButton.styleFrom(
                foregroundColor: Colors.white,
                side: const BorderSide(color: Colors.white),
              ),
              child: const Text('Kontak'),
            ),
          ),
        ],
      ),
      body: daftarKontak.isEmpty
          ? Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.contact_phone,
                    size: 65,
                    color: Colors.grey.shade400,
                  ),
                  const SizedBox(height: 15),
                  const Text(
                    'Belum ada kontak tersimpan.',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 5),
                  const Text(
                    'Tekan tombol + di bawah untuk menambahkan\nkontak baru.',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.grey),
                  ),
                ],
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(15),
              itemCount: daftarKontak.length,
              itemBuilder: (context, index) {
                Kontak kontak = daftarKontak[index];

                return Card(
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundColor: Colors.blue.shade100,
                      child: Text(
                        kontak.nama[0].toUpperCase(),
                        style: const TextStyle(color: Colors.blue),
                      ),
                    ),
                    title: Text(
                      kontak.nama,
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    subtitle: Text('☎ ${kontak.telepon}'),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: const Icon(
                            Icons.edit,
                            color: Colors.blue,
                          ),
                          onPressed: () {
                            bukaForm(kontak: kontak);
                          },
                        ),
                        IconButton(
                          icon: const Icon(
                            Icons.delete,
                            color: Colors.red,
                          ),
                          onPressed: () {
                            konfirmasiHapus(kontak);
                          },
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          bukaForm();
        },
        backgroundColor: Colors.blue.shade800,
        foregroundColor: Colors.white,
        icon: const Icon(Icons.add),
        label: const Text('Tambah Kontak'),
      ),
    );
  }
}
