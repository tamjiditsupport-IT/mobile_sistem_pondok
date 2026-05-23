import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/repositories/kamtib_repository.dart';
import '../../data/models/kamtib_model.dart';

class KamtibState {
  final bool isLoading;
  final List<PelanggaranModel> pelanggaranList;
  final List<PerizinanModel> perizinanList;
  final String? error;

  const KamtibState({
    this.isLoading = false,
    this.pelanggaranList = const [],
    this.perizinanList = const [],
    this.error,
  });

  KamtibState copyWith({
    bool? isLoading, 
    List<PelanggaranModel>? pelanggaranList, 
    List<PerizinanModel>? perizinanList,
    String? error,
  }) {
    return KamtibState(
      isLoading: isLoading ?? this.isLoading,
      pelanggaranList: pelanggaranList ?? this.pelanggaranList,
      perizinanList: perizinanList ?? this.perizinanList,
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
      final responses = await Future.wait([
        _repo.getPelanggaranTerbaru(),
        _repo.getPerizinan(),
      ]);
      
      state = state.copyWith(
        isLoading: false, 
        pelanggaranList: responses[0] as List<PelanggaranModel>,
        perizinanList: responses[1] as List<PerizinanModel>,
      );
    } catch (e) {
      state = state.copyWith(isLoading: false, error: 'Gagal memuat data kamtib');
    }
  }

  Future<void> submitPerizinan({
    required int studentId,
    required String startDate,
    required String endDate,
    required String reason,
  }) async {
    try {
      await _repo.submitPerizinan(
        studentId: studentId,
        startDate: startDate,
        endDate: endDate,
        reason: reason,
      );
      // Reload data after successful submission
      await loadData();
    } catch (e) {
      throw Exception('Gagal mengajukan perizinan');
    }
  }
}

final kamtibRepositoryProvider = Provider<KamtibRepository>((ref) {
  return KamtibRepository();
});

final kamtibProvider = StateNotifierProvider<KamtibNotifier, KamtibState>((ref) {
  return KamtibNotifier(ref.watch(kamtibRepositoryProvider));
});
