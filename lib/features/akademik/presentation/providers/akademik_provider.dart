import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/models/akademik_models.dart';
import '../../data/repositories/akademik_repository.dart';

class AkademikState {
  final bool isLoading;
  final List<JadwalModel> jadwal;
  final List<NilaiModel> nilai;
  final List<AbsensiModel> absensi;
  final String? error;

  const AkademikState({
    this.isLoading = false,
    this.jadwal = const [],
    this.nilai = const [],
    this.absensi = const [],
    this.error,
  });

  AkademikState copyWith({
    bool? isLoading,
    List<JadwalModel>? jadwal,
    List<NilaiModel>? nilai,
    List<AbsensiModel>? absensi,
    String? error,
  }) {
    return AkademikState(
      isLoading: isLoading ?? this.isLoading,
      jadwal: jadwal ?? this.jadwal,
      nilai: nilai ?? this.nilai,
      absensi: absensi ?? this.absensi,
      error: error,
    );
  }
}

class AkademikNotifier extends StateNotifier<AkademikState> {
  final AkademikRepository _repo;

  AkademikNotifier(this._repo) : super(const AkademikState()) {
    loadData();
  }

  Future<void> loadData({int? studentId}) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final responses = await Future.wait([
        _repo.getJadwal(studentId: studentId),
        _repo.getNilai(studentId: studentId),
        _repo.getAbsensiSummary(studentId: studentId),
      ]);

      state = state.copyWith(
        isLoading: false,
        jadwal: responses[0] as List<JadwalModel>,
        nilai: responses[1] as List<NilaiModel>,
        absensi: responses[2] as List<AbsensiModel>,
      );
    } catch (e) {
      state = state.copyWith(isLoading: false, error: 'Gagal memuat data akademik');
    }
  }
}

final akademikRepositoryProvider = Provider<AkademikRepository>((ref) {
  return AkademikRepository();
});

final akademikProvider = StateNotifierProvider<AkademikNotifier, AkademikState>((ref) {
  return AkademikNotifier(ref.watch(akademikRepositoryProvider));
});
