import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/repositories/santri_repository.dart';
import '../../data/models/santri_model.dart';
import '../../../auth/presentation/providers/auth_provider.dart';

class SantriState {
  final bool isLoading;
  final List<SantriModel> santriList;
  final String? error;

  const SantriState({
    this.isLoading = false,
    this.santriList = const [],
    this.error,
  });

  SantriState copyWith({bool? isLoading, List<SantriModel>? santriList, String? error}) {
    return SantriState(
      isLoading: isLoading ?? this.isLoading,
      santriList: santriList ?? this.santriList,
      error: error,
    );
  }
}

class SantriNotifier extends StateNotifier<SantriState> {
  final SantriRepository _repo;
  final AuthState _authState;

  SantriNotifier(this._repo, this._authState) : super(const SantriState()) {
    loadSantri();
  }

  Future<void> loadSantri() async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      List<SantriModel> list;
      final user = _authState.user;
      if (user != null && user.isWaliSantri) {
        list = await _repo.getSantriByWali(user.id);
      } else {
        list = await _repo.getSantriList();
      }
      state = state.copyWith(isLoading: false, santriList: list);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: 'Gagal memuat data santri');
    }
  }

  Future<void> search(String query) async {
    if (_authState.user?.isWaliSantri == true) return; // Wali tak bisa search semua
    
    state = state.copyWith(isLoading: true, error: null);
    try {
      final list = await _repo.getSantriList(search: query);
      state = state.copyWith(isLoading: false, santriList: list);
    } catch (_) {
      state = state.copyWith(isLoading: false, error: 'Pencarian gagal');
    }
  }
}

final santriRepositoryProvider = Provider<SantriRepository>((ref) {
  return SantriRepository();
});

final santriProvider = StateNotifierProvider<SantriNotifier, SantriState>((ref) {
  return SantriNotifier(
    ref.watch(santriRepositoryProvider),
    ref.watch(authProvider),
  );
});
