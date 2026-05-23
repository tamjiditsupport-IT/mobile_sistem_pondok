import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/repositories/keuangan_repository.dart';
import '../../data/models/bank_models.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../../auth/data/models/auth_user.dart';

// ─── State ────────────────────────────────────────────────────────────────────
enum KeuanganTab { transaksi, tagihan }

class KeuanganState {
  final bool isLoadingAccount;
  final bool isLoadingTransaksi;
  final bool isLoadingTagihan;
  final BankAccount? account;
  final List<BankTransaction> transaksi;
  final List<PaymentRecord> tagihan;
  final String? error;
  final KeuanganTab activeTab;
  final int currentPage;
  final bool hasMore;

  const KeuanganState({
    this.isLoadingAccount = false,
    this.isLoadingTransaksi = false,
    this.isLoadingTagihan = false,
    this.account,
    this.transaksi = const [],
    this.tagihan = const [],
    this.error,
    this.activeTab = KeuanganTab.transaksi,
    this.currentPage = 1,
    this.hasMore = true,
  });

  bool get isLoading => isLoadingAccount || isLoadingTransaksi || isLoadingTagihan;

  KeuanganState copyWith({
    bool? isLoadingAccount,
    bool? isLoadingTransaksi,
    bool? isLoadingTagihan,
    BankAccount? account,
    List<BankTransaction>? transaksi,
    List<PaymentRecord>? tagihan,
    String? error,
    KeuanganTab? activeTab,
    int? currentPage,
    bool? hasMore,
  }) {
    return KeuanganState(
      isLoadingAccount: isLoadingAccount ?? this.isLoadingAccount,
      isLoadingTransaksi: isLoadingTransaksi ?? this.isLoadingTransaksi,
      isLoadingTagihan: isLoadingTagihan ?? this.isLoadingTagihan,
      account: account ?? this.account,
      transaksi: transaksi ?? this.transaksi,
      tagihan: tagihan ?? this.tagihan,
      error: error,
      activeTab: activeTab ?? this.activeTab,
      currentPage: currentPage ?? this.currentPage,
      hasMore: hasMore ?? this.hasMore,
    );
  }
}

// ─── Notifier ─────────────────────────────────────────────────────────────────
class KeuanganNotifier extends StateNotifier<KeuanganState> {
  final KeuanganRepository _repo;
  final AuthUser? user;

  KeuanganNotifier(this._repo, {this.user}) : super(const KeuanganState()) {
    loadInitial();
  }

  Future<void> loadInitial() async {
    state = state.copyWith(isLoadingAccount: true, error: null);
    try {
      // Ambil akun berdasarkan NIS (jika santri), jika tidak ambil akun pertama
      final acc = await _repo.getFirstAccount(nis: user?.nis);

      if (acc != null) {
        state = state.copyWith(isLoadingAccount: false, account: acc);
        await Future.wait([
          _loadTransaksi(acc.accountNumber, reset: true),
          _loadTagihan(acc.accountNumber),
        ]);
      } else {
        state = state.copyWith(isLoadingAccount: false, error: 'Rekening tidak ditemukan');
      }
    } catch (e) {
      state = state.copyWith(isLoadingAccount: false, error: 'Gagal memuat data keuangan');
    }
  }

  Future<void> loadAccountByNumber(String accountNumber) async {
    state = state.copyWith(isLoadingAccount: true, error: null);
    try {
      final acc = await _repo.getAccount(accountNumber);
      state = state.copyWith(isLoadingAccount: false, account: acc);
      await Future.wait([
        _loadTransaksi(accountNumber, reset: true),
        _loadTagihan(accountNumber),
      ]);
    } catch (e) {
      state = state.copyWith(isLoadingAccount: false, error: 'Rekening tidak ditemukan');
    }
  }

  Future<void> _loadTransaksi(String accountNumber, {bool reset = false}) async {
    if (state.isLoadingTransaksi) return;
    final page = reset ? 1 : state.currentPage + 1;

    state = state.copyWith(isLoadingTransaksi: true);
    try {
      final list = await _repo.getTransactions(accountNumber, page: page);
      final newList = reset ? list : [...state.transaksi, ...list];
      state = state.copyWith(
        isLoadingTransaksi: false,
        transaksi: newList,
        currentPage: page,
        hasMore: list.length >= 15,
      );
    } catch (_) {
      state = state.copyWith(isLoadingTransaksi: false);
    }
  }

  Future<void> _loadTagihan(String accountNumber) async {
    state = state.copyWith(isLoadingTagihan: true);
    try {
      final list = await _repo.getPayments(accountNumber);
      state = state.copyWith(isLoadingTagihan: false, tagihan: list);
    } catch (_) {
      state = state.copyWith(isLoadingTagihan: false);
    }
  }

  Future<void> refresh() async {
    if (state.account != null) {
      await Future.wait([
        loadAccountByNumber(state.account!.accountNumber),
      ]);
    } else {
      await loadInitial();
    }
  }

  Future<void> requestTopUp(double amount, {String? description}) async {
    if (state.account == null) return;
    try {
      await _repo.cashTopUp(
        accountNumber: state.account!.accountNumber,
        amount: amount,
        description: description,
      );
      await refresh();
    } catch (e) {
      state = state.copyWith(error: 'Gagal melakukan request top-up');
    }
  }

  void setTab(KeuanganTab tab) {
    state = state.copyWith(activeTab: tab);
  }

  Future<void> loadMore() async {
    if (state.account != null && state.hasMore && !state.isLoadingTransaksi) {
      await _loadTransaksi(state.account!.accountNumber);
    }
  }
}

// ─── Providers ────────────────────────────────────────────────────────────────
final keuanganRepositoryProvider = Provider<KeuanganRepository>((ref) {
  return KeuanganRepository();
});

final keuanganProvider = StateNotifierProvider<KeuanganNotifier, KeuanganState>((ref) {
  final user = ref.watch(authProvider).user;
  return KeuanganNotifier(ref.watch(keuanganRepositoryProvider), user: user);
});
