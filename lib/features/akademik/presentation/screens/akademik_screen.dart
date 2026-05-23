import 'package:flutter/material.dart';
import '../../../../app/themes/app_theme.dart';

class AkademikScreen extends StatefulWidget {
  const AkademikScreen({super.key});

  @override
  State<AkademikScreen> createState() => _AkademikScreenState();
}

class _AkademikScreenState extends State<AkademikScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF0F4F8),
      appBar: AppBar(
        title: const Text('Akademik'),
        bottom: TabBar(
          controller: _tabController,
          labelColor: AppTheme.primary,
          unselectedLabelColor: AppTheme.textSecondary,
          indicatorColor: AppTheme.primary,
          indicatorWeight: 3,
          labelStyle: const TextStyle(
            fontFamily: 'Poppins',
            fontSize: 13,
            fontWeight: FontWeight.w600,
          ),
          unselectedLabelStyle: const TextStyle(
            fontFamily: 'Poppins',
            fontSize: 13,
          ),
          tabs: const [
            Tab(text: 'Jadwal'),
            Tab(text: 'Nilai'),
            Tab(text: 'Absensi'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildJadwalTab(),
          _buildNilaiTab(),
          _buildAbsensiTab(),
        ],
      ),
    );
  }

  Widget _buildJadwalTab() {
    // Dummy Data
    final jadwal = [
      {'hari': 'Senin', 'mapel': 'Matematika', 'jam': '07:00 - 08:30', 'guru': 'Ust. Ahmad'},
      {'hari': 'Senin', 'mapel': 'Fiqih', 'jam': '08:30 - 10:00', 'guru': 'Ust. Hasan'},
      {'hari': 'Selasa', 'mapel': 'Bahasa Arab', 'jam': '07:00 - 08:30', 'guru': 'Ust. Ali'},
      {'hari': 'Selasa', 'mapel': 'Aqidah Akhlaq', 'jam': '08:30 - 10:00', 'guru': 'Ust. Umar'},
    ];

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: jadwal.length,
      itemBuilder: (context, index) {
        final j = jadwal[index];
        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppTheme.primary.withValues(alpha: 0.1)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.04),
                blurRadius: 6,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppTheme.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(Icons.schedule_rounded, color: AppTheme.primary),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          j['mapel']!,
                          style: const TextStyle(
                            fontFamily: 'Poppins',
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        Text(
                          j['hari']!,
                          style: const TextStyle(
                            fontFamily: 'Poppins',
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: AppTheme.secondary,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${j['jam']} • ${j['guru']}',
                      style: const TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: 12,
                        color: AppTheme.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildNilaiTab() {
    // Dummy Data
    final nilai = [
      {'semester': 'Ganjil 2025/2026', 'mapel': 'Matematika', 'nilai': 85},
      {'semester': 'Ganjil 2025/2026', 'mapel': 'Fiqih', 'nilai': 90},
      {'semester': 'Ganjil 2025/2026', 'mapel': 'Bahasa Arab', 'nilai': 78},
      {'semester': 'Ganjil 2025/2026', 'mapel': 'Aqidah Akhlaq', 'nilai': 88},
    ];

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: nilai.length,
      itemBuilder: (context, index) {
        final n = nilai[index];
        final num val = n['nilai'] as num;
        final color = val >= 80 ? AppTheme.success : (val >= 70 ? AppTheme.warning : AppTheme.danger);

        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.04),
                blurRadius: 6,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      n['mapel'] as String,
                      style: const TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Semester ${n['semester']}',
                      style: const TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: 11,
                        color: AppTheme.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  val.toString(),
                  style: TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: color,
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildAbsensiTab() {
    final absensi = [
      {'bulan': 'Januari 2026', 'hadir': 22, 'izin': 1, 'sakit': 0, 'alfa': 0},
      {'bulan': 'Desember 2025', 'hadir': 20, 'izin': 0, 'sakit': 2, 'alfa': 0},
      {'bulan': 'November 2025', 'hadir': 21, 'izin': 0, 'sakit': 0, 'alfa': 1},
    ];

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: absensi.length,
      itemBuilder: (context, index) {
        final a = absensi[index];
        return Container(
          margin: const EdgeInsets.only(bottom: 16),
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
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Icon(Icons.date_range_rounded, size: 20, color: AppTheme.primary),
                  const SizedBox(width: 8),
                  Text(
                    a['bulan'] as String,
                    style: const TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: AppTheme.textPrimary,
                    ),
                  ),
                ],
              ),
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 12),
                child: Divider(height: 1),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _buildAbsensiItem('Hadir', a['hadir'] as int, AppTheme.success),
                  _buildAbsensiItem('Izin', a['izin'] as int, AppTheme.primary),
                  _buildAbsensiItem('Sakit', a['sakit'] as int, AppTheme.warning),
                  _buildAbsensiItem('Alfa', a['alfa'] as int, AppTheme.danger),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildAbsensiItem(String label, int value, Color color) {
    return Column(
      children: [
        Text(
          value.toString(),
          style: TextStyle(
            fontFamily: 'Poppins',
            fontSize: 20,
            fontWeight: FontWeight.w700,
            color: color,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: const TextStyle(
            fontFamily: 'Poppins',
            fontSize: 11,
            fontWeight: FontWeight.w500,
            color: AppTheme.textSecondary,
          ),
        ),
      ],
    );
  }
}
