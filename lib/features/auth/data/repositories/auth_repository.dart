import 'dart:convert';
import 'package:dio/dio.dart';
import '../../../../core/network/smpt_api_client.dart';
import '../../../../core/storage/secure_storage_service.dart';
import '../models/auth_user.dart';

/// Repository untuk semua operasi autentikasi.
/// Terhubung ke SMPT backend via JWT.
class AuthRepository {
  final Dio _dio = SmptApiClient.instance;

  /// Login dengan email & password.
  /// Returns [AuthUser] jika berhasil, throws [Exception] jika gagal.
  Future<AuthUser> login({
    required String email,
    required String password,
  }) async {
    final response = await _dio.post('/auth/login', data: {
      'login': email,
      'password': password,
    });

    final data = response.data;
    final token = data['access_token'] ?? data['token'] ?? '';
    final userData = data['user'] ?? data;

    final user = AuthUser.fromJson(userData, token: token);

    // Simpan token & user data secara aman
    await SecureStorageService.saveToken(token);
    await SecureStorageService.saveUserData(jsonEncode(userData));
    if (user.role != null) {
      await SecureStorageService.saveUserRole(user.role!);
    }

    return user;
  }

  /// Ambil profil user yang sedang login.
  Future<AuthUser> getProfile() async {
    final response = await _dio.get('/auth/profile');
    final token = await SecureStorageService.getToken() ?? '';
    return AuthUser.fromJson(response.data['user'] ?? response.data, token: token);
  }

  /// Logout: hapus token dari server & storage lokal.
  Future<void> logout() async {
    try {
      await _dio.post('/auth/logout');
    } catch (_) {
      // Tetap lanjutkan logout meski request gagal
    } finally {
      await SecureStorageService.clearAll();
      SmptApiClient.resetInstance();
    }
  }

  /// Cek apakah user masih login (token ada di storage).
  Future<AuthUser?> getLoggedInUser() async {
    final token = await SecureStorageService.getToken();
    final userJson = await SecureStorageService.getUserData();

    if (token == null || token.isEmpty || userJson == null) return null;

    try {
      final userData = jsonDecode(userJson) as Map<String, dynamic>;
      return AuthUser.fromJson(userData, token: token);
    } catch (_) {
      return null;
    }
  }
}
