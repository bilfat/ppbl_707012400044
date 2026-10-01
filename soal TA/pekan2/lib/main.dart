import 'package:flutter/material.dart';

import 'navigation/app_routes.dart';

void main() {
  runApp(const NusantaraCerdasApp());
}

class NusantaraCerdasApp extends StatelessWidget {
  const NusantaraCerdasApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Nusantara Cerdas Mobile',
      debugShowCheckedModeBanner: false,

      theme: ThemeData(
        colorSchemeSeed: Colors.indigo,
        useMaterial3: true,
      ),

      // Route awal
      initialRoute: AppRoutes.beranda,

      // Named route
      routes: AppRoutes.daftarRoute(),

      // onGenerateRoute
      onGenerateRoute: AppRoutes.bentukRoute,

      // Route tidak dikenal
      onUnknownRoute: AppRoutes.routeTidakDikenal,
    );
  }
}