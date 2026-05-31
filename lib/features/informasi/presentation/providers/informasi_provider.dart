import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/repositories/informasi_repository.dart';
import '../../data/models/informasi_models.dart';

class InformasiState {
  final bool isLoading;
  final List<NewsModel> beritaList;
  final List<ActivityModel> kegiatanList;
  final String? error;

  const InformasiState({
    this.isLoading = false,
    this.beritaList = const [],
    this.kegiatanList = const [],
    this.error,
  });

  InformasiState copyWith({
    bool? isLoading,
    List<NewsModel>? beritaList,
    List<ActivityModel>? kegiatanList,
    String? error,
    bool clearError = false,
  }) {
    return InformasiState(
      isLoading: isLoading ?? this.isLoading,
      beritaList: beritaList ?? this.beritaList,
      kegiatanList: kegiatanList ?? this.kegiatanList,
      error: clearError ? null : (error ?? this.error),
    );
  }
}

class InformasiNotifier extends StateNotifier<InformasiState> {
  final InformasiRepository _repo;

  InformasiNotifier(this._repo) : super(const InformasiState());

  Future<void> loadAll() async {
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      final results = await Future.wait([
        _repo.getBerita(),
        _repo.getKegiatan(),
      ]);
      state = state.copyWith(
        isLoading: false,
        beritaList: results[0] as List<NewsModel>,
        kegiatanList: results[1] as List<ActivityModel>,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString().replaceAll('Exception: ', ''),
      );
    }
  }
}

final informasiRepositoryProvider = Provider<InformasiRepository>((ref) {
  return InformasiRepository();
});

final informasiProvider = StateNotifierProvider<InformasiNotifier, InformasiState>((ref) {
  final notifier = InformasiNotifier(ref.watch(informasiRepositoryProvider));
  notifier.loadAll();
  return notifier;
});
