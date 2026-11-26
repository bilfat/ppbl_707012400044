import 'package:flutter/foundation.dart';

// ============================================================
// KONFIGURASI ALAMAT API
// ============================================================
// Jalankan Laravel dengan perintah:
//   php artisan serve --host=0.0.0.0 --port=8000
//
// - Web / Desktop (Chrome, Edge, Windows) : otomatis pakai 127.0.0.1
// - Android Emulator                      : otomatis pakai 10.0.2.2
// - HP Android fisik (Wi-Fi yang sama)    : ubah androidHost menjadi IP laptop
//   (cek lewat `ipconfig`, misal: '10.66.184.110')

class ApiConfig {
  // Ganti ke IPv4 laptop (misal '10.66.184.110') jika menjalankan di HP fisik.
  // Biarkan '10.0.2.2' jika menjalankan di Android Emulator.
  static const String androidHost = '10.0.2.2';
  static const String port = '8000';

  static String get ip {
    if (kIsWeb) return '127.0.0.1';
    if (defaultTargetPlatform == TargetPlatform.android) return androidHost;
    return '127.0.0.1';
  }

  static String get baseUrl => 'http://$ip:$port/api';
}
