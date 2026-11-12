import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../core/constants/sensor_config.dart';
import '../features/settings/cubit/pengaturan_cubit.dart';

Color warnaStatusSiaga(StatusSiaga status) {
  switch (status) {
    case StatusSiaga.aman:
      return Colors.green;
    case StatusSiaga.waspada:
      return Colors.orange;
    case StatusSiaga.siaga:
      return Colors.red;
  }
}

class StatusSiagaBadge extends StatelessWidget {
  const StatusSiagaBadge({
    super.key,
    required this.jenis,
    required this.nilai,
  });

  final JenisSensor jenis;
  final double nilai;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<PengaturanCubit, Map<JenisSensor, AmbangBatas>>(
      builder: (context, pengaturan) {
        final ambang = pengaturan[jenis] ??
            AmbangBatas(
              waspada: jenis.defaultWaspada,
              siaga: jenis.defaultSiaga,
            );
        final status = hitungStatusSiaga(nilai, ambang);
        final warna = warnaStatusSiaga(status);

        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
          decoration: BoxDecoration(
            color: warna.withOpacity(0.12),
            borderRadius: BorderRadius.circular(30),
          ),
          child: Text(
            status.label,
            style: TextStyle(
              color: warna,
              fontWeight: FontWeight.bold,
              fontSize: 12,
            ),
          ),
        );
      },
    );
  }
}
