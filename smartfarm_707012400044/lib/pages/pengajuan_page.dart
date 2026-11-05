import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../models/layanan.dart';

class PengajuanPage extends StatefulWidget {
  const PengajuanPage({super.key});

  @override
  State<PengajuanPage> createState() => _PengajuanPageState();
}

class _PengajuanPageState extends State<PengajuanPage> {
  final namaController = TextEditingController();
  final emailController = TextEditingController();

  bool setujuData = false;
  String? bidangTerpilih;
  String? sesiTerpilih;
  bool sedangMengirim = false;

  final List<String> bidang = [
    'Administrasi Kependudukan',
    'Kesehatan',
    'Perizinan',
    'Sosial',
  ];

  final List<String> sesi = [
    'Pagi',
    'Siang',
    'Sore',
  ];

  bool get formLengkap {
    return namaController.text.trim().isNotEmpty &&
        emailController.text.trim().isNotEmpty &&
        setujuData &&
        bidangTerpilih != null &&
        sesiTerpilih != null;
  }

  @override
  void dispose() {
    namaController.dispose();
    emailController.dispose();
    super.dispose();
  }

  Future<void> kirimPengajuan() async {
    if (!formLengkap) return;

    setState(() {
      sedangMengirim = true;
    });

    await Future.delayed(const Duration(seconds: 2));

    if (!mounted) return;

    // context.read<layanan>().tambahPengajuan(
    //       layanan(
    //         id: DateTime.now().millisecondsSinceEpoch.toString(),
    //         nama: namaController.text.trim(),
    //         email: emailController.text.trim(),
    //         bidang: bidangTerpilih!,
    //         sesi: sesiTerpilih!,
    //       ),
    //     );

    setState(() {
      sedangMengirim = false;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('data tersimpan'),
      ),
    );

    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Form Tambah Monitoring'),
      ),

      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Input Monitoring',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 8),

            const Text(
              'Silakan lengkapi data dibawah ini.',
            ),

            const SizedBox(height: 24),

            TextField(
              controller: namaController,
              onChanged: (_) => setState(() {}),
              decoration: const InputDecoration(
                labelText: 'Nama Lengkap',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.person),
              ),
            ),

            const SizedBox(height: 16),

            TextField(
              controller: emailController,
              onChanged: (_) => setState(() {}),
              keyboardType: TextInputType.emailAddress,
              decoration: const InputDecoration(
                labelText: 'Email',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.email),
              ),
            ),

            const SizedBox(height: 16),

            const Text(
              'Bidang Layanan',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),

            const SizedBox(height: 8),

            DropdownButtonFormField<String>(
              value: bidangTerpilih,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.miscellaneous_services),
              ),
              hint: const Text('Pilih bidang layanan'),
              items: bidang.map((item) {
                return DropdownMenuItem(
                  value: item,
                  child: Text(item),
                );
              }).toList(),
              onChanged: (value) {
                setState(() {
                  bidangTerpilih = value;
                });
              },
            ),

            const SizedBox(height: 16),

            const Text(
              'lokasi',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),

            Column(
              children: sesi.map((item) {
                return RadioListTile<String>(
                  title: Text('Sesi $item'),
                  value: item,
                  groupValue: sesiTerpilih,
                  onChanged: (value) {
                    setState(() {
                      sesiTerpilih = value;
                    });
                  },
                );
              }).toList(),
            ),

            CheckboxListTile(
              value: setujuData,
              title: const Text(
                'Data Sudah Benar.',
              ),
              onChanged: (value) {
                setState(() {
                  setujuData = value ?? false;
                });
              },
            ),

            const SizedBox(height: 20),

            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed:
                    formLengkap && !sedangMengirim
                        ? kirimPengajuan
                        : null,
                child: sedangMengirim
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                        ),
                      )
                    : const Text('Kirim Pengajuan'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}