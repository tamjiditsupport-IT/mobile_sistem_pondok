import 'package:dio/dio.dart';
import '../../../../core/network/smpt_api_client.dart';
import '../../../../core/errors/app_exception.dart';
import '../models/santri_model.dart';

/// Wrapper pagination result
class PaginatedResult<T> {
  final List<T> data;
  final int currentPage;
  final int lastPage;
  final int total;

  const PaginatedResult({
    required this.data,
    required this.currentPage,
    required this.lastPage,
    required this.total,
  });
}

class SantriRepository {
  final Dio _dio = SmptApiClient.instance;

  Future<PaginatedResult<SantriModel>> getSantriList({
    int page = 1,
    String? search,
    int perPage = 20,
  }) async {
    try {
      final response = await _dio.get('/main/student', queryParameters: {
        'page': page,
        'per_page': perPage,
        if (search != null && search.isNotEmpty) 'search': search,
      });

      final raw = response.data;
      // Laravel paginator: { data: { data: [...], current_page: 1, last_page: 3, total: 60 } }
      final paginator = raw['data'] is Map ? raw['data'] : raw;
      final dataList = paginator['data'] as List? ?? [];
      final currentPage = paginator['current_page'] ?? 1;
      final lastPage = paginator['last_page'] ?? 1;
      final total = paginator['total'] ?? dataList.length;

      return PaginatedResult(
        data: dataList.map<SantriModel>((e) => SantriModel.fromJson(e)).toList(),
        currentPage: currentPage,
        lastPage: lastPage,
        total: total,
      );
    } on DioException catch (e) {
      throw e.error is AppException ? e.error as AppException : NetworkException(
        e.response?.data?['message']?.toString() ?? 'Gagal memuat data santri',
        statusCode: e.response?.statusCode,
      );
    }
  }

  Future<List<SantriModel>> getSantriByWali(int waliId) async {
    try {
      final response = await _dio.get('/main/parent/$waliId');
      final data = response.data['data']?['students'] as List? ?? [];
      return data.map<SantriModel>((e) => SantriModel.fromJson(e)).toList();
    } on DioException catch (e) {
      throw e.error is AppException ? e.error as AppException : NetworkException(
        e.response?.data?['message']?.toString() ?? 'Gagal memuat data santri',
        statusCode: e.response?.statusCode,
      );
    }
  }

  Future<SantriModel> getSantriById(int santriId) async {
    try {
      final response = await _dio.get('/main/student/$santriId');
      return SantriModel.fromJson(response.data['data']);
    } on DioException catch (e) {
      throw e.error is AppException ? e.error as AppException : NetworkException(
        e.response?.data?['message']?.toString() ?? 'Gagal mengambil detail santri',
        statusCode: e.response?.statusCode,
      );
    }
  }
}
