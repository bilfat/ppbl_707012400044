import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../config/api_config.dart';
import '../models/book.dart';
import '../models/loan.dart';
import '../models/upload_file.dart';
import '../models/user.dart';

// ============================================================
// API SERVICE SIPUSTAKA
// ============================================================
// Semua komunikasi dengan REST API Laravel SiPustaka ada di file ini.
//
// | Method | Endpoint              | Butuh token? |
// |--------|-----------------------|--------------|
// | POST   | /auth/register        | Tidak        |
// | POST   | /auth/login           | Tidak        |
// | GET    | /auth/me              | Ya           |
// | POST   | /auth/logout          | Ya           |
// | GET    | /books                | Tidak        |
// | GET    | /books/{id}           | Tidak        |
// | GET    | /books/{id}/cover     | Tidak        |
// | POST   | /books                | Ya           |
// | PATCH  | /books/{id}           | Ya           |
// | DELETE | /books/{id}           | Ya           |
// | GET    | /loans                | Ya           |
// | POST   | /loans                | Ya           |
// | GET    | /loans/{id}           | Ya           |
// | PATCH  | /loans/{id}           | Ya           |
// | DELETE | /loans/{id}           | Ya           |

/// Error yang dikirim ketika request ke API gagal.
class ApiException implements Exception {
  final String message;
  final int statusCode; // 0 artinya tidak bisa terhubung ke server

  ApiException(this.message, this.statusCode);

  @override
  String toString() => message;
}

class ApiService {
  final http.Client client;

  ApiService({http.Client? client}) : client = client ?? http.Client();

