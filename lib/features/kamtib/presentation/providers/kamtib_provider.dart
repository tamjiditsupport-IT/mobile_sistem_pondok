import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/repositories/kamtib_repository.dart';
import '../../data/models/kamtib_model.dart';
import '../../data/models/leave_type_model.dart';

class KamtibState {
  final bool isLoading;
  final List<PelanggaranModel> pelanggaranList;
  final List<PerizinanModel> perizinanList;
  final List<LeaveTypeModel> leaveTypes;
  final bool isLoadingLeaveTypes;
  final String? error;

  const KamtibState({
    this.isLoading = false,
    this.pelanggaranList = const [],
    this.perizinanList = const [],
    this.leaveTypes = const [],
    this.isLoadingLeaveTypes = false,
    this.error,
  });

  KamtibState copyWith({
    bool? isLoading,
    List<PelanggaranModel>? pelanggaranList,
    List<PerizinanModel>? perizinanList,
    List<LeaveTypeModel>? leaveTypes,
    bool? isLoadingLeaveTypes,
    String? error,
    bool clearError = false,
  }) {
    return KamtibState(
      isLoading: isLoading ?? this.isLoading,
      pelanggaranList: pelanggaranList ?? this.pelanggaranList,
      perizinanList: perizinanList ?? this.perizinanList,
      leaveTypes: leaveTypes ?? this.leaveTypes,
      isLoadingLeaveTypes: isLoadingLeaveTypes ?? this.isLoadingLeaveTypes,
      error: clearError ? null : (error ?? this.error),
    );
  }
}

class KamtibNotifier extends StateNotifier<KamtibState> {
  final KamtibRepository _repo;

  KamtibNotifier(this._repo) : super(const KamtibState());

  Future<void> init() async {
    // Load leave types sekali saat init
    await _loadLeaveTypes();
  }

  Future<void> _loadLeaveTypes() async {
    state = state.copyWith(isLoadingLeaveTypes: true);
    try {
      final types = await _repo.getLeaveTypes();
      state = state.copyWith(leaveTypes: types, isLoadingLeaveTypes: false);
    } catch (_) {
      state = state.copyWith(isLoadingLeaveTypes: false);
    }
  }

  Future<void> loadData({int? studentId}) async {
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      final responses = await Future.wait([
        _repo.getPelanggaranTerbaru(studentId: studentId),
        _repo.getPerizinan(studentId: studentId),
      ]);

      state = state.copyWith(
        isLoading: false,
        pelanggaranList: responses[0] as List<PelanggaranModel>,
        perizinanList: responses[1] as List<PerizinanModel>,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString().replaceAll('Exception: ', ''),
      );
    }
  }

  Future<void> submitPerizinan({
    required int studentId,
    required int leaveTypeId,
    required String startDate,
    required String endDate,
    required String reason,
    String? destination,
    String? contactPerson,
    String? contactPhone,
  }) async {
    await _repo.submitPerizinan(
      studentId: studentId,
      leaveTypeId: leaveTypeId,
      startDate: startDate,
      endDate: endDate,
      reason: reason,
      destination: destination,
      contactPerson: contactPerson,
      contactPhone: contactPhone,
    );
    await loadData();
  }

  Future<void> approvePerizinan(int id) async {
    await _repo.approvePerizinan(id);
    await loadData();
  }

  Future<void> rejectPerizinan(int id, String reason) async {
    await _repo.rejectPerizinan(id, reason);
    await loadData();
  }
}

final kamtibRepositoryProvider = Provider<KamtibRepository>((ref) {
  return KamtibRepository();
});

final kamtibProvider = StateNotifierProvider<KamtibNotifier, KamtibState>((ref) {
  final notifier = KamtibNotifier(ref.watch(kamtibRepositoryProvider));
  notifier.init(); // load leave types on startup
  return notifier;
});
