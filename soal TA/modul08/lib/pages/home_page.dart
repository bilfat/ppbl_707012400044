import 'package:flutter/material.dart';

import '../database/database_helper.dart';
import '../models/pembacaan_sensor.dart';
import '../widgets/status_chip.dart';
import 'history_page.dart';

class HomePage extends StatefulWidget {
  final bool isDarkMode;
  final VoidCallback onToggleTheme;

  const HomePage({
    super.key,
    required this.isDarkMode,
    required this.onToggleTheme,
  });

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _selectedIndex = 0;
  int _refreshKey = 0;

  void _refresh() {
    setState(() => _refreshKey++);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            Container(
              width: 38,
              height: 38,
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primary.withOpacity(0.12),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                Icons.radar_rounded,
                color: Theme.of(context).colorScheme.primary,
              ),
            ),
            const SizedBox(width: 10),
            const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'RUANGPANTAU',
                  style: TextStyle(fontSize: 15, fontWeight: FontWeight.w900, letterSpacing: 1),
                ),
                Text(
                  'Pemantauan kondisi wilayah',
                  style: TextStyle(fontSize: 10, fontWeight: FontWeight.w400),
                ),
              ],
            ),
          ],
        ),
        actions: [
          IconButton(
            tooltip: widget.isDarkMode ? 'Aktifkan tema terang' : 'Aktifkan tema gelap',
            onPressed: widget.onToggleTheme,
            icon: Icon(widget.isDarkMode ? Icons.light_mode : Icons.dark_mode),
          ),
          const SizedBox(width: 4),
        ],
      ),
      body: IndexedStack(
        index: _selectedIndex,
        children: [
          DashboardContent(
            key: ValueKey('dashboard-$_refreshKey'),
            onDataChanged: _refresh,
          ),
          HistoryPage(
            key: ValueKey('history-$_refreshKey'),
            onDataChanged: _refresh,
          ),
        ],
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _selectedIndex,
        onDestinationSelected: (index) {
          setState(() => _selectedIndex = index);
        },
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.space_dashboard_outlined),
            selectedIcon: Icon(Icons.space_dashboard_rounded),
            label: 'Ringkasan',
          ),
          NavigationDestination(
            icon: Icon(Icons.history_rounded),
            label: 'Riwayat',
          ),
        ],
      ),
    );
  }
}

class DashboardContent extends StatefulWidget {
  final VoidCallback onDataChanged;

  const DashboardContent({super.key, required this.onDataChanged});

  @override
  State<DashboardContent> createState() => _DashboardContentState();
}

class _DashboardContentState extends State<DashboardContent> {
  late Future<List<PembacaanSensor>> _latestFuture;

  @override
  void initState() {
    super.initState();
    _load();
  }

  void _load() {
    _latestFuture = DatabaseHelper.instance.ambilPembacaanTerbaru();
  }

  String _status(PembacaanSensor sensor) {
    switch (sensor.jenisSensor) {
      case 'ketinggian_air':
        if (sensor.nilai >= 150) return 'SIAGA';
        if (sensor.nilai >= 100) return 'WASPADA';
        return 'AMAN';
      case 'pergeseran_tanah':
        if (sensor.nilai >= 10) return 'SIAGA';
        if (sensor.nilai >= 5) return 'WASPADA';
        return 'AMAN';
      case 'curah_hujan':
        if (sensor.nilai >= 50) return 'SIAGA';
        if (sensor.nilai >= 25) return 'WASPADA';
        return 'AMAN';
      default:
        return 'AMAN';
    }
  }

  String _label(String type) {
    switch (type) {
      case 'ketinggian_air':
        return 'Ketinggian air';
      case 'pergeseran_tanah':
        return 'Pergeseran tanah';
      case 'curah_hujan':
        return 'Curah hujan';
      default:
        return type;
    }
  }

  String _unit(String type) {
    switch (type) {
      case 'ketinggian_air':
        return 'cm';
      case 'pergeseran_tanah':
        return 'mm';
      default:
        return 'mm/jam';
    }
  }

