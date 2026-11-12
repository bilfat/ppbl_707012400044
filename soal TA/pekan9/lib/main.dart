import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'app.dart';
import 'data/helpers/hive_helper.dart';
import 'data/helpers/pengaturan_helper.dart';
import 'features/sensor/cubit/sensor_cubit.dart';
import 'features/settings/cubit/pengaturan_cubit.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Inisialisasi penyimpanan lokal sebelum aplikasi dijalankan.
  await HiveHelper.instance.init();
  await PengaturanHelper.instance.init();

  runApp(
    MultiBlocProvider(
      providers: [
        BlocProvider<SensorCubit>(
          create: (_) => SensorCubit(
            HiveHelper.instance.pembacaanSensorBox,
          )..muatRiwayat(),
        ),
        BlocProvider<PengaturanCubit>(
          create: (_) => PengaturanCubit(
            PengaturanHelper.instance,
          )..muatPengaturan(),
        ),
      ],
      child: const AiotApp(),
    ),
  );
}
