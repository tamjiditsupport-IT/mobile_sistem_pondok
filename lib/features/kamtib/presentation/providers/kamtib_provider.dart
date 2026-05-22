import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/repositories/kamtib_repository.dart';
import '../../data/models/kamtib_model.dart';

class KamtibState {
  final bool isLoading;
  final List<PelanggaranModel> pelanggaranList;
  final String? error;

  const KamtibState({
    this.isLoading = false,
    this.pelanggaranList = const [],
    this.error,
  });

  KamtibState copyWith({bool? isLoading, List<PelanggaranModel>? pelanggaranList, String? error}) {
    return KamtibState(
      isLoading: isLoading ?? this.isLoading,
      pelanggaranList: pelanggaranList ?? this.pelanggaranList,
      error: error,
    );
  }
}

class KamtibNotifier extends StateNotifier<KamtibState> {
  final KamtibRepository _repo;

  KamtibNotifier(this._repo) : super(const KamtibState()) {
    loadData();
  }

  Future<void> loadData() async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final list = await _repo.getPelanggaranTerbaru();
      state = state.copyWith(isLoading: false, pelanggaranList: list);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: 'Gagal memuat data kamtib');
    }
  }
}

final kamtibRepositoryProvider = Provider<KamtibRepository>((ref) {
  return KamtibRepository();
});

final kamtibProvider = StateNotifierProvider<KamtibNotifier, KamtibState>((ref) {
  return KamtibNotifier(ref.watch(kamtibRepositoryProvider));
});