  Future<void> _showAddDialog() async {
    final formKey = GlobalKey<FormState>();
    final valueController = TextEditingController();
    final locationController = TextEditingController();
    String selectedType = 'ketinggian_air';

    final result = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: const Text('Catat pembacaan sensor'),
              content: Form(
                key: formKey,
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      DropdownButtonFormField<String>(
                        value: selectedType,
                        decoration: const InputDecoration(
                          labelText: 'Jenis sensor',
                          prefixIcon: Icon(Icons.sensors_outlined),
                        ),
                        items: const [
                          DropdownMenuItem(value: 'ketinggian_air', child: Text('Ketinggian air')),
                          DropdownMenuItem(value: 'pergeseran_tanah', child: Text('Pergeseran tanah')),
                          DropdownMenuItem(value: 'curah_hujan', child: Text('Curah hujan')),
                        ],
                        onChanged: (value) {
                          if (value != null) {
                            setDialogState(() => selectedType = value);
                          }
                        },
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: valueController,
                        keyboardType: const TextInputType.numberWithOptions(decimal: true),
                        decoration: InputDecoration(
                          labelText: 'Nilai pengukuran (${_unit(selectedType)})',
                          prefixIcon: const Icon(Icons.speed_rounded),
                        ),
                        validator: (value) {
                          final number = double.tryParse((value ?? '').replaceAll(',', '.'));
                          if (number == null || number < 0) {
                            return 'Masukkan angka yang valid';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: locationController,
                        decoration: const InputDecoration(
                          labelText: 'Nama lokasi pos',
                          prefixIcon: Icon(Icons.location_on_outlined),
                        ),
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Lokasi wajib diisi';
                          }
                          return null;
                        },
                      ),
                    ],
                  ),
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(dialogContext, false),
                  child: const Text('Batal'),
                ),
                FilledButton(
                  onPressed: () async {
                    if (!formKey.currentState!.validate()) return;
                    final value = double.parse(valueController.text.replaceAll(',', '.'));
                    final sensor = PembacaanSensor(
                      jenisSensor: selectedType,
                      nilai: value,
                      lokasiPos: locationController.text.trim(),
                      waktu: DateTime.now().toIso8601String(),
                    );
                    await DatabaseHelper.instance.tambahPembacaan(sensor);
                    if (dialogContext.mounted) {
                      Navigator.pop(dialogContext, true);
                    }
                  },
                  child: const Text('Simpan'),
                ),
              ],
            );
          },
        );
      },
    );

    valueController.dispose();
    locationController.dispose();

    if (result == true && mounted) {
      setState(_load);
      widget.onDataChanged();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Pembacaan berhasil disimpan ke SQLite.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return RefreshIndicator(
      onRefresh: () async => setState(_load),
      child: ListView(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 28),
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF075B67), Color(0xFF139A9A)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(22),
            ),
            child: const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'PANTAU LINGKUNGAN',
                  style: TextStyle(color: Color(0xFFC5F4EE), fontSize: 10, fontWeight: FontWeight.w800, letterSpacing: 1.2),
                ),
                SizedBox(height: 12),
                Text(
                  'Data kecil hari ini,\nperingatan lebih dini esok hari.',
                  style: TextStyle(color: Colors.white, fontSize: 21, height: 1.3, fontWeight: FontWeight.w800),
                ),
                SizedBox(height: 8),
                Text(
                  'Simpan hasil pembacaan dari setiap pos dan pantau perubahan kondisinya.',
                  style: TextStyle(color: Color(0xFFE0F6F3), fontSize: 12, height: 1.5),
                ),
              ],
            ),
          ),
          const SizedBox(height: 22),
          Row(
            children: [
              Expanded(
                child: Text(
                  'Status pemantauan',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800),
                ),
              ),
              Icon(Icons.monitor_heart_outlined, color: colorScheme.primary),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            'Diambil dari pembacaan terbaru tiap jenis sensor.',
            style: Theme.of(context).textTheme.bodySmall,
          ),
          const SizedBox(height: 13),
          FutureBuilder<List<PembacaanSensor>>(
            future: _latestFuture,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Padding(
                  padding: EdgeInsets.all(24),
                  child: Center(child: CircularProgressIndicator()),
                );
              }
              if (snapshot.hasError) {
                return _InfoPanel(message: 'Gagal membaca database: ${snapshot.error}');
              }

              final sensors = snapshot.data ?? [];
              if (sensors.isEmpty) {
                return const _InfoPanel(
                  icon: Icons.sensors_off_outlined,
                  message: 'Belum ada pembacaan sensor. Tekan tombol di bawah untuk menambahkan data pertama.',
                );
              }

              final siaga = sensors.where((sensor) => _status(sensor) == 'SIAGA').length;
              final waspada = sensors.where((sensor) => _status(sensor) == 'WASPADA').length;
              final aman = sensors.where((sensor) => _status(sensor) == 'AMAN').length;

              return Column(
                children: [
                  Row(
                    children: [
                      Expanded(child: _SummaryBox(label: 'Aman', count: aman, color: const Color(0xFF26966B))),
                      const SizedBox(width: 8),
                      Expanded(child: _SummaryBox(label: 'Waspada', count: waspada, color: const Color(0xFFE99A27))),
                      const SizedBox(width: 8),
                      Expanded(child: _SummaryBox(label: 'Siaga', count: siaga, color: const Color(0xFFD94343))),
                    ],
                  ),
                  const SizedBox(height: 12),
                  ...sensors.map((sensor) => _SensorOverviewCard(
                    sensor: sensor,
                    label: _label(sensor.jenisSensor),
                    unit: _unit(sensor.jenisSensor),
                    status: _status(sensor),
                  )),
                ],
              );
            },
          ),
          const SizedBox(height: 18),
          FilledButton.icon(
            onPressed: _showAddDialog,
            icon: const Icon(Icons.add_rounded),
            label: const Text('Tambah pembacaan sensor'),
            style: FilledButton.styleFrom(
              minimumSize: const Size.fromHeight(52),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
            ),
          ),
          const SizedBox(height: 10),
          Text(
            'Ambang status pada aplikasi ini merupakan contoh praktikum dan dapat disesuaikan dengan standar sensor di lapangan.',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(fontSize: 10),
          ),
        ],
      ),
    );
  }
}

