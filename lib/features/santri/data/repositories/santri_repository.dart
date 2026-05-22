import 'package:dio/dio.dart';
import '../../../../core/network/smpt_api_client.dart';
import '../models/santri_model.dart';

class SantriRepository {
  final Dio _dio = SmptApiClient.instance;

  Future<List<SantriModel>> getSantriList({int page = 1, String? search}) async {
    final response = await _dio.get('/santri', queryParameters: {
      'page': page,
      if (search != null && search.isNotEmpty) 'search': search,
    });
    
    // Sesuaikan parsing dengan response wrapper SMPT
    final data = response.data['data']?['data'] ?? response.data['data'] as List? ?? [];
    return data.map<SantriModel>((e) => SantriModel.fromJson(e)).toList();
  }
  
  Future<List<SantriModel>> getSantriByWali(int waliId) async {
    final response = await _dio.get('/wali/$waliId/santri');
    final data = response.data['data'] as List? ?? [];
    return data.map<SantriModel>((e) => SantriModel.fromJson(e)).toList();
  }
}
