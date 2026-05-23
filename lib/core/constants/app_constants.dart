/// Base URL untuk backend SMPT (Sistem Manajemen Pesantren Terpadu)
/// dan Bank Santri.
///
/// Untuk development lokal, gunakan URL localhost.
/// Untuk production, ganti dengan URL server VPS.
class AppConstants {
  // ─── SMPT Backend ──────────────────────────────────────────────────────────
  // Local Development: 'http://10.0.2.2:8000/api'
  static const String smptBaseUrl = 'https://api.tamjid.or.id/api';

  // ─── Bank Santri Backend ───────────────────────────────────────────────────
  // Local Development: 'http://10.0.2.2:8001/api'
  static const String bankBaseUrl = 'https://bank.tamjid.or.id/api';

  // ─── Storage Keys ─────────────────────────────────────────────────────────
  static const String tokenKey = 'auth_token';
  static const String refreshTokenKey = 'refresh_token';
  static const String userKey = 'user_data';
  static const String activeBankKey = 'active_bank'; // smpt | bank-santri
  static const String userRoleKey = 'user_role';

  // ─── Timeouts ─────────────────────────────────────────────────────────────
  static const Duration connectTimeout = Duration(seconds: 5);
  static const Duration receiveTimeout = Duration(seconds: 10);

  // ─── Pagination ───────────────────────────────────────────────────────────
  static const int defaultPageSize = 15;

  // ─── App Info ─────────────────────────────────────────────────────────────
  static const String appName = 'Pondok Mobile';
  static const String appVersion = '1.0.0';
}
