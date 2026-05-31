import 'package:dio/dio.dart';
import '../../../../core/network/bank_api_client.dart';
import '../models/bank_models.dart';

/// Repository untuk semua operasi keuangan via bank-santri backend.
class KeuanganRepository {
  final Dio _dio = BankApiClient.instance;

  /// Ambil data rekening berdasarkan nomor akun.
  Future<BankAccount> getAccount(String accountNumber) async {
    final response = await _dio.get('/main/account/$accountNumber');
    return BankAccount.fromJson(response.data['data'] ?? response.data);
  }

  /// Ambil rekening santri berdasarkan NIS (search via SMPT) atau ambil rekening pertama
  Future<BankAccount?> getFirstAccount({String? nis}) async {
    try {
      final Map<String, dynamic> query = nis != null && nis.isNotEmpty ? {'nis': nis} : <String, dynamic>{};
      final response = await _dio.get('/main/account', queryParameters: query);
      
      final dynamic responseData = response.data['data'];
      final List listData = responseData is Map && responseData.containsKey('data') 
          ? responseData['data'] 
          : (responseData is List ? responseData : []);
          
      if (listData.isEmpty) return null;
      return BankAccount.fromJson(listData.first);
    } catch (_) {
      return null;
    }
  }

  /// Ambil riwayat transaksi berdasarkan nomor akun.
  Future<List<BankTransaction>> getTransactions(
    String accountNumber, {
    int page = 1,
    int perPage = 15,
    int? month,
    int? year,
  }) async {
    final Map<String, dynamic> query = {
      'page': page,
      'per_page': perPage,
      if (month != null) 'month': month,
      if (year != null) 'year': year,
    };
    final response = await _dio.get(
      '/main/account/$accountNumber/transactions',
      queryParameters: query,
    );
    final data = response.data['data'] as List? ?? [];
    return data.map((e) => BankTransaction.fromJson(e)).toList();
  }

  /// Ambil 7 transaksi terakhir untuk dashboard.
  Future<List<BankTransaction>> getLast7Days(String accountNumber) async {
    final response = await _dio.get(
      '/main/transaction/account/$accountNumber/last-7-days',
    );
    final data = response.data['data'] as List? ?? [];
    return data.map((e) => BankTransaction.fromJson(e)).toList();
  }

  /// Ambil daftar tagihan berdasarkan nomor akun.
  Future<List<PaymentRecord>> getPayments(String accountNumber) async {
    final response = await _dio.get(
      '/main/payment/account/$accountNumber',
    );
    final data = response.data['data'] as List? ?? [];
    return data.map((e) => PaymentRecord.fromJson(e)).toList();
  }

  /// Ambil summary dashboard (total saldo, transaksi bulan ini, dll).
  Future<Map<String, dynamic>> getDashboardSummary() async {
    final response = await _dio.get('/main/dashboard/summary');
    return response.data['data'] ?? response.data;
  }

  /// Request top-up via tunai.
  Future<void> cashTopUp({
    required String accountNumber,
    required double amount,
    String? description,
  }) async {
    await _dio.post('/main/top-up/cash', data: {
      'account_number': accountNumber,
      'amount': amount,
      'description': description ?? 'Top-up tunai via mobile',
    });
  }

  /// Ambil riwayat top-up berdasarkan nomor akun.
  Future<List<TopUpRecord>> getTopUpHistory(String accountNumber) async {
    final response = await _dio.get('/main/top-up/account/$accountNumber');
    final data = response.data['data'] as List? ?? [];
    return data.map((e) => TopUpRecord.fromJson(e)).toList();
  }
}
