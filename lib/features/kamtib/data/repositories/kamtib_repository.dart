import 'package:dio/dio.dart';
import '../../../../core/network/smpt_api_client.dart';
import '../models/kamtib_model.dart';

class KamtibRepository {
  final Dio _dio = SmptApiClient.instance;

  Future<List<PelanggaranModel>> getPelanggaranTerbaru() async {
    try {
      final response = await _dio.get('/main/student-violation', queryParameters: {
        'limit': 20,
      });
      
      final data = response.data['data']?['data'] ?? response.data['data'] as List? ?? [];
      return data.map<PelanggaranModel>((e) => PelanggaranModel.fromJson(e)).toList();
    } catch (_) {
      return [];
    }
  }

  Future<List<PerizinanModel>> getPerizinan() async {
    try {
      final response = await _dio.get('/main/student-leave');
      final data = response.data['data']?['data'] ?? response.data['data'] as List? ?? [];
      return data.map<PerizinanModel>((e) => PerizinanModel.fromJson(e)).toList();
    } catch (_) {
      return [];
    }
  }

  Future<void> submitPerizinan({
    required int studentId,
    required String startDate,
    required String endDate,
    required String reason,
  }) async {
    await _dio.post('/main/student-leave', data: {
      'student_id': studentId,
      'start_date': startDate,
      'end_date': endDate,
      'reason': reason,
    });
  }

  Future<void> approvePerizinan(int id) async {
    await _dio.post('/main/student-leave/$id/approve');
  }

  Future<void> rejectPerizinan(int id, String reason) async {
    await _dio.post('/main/student-leave/$id/reject', data: {
      'reason': reason,
    });
  }
}
