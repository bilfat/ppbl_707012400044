import 'package:flutter/material.dart';

import 'core/theme/app_theme.dart';
import 'pages/home_page.dart';

class AiotApp extends StatelessWidget {
  const AiotApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'AIoT Peringatan Dini Bencana',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      home: const HomePage(),
    );
  }
}
