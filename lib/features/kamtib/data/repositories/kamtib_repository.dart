import 'package:dio/dio.dart';
import '../../../../core/network/smpt_api_client.dart';
import '../models/kamtib_model.dart';

class KamtibRepository {
  final Dio _dio = SmptApiClient.instance;

  Future<List<PelanggaranModel>> getPelanggaranTerbaru() async {
    final response = await _dio.get('/kamtib/pelanggaran', queryParameters: {
      'limit': 20,
    });
    
    final data = response.data['data']?['data'] ?? response.data['data'] as List? ?? [];
    return data.map<PelanggaranModel>((e) => PelanggaranModel.fromJson(e)).toList();
  }
}
