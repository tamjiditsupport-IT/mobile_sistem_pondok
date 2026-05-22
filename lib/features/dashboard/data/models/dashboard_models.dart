// Model untuk data dari SMPT dashboard endpoint
class SmptDashboardData {
  final int totalSantri;
  final int totalStaf;
  final int totalCalonSantri;
  final Map<String, dynamic> raw;

  const SmptDashboardData({
    required this.totalSantri,
    required this.totalStaf,
    required this.totalCalonSantri,
    required this.raw,
  });

  factory SmptDashboardData.fromJson(Map<String, dynamic> json) {
    final data = json['data'] ?? json;
    return SmptDashboardData(
      totalSantri: data['total_students'] ?? data['total_santri'] ?? data['santri'] ?? 0,
      totalStaf: data['total_staff'] ?? data['total_staf'] ?? data['asatidz'] ?? 0,
      totalCalonSantri: data['total_registrations'] ?? data['total_calon_santri'] ?? data['santri_baru'] ?? 0,
      raw: data,
    );
  }
}

// Model untuk data summary dari bank-santri dashboard
class BankDashboardSummary {
  final double totalSaldo;
  final int totalAkun;
  final double totalTopUpHariIni;
  final double totalTransaksiHariIni;
  final int totalTransaksiCount;

  const BankDashboardSummary({
    required this.totalSaldo,
    required this.totalAkun,
    required this.totalTopUpHariIni,
    required this.totalTransaksiHariIni,
    required this.totalTransaksiCount,
  });

  factory BankDashboardSummary.fromJson(Map<String, dynamic> json) {
    final data = json['data'] ?? json;
    return BankDashboardSummary(
      totalSaldo: double.tryParse(data['rekening']?['total_saldo']?.toString() ?? data['total_saldo']?.toString() ?? '0') ?? 0.0,
      totalAkun: data['rekening']?['total_aktif'] ?? data['total_akun'] ?? 0,
      totalTopUpHariIni: double.tryParse(data['topup']?['today_amount']?.toString() ?? data['total_topup_today']?.toString() ?? '0') ?? 0.0,
      totalTransaksiHariIni: double.tryParse(data['payment']?['month_amount']?.toString() ?? data['total_transaction_today']?.toString() ?? '0') ?? 0.0,
      totalTransaksiCount: data['koperasi']?['today_count'] ?? data['transaction_count'] ?? 0,
    );
  }

  String formatCurrency(double amount) {
    final str = amount.toStringAsFixed(0);
    final result = StringBuffer();
    int count = 0;
    for (int i = str.length - 1; i >= 0; i--) {
      if (count > 0 && count % 3 == 0) result.write('.');
      result.write(str[i]);
      count++;
    }
    return 'Rp ${result.toString().split('').reversed.join()}';
  }

  String get formattedTotalSaldo => formatCurrency(totalSaldo);
  String get formattedTopUp => formatCurrency(totalTopUpHariIni);
  String get formattedTransaksi => formatCurrency(totalTransaksiHariIni);
}