class _SummaryBox extends StatelessWidget {
  final String label;
  final int count;
  final Color color;

  const _SummaryBox({required this.label, required this.count, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 13, horizontal: 8),
      decoration: BoxDecoration(
        color: color.withOpacity(0.10),
        borderRadius: BorderRadius.circular(15),
      ),
      child: Column(
        children: [
          Text('$count', style: TextStyle(color: color, fontSize: 22, fontWeight: FontWeight.w900)),
          Text(label, style: TextStyle(color: color, fontSize: 11, fontWeight: FontWeight.w700)),
        ],
      ),
    );
  }
}

class _SensorOverviewCard extends StatelessWidget {
  final PembacaanSensor sensor;
  final String label;
  final String unit;
  final String status;

  const _SensorOverviewCard({
    required this.sensor,
    required this.label,
    required this.unit,
    required this.status,
  });

  IconData get _icon {
    switch (sensor.jenisSensor) {
      case 'ketinggian_air':
        return Icons.water_outlined;
      case 'pergeseran_tanah':
        return Icons.landscape_outlined;
      default:
        return Icons.cloud_outlined;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
  margin: const EdgeInsets.only(bottom: 9),
  child: ListTile(
    dense: true,
    // Gunakan visualDensity standard agar area vertical lebih leluasa
    visualDensity: VisualDensity.standard,
    contentPadding: const EdgeInsets.symmetric(
      horizontal: 15,
      vertical: 0, // Set ke 0 agar padding mengikuti batas default ListTile
    ),
    leading: CircleAvatar(
      backgroundColor: Theme.of(context)
          .colorScheme.primary
          .withOpacity(0.12),
      child: Icon(
        _icon,
        color: Theme.of(context).colorScheme.primary,
      ),
    ),
    title: Text(
      label,
      style: const TextStyle(
        fontWeight: FontWeight.w800,
        fontSize: 13,
      ),
    ),
    subtitle: Text(
      sensor.lokasiPos,
      style: const TextStyle(fontSize: 11),
    ),
    trailing: Column(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Text(
          '${sensor.nilai.toStringAsFixed(sensor.nilai % 1 == 0 ? 0 : 1)} $unit',
          style: const TextStyle(
            fontWeight: FontWeight.w900,
            fontSize: 13, // Sedikit diperkecil dari 14 ke 13 agar lebih pas
          ),
        ),
        const SizedBox(height: 1), // Mengurangi spacing dari 2 ke 1
        StatusChip(status: status),
      ],
    ),
  ),
);

  }
}

class _InfoPanel extends StatelessWidget {
  final String message;
  final IconData icon;

  const _InfoPanel({
    required this.message,
    this.icon = Icons.info_outline_rounded,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(22),
        child: Column(
          children: [
            Icon(icon, size: 34, color: Theme.of(context).colorScheme.primary),
            const SizedBox(height: 10),
            Text(message, textAlign: TextAlign.center, style: Theme.of(context).textTheme.bodyMedium),
          ],
        ),
      ),
    );
  }
}
