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

  /// Ambil rekening santri berdasarkan NIS (search via SMPT).
  Future<BankAccount?> getAccountByNis(String nis) async {
    try {
      final response = await _dio.get('/main/account', queryParameters: {'nis': nis});
      final data = response.data['data'];
      if (data == null || (data is List && data.isEmpty)) return null;
      final item = data is List ? data.first : data;
      return BankAccount.fromJson(item);
    } catch (_) {
      return null;
    }
  }

  /// Ambil riwayat transaksi berdasarkan nomor akun.
  Future<List<BankTransaction>> getTransactions(
    String accountNumber, {
    int page = 1,
    int perPage = 15,
  }) async {
    final response = await _dio.get(
      '/main/account/$accountNumber/transactions',
      queryParameters: {'page': page, 'per_page': perPage},
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
}
