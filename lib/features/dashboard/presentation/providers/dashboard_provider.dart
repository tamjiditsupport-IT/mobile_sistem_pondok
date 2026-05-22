import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/repositories/dashboard_repository.dart';
import '../../data/models/dashboard_models.dart';

// ─── State ────────────────────────────────────────────────────────────────────
class DashboardState {
  final bool isLoading;
  final SmptDashboardData? smptData;
  final BankDashboardSummary? bankData;
  final String? error;

  const DashboardState({
    this.isLoading = false,
    this.smptData,
    this.bankData,
    this.error,
  });

  bool get hasData => smptData != null || bankData != null;

  DashboardState copyWith({
    bool? isLoading,
    SmptDashboardData? smptData,
    BankDashboardSummary? bankData,
    String? error,
  }) {
    return DashboardState(
      isLoading: isLoading ?? this.isLoading,
      smptData: smptData ?? this.smptData,
      bankData: bankData ?? this.bankData,
      error: error,
    );
  }
}

// ─── Notifier ─────────────────────────────────────────────────────────────────
class DashboardNotifier extends StateNotifier<DashboardState> {
  final DashboardRepository _repo;

  DashboardNotifier(this._repo) : super(const DashboardState()) {
    loadDashboard();
  }

  Future<void> loadDashboard() async {
    state = state.copyWith(isLoading: true, error: null);

    SmptDashboardData? smpt;
    BankDashboardSummary? bank;
    String? err;

    // Fetch keduanya secara paralel, toleransi jika salah satu gagal
    final results = await Future.wait([
      _repo.getSmptSummary().then<SmptDashboardData?>((d) => d).catchError((_) => null),
      _repo.getBankSummary().then<BankDashboardSummary?>((d) => d).catchError((_) => null),
    ]);
    smpt = results[0] as SmptDashboardData?;
    bank = results[1] as BankDashboardSummary?;


    if (smpt == null && bank == null) {
      err = 'Gagal memuat data dashboard';
    }

    state = state.copyWith(
      isLoading: false,
      smptData: smpt,
      bankData: bank,
      error: err,
    );
  }

  Future<void> refresh() => loadDashboard();
}

// ─── Providers ────────────────────────────────────────────────────────────────
final dashboardRepositoryProvider = Provider<DashboardRepository>((ref) {
  return DashboardRepository();
});

final dashboardProvider = StateNotifierProvider<DashboardNotifier, DashboardState>((ref) {
  return DashboardNotifier(ref.watch(dashboardRepositoryProvider));
});
