import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../app/themes/app_theme.dart';
import '../providers/santri_provider.dart';
import '../../data/models/santri_model.dart';
import '../../../auth/presentation/providers/auth_provider.dart';

class SantriScreen extends ConsumerStatefulWidget {
  const SantriScreen({super.key});

  @override
  ConsumerState<SantriScreen> createState() => _SantriScreenState();
}

class _SantriScreenState extends ConsumerState<SantriScreen> {
  final _searchController = TextEditingController();
  
  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(santriProvider);
    final user = ref.watch(authProvider).user;
    final isWali = user?.isWaliSantri ?? false;

    return Scaffold(
      backgroundColor: const Color(0xFFF0F4F8),
      appBar: AppBar(
        title: Text(isWali ? 'Data Anak' : 'Data Santri'),
        bottom: isWali ? null : PreferredSize(
          preferredSize: const Size.fromHeight(60),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Cari nama atau NIS santri...',
                prefixIcon: const Icon(Icons.search, color: AppTheme.textSecondary),
                suffixIcon: IconButton(
                  icon: const Icon(Icons.clear, color: AppTheme.textSecondary),
                  onPressed: () {
                    _searchController.clear();
                    ref.read(santriProvider.notifier).loadSantri();
                  },
                ),
                filled: true,
                fillColor: Colors.white,
                contentPadding: const EdgeInsets.symmetric(vertical: 0),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
              ),
              onSubmitted: (val) {
                if (val.trim().isNotEmpty) {
                  ref.read(santriProvider.notifier).search(val.trim());
                }
              },
            ),
          ),
        ),
      ),
      body: RefreshIndicator(
        onRefresh: () => ref.read(santriProvider.notifier).loadSantri(),
        color: AppTheme.primary,
        child: _buildBody(state, isWali),
      ),
    );
  }

  Widget _buildBody(SantriState state, bool isWali) {
    if (state.isLoading && state.santriList.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }
    if (state.error != null && state.santriList.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 48, color: AppTheme.danger),
            const SizedBox(height: 12),
            Text(state.error!, style: const TextStyle(fontFamily: 'Poppins')),
            const SizedBox(height: 12),
            ElevatedButton(
              onPressed: () => ref.read(santriProvider.notifier).loadSantri(),
              child: const Text('Coba Lagi'),
            )
          ],
        ),
      );
    }
    if (state.santriList.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.people_outline, size: 64, color: AppTheme.textSecondary.withValues(alpha: 0.5)),
            const SizedBox(height: 16),
            const Text(
              'Tidak ada data santri',
              style: TextStyle(fontFamily: 'Poppins', fontSize: 16, color: AppTheme.textSecondary),
            ),
          ],
        ),
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: state.santriList.length,
      separatorBuilder: (_, __) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        return _SantriCard(santri: state.santriList[index]);
      },
    );
  }
}

class _SantriCard extends StatelessWidget {
  final SantriModel santri;

  const _SantriCard({required this.santri});

  @override
  Widget build(BuildContext context) {
    final isAktif = santri.status.toLowerCase() == 'aktif';
    
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          )
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(14),
          onTap: () {
            context.push('/home/santri/${santri.id}');
          },
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                // Avatar
                Container(
                  width: 56,
                  height: 56,
                  decoration: BoxDecoration(
                    color: AppTheme.primary.withValues(alpha: 0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: Text(
                      santri.nama.isNotEmpty ? santri.nama[0].toUpperCase() : 'S',
                      style: const TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                        color: AppTheme.primary,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                
                // Info
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        santri.nama,
                        style: const TextStyle(
                          fontFamily: 'Poppins',
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          color: AppTheme.textPrimary,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'NIS: ${santri.nis}',
                        style: const TextStyle(
                          fontFamily: 'Poppins',
                          fontSize: 12,
                          color: AppTheme.textSecondary,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          const Icon(Icons.class_outlined, size: 14, color: AppTheme.primary),
                          const SizedBox(width: 4),
                          Expanded(
                            child: Text(
                              '${santri.kelas} | ${santri.kamar}',
                              style: const TextStyle(
                                fontFamily: 'Poppins',
                                fontSize: 11,
                                color: AppTheme.primary,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      )
                    ],
                  ),
                ),
                
                // Status badge
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: (isAktif ? AppTheme.success : AppTheme.danger).withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    santri.status,
                    style: TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                      color: isAktif ? AppTheme.success : AppTheme.danger,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
