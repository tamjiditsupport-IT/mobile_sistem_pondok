import 'package:dio/dio.dart';
import '../../../../core/network/smpt_api_client.dart';
import '../../../../core/errors/app_exception.dart';
import '../models/informasi_models.dart';

class InformasiRepository {
  final Dio _dio = SmptApiClient.instance;

  Future<List<NewsModel>> getBerita() async {
    try {
      final response = await _dio.get('/main/news');
      final raw = response.data;
      List dataList = [];
      if (raw is Map) {
        dataList = raw['data'] as List? ?? [];
      } else if (raw is List) {
        dataList = raw;
      }
      return dataList
          .map<NewsModel>((e) => NewsModel.fromJson(e))
          .where((n) => n.isPublished)
          .toList();
    } on DioException catch (e) {
      throw e.error is AppException
          ? e.error as AppException
          : NetworkException(
              e.response?.data?['message']?.toString() ?? 'Gagal memuat berita',
              statusCode: e.response?.statusCode,
            );
    }
  }

  Future<List<ActivityModel>> getKegiatan() async {
    try {
      final response = await _dio.get('/main/activity');
      final raw = response.data;
      List dataList = [];
      if (raw is Map) {
        dataList = raw['data'] as List? ?? [];
      } else if (raw is List) {
        dataList = raw;
      }
      return dataList.map<ActivityModel>((e) => ActivityModel.fromJson(e)).toList();
    } on DioException catch (e) {
      throw e.error is AppException
          ? e.error as AppException
          : NetworkException(
              e.response?.data?['message']?.toString() ?? 'Gagal memuat kegiatan',
              statusCode: e.response?.statusCode,
            );
    }
  }
}
