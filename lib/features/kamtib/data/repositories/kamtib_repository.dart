import 'package:dio/dio.dart';
import '../../../../core/network/smpt_api_client.dart';
import '../../../../core/errors/app_exception.dart';
import '../models/kamtib_model.dart';
import '../models/leave_type_model.dart';

class KamtibRepository {
  final Dio _dio = SmptApiClient.instance;

  Future<List<PelanggaranModel>> getPelanggaranTerbaru({int? studentId}) async {
    try {
      final queryParams = <String, dynamic>{'limit': 20};
      if (studentId != null) queryParams['student_id'] = studentId;

      final response = await _dio.get('/main/student-violation', queryParameters: queryParams);
      final data = response.data['data']?['data'] ?? response.data['data'] as List? ?? [];
      return data.map<PelanggaranModel>((e) => PelanggaranModel.fromJson(e)).toList();
    } on DioException catch (e) {
      throw e.error is AppException ? e.error as AppException : NetworkException(
        e.response?.data?['message']?.toString() ?? 'Gagal memuat data pelanggaran',
        statusCode: e.response?.statusCode,
      );
    }
  }

  Future<List<PerizinanModel>> getPerizinan({int? studentId}) async {
    try {
      final queryParams = <String, dynamic>{};
      if (studentId != null) queryParams['student_id'] = studentId;

      final response = await _dio.get('/main/student-leave', queryParameters: queryParams);
      final data = response.data['data']?['data'] ?? response.data['data'] as List? ?? [];
      return data.map<PerizinanModel>((e) => PerizinanModel.fromJson(e)).toList();
    } on DioException catch (e) {
      throw e.error is AppException ? e.error as AppException : NetworkException(
        e.response?.data?['message']?.toString() ?? 'Gagal memuat data perizinan',
        statusCode: e.response?.statusCode,
      );
    }
  }

  /// Ambil jenis izin dari API (sebelumnya hardcoded)
  Future<List<LeaveTypeModel>> getLeaveTypes() async {
    try {
      final response = await _dio.get('/master/leave-type');
      final raw = response.data;
      List dataList = [];
      if (raw is Map) {
        dataList = raw['data'] as List? ?? [];
      } else if (raw is List) {
        dataList = raw;
      }
      return dataList.map<LeaveTypeModel>((e) => LeaveTypeModel.fromJson(e)).toList();
    } on DioException catch (_) {
      // Fallback ke default list jika API tidak tersedia
      return _defaultLeaveTypes();
    }
  }

  List<LeaveTypeModel> _defaultLeaveTypes() {
    return const [
      LeaveTypeModel(id: 1, name: 'Pulang'),
      LeaveTypeModel(id: 2, name: 'Keluar Pesantren'),
      LeaveTypeModel(id: 3, name: 'Sakit'),
      LeaveTypeModel(id: 4, name: 'Berobat'),
      LeaveTypeModel(id: 5, name: 'Keperluan Keluarga'),
      LeaveTypeModel(id: 7, name: 'Mengikuti Kegiatan'),
    ];
  }

  Future<void> submitPerizinan({
    required int studentId,
    required int leaveTypeId,
    required String startDate,
    required String endDate,
    required String reason,
    String? destination,
    String? contactPerson,
    String? contactPhone,
  }) async {
    try {
      await _dio.post('/main/student-leave', data: {
        'student_id': studentId,
        'leave_type_id': leaveTypeId,
        'start_date': startDate,
        'end_date': endDate,
        'reason': reason,
        if (destination != null) 'destination': destination,
        if (contactPerson != null) 'contact_person': contactPerson,
        if (contactPhone != null) 'contact_phone': contactPhone,
      });
    } on DioException catch (e) {
      final msg = e.response?.data?['message'] ?? e.response?.data?['error'] ?? 'Gagal mengajukan perizinan';
      throw Exception(msg.toString());
    }
  }

  Future<void> approvePerizinan(int id) async {
    try {
      await _dio.post('/main/student-leave/$id/approve');
    } on DioException catch (e) {
      throw Exception(e.response?.data?['message'] ?? 'Gagal menyetujui perizinan');
    }
  }

  Future<void> rejectPerizinan(int id, String reason) async {
    try {
      await _dio.post('/main/student-leave/$id/reject', data: {
        'approval_notes': reason,
      });
    } on DioException catch (e) {
      throw Exception(e.response?.data?['message'] ?? 'Gagal menolak perizinan');
    }
  }
}
