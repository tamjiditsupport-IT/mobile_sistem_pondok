import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../app/themes/app_theme.dart';
import '../providers/kamtib_provider.dart';
import '../../data/models/kamtib_model.dart';

class KamtibScreen extends ConsumerWidget {
  const KamtibScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(kamtibProvider);

    return Scaffold(
      backgroundColor: const Color(0xFFF0F4F8),
      appBar: AppBar(
        title: const Text('Kamtib & Kedisiplinan'),
      ),
      body: RefreshIndicator(
        onRefresh: () => ref.read(kamtibProvider.notifier).loadData(),
        color: AppTheme.primary,
        child: _buildBody(state, ref),
      ),
    );
  }

  Widget _buildBody(KamtibState state, WidgetRef ref) {
    if (state.isLoading && state.pelanggaranList.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }
    
    if (state.error != null && state.pelanggaranList.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 48, color: AppTheme.danger),
            const SizedBox(height: 12),
            Text(state.error!, style: const TextStyle(fontFamily: 'Poppins')),
            const SizedBox(height: 12),
            ElevatedButton(
              onPressed: () => ref.read(kamtibProvider.notifier).loadData(),
              child: const Text('Coba Lagi'),
            )
          ],
        ),
      );
    }
    
    if (state.pelanggaranList.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.shield_outlined, size: 64, color: AppTheme.success.withValues(alpha: 0.5)),
            const SizedBox(height: 16),
            const Text(
              'Tidak ada catatan pelanggaran',
              style: TextStyle(fontFamily: 'Poppins', fontSize: 16, color: AppTheme.textSecondary),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: state.pelanggaranList.length,
      itemBuilder: (context, index) {
        final p = state.pelanggaranList[index];
        return _PelanggaranCard(pelanggaran: p);
      },
    );
  }
}

class _PelanggaranCard extends StatelessWidget {
  final PelanggaranModel pelanggaran;

  const _PelanggaranCard({required this.pelanggaran});

  @override
  Widget build(BuildContext context) {
    final isBerat = pelanggaran.kategori.toLowerCase() == 'berat' || pelanggaran.poin >= 50;
    final color = isBerat ? AppTheme.danger : AppTheme.warning;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: color.withValues(alpha: 0.3)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          )
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    pelanggaran.namaSantri,
                    style: const TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: AppTheme.textPrimary,
                    ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: color,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    '-${pelanggaran.poin} Poin',
                    style: const TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(Icons.gavel_rounded, size: 16, color: color),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    pelanggaran.namaPelanggaran,
                    style: const TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 13,
                      color: AppTheme.textPrimary,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  _formatDate(pelanggaran.tanggal),
                  style: const TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 11,
                    color: AppTheme.textSecondary,
                  ),
                ),
                Text(
                  pelanggaran.kategori.toUpperCase(),
                  style: TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                    color: color,
                  ),
                ),
              ],
            )
          ],
        ),
      ),
    );
  }

  String _formatDate(String dateStr) {
    try {
      final dt = DateTime.parse(dateStr);
      return '${dt.day}/${dt.month}/${dt.year}';
    } catch (_) {
      return dateStr;
    }
  }
}
