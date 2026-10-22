import 'package:flutter/material.dart';

import 'navigation/app_routes.dart';
import 'navigation/kerangka_navigasi.dart';
import 'pages/halaman_detail.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Navigasi Adaptif',

      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF4F5BD5),
        ),
        scaffoldBackgroundColor: const Color(0xFFFBF9FF),
      ),

      // Halaman awal
      home: const KerangkaNavigasi(),

      // Named Route
      routes: {
        AppRoutes.detail: (context) => const HalamanDetail(),
      },
    );
  }
}