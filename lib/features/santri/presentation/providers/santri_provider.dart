import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/repositories/santri_repository.dart';
import '../../data/models/santri_model.dart';
import '../../../auth/presentation/providers/auth_provider.dart';

class SantriState {
  final bool isLoading;
  final bool isLoadingMore;
  final List<SantriModel> santriList;
  final String? error;
  final int currentPage;
  final int lastPage;
  final bool hasMore;
  final String searchQuery;

  const SantriState({
    this.isLoading = false,
    this.isLoadingMore = false,
    this.santriList = const [],
    this.error,
    this.currentPage = 1,
    this.lastPage = 1,
    this.hasMore = false,
    this.searchQuery = '',
  });

  SantriState copyWith({
    bool? isLoading,
    bool? isLoadingMore,
    List<SantriModel>? santriList,
    String? error,
    bool clearError = false,
    int? currentPage,
    int? lastPage,
    bool? hasMore,
    String? searchQuery,
  }) {
    return SantriState(
      isLoading: isLoading ?? this.isLoading,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      santriList: santriList ?? this.santriList,
      error: clearError ? null : (error ?? this.error),
      currentPage: currentPage ?? this.currentPage,
      lastPage: lastPage ?? this.lastPage,
      hasMore: hasMore ?? this.hasMore,
      searchQuery: searchQuery ?? this.searchQuery,
    );
  }
}

class SantriNotifier extends StateNotifier<SantriState> {
  final SantriRepository _repo;
  final AuthState _authState;
  Timer? _debounce;

  SantriNotifier(this._repo, this._authState) : super(const SantriState());

  Future<void> loadSantri({bool reset = true}) async {
    // Wali santri load children only
    if (_authState.user?.isWaliSantri == true) {
      state = state.copyWith(isLoading: true, clearError: true);
      try {
        final list = await _repo.getSantriByWali(_authState.user!.id);
        state = state.copyWith(isLoading: false, santriList: list, hasMore: false);
      } catch (e) {
        state = state.copyWith(isLoading: false, error: e.toString().replaceAll('Exception: ', ''));
      }
      return;
    }

    if (reset) {
      state = state.copyWith(isLoading: true, clearError: true, currentPage: 1, santriList: []);
    } else {
      state = state.copyWith(isLoadingMore: true);
    }

    try {
      final page = reset ? 1 : state.currentPage + 1;
      final result = await _repo.getSantriList(
        search: state.searchQuery.isNotEmpty ? state.searchQuery : null,
        page: page,
      );
      state = state.copyWith(
        isLoading: false,
        isLoadingMore: false,
        santriList: reset ? result.data : [...state.santriList, ...result.data],
        currentPage: result.currentPage,
        lastPage: result.lastPage,
        hasMore: result.currentPage < result.lastPage,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        isLoadingMore: false,
        error: e.toString().replaceAll('Exception: ', ''),
      );
    }
  }

  Future<void> loadMore() async {
    if (state.isLoadingMore || !state.hasMore) return;
    await loadSantri(reset: false);
  }

  /// Real-time search dengan debounce 400ms
  void searchDebounced(String query) {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 400), () {
      state = state.copyWith(searchQuery: query);
      loadSantri(reset: true);
    });
  }

  @override
  void dispose() {
    _debounce?.cancel();
    super.dispose();
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

final santriDetailProvider = FutureProvider.family<SantriModel, int>((ref, id) async {
  final repo = ref.watch(santriRepositoryProvider);
  return repo.getSantriById(id);
});
