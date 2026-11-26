import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../config/app_theme.dart';

// ============================================================
// FUNGSI BANTUAN
// ============================================================

/// Kunci global agar SnackBar bisa ditampilkan dari mana saja.
/// Dipasang di MaterialApp (lihat main.dart).
final messengerKey = GlobalKey<ScaffoldMessengerState>();

/// Menampilkan pesan di bagian bawah layar.
/// Hijau untuk sukses, merah untuk error.
void showMessage(String text, {bool isError = false}) {
  messengerKey.currentState
    ?..hideCurrentSnackBar()
    ..showSnackBar(
      SnackBar(
        behavior: SnackBarBehavior.floating,
        backgroundColor: isError ? AppColors.danger : AppColors.success,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        content: Row(
          children: [
            Icon(
              isError ? Icons.error_outline : Icons.check_circle_outline,
              color: Colors.white,
            ),
            const SizedBox(width: 12),
            Expanded(child: Text(text)),
          ],
        ),
      ),
    );
}

// ------------------------------------------------------------
// FILE SAMPUL BUKU
// ------------------------------------------------------------

/// Ekstensi sampul yang diizinkan (sama dengan validasi Laravel SiPustaka)
const allowedCoverExtensions = ['jpg', 'jpeg', 'png'];

/// Batas ukuran file sampul: 2 MB
const maxCoverSize = 2 * 1024 * 1024;

/// Mengambil ekstensi file, contoh: "sampul.PNG" -> "png"
String fileExtension(String fileName) {
  if (!fileName.contains('.')) return '';
  return fileName.split('.').last.toLowerCase();
}

/// Apakah file sampul berformat jpg, jpeg, atau png?
bool isAllowedCoverFile(String fileName) {
  return allowedCoverExtensions.contains(fileExtension(fileName));
}

/// Ikon sesuai jenis file
IconData fileIcon(String fileName) {
  switch (fileExtension(fileName)) {
    case 'jpg':
    case 'jpeg':
    case 'png':
      return Icons.image_rounded;
    case 'pdf':
      return Icons.picture_as_pdf_rounded;
    default:
      return Icons.insert_drive_file_rounded;
  }
}

/// Warna sesuai jenis file
Color fileColor(String fileName) {
  switch (fileExtension(fileName)) {
    case 'jpg':
    case 'jpeg':
    case 'png':
      return AppColors.primary;
    case 'pdf':
      return const Color(0xFFE74C3C);
    default:
      return AppColors.textGrey;
  }
}

/// Membuka URL (gambar sampul) di browser / aplikasi lain
Future<void> openUrl(String url) async {
  final success = await launchUrl(
    Uri.parse(url),
    mode: LaunchMode.externalApplication,
  );
  if (!success) showMessage('Tidak bisa membuka file', isError: true);
}

// ------------------------------------------------------------
// TANGGAL
// ------------------------------------------------------------

const _bulan = [
  'Jan', 'Feb', 'Mar', 'Apr', 'Mei', 'Jun',
  'Jul', 'Agu', 'Sep', 'Okt', 'Nov', 'Des',
];

/// Mengubah DateTime menjadi teks, contoh: "14 Nov 2026, 10:00"
String formatTanggal(DateTime? date) {
  if (date == null) return '-';
  final jam = date.hour.toString().padLeft(2, '0');
  final menit = date.minute.toString().padLeft(2, '0');
  return '${date.day} ${_bulan[date.month - 1]} ${date.year}, $jam:$menit';
}

/// Mengubah string tanggal "2026-11-26" menjadi "26 Nov 2026"
String formatTanggalPendek(String? rawDate) {
  if (rawDate == null || rawDate.isEmpty) return '-';
  final parsed = DateTime.tryParse(rawDate);
  if (parsed == null) return rawDate;
  return '${parsed.day} ${_bulan[parsed.month - 1]} ${parsed.year}';
}

/// Mengubah DateTime menjadi format API "YYYY-MM-DD"
String toApiDate(DateTime date) {
  final y = date.year.toString().padLeft(4, '0');
  final m = date.month.toString().padLeft(2, '0');
  final d = date.day.toString().padLeft(2, '0');
  return '$y-$m-$d';
}
