import 'package:flutter/foundation.dart';

// ============================================================
// KONFIGURASI ALAMAT API SIPUSTAKA
// ============================================================
// Jalankan Laravel dengan perintah:
//   cd sipustaka_api_707012400044
//   php artisan serve --host=0.0.0.0 --port=8000
//
// Ganti [ip] dengan IP laptop kamu (cek lewat perintah `ipconfig`),
// atau gunakan '10.0.2.2' jika menjalankan di Android Emulator.
// HP / emulator dan laptop harus berada di jaringan Wi-Fi yang sama.
class ApiConfig {
  static const String ip = '10.66.184.110';
  static const String port = '8000';

  /// Base URL REST API SiPustaka:
  /// - Web / Desktop (Windows/macOS/Linux): http://127.0.0.1:8000/api
  /// - Android / iOS: http://`ip`:8000/api
  static String get baseUrl {
    if (kIsWeb ||
        defaultTargetPlatform == TargetPlatform.windows ||
        defaultTargetPlatform == TargetPlatform.macOS ||
        defaultTargetPlatform == TargetPlatform.linux) {
      return 'http://127.0.0.1:$port/api';
    }
    return 'http://$ip:$port/api';
  }
}
