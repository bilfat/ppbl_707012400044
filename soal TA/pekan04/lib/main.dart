import 'package:flutter/material.dart';
import 'package:pekan04/models/pengajuan_model.dart';
import 'package:provider/provider.dart';

import 'models/pengajuan_model.dart';
import 'navigation/app_routes.dart';

void main() {
  runApp(
    ChangeNotifierProvider(
      create: (_) => PengajuanModel(),

      child: MaterialApp(
        debugShowCheckedModeBanner: false,

        title: 'Nusantara Cerdas Mobile',

        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(
            seedColor: Colors.blue,
          ),
          useMaterial3: true,
        ),

        initialRoute: AppRoutes.beranda,

        routes: AppRoutes.daftarRoute(),

        onGenerateRoute:
            AppRoutes.bentukRoute,

        onUnknownRoute:
            AppRoutes.routeTidakDikenal,
      ),
    ),
  );
}