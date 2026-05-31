import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../app/themes/app_theme.dart';
import '../providers/kamtib_provider.dart';
import '../../data/models/kamtib_model.dart';
import '../../../../features/auth/presentation/providers/auth_provider.dart';
import '../../../../features/santri/presentation/providers/santri_provider.dart';

class KamtibScreen extends ConsumerStatefulWidget {
  const KamtibScreen({super.key});

  @override
  ConsumerState<KamtibScreen> createState() => _KamtibScreenState();
}

class _KamtibScreenState extends ConsumerState<KamtibScreen> {
  int? selectedSantriId;

  @override
  void initState() {
    super.initState();
    // Gunakan addPostFrameCallback agar provider sudah siap
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initLoad();
    });
  }

  void _initLoad() {
    if (!mounted) return;
    final user = ref.read(authProvider).user;
    if (user != null && user.isWaliSantri) {
      ref.read(santriProvider.notifier).loadSantri();
    } else {
      ref.read(kamtibProvider.notifier).loadData();
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(kamtibProvider);
    final user = ref.watch(authProvider).user;
    final isStaffOrAdmin = user?.isStaff == true || user?.isAdmin == true;
    final isWaliSantri = user?.isWaliSantri == true;

    final santriState = ref.watch(santriProvider);

    // Auto-select first child jika wali santri: listen perubahan, bukan di dalam build()
    ref.listen<dynamic>(santriProvider, (_, next) {
      final s = next as dynamic;
      if (isWaliSantri && selectedSantriId == null && s.santriList.isNotEmpty) {
        setState(() {
          selectedSantriId = s.santriList.first.id;
        });
        ref.read(kamtibProvider.notifier).loadData(studentId: selectedSantriId);
      }
    });

    return DefaultTabController(
      length: 2,
      child: Scaffold(
        backgroundColor: const Color(0xFFF0F4F8),
        appBar: AppBar(
          backgroundColor: AppTheme.primary,
          elevation: 0,
          iconTheme: const IconThemeData(color: Colors.white),
          title: const Text(
            'Kamtib & Perizinan',
            style: TextStyle(fontFamily: 'Poppins', fontWeight: FontWeight.w600, color: Colors.white),
          ),
          bottom: TabBar(
            labelColor: Colors.white,
            unselectedLabelColor: Colors.white.withValues(alpha: 0.6),
            indicatorColor: Colors.white,
            indicatorWeight: 4,
            indicatorSize: TabBarIndicatorSize.label,
            indicator: const UnderlineTabIndicator(
              borderSide: BorderSide(width: 4.0, color: Colors.white),
              borderRadius: BorderRadius.vertical(top: Radius.circular(4)),
            ),
            labelStyle: const TextStyle(
              fontFamily: 'Poppins',
              fontSize: 14,
              fontWeight: FontWeight.w700,
            ),
            unselectedLabelStyle: const TextStyle(
              fontFamily: 'Poppins',
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
            tabs: const [
              Tab(text: 'Pelanggaran'),
              Tab(text: 'Perizinan'),
            ],
          ),
        ),
        body: Column(
          children: [
            if (isWaliSantri && santriState.santriList.isNotEmpty)
              Container(
                color: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                child: Row(
                  children: [
                    const Icon(Icons.person_outline, color: AppTheme.primary),
                    const SizedBox(width: 12),
                    const Text('Pilih Anak:', style: TextStyle(fontFamily: 'Poppins', fontWeight: FontWeight.w600)),
                    const SizedBox(width: 12),
                    Expanded(
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<int>(
                          value: selectedSantriId,
                          isExpanded: true,
                          items: santriState.santriList.map((s) {
                            return DropdownMenuItem(
                              value: s.id,
                              child: Text(s.nama, style: const TextStyle(fontFamily: 'Poppins')),
                            );
                          }).toList(),
                          onChanged: (val) {
                            if (val != null) {
                              setState(() => selectedSantriId = val);
                              ref.read(kamtibProvider.notifier).loadData(studentId: val);
                            }
                          },
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            Expanded(
              child: TabBarView(
                children: [
                  RefreshIndicator(
                    onRefresh: () => ref.read(kamtibProvider.notifier).loadData(studentId: selectedSantriId),
                    color: AppTheme.primary,
                    child: _buildPelanggaranTab(state),
                  ),
                  RefreshIndicator(
                    onRefresh: () => ref.read(kamtibProvider.notifier).loadData(studentId: selectedSantriId),
                    color: AppTheme.primary,
                    child: _buildPerizinanTab(state, isStaffOrAdmin, context),
                  ),
                ],
              ),
            ),
          ],
        ),
        floatingActionButton: (isWaliSantri || isStaffOrAdmin) ? FloatingActionButton.extended(
          onPressed: () {
            if (isWaliSantri && selectedSantriId == null) {
              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Pilih anak terlebih dahulu')));
              return;
            }
            _showAddPerizinanDialog(context, isWaliSantri ? selectedSantriId! : null, santriState.santriList, state.leaveTypes);
          },
          backgroundColor: AppTheme.primary,
          icon: const Icon(Icons.add, color: Colors.white),
          label: const Text(
            'Ajukan Izin',
            style: TextStyle(fontFamily: 'Poppins', color: Colors.white, fontWeight: FontWeight.w600),
          ),
        ) : null,
      ),
    );
  }

  void _showAddPerizinanDialog(BuildContext context, int? defaultStudentId, List santriList, List leaveTypes) {
    final reasonController = TextEditingController();
    final destinationController = TextEditingController();
    final contactController = TextEditingController();
    int? formStudentId = defaultStudentId;
    int? leaveTypeId = leaveTypes.isNotEmpty ? leaveTypes.first.id : null;
    DateTime? startDate = DateTime.now();
    DateTime? endDate = DateTime.now().add(const Duration(days: 1));

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Padding(
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(ctx).viewInsets.bottom,
                left: 20,
                right: 20,
                top: 24,
              ),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Ajukan Izin Baru',
                      style: TextStyle(fontFamily: 'Poppins', fontSize: 18, fontWeight: FontWeight.w700),
                    ),
                    const SizedBox(height: 16),

                    if (formStudentId == null && santriList.isNotEmpty)
                      DropdownButtonFormField<int>(
                        decoration: InputDecoration(
                          labelText: 'Pilih Santri',
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                          prefixIcon: const Icon(Icons.person),
                        ),
                        value: formStudentId,
                        items: santriList.map((s) => DropdownMenuItem<int>(
                          value: s.id,
                          child: Text(s.nama),
                        )).toList(),
                        onChanged: (val) => setModalState(() => formStudentId = val),
                      ),
                    if (formStudentId == null && santriList.isNotEmpty)
                      const SizedBox(height: 12),

                    // Jenis izin dari API (dinamis)
                    DropdownButtonFormField<int>(
                      decoration: InputDecoration(
                        labelText: 'Jenis Izin',
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                        prefixIcon: const Icon(Icons.category),
                      ),
                      value: leaveTypeId,
                      items: leaveTypes.map((t) => DropdownMenuItem<int>(
                        value: t.id,
                        child: Text(t.name, style: const TextStyle(fontFamily: 'Poppins')),
                      )).toList(),
                      onChanged: (val) => setModalState(() => leaveTypeId = val),
                    ),
                    const SizedBox(height: 12),

                    Row(
                      children: [
                        Expanded(
                          child: InkWell(
                            onTap: () async {
                              final date = await showDatePicker(
                                context: context,
                                initialDate: startDate!,
                                firstDate: DateTime.now(),
                                lastDate: DateTime.now().add(const Duration(days: 365)),
                              );
                              if (date != null) {
                                setModalState(() {
                                  startDate = date;
                                  if (endDate!.isBefore(startDate!)) endDate = startDate;
                                });
                              }
                            },
                            child: InputDecorator(
                              decoration: InputDecoration(
                                labelText: 'Tanggal Mulai',
                                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                                prefixIcon: const Icon(Icons.calendar_today, size: 18),
                              ),
                              child: Text('${startDate!.day}/${startDate!.month}/${startDate!.year}'),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: InkWell(
                            onTap: () async {
                              final date = await showDatePicker(
                                context: context,
                                initialDate: endDate!,
                                firstDate: startDate!,
                                lastDate: DateTime.now().add(const Duration(days: 365)),
                              );
                              if (date != null) {
                                setModalState(() => endDate = date);
                              }
                            },
                            child: InputDecorator(
                              decoration: InputDecoration(
                                labelText: 'Tanggal Selesai',
                                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                                prefixIcon: const Icon(Icons.calendar_today, size: 18),
                              ),
                              child: Text('${endDate!.day}/${endDate!.month}/${endDate!.year}'),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),

                    TextField(
                      controller: reasonController,
                      decoration: InputDecoration(
                        labelText: 'Alasan Izin',
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                        prefixIcon: const Icon(Icons.edit_note_rounded),
                      ),
                      maxLines: 3,
                    ),
                    const SizedBox(height: 12),

                    TextField(
                      controller: destinationController,
                      decoration: InputDecoration(
                        labelText: 'Tujuan (opsional)',
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                        prefixIcon: const Icon(Icons.location_on_outlined),
                      ),
                    ),
                    const SizedBox(height: 12),

                    TextField(
                      controller: contactController,
                      keyboardType: TextInputType.phone,
                      decoration: InputDecoration(
                        labelText: 'Kontak Wali (opsional)',
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                        prefixIcon: const Icon(Icons.phone_outlined),
                      ),
                    ),
                    const SizedBox(height: 20),

                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () async {
                          if (reasonController.text.trim().isEmpty) {
                            ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Alasan harus diisi')));
                            return;
                          }
                          if (formStudentId == null) {
                            ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Pilih santri terlebih dahulu')));
                            return;
                          }
                          if (leaveTypeId == null) {
                            ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Pilih jenis izin')));
                            return;
                          }

                          Navigator.pop(ctx);

                          try {
                            await ref.read(kamtibProvider.notifier).submitPerizinan(
                              studentId: formStudentId!,
                              leaveTypeId: leaveTypeId!,
                              startDate: startDate!.toIso8601String().split('T').first,
                              endDate: endDate!.toIso8601String().split('T').first,
                              reason: reasonController.text,
                              destination: destinationController.text.isNotEmpty ? destinationController.text : null,
                              contactPhone: contactController.text.isNotEmpty ? contactController.text : null,
                            );
                            if (context.mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text('Pengajuan izin berhasil dikirim'), backgroundColor: AppTheme.success),
                              );
                            }
                          } catch (e) {
                            if (context.mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text(e.toString().replaceAll('Exception: ', '')), backgroundColor: AppTheme.danger),
                              );
                            }
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppTheme.primary,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                        child: const Text(
                          'Kirim Pengajuan',
                          style: TextStyle(fontFamily: 'Poppins', fontSize: 14, fontWeight: FontWeight.w600, color: Colors.white),
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildPerizinanTab(KamtibState state, bool isStaffOrAdmin, BuildContext context) {
    if (state.isLoading && state.perizinanList.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }

    if (state.perizinanList.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.assignment_outlined, size: 64, color: AppTheme.textSecondary.withValues(alpha: 0.5)),
            const SizedBox(height: 16),
            const Text(
              'Belum ada riwayat perizinan',
              style: TextStyle(fontFamily: 'Poppins', fontSize: 16, color: AppTheme.textSecondary),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: state.perizinanList.length,
      itemBuilder: (context, index) {
        final p = state.perizinanList[index];
        final status = p.status;
        Color statusColor = AppTheme.warning;
        if (status == 'approved' || status == 'completed') statusColor = AppTheme.success;
        if (status == 'rejected' || status == 'cancelled') statusColor = AppTheme.danger;

        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: AppTheme.primary.withValues(alpha: 0.1)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.04),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppTheme.primary.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(Icons.assignment_turned_in_rounded, color: AppTheme.primary),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          p.alasan,
                          style: const TextStyle(
                            fontFamily: 'Poppins',
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '${p.tanggal} — ${p.tanggalSelesai}',
                          style: const TextStyle(
                            fontFamily: 'Poppins',
                            fontSize: 12,
                            color: AppTheme.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: statusColor.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      status.toUpperCase(),
                      style: TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                        color: statusColor,
                      ),
                    ),
                  ),
                ],
              ),
              if (isStaffOrAdmin && status.toLowerCase() == 'pending') ...[
                const SizedBox(height: 16),
                const Divider(height: 1),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      onPressed: () async {
                        try {
                          await ref.read(kamtibProvider.notifier).rejectPerizinan(p.id, 'Ditolak Pengurus');
                          if (context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Perizinan Ditolak'), backgroundColor: AppTheme.danger));
                          }
                        } catch (e) {
                          if (context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.toString().replaceAll('Exception: ', '')), backgroundColor: AppTheme.danger));
                          }
                        }
                      },
                      child: const Text('Tolak', style: TextStyle(color: AppTheme.danger, fontFamily: 'Poppins', fontWeight: FontWeight.w600)),
                    ),
                    const SizedBox(width: 8),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.success,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      ),
                      onPressed: () async {
                        try {
                          await ref.read(kamtibProvider.notifier).approvePerizinan(p.id);
                          if (context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Perizinan Disetujui'), backgroundColor: AppTheme.success));
                          }
                        } catch (e) {
                          if (context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.toString().replaceAll('Exception: ', '')), backgroundColor: AppTheme.danger));
                          }
                        }
                      },
                      child: const Text('Setujui', style: TextStyle(color: Colors.white, fontFamily: 'Poppins', fontWeight: FontWeight.w600)),
                    ),
                  ],
                ),
              ],
            ],
          ),
        );
      },
    );
  }

  Widget _buildPelanggaranTab(KamtibState state) {
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
            Text(state.error!, style: const TextStyle(fontFamily: 'Poppins'), textAlign: TextAlign.center),
            const SizedBox(height: 12),
            ElevatedButton(
              onPressed: () => ref.read(kamtibProvider.notifier).loadData(studentId: selectedSantriId),
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
