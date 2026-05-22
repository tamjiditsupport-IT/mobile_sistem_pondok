import 'package:dio/dio.dart';
import '../../../../core/network/smpt_api_client.dart';
import '../../../../core/network/bank_api_client.dart';
import '../models/dashboard_models.dart';

class DashboardRepository {
  final Dio _smpt = SmptApiClient.instance;
  final Dio _bank = BankApiClient.instance;

  /// Ambil data summary dari SMPT (jumlah santri, staf, dll)
  Future<SmptDashboardData> getSmptSummary() async {
    final response = await _smpt.get('/main/dashboard');
    return SmptDashboardData.fromJson(response.data);
  }

  /// Ambil data summary dari Bank Santri (total saldo, transaksi, dll)
  Future<BankDashboardSummary> getBankSummary() async {
    final response = await _bank.get('/main/dashboard/summary');
    return BankDashboardSummary.fromJson(response.data);
  }
}
