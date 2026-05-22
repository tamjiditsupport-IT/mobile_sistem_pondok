import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../app/themes/app_theme.dart';
import '../../features/auth/presentation/screens/login_screen.dart';
import '../../features/auth/presentation/providers/auth_provider.dart';
import '../../features/dashboard/presentation/screens/main_screen.dart';
import '../../features/dashboard/presentation/screens/dashboard_screen.dart';
import '../../features/profil/presentation/screens/profil_screen.dart';

// ─── Route Names ──────────────────────────────────────────────────────────────
class AppRoutes {
  static const String splash = '/';
  static const String login = '/login';
  static const String home = '/home';
  static const String dashboard = '/home/dashboard';
  static const String keuangan = '/home/keuangan';
  static const String transaksi = '/home/keuangan/transaksi';
  static const String topUp = '/home/keuangan/topup';
  static const String santri = '/home/santri';
  static const String santriDetail = '/home/santri/:id';
  static const String akademik = '/home/akademik';
  static const String kamtib = '/home/kamtib';
  static const String perizinan = '/home/kamtib/perizinan';
  static const String profil = '/home/profil';
}

// ─── Router Provider ──────────────────────────────────────────────────────────
final routerProvider = Provider<GoRouter>((ref) {
  final authState = ref.watch(authProvider);

  return GoRouter(
    initialLocation: AppRoutes.splash,
    redirect: (context, state) {
      final isAuthenticated = authState.status == AuthStatus.authenticated;
      final isLoading = authState.status == AuthStatus.loading ||
          authState.status == AuthStatus.initial;
      final isLoginPage = state.matchedLocation == AppRoutes.login;

      if (isLoading) return null;
      if (!isAuthenticated && !isLoginPage) return AppRoutes.login;
      if (isAuthenticated && isLoginPage) return AppRoutes.home;
      return null;
    },
    routes: [
      GoRoute(
        path: AppRoutes.splash,
        builder: (context, state) => const _SplashScreen(),
      ),
      GoRoute(
        path: AppRoutes.login,
        builder: (context, state) => const LoginScreen(),
      ),
      ShellRoute(
        builder: (context, state, child) => MainScreen(child: child),
        routes: [
          GoRoute(
            path: AppRoutes.home,
            redirect: (context, state) => AppRoutes.dashboard,
          ),
          // ── Dashboard ───────────────────────────────────────────────────
          GoRoute(
            path: AppRoutes.dashboard,
            builder: (context, state) => const DashboardScreen(),
          ),
          // ── Keuangan ────────────────────────────────────────────────────
          GoRoute(
            path: AppRoutes.keuangan,
            builder: (context, state) => const _KeuanganScreen(),
          ),
          // ── Santri ──────────────────────────────────────────────────────
          GoRoute(
            path: AppRoutes.santri,
            builder: (context, state) => const _SantriScreen(),
          ),
          // ── Kamtib ──────────────────────────────────────────────────────
          GoRoute(
            path: AppRoutes.kamtib,
            builder: (context, state) => const _KamtibScreen(),
          ),
          // ── Profil ──────────────────────────────────────────────────────
          GoRoute(
            path: AppRoutes.profil,
            builder: (context, state) => const ProfilScreen(),
          ),
        ],
      ),
    ],
  );
});

// ─── Splash Screen ────────────────────────────────────────────────────────────
class _SplashScreen extends StatelessWidget {
  const _SplashScreen();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.primary,
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.mosque_rounded, size: 72, color: Colors.white),
            const SizedBox(height: 16),
            const Text(
              'PONDOK MOBILE',
              style: TextStyle(
                fontFamily: 'Poppins',
                fontSize: 22,
                fontWeight: FontWeight.w700,
                color: Colors.white,
                letterSpacing: 2,
              ),
            ),
            const SizedBox(height: 40),
            const CircularProgressIndicator(color: Colors.white70, strokeWidth: 2),
          ],
        ),
      ),
    );
  }
}

// ─── Placeholder Screens (akan dikembangkan selanjutnya) ─────────────────────

class _KeuanganScreen extends StatelessWidget {
  const _KeuanganScreen();
  @override
  Widget build(BuildContext context) => _ComingSoonPage(
    title: 'Keuangan',
    icon: Icons.account_balance_wallet_rounded,
    description: 'Lihat saldo, riwayat transaksi, tagihan, dan top-up rekening santri.',
  );
}

class _SantriScreen extends StatelessWidget {
  const _SantriScreen();
  @override
  Widget build(BuildContext context) => _ComingSoonPage(
    title: 'Manajemen Santri',
    icon: Icons.people_rounded,
    description: 'Data santri, informasi detail, dan riwayat akademik.',
  );
}

class _KamtibScreen extends StatelessWidget {
  const _KamtibScreen();
  @override
  Widget build(BuildContext context) => _ComingSoonPage(
    title: 'Kamtib',
    icon: Icons.shield_rounded,
    description: 'Perizinan santri, pelanggaran, sanksi, dan laporan.',
  );
}

/// Halaman placeholder yang lebih elegan dari sekedar teks
class _ComingSoonPage extends StatelessWidget {
  final String title;
  final IconData icon;
  final String description;

  const _ComingSoonPage({
    required this.title,
    required this.icon,
    required this.description,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: AppTheme.primary.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, size: 56, color: AppTheme.primary),
              ),
              const SizedBox(height: 24),
              Text(
                title,
                style: Theme.of(context).textTheme.headlineSmall,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 12),
              Text(
                description,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: AppTheme.textSecondary,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 32),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                decoration: BoxDecoration(
                  color: AppTheme.accent.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: AppTheme.accent.withValues(alpha: 0.3)),
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.construction_rounded, color: AppTheme.accent, size: 16),
                    SizedBox(width: 8),
                    Text(
                      'Segera hadir di versi berikutnya',
                      style: TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: 12,
                        color: AppTheme.accent,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
