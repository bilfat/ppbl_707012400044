import 'package:flutter_bloc/flutter_bloc.dart';
import '../services/api_service.dart';
import 'auth_state.dart';

// ============================================================
// AUTH CUBIT
// ============================================================
// Pola setiap fungsi: loading -> try -> emit data / emit error
class AuthCubit extends Cubit<AuthState> {
  final ApiService api;

  AuthCubit(this.api) : super(const AuthState(isChecking: true));

  /// Dipanggil saat aplikasi dibuka.
  /// Jika ada token tersimpan di shared_preferences, cek ke GET /auth/me.
  Future<void> checkLogin() async {
    emit(const AuthState(isChecking: true));
    final token = await api.getToken();
    if (token == null) {
      emit(const AuthState());
      return;
    }

    try {
      final user = await api.getMe();
      emit(AuthState(user: user));
    } on ApiException catch (e) {
      if (e.statusCode == 401) {
        await api.removeToken();
        emit(AuthState(message: e.message, isError: true));
      } else {
        emit(const AuthState());
      }
    }
  }

  /// Login. Mengembalikan true jika berhasil.
  Future<bool> login(String email, String password) async {
    emit(const AuthState(isLoading: true));
    try {
      final user = await api.login(email, password);
      emit(AuthState(
        user: user,
        message: 'Login berhasil. Halo, ${user.name}!',
      ));
      return true;
    } on ApiException catch (e) {
      emit(AuthState(message: e.message, isError: true));
      return false;
    }
  }

  /// Registrasi akun baru. Mengembalikan true jika berhasil.
  Future<bool> register(String name, String email, String password) async {
    emit(const AuthState(isLoading: true));
    try {
      await api.register(name, email, password);
      emit(const AuthState(message: 'Registrasi berhasil, silakan login'));
      return true;
    } on ApiException catch (e) {
      emit(AuthState(message: e.message, isError: true));
      return false;
    }
  }

  /// Logout: hapus token di server dan perangkat.
  Future<void> logout() async {
    emit(AuthState(user: state.user, isLoading: true));
    try {
      await api.logout();
    } on ApiException {
      // Token lokal tetap sudah dihapus oleh ApiService
    }
    emit(const AuthState(message: 'Logout berhasil. Sampai jumpa!'));
  }
}
