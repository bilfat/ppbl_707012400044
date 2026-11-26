import 'dart:typed_data';

// ============================================================
// MODEL FILE SAMPUL YANG AKAN DIUNGGAH
// ============================================================
// Isi file disimpan dalam bentuk bytes agar bisa dipakai di
// Android, iOS, Web, maupun Desktop.
class UploadFile {
  final String name;
  final Uint8List bytes;

  UploadFile({required this.name, required this.bytes});

  /// Ukuran file dalam KB / MB, contoh: "1.2 MB"
  String get sizeText {
    final kb = bytes.length / 1024;
    if (kb < 1024) return '${kb.toStringAsFixed(0)} KB';
    return '${(kb / 1024).toStringAsFixed(1)} MB';
  }
}
