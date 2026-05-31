/// Custom exception hierarchy untuk pondok-mobile.
/// Semua error dari network, parsing, dll dipetakan ke sini.
abstract class AppException implements Exception {
  final String message;
  final String? code;
  const AppException(this.message, {this.code});

  @override
  String toString() => message;
}

/// Error dari HTTP request (4xx, 5xx)
class NetworkException extends AppException {
  final int? statusCode;
  const NetworkException(super.message, {this.statusCode, super.code});
}

/// Error khusus 401 Unauthorized / token expired
class UnauthorizedException extends AppException {
  const UnauthorizedException([String message = 'Sesi habis, silakan login kembali'])
      : super(message, code: '401');
}

/// Error 403 Forbidden
class ForbiddenException extends AppException {
  const ForbiddenException([String message = 'Akses tidak diizinkan'])
      : super(message, code: '403');
}

/// Error 404 Not Found
class NotFoundException extends AppException {
  const NotFoundException([String message = 'Data tidak ditemukan'])
      : super(message, code: '404');
}

/// Error saat parsing / mapping JSON
class DataParseException extends AppException {
  const DataParseException([String message = 'Gagal membaca data dari server'])
      : super(message, code: 'PARSE_ERROR');
}

/// Error validasi dari backend (422)
class ValidationException extends AppException {
  final Map<String, dynamic>? errors;
  const ValidationException(super.message, {this.errors, super.code});
}

/// Error koneksi / timeout / no internet
class ConnectionException extends AppException {
  const ConnectionException([String message = 'Tidak dapat terhubung ke server. Periksa koneksi internet.'])
      : super(message, code: 'CONNECTION_ERROR');
}

/// Error umum yang tidak diketahui
class UnknownException extends AppException {
  const UnknownException([String message = 'Terjadi kesalahan yang tidak diketahui'])
      : super(message, code: 'UNKNOWN');
}
