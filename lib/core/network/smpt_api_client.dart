import 'package:dio/dio.dart';
import '../constants/app_constants.dart';
import '../storage/secure_storage_service.dart';
import '../errors/app_exception.dart';
import 'package:pretty_dio_logger/pretty_dio_logger.dart';

/// HTTP Client khusus untuk SMPT Backend.
/// Otomatis menyertakan JWT token & melakukan auto-refresh saat token expired.
class SmptApiClient {
  static Dio? _instance;
  static bool _isRefreshing = false;

  static Dio get instance {
    _instance ??= _createDio();
    return _instance!;
  }

  static Dio _createDio() {
    final dio = Dio(
      BaseOptions(
        baseUrl: AppConstants.smptBaseUrl,
        connectTimeout: AppConstants.connectTimeout,
        receiveTimeout: AppConstants.receiveTimeout,
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      ),
    );

    // Interceptor: inject JWT token + auto refresh + error mapping
    dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          final token = await SecureStorageService.getToken();
          if (token != null && token.isNotEmpty) {
            options.headers['Authorization'] = 'Bearer $token';
          }
          return handler.next(options);
        },
        onError: (DioException e, handler) async {
          if (e.response?.statusCode == 401 && !_isRefreshing) {
            _isRefreshing = true;
            try {
              // Coba refresh token
              final refreshToken = await SecureStorageService.getRefreshToken();
              if (refreshToken != null && refreshToken.isNotEmpty) {
                final refreshDio = Dio(BaseOptions(
                  baseUrl: AppConstants.smptBaseUrl,
                  connectTimeout: AppConstants.connectTimeout,
                  receiveTimeout: AppConstants.receiveTimeout,
                ));
                final refreshResponse = await refreshDio.post(
                  '/auth/refresh',
                  options: Options(
                    headers: {'Authorization': 'Bearer $refreshToken'},
                  ),
                );
                final newToken = refreshResponse.data['access_token'] ?? '';
                if (newToken.isNotEmpty) {
                  await SecureStorageService.saveToken(newToken);
                  // Retry request asal dengan token baru
                  e.requestOptions.headers['Authorization'] = 'Bearer $newToken';
                  final retryResponse = await dio.fetch(e.requestOptions);
                  return handler.resolve(retryResponse);
                }
              }
            } catch (_) {
              // Refresh gagal → clear all & throw unauthorized
            } finally {
              _isRefreshing = false;
            }
            await SecureStorageService.clearAll();
            return handler.next(
              DioException(
                requestOptions: e.requestOptions,
                error: const UnauthorizedException(),
                type: DioExceptionType.badResponse,
                response: e.response,
              ),
            );
          }

          // Map DioException ke AppException
          final appError = _mapDioError(e);
          return handler.next(
            DioException(
              requestOptions: e.requestOptions,
              error: appError,
              type: e.type,
              response: e.response,
            ),
          );
        },
      ),
    );

    // Logger hanya di debug mode
    assert(() {
      dio.interceptors.add(
        PrettyDioLogger(
          requestHeader: true,
          requestBody: true,
          responseBody: true,
          responseHeader: false,
          error: true,
          compact: true,
          maxWidth: 90,
        ),
      );
      return true;
    }());

    return dio;
  }

  static AppException _mapDioError(DioException e) {
    switch (e.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        return const ConnectionException('Koneksi timeout. Periksa koneksi internet Anda.');
      case DioExceptionType.connectionError:
        return const ConnectionException();
      case DioExceptionType.badResponse:
        final statusCode = e.response?.statusCode;
        final message = e.response?.data?['message'] ??
            e.response?.data?['error'] ??
            'Server error';
        switch (statusCode) {
          case 401:
            return const UnauthorizedException();
          case 403:
            return const ForbiddenException();
          case 404:
            return const NotFoundException();
          case 422:
            return ValidationException(
              message.toString(),
              errors: e.response?.data?['errors'],
            );
          default:
            return NetworkException(message.toString(), statusCode: statusCode);
        }
      default:
        return const UnknownException();
    }
  }

  static void resetInstance() {
    _instance = null;
    _isRefreshing = false;
  }
}
