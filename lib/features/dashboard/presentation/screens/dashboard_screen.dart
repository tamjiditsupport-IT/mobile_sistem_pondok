import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../app/themes/app_theme.dart';
import '../../../../app/routes/app_router.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../providers/dashboard_provider.dart';
import '../widgets/dashboard_widgets.dart';

class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final dashState = ref.watch(dashboardProvider);
    final user = ref.watch(authProvider).user;

    return Scaffold(
      backgroundColor: const Color(0xFFF0F4F8),
      body: RefreshIndicator(
        onRefresh: () => ref.read(dashboardProvider.notifier).refresh(),
        color: AppTheme.primary,
        child: CustomScrollView(
          slivers: [
            // ─── Header AppBar ─────────────────────────────────────────────
            SliverAppBar(
              expandedHeight: 130,
              floating: false,
              pinned: true,
              backgroundColor: AppTheme.primary,
              flexibleSpace: FlexibleSpaceBar(
                background: Container(
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [AppTheme.primaryDark, AppTheme.primary, AppTheme.primaryLight],
                    ),
                  ),
                  child: SafeArea(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  _getGreeting(),
                                  style: const TextStyle(
                                    fontFamily: 'Poppins',
                                    fontSize: 13,
                                    color: Colors.white70,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  user?.name ?? 'Pengguna',
                                  style: const TextStyle(
                                    fontFamily: 'Poppins',
                                    fontSize: 18,
                                    fontWeight: FontWeight.w700,
                                    color: Colors.white,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                const SizedBox(height: 4),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                  decoration: BoxDecoration(
                                    color: Colors.white.withValues(alpha: 0.2),
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  child: Text(
                                    _getRoleLabel(user?.role),
                                    style: const TextStyle(
                                      fontFamily: 'Poppins',
                                      fontSize: 10,
                                      color: Colors.white,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          GestureDetector(
                            onTap: () => context.go(AppRoutes.profil),
                            child: CircleAvatar(
                              radius: 26,
                              backgroundColor: Colors.white.withValues(alpha: 0.25),
                              child: Text(
                                (user?.name.isNotEmpty == true)
                                    ? user!.name[0].toUpperCase()
                                    : 'U',
                                style: const TextStyle(
                                  fontFamily: 'Poppins',
                                  fontSize: 20,
                                  fontWeight: FontWeight.w700,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),

            // ─── Body Content ──────────────────────────────────────────────
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [

                    // ── Error Banner ──────────────────────────────────────
                    if (dashState.error != null)
                      Container(
                        margin: const EdgeInsets.only(bottom: 16),
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: AppTheme.warning.withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: AppTheme.warning.withValues(alpha: 0.4)),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.wifi_off_rounded, color: AppTheme.warning, size: 18),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Text(
                                'Beberapa data tidak dapat dimuat. Periksa koneksi server.',
                                style: TextStyle(
                                  fontFamily: 'Poppins',
                                  fontSize: 12,
                                  color: AppTheme.warning.withValues(alpha: 0.9),
                                ),
                              ),
                            ),
                            TextButton(
                              onPressed: () => ref.read(dashboardProvider.notifier).refresh(),
                              style: TextButton.styleFrom(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                minimumSize: Size.zero,
                              ),
                              child: const Text('Coba lagi', style: TextStyle(fontSize: 11, fontFamily: 'Poppins')),
                            ),
                          ],
                        ),
                      ),

                    // ── Balance Card ──────────────────────────────────────
                    BalanceCard(
                      balance: dashState.bankData?.formattedTotalSaldo ?? 'Rp -',
                      accountNumber: '•••• •••• ••••',
                      accountName: user?.name ?? 'Rekening Santri',
                      isLoading: dashState.isLoading,
                      onTopUp: () => context.go(AppRoutes.keuangan),
                      onDetail: () => context.go(AppRoutes.keuangan),
                    ),
                    const SizedBox(height: 24),

                    // ── Quick Actions ─────────────────────────────────────
                    const SectionHeader(title: 'Aksi Cepat'),
                    const SizedBox(height: 12),
                    QuickActionGrid(
                      actions: _buildQuickActions(context, user?.role),
                    ),
                    const SizedBox(height: 24),

                    // ── Statistik (hanya admin/staf) ──────────────────────
                    if (_isAdminOrStaf(user?.role)) ...[
                      const SectionHeader(title: 'Statistik Pondok'),
                      const SizedBox(height: 12),
                      GridView.count(
                        crossAxisCount: 2,
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        crossAxisSpacing: 12,
                        mainAxisSpacing: 12,
                        childAspectRatio: 1.4,
                        children: [
                          StatCard(
                            label: 'Total Santri',
                            value: dashState.isLoading
                                ? '...'
                                : '${dashState.smptData?.totalSantri ?? 0}',
                            icon: Icons.people_rounded,
                            color: const Color(0xFF1A5276),
                            secondColor: const Color(0xFF2E86C1),
                            isLoading: dashState.isLoading,
                          ),
                          StatCard(
                            label: 'Total Staf',
                            value: dashState.isLoading
                                ? '...'
                                : '${dashState.smptData?.totalStaf ?? 0}',
                            icon: Icons.badge_rounded,
                            color: const Color(0xFF1D8348),
                            secondColor: const Color(0xFF27AE60),
                            isLoading: dashState.isLoading,
                          ),
                          StatCard(
                            label: 'Calon Santri',
                            value: dashState.isLoading
                                ? '...'
                                : '${dashState.smptData?.totalCalonSantri ?? 0}',
                            icon: Icons.person_add_rounded,
                            color: const Color(0xFF7D3C98),
                            secondColor: const Color(0xFF9B59B6),
                            isLoading: dashState.isLoading,
                          ),
                          StatCard(
                            label: 'Total Akun Bank',
                            value: dashState.isLoading
                                ? '...'
                                : '${dashState.bankData?.totalAkun ?? 0}',
                            icon: Icons.account_balance_wallet_rounded,
                            color: const Color(0xFFB7770D),
                            secondColor: const Color(0xFFF39C12),
                            isLoading: dashState.isLoading,
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),

                      // Bank Summary
                      const SectionHeader(title: 'Ringkasan Bank Hari Ini'),
                      const SizedBox(height: 12),
                      _BankSummaryRow(
                        topUp: dashState.bankData?.formattedTopUp ?? 'Rp -',
                        transaksi: dashState.bankData?.formattedTransaksi ?? 'Rp -',
                        totalTrx: dashState.bankData?.totalTransaksiCount ?? 0,
                        isLoading: dashState.isLoading,
                      ),
                      const SizedBox(height: 24),
                    ],

                    // ── Info Aplikasi ─────────────────────────────────────
                    _InfoCard(),
                    const SizedBox(height: 80),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _getGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 11) return 'Selamat Pagi 🌤️';
    if (hour < 15) return 'Selamat Siang ☀️';
    if (hour < 18) return 'Selamat Sore 🌇';
    return 'Selamat Malam 🌙';
  }

  String _getRoleLabel(String? role) {
    if (role == null) return 'Pengguna';
    final r = role.toLowerCase();
    if (r.contains('wali')) return '👨‍👩‍👦 Wali Santri';
    if (r.contains('santri')) return '🎓 Santri';
    if (r.contains('admin')) return '⚙️ Administrator';
    if (r.contains('guru') || r.contains('staf')) return '👨‍🏫 Staf/Guru';
    return role;
  }

  bool _isAdminOrStaf(String? role) {
    if (role == null) return false;
    final r = role.toLowerCase();
    return r.contains('admin') || r.contains('staf') || r.contains('staff') || r.contains('guru');
  }

  List<QuickAction> _buildQuickActions(BuildContext context, String? role) {
    final actions = <QuickAction>[
      QuickAction(
        icon: Icons.account_balance_wallet_rounded,
        label: 'Keuangan',
        color: AppTheme.primary,
        onTap: () => context.go(AppRoutes.keuangan),
      ),
      QuickAction(
        icon: Icons.add_card_rounded,
        label: 'Top Up',
        color: AppTheme.secondary,
        onTap: () => context.go(AppRoutes.keuangan),
      ),
      QuickAction(
        icon: Icons.receipt_long_rounded,
        label: 'Tagihan',
        color: AppTheme.accent,
        onTap: () => context.go(AppRoutes.keuangan),
      ),
      QuickAction(
        icon: Icons.person_rounded,
        label: 'Profil',
        color: const Color(0xFF7D3C98),
        onTap: () => context.go(AppRoutes.profil),
      ),
    ];

    final r = role?.toLowerCase() ?? '';
    if (r.contains('admin') || r.contains('staf') || r.contains('staff')) {
      actions.addAll([
        QuickAction(
          icon: Icons.people_rounded,
          label: 'Santri',
          color: const Color(0xFF1D8348),
          onTap: () => context.go(AppRoutes.santri),
        ),
        QuickAction(
          icon: Icons.shield_rounded,
          label: 'Kamtib',
          color: AppTheme.danger,
          onTap: () => context.go(AppRoutes.kamtib),
        ),
      ]);
    }

    return actions;
  }
}

// ─── Bank Summary Row Widget ──────────────────────────────────────────────────
class _BankSummaryRow extends StatelessWidget {
  final String topUp;
  final String transaksi;
  final int totalTrx;
  final bool isLoading;

  const _BankSummaryRow({
    required this.topUp,
    required this.transaksi,
    required this.totalTrx,
    required this.isLoading,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(child: _SummaryItem(label: 'Top Up Hari Ini', value: topUp, icon: Icons.arrow_upward_rounded, color: AppTheme.secondary, isLoading: isLoading)),
        const SizedBox(width: 8),
        Expanded(child: _SummaryItem(label: 'Transaksi', value: transaksi, icon: Icons.swap_horiz_rounded, color: AppTheme.primary, isLoading: isLoading)),
        const SizedBox(width: 8),
        Expanded(child: _SummaryItem(label: 'Jml Transaksi', value: '$totalTrx', icon: Icons.receipt_outlined, color: AppTheme.accent, isLoading: isLoading)),
      ],
    );
  }
}

class _SummaryItem extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color color;
  final bool isLoading;

  const _SummaryItem({
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
    required this.isLoading,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(height: 6),
          if (isLoading)
            Container(height: 14, width: 50, decoration: BoxDecoration(color: Colors.grey.shade200, borderRadius: BorderRadius.circular(4)))
          else
            Text(value, style: TextStyle(fontFamily: 'Poppins', fontSize: 12, fontWeight: FontWeight.w700, color: color), maxLines: 1, overflow: TextOverflow.ellipsis),
          const SizedBox(height: 2),
          Text(label, style: const TextStyle(fontFamily: 'Poppins', fontSize: 9, color: AppTheme.textSecondary), textAlign: TextAlign.center),
        ],
      ),
    );
  }
}

// ─── Info Card ────────────────────────────────────────────────────────────────
class _InfoCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFECF0F1)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: AppTheme.primary.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(Icons.mosque_rounded, color: AppTheme.primary, size: 24),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Pondok Mobile',
                  style: TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: AppTheme.textPrimary,
                  ),
                ),
                Text(
                  'Sistem Manajemen Pondok Pesantren v1.0',
                  style: TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 11,
                    color: AppTheme.textSecondary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
