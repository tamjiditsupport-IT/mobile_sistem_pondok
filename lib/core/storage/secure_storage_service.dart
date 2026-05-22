import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../constants/app_constants.dart';

/// Service untuk menyimpan data sensitif (JWT token, user info)
/// menggunakan enkripsi native platform (Keystore/Keychain).
class SecureStorageService {
  static const FlutterSecureStorage _storage = FlutterSecureStorage(
    aOptions: AndroidOptions(encryptedSharedPreferences: true),
    iOptions: IOSOptions(accessibility: KeychainAccessibility.first_unlock),
  );

  // ─── Token ────────────────────────────────────────────────────────────────
  static Future<void> saveToken(String token) async {
    await _storage.write(key: AppConstants.tokenKey, value: token);
  }

  static Future<String?> getToken() async {
    return await _storage.read(key: AppConstants.tokenKey);
  }

  static Future<void> deleteToken() async {
    await _storage.delete(key: AppConstants.tokenKey);
  }

  // ─── User Data ────────────────────────────────────────────────────────────
  static Future<void> saveUserData(String json) async {
    await _storage.write(key: AppConstants.userKey, value: json);
  }

  static Future<String?> getUserData() async {
    return await _storage.read(key: AppConstants.userKey);
  }

  static Future<void> saveUserRole(String role) async {
    await _storage.write(key: AppConstants.userRoleKey, value: role);
  }

  static Future<String?> getUserRole() async {
    return await _storage.read(key: AppConstants.userRoleKey);
  }

  // ─── Clear All ────────────────────────────────────────────────────────────
  static Future<void> clearAll() async {
    await _storage.deleteAll();
  }
}
