import 'package:flutter/material.dart';

import '../database/database_helper.dart';
import '../models/pembacaan_sensor.dart';
import '../widgets/status_chip.dart';

class HistoryPage extends StatefulWidget {
  final VoidCallback onDataChanged;

  const HistoryPage({super.key, required this.onDataChanged});

  @override
  State<HistoryPage> createState() => _HistoryPageState();
}

class _HistoryPageState extends State<HistoryPage> {
  final TextEditingController _searchController = TextEditingController();
  String _selectedType = 'semua';
  late Future<List<PembacaanSensor>> _historyFuture;

  @override
  void initState() {
    super.initState();
    _loadHistory();
    _searchController.addListener(() => setState(() {}));
  }

  void _loadHistory() {
    _historyFuture = DatabaseHelper.instance.ambilSemuaPembacaan(
      jenisSensor: _selectedType,
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
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

  String _formatDate(String rawDate) {
    final date = DateTime.tryParse(rawDate)?.toLocal();
    if (date == null) return rawDate;

    final day = date.day.toString().padLeft(2, '0');
    final month = date.month.toString().padLeft(2, '0');
    final hour = date.hour.toString().padLeft(2, '0');
    final minute = date.minute.toString().padLeft(2, '0');
    return '$day/$month/${date.year} • $hour:$minute';
  }

  Future<void> _editSensor(PembacaanSensor sensor) async {
    if (sensor.id == null) return;

    final controller = TextEditingController(text: sensor.nilai.toString());
    final newValue = await showDialog<double>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Ubah nilai pembacaan'),
        content: TextField(
          controller: controller,
          autofocus: true,
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          decoration: InputDecoration(labelText: 'Nilai (${_unit(sensor.jenisSensor)})'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Batal'),
          ),
          FilledButton(
            onPressed: () {
              final value = double.tryParse(controller.text.trim().replaceAll(',', '.'));
              if (value != null && value >= 0) {
                Navigator.pop(dialogContext, value);
              }
            },
            child: const Text('Simpan'),
          ),
        ],
      ),
    );
    controller.dispose();

    if (newValue == null) return;
    await DatabaseHelper.instance.ubahPembacaan(sensor.id!, newValue);
    if (!mounted) return;
    setState(_loadHistory);
    widget.onDataChanged();
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Pembacaan berhasil diperbarui.')),
    );
  }

  Future<bool> _confirmDelete(PembacaanSensor sensor) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Hapus pembacaan?'),
        content: Text('Data ${_label(sensor.jenisSensor)} dari ${sensor.lokasiPos} akan dihapus.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('Batal'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: const Color(0xFFD94343)),
            onPressed: () => Navigator.pop(dialogContext, true),
            child: const Text('Hapus'),
          ),
        ],
      ),
    );
    return confirmed ?? false;
  }

  Future<void> _deleteSensor(PembacaanSensor sensor) async {
    if (sensor.id == null) return;
    await DatabaseHelper.instance.hapusPembacaan(sensor.id!);
    if (!mounted) return;
    setState(_loadHistory);
    widget.onDataChanged();
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Pembacaan berhasil dihapus.')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 14, 16, 10),
          child: Column(
            children: [
              TextField(
                controller: _searchController,
                decoration: InputDecoration(
                  hintText: 'Cari lokasi atau jenis sensor...',
                  prefixIcon: const Icon(Icons.search_rounded),
                  suffixIcon: _searchController.text.isEmpty
                      ? null
                      : IconButton(
                          onPressed: _searchController.clear,
                          icon: const Icon(Icons.close_rounded),
                        ),
                ),
              ),
              const SizedBox(height: 10),
              DropdownButtonFormField<String>(
                value: _selectedType,
                decoration: const InputDecoration(
                  labelText: 'Filter jenis sensor',
                  prefixIcon: Icon(Icons.filter_list_rounded),
                  contentPadding: EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                ),
                items: const [
                  DropdownMenuItem(value: 'semua', child: Text('Semua jenis sensor')),
                  DropdownMenuItem(value: 'ketinggian_air', child: Text('Ketinggian air')),
                  DropdownMenuItem(value: 'pergeseran_tanah', child: Text('Pergeseran tanah')),
                  DropdownMenuItem(value: 'curah_hujan', child: Text('Curah hujan')),
                ],
                onChanged: (value) {
                  if (value == null) return;
                  setState(() {
                    _selectedType = value;
                    _loadHistory();
                  });
                },
              ),
            ],
          ),
        ),
        Expanded(
          child: FutureBuilder<List<PembacaanSensor>>(
            future: _historyFuture,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }
              if (snapshot.hasError) {
                return Center(child: Text('Gagal memuat data: ${snapshot.error}'));
              }

              final keyword = _searchController.text.trim().toLowerCase();
              final allRecords = snapshot.data ?? [];
              final records = allRecords.where((sensor) {
                final locationMatch = sensor.lokasiPos.toLowerCase().contains(keyword);
                final typeMatch = _label(sensor.jenisSensor).toLowerCase().contains(keyword);
                return locationMatch || typeMatch;
              }).toList();

              if (records.isEmpty) {
                return RefreshIndicator(
                  onRefresh: () async => setState(_loadHistory),
                  child: ListView(
                    children: const [
                      SizedBox(height: 100),
                      Icon(Icons.inbox_outlined, size: 42),
                      SizedBox(height: 12),
                      Center(child: Text('Belum ada data yang cocok.')),
                    ],
                  ),
                );
              }

              return RefreshIndicator(
                onRefresh: () async => setState(_loadHistory),
                child: ListView.separated(
                  padding: const EdgeInsets.fromLTRB(16, 4, 16, 24),
                  itemCount: records.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 9),
                  itemBuilder: (context, index) {
                    final sensor = records[index];
                    return Dismissible(
                      key: ValueKey(sensor.id),
                      direction: DismissDirection.endToStart,
                      confirmDismiss: (_) => _confirmDelete(sensor),
                      onDismissed: (_) => _deleteSensor(sensor),
                      background: Container(
                        alignment: Alignment.centerRight,
                        padding: const EdgeInsets.only(right: 22),
                        decoration: BoxDecoration(
                          color: const Color(0xFFD94343),
                          borderRadius: BorderRadius.circular(18),
                        ),
                        child: const Icon(Icons.delete_outline, color: Colors.white),
                      ),
                      child: Card(
                        child: Padding(
                          padding: const EdgeInsets.all(14),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Expanded(
                                    child: Text(
                                      _label(sensor.jenisSensor),
                                      style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 14),
                                    ),
                                  ),
                                  StatusChip(status: _status(sensor)),
                                  PopupMenuButton<String>(
                                    tooltip: 'Aksi data',
                                    onSelected: (value) {
                                      if (value == 'edit') _editSensor(sensor);
                                      if (value == 'delete') _deleteAfterConfirm(sensor);
                                    },
                                    itemBuilder: (_) => const [
                                      PopupMenuItem(value: 'edit', child: Text('Ubah nilai')),
                                      PopupMenuItem(value: 'delete', child: Text('Hapus data')),
                                    ],
                                  ),
                                ],
                              ),
                              const SizedBox(height: 8),
                              Text(
                                '${sensor.nilai.toStringAsFixed(sensor.nilai % 1 == 0 ? 0 : 1)} ${_unit(sensor.jenisSensor)}',
                                style: TextStyle(
                                  color: Theme.of(context).colorScheme.primary,
                                  fontSize: 22,
                                  fontWeight: FontWeight.w900,
                                ),
                              ),
                              const SizedBox(height: 7),
                              Row(
                                children: [
                                  const Icon(Icons.place_outlined, size: 15),
                                  const SizedBox(width: 5),
                                  Expanded(child: Text(sensor.lokasiPos, style: const TextStyle(fontSize: 12))),
                                ],
                              ),
                              const SizedBox(height: 4),
                              Row(
                                children: [
                                  const Icon(Icons.schedule_rounded, size: 15),
                                  const SizedBox(width: 5),
                                  Text(_formatDate(sensor.waktu), style: const TextStyle(fontSize: 11)),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Future<void> _deleteAfterConfirm(PembacaanSensor sensor) async {
    final confirmed = await _confirmDelete(sensor);
    if (confirmed) await _deleteSensor(sensor);
  }
}
