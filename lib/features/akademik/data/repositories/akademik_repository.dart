import 'package:dio/dio.dart';
import '../../../../core/network/smpt_api_client.dart';
import '../models/akademik_models.dart';

class AkademikRepository {
  final Dio _dio = SmptApiClient.instance;

  Future<List<JadwalModel>> getJadwal({int? studentId}) async {
    try {
      final response = await _dio.get('/main/class-schedule', queryParameters: {
        if (studentId != null) 'student_id': studentId,
      });
      final data = response.data['data']?['data'] ?? response.data['data'] as List? ?? [];
      return data.map<JadwalModel>((e) => JadwalModel.fromJson(e)).toList();
    } catch (_) {
      // Fallback dummy for development if endpoint is not fully ready
      return [
        JadwalModel(id: 1, hari: 'Senin', mapel: 'Matematika', jamMulai: '07:00', jamSelesai: '08:30', namaGuru: 'Ust. Ahmad'),
        JadwalModel(id: 2, hari: 'Senin', mapel: 'Fiqih', jamMulai: '08:30', jamSelesai: '10:00', namaGuru: 'Ust. Hasan'),
        JadwalModel(id: 3, hari: 'Selasa', mapel: 'Bahasa Arab', jamMulai: '07:00', jamSelesai: '08:30', namaGuru: 'Ust. Ali'),
      ];
    }
  }

  Future<List<NilaiModel>> getNilai({int? studentId}) async {
    try {
      final response = await _dio.get('/main/report-card', queryParameters: {
        if (studentId != null) 'student_id': studentId,
      });
      final data = response.data['data']?['data'] ?? response.data['data'] as List? ?? [];
      return data.map<NilaiModel>((e) => NilaiModel.fromJson(e)).toList();
    } catch (_) {
      return [
        NilaiModel(id: 1, semester: 'Ganjil 2025/2026', mapel: 'Matematika', nilai: 85),
        NilaiModel(id: 2, semester: 'Ganjil 2025/2026', mapel: 'Fiqih', nilai: 90),
        NilaiModel(id: 3, semester: 'Ganjil 2025/2026', mapel: 'Bahasa Arab', nilai: 78),
      ];
    }
  }

  Future<List<AbsensiModel>> getAbsensiSummary({int? studentId}) async {
    try {
      final response = await _dio.get('/main/presence/summary', queryParameters: {
        if (studentId != null) 'student_id': studentId,
      });
      final data = response.data['data'] as List? ?? [];
      return data.map<AbsensiModel>((e) => AbsensiModel.fromJson(e)).toList();
    } catch (_) {
      return [
        AbsensiModel(bulan: 'Bulan Ini', hadir: 22, izin: 1, sakit: 0, alfa: 0),
        AbsensiModel(bulan: 'Bulan Lalu', hadir: 20, izin: 0, sakit: 2, alfa: 0),
      ];
    }
  }
}
