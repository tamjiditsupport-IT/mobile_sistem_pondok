/// Model untuk data rekening santri dari bank-santri backend
class BankAccount {
  final int id;
  final String accountNumber;
  final String accountName;
  final double balance;
  final String? nis;
  final String? accountType;
  final bool isActive;

  const BankAccount({
    required this.id,
    required this.accountNumber,
    required this.accountName,
    required this.balance,
    this.nis,
    this.accountType,
    this.isActive = true,
  });

  factory BankAccount.fromJson(Map<String, dynamic> json) {
    return BankAccount(
      id: json['id'] ?? 0,
      accountNumber: json['account_number'] ?? '',
      accountName: json['account_name'] ?? json['name'] ?? '',
      balance: double.tryParse(json['balance']?.toString() ?? '0') ?? 0.0,
      nis: json['nis'],
      accountType: json['account_type'],
      isActive: json['is_active'] ?? true,
    );
  }

  String get formattedBalance {
    return 'Rp ${balance.toStringAsFixed(0).replaceAllMapped(
      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
      (m) => '${m[1]}.',
    )}';
  }
}

/// Model untuk transaksi dari bank-santri backend
class BankTransaction {
  final int id;
  final String transactionCode;
  final String type;
  final double amount;
  final double balanceBefore;
  final double balanceAfter;
  final String? description;
  final String? referenceNumber;
  final DateTime createdAt;
  final bool isCredit; // true = masuk, false = keluar

  const BankTransaction({
    required this.id,
    required this.transactionCode,
    required this.type,
    required this.amount,
    required this.balanceBefore,
    required this.balanceAfter,
    this.description,
    this.referenceNumber,
    required this.createdAt,
    required this.isCredit,
  });

  factory BankTransaction.fromJson(Map<String, dynamic> json) {
    final amount = double.tryParse(json['amount']?.toString() ?? '0') ?? 0.0;
    final balanceAfter = double.tryParse(json['balance_after']?.toString() ?? '0') ?? 0.0;
    final balanceBefore = double.tryParse(json['balance_before']?.toString() ?? '0') ?? 0.0;
    
    return BankTransaction(
      id: json['id'] ?? 0,
      transactionCode: json['transaction_code'] ?? '',
      type: json['transaction_type']?['name'] ?? json['type'] ?? '',
      amount: amount,
      balanceBefore: balanceBefore,
      balanceAfter: balanceAfter,
      description: json['description'],
      referenceNumber: json['reference_number'],
      createdAt: DateTime.tryParse(json['created_at'] ?? '') ?? DateTime.now(),
      isCredit: balanceAfter >= balanceBefore,
    );
  }

  String get formattedAmount {
    final sign = isCredit ? '+' : '-';
    return '$sign Rp ${amount.toStringAsFixed(0).replaceAllMapped(
      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
      (m) => '${m[1]}.',
    )}';
  }
}

/// Model untuk tagihan/payment record dari bank-santri
class PaymentRecord {
  final int id;
  final String packageName;
  final double totalAmount;
  final double paidAmount;
  final String status;
  final DateTime dueDate;

  const PaymentRecord({
    required this.id,
    required this.packageName,
    required this.totalAmount,
    required this.paidAmount,
    required this.status,
    required this.dueDate,
  });

  factory PaymentRecord.fromJson(Map<String, dynamic> json) {
    return PaymentRecord(
      id: json['id'] ?? 0,
      packageName: json['payment_package']?['name'] ?? json['package_name'] ?? '',
      totalAmount: double.tryParse(json['total_amount']?.toString() ?? '0') ?? 0.0,
      paidAmount: double.tryParse(json['paid_amount']?.toString() ?? '0') ?? 0.0,
      status: json['status'] ?? 'unpaid',
      dueDate: DateTime.tryParse(json['due_date'] ?? '') ?? DateTime.now(),
    );
  }

  double get remainingAmount => totalAmount - paidAmount;
  bool get isPaid => status.toLowerCase() == 'paid';
}