  // ----------------------------------------------------------
  // 1. MENYIMPAN TOKEN (shared_preferences)
  // ----------------------------------------------------------

  Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('token');
  }

  Future<void> saveToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('token', token);
  }

  Future<void> removeToken() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('token');
  }

  // ----------------------------------------------------------
  // 2. FUNGSI BANTUAN
  // ----------------------------------------------------------

  /// Membuat URL lengkap, contoh: '/books' -> http://IP:8000/api/books
  Uri _url(String path) => Uri.parse('${ApiConfig.baseUrl}$path');

  /// Header yang dikirim di setiap request.
  /// Jika [withToken] true, token ditambahkan: `Authorization: Bearer <token>`
  Future<Map<String, String>> _headers({bool withToken = false}) async {
    final headers = {
      'Accept': 'application/json',
      'Content-Type': 'application/json',
    };
    if (withToken) {
      final token = await getToken();
      if (token != null) headers['Authorization'] = 'Bearer $token';
    }
    return headers;
  }

  /// Mengirim request lalu memeriksa status code (200-299, 401, 403, 404, 409, 422).
  Future<dynamic> _send(Future<http.Response> Function() request) async {
    http.Response response;
    try {
      response = await request().timeout(const Duration(seconds: 10));
    } catch (_) {
      throw ApiException(
        'Tidak bisa terhubung ke server.\n'
        'Pastikan Laravel berjalan di ${ApiConfig.baseUrl}',
        0,
      );
    }

    dynamic data;
    try {
      data = response.body.isEmpty ? null : jsonDecode(response.body);
    } catch (_) {
      data = null;
    }

    if (response.statusCode >= 200 && response.statusCode < 300) {
      return data;
    }

    String message = 'Terjadi kesalahan (kode ${response.statusCode})';

    if (response.statusCode == 401 &&
        data is Map &&
        data['message'] == 'Unauthenticated.') {
      message = 'Sesi login habis, silakan login ulang';
    } else if (response.statusCode == 422 &&
        data is Map &&
        data['errors'] is Map) {
      final errors = data['errors'] as Map;
      message = errors.values
          .map((e) => e is List && e.isNotEmpty ? e.first.toString() : '$e')
          .join('\n');
    } else if (data is Map && data['message'] != null) {
      message = data['message'].toString();
    } else {
      switch (response.statusCode) {
        case 401:
          message = 'Sesi login tidak valid atau kredensial salah';
          break;
        case 403:
          message = 'Anda tidak memiliki izin untuk aksi ini';
          break;
        case 404:
          message = 'Data tidak ditemukan';
          break;
        case 409:
          message = 'Terjadi konflik data';
          break;
        case 422:
          message = 'Data yang dikirim tidak valid';
          break;
      }
    }

    throw ApiException(message, response.statusCode);
  }

  /// Mengirim form + file sampul (multipart/form-data).
  Future<http.Response> _sendMultipart(
    String path,
    Map<String, String> fields,
    UploadFile? file, {
    String fileField = 'cover',
  }) async {
    final request = http.MultipartRequest('POST', _url(path));
    final headers = await _headers(withToken: true);
    headers.remove('Content-Type'); // diisi otomatis dengan boundary
    request.headers.addAll(headers);
    request.fields.addAll(fields);

    if (file != null) {
      request.files.add(http.MultipartFile.fromBytes(
        fileField,
        file.bytes,
        filename: file.name,
      ));
    }

    final streamed = await client.send(request);
    return http.Response.fromStream(streamed);
  }

  // ----------------------------------------------------------
  // 3. AUTENTIKASI
  // ----------------------------------------------------------

  Future<void> register(String name, String email, String password) async {
    await _send(() async => client.post(
          _url('/auth/register'),
          headers: await _headers(),
          body: jsonEncode({
            'name': name,
            'email': email,
            'password': password,
          }),
        ));
  }

  Future<User> login(String email, String password) async {
    final data = await _send(() async => client.post(
          _url('/auth/login'),
          headers: await _headers(),
          body: jsonEncode({'email': email, 'password': password}),
        ));

    await saveToken(data['access_token']);
    return User.fromJson(data['user']);
  }

  Future<User> getMe() async {
    final data = await _send(() async => client.get(
          _url('/auth/me'),
          headers: await _headers(withToken: true),
        ));
    return User.fromJson(data);
  }

  Future<void> logout() async {
    try {
      await _send(() async => client.post(
            _url('/auth/logout'),
            headers: await _headers(withToken: true),
          ));
    } finally {
      await removeToken();
    }
  }

  // ----------------------------------------------------------
  // 4. CRUD BUKU (/api/books)
  // ----------------------------------------------------------

  Future<List<Book>> getBooks() async {
    final data = await _send(() async => client.get(
          _url('/books'),
          headers: await _headers(),
        ));
    return (data as List).map((item) => Book.fromJson(item)).toList();
  }

  Future<Book> getBook(int id) async {
    final data = await _send(() async => client.get(
          _url('/books/$id'),
          headers: await _headers(),
        ));
    return Book.fromJson(data);
  }

  /// CREATE: POST /books (multipart/form-data dengan field opsional `cover`)
  Future<Book> createBook({
    required String judul,
    required String penulis,
    required String penerbit,
    required int tahunTerbit,
    required int stok,
    UploadFile? cover,
  }) async {
    final data = await _send(() => _sendMultipart(
          '/books',
          {
            'judul': judul,
            'penulis': penulis,
            'penerbit': penerbit,
            'tahun_terbit': tahunTerbit.toString(),
            'stok': stok.toString(),
          },
          cover,
          fileField: 'cover',
        ));
    return Book.fromJson(data);
  }

  /// UPDATE: POST /books/{id} + _method=PATCH (method spoofing untuk file)
  Future<Book> updateBook(
    int id, {
    required String judul,
    required String penulis,
    required String penerbit,
    required int tahunTerbit,
    required int stok,
    UploadFile? cover,
    bool removeCover = false,
  }) async {
    final data = await _send(() => _sendMultipart(
          '/books/$id',
          {
            '_method': 'PATCH',
            'judul': judul,
            'penulis': penulis,
            'penerbit': penerbit,
            'tahun_terbit': tahunTerbit.toString(),
            'stok': stok.toString(),
            if (removeCover) 'remove_cover': '1',
          },
          cover,
          fileField: 'cover',
        ));
    return Book.fromJson(data);
  }

  Future<void> deleteBook(int id) async {
    await _send(() async => client.delete(
          _url('/books/$id'),
          headers: await _headers(withToken: true),
        ));
  }

  // ----------------------------------------------------------
  // 5. CRUD PEMINJAMAN (/api/loans)
  // ----------------------------------------------------------

  Future<List<Loan>> getLoans() async {
    final data = await _send(() async => client.get(
          _url('/loans'),
          headers: await _headers(withToken: true),
        ));
    return (data as List).map((item) => Loan.fromJson(item)).toList();
  }

  Future<Loan> getLoan(int id) async {
    final data = await _send(() async => client.get(
          _url('/loans/$id'),
          headers: await _headers(withToken: true),
        ));
    return Loan.fromJson(data);
  }

  Future<Loan> createLoan({
    required int bookId,
    required String tanggalPinjam,
  }) async {
    final data = await _send(() async => client.post(
          _url('/loans'),
          headers: await _headers(withToken: true),
          body: jsonEncode({
            'book_id': bookId,
            'tanggal_pinjam': tanggalPinjam,
          }),
        ));
    return Loan.fromJson(data);
  }

  Future<Loan> updateLoan(
    int id, {
    String? status,
    String? tanggalPinjam,
    String? tanggalKembali,
  }) async {
    final body = <String, dynamic>{};
    if (status != null) body['status'] = status;
    if (tanggalPinjam != null) body['tanggal_pinjam'] = tanggalPinjam;
    if (tanggalKembali != null) body['tanggal_kembali'] = tanggalKembali;

    final data = await _send(() async => client.patch(
          _url('/loans/$id'),
          headers: await _headers(withToken: true),
          body: jsonEncode(body),
        ));
    return Loan.fromJson(data);
  }

  Future<void> deleteLoan(int id) async {
    await _send(() async => client.delete(
          _url('/loans/$id'),
          headers: await _headers(withToken: true),
        ));
  }
}
