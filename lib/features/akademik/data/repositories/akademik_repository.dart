import 'package:dio/dio.dart';
import '../../../../core/network/smpt_api_client.dart';
import '../../../../core/errors/app_exception.dart';
import '../models/akademik_models.dart';

class AkademikRepository {
  final Dio _dio = SmptApiClient.instance;

  Future<List<JadwalModel>> getJadwal({int? studentId}) async {
    try {
      final response = await _dio.get('/main/class-schedule', queryParameters: {
        if (studentId != null) 'student_id': studentId,
      });
      final raw = response.data;
      List dataList = [];
      if (raw is Map) {
        dataList = raw['data']?['data'] ?? raw['data'] ?? [];
      } else if (raw is List) {
        dataList = raw;
      }
      return dataList.map<JadwalModel>((e) => JadwalModel.fromJson(e)).toList();
    } on DioException catch (e) {
      throw e.error is AppException ? e.error as AppException : NetworkException(
        e.response?.data?['message']?.toString() ?? 'Gagal memuat jadwal pelajaran',
        statusCode: e.response?.statusCode,
      );
    } catch (e) {
      throw DataParseException('Gagal membaca data jadwal: ${e.toString()}');
    }
  }

  Future<List<NilaiModel>> getNilai({int? studentId}) async {
    try {
      final response = await _dio.get('/main/report-card', queryParameters: {
        if (studentId != null) 'student_id': studentId,
      });
      final raw = response.data;
      List dataList = [];
      if (raw is Map) {
        dataList = raw['data']?['data'] ?? raw['data'] ?? [];
      } else if (raw is List) {
        dataList = raw;
      }
      return dataList.map<NilaiModel>((e) => NilaiModel.fromJson(e)).toList();
    } on DioException catch (e) {
      throw e.error is AppException ? e.error as AppException : NetworkException(
        e.response?.data?['message']?.toString() ?? 'Gagal memuat data nilai',
        statusCode: e.response?.statusCode,
      );
    } catch (e) {
      throw DataParseException('Gagal membaca data nilai: ${e.toString()}');
    }
  }

  Future<List<AbsensiModel>> getAbsensiSummary({int? studentId}) async {
    try {
      final response = await _dio.get('/main/presence/summary', queryParameters: {
        if (studentId != null) 'student_id': studentId,
      });
      final raw = response.data;
      List dataList = [];
      if (raw is Map) {
        dataList = raw['data'] as List? ?? [];
      } else if (raw is List) {
        dataList = raw;
      }
      return dataList.map<AbsensiModel>((e) => AbsensiModel.fromJson(e)).toList();
    } on DioException catch (e) {
      throw e.error is AppException ? e.error as AppException : NetworkException(
        e.response?.data?['message']?.toString() ?? 'Gagal memuat data absensi',
        statusCode: e.response?.statusCode,
      );
    } catch (e) {
      throw DataParseException('Gagal membaca data absensi: ${e.toString()}');
    }
  }

  Future<AbsensiStatistikModel?> getAbsensiStatistik({int? studentId}) async {
    try {
      final response = await _dio.get('/main/presence/statistics', queryParameters: {
        if (studentId != null) 'student_id': studentId,
      });
      final raw = response.data;
      if (raw is Map && raw['data'] != null) {
        return AbsensiStatistikModel.fromJson(raw['data'] as Map<String, dynamic>);
      }
      return null;
    } on DioException catch (e) {
      throw e.error is AppException ? e.error as AppException : NetworkException(
        e.response?.data?['message']?.toString() ?? 'Gagal memuat statistik absensi',
        statusCode: e.response?.statusCode,
      );
    } catch (e) {
      return null; // statistik opsional, boleh null
    }
  }
}
