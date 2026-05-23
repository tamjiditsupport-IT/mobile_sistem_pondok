import 'dart:async';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../app/themes/app_theme.dart';
import '../../features/auth/presentation/screens/login_screen.dart';
import '../../features/auth/presentation/providers/auth_provider.dart';
import '../../features/dashboard/presentation/screens/main_screen.dart';
import '../../features/dashboard/presentation/screens/dashboard_screen.dart';
import '../../features/profil/presentation/screens/profil_screen.dart';
import '../../features/keuangan/presentation/screens/keuangan_screen.dart';
import '../../features/santri/presentation/screens/santri_screen.dart';
import '../../features/kamtib/presentation/screens/kamtib_screen.dart';
import '../../features/akademik/presentation/screens/akademik_screen.dart';

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

// ─── Stream Notifier untuk GoRouter Refresh ──────────────────────────────────
class GoRouterRefreshStream extends ChangeNotifier {
  GoRouterRefreshStream(Stream<dynamic> stream) {
    notifyListeners();
    _subscription = stream.listen((dynamic _) => notifyListeners());
  }

  late final StreamSubscription<dynamic> _subscription;

  @override
  void dispose() {
    _subscription.cancel();
    super.dispose();
  }
}

// ─── Router Provider ──────────────────────────────────────────────────────────
final routerProvider = Provider<GoRouter>((ref) {
  final notifier = ref.watch(authProvider.notifier);

  return GoRouter(
    initialLocation: AppRoutes.splash,
    refreshListenable: GoRouterRefreshStream(notifier.stream),
    redirect: (context, state) {
      final authState = ref.read(authProvider);
      final isAuthenticated = authState.status == AuthStatus.authenticated;
      final isLoading =
          authState.status == AuthStatus.loading ||
          authState.status == AuthStatus.initial;
      final isLoginPage = state.matchedLocation == AppRoutes.login;

      if (isLoading) return null;
      if (!isAuthenticated && !isLoginPage) return AppRoutes.login;
      if (isAuthenticated && isLoginPage) return AppRoutes.home;
      if (isAuthenticated && state.matchedLocation == AppRoutes.splash)
        return AppRoutes.home;
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
            builder: (context, state) => const KeuanganScreen(),
          ),
          // ── Santri ──────────────────────────────────────────────────────
          GoRoute(
            path: AppRoutes.santri,
            builder: (context, state) => const SantriScreen(),
          ),
          // ── Kamtib ──────────────────────────────────────────────────────
          GoRoute(
            path: AppRoutes.kamtib,
            builder: (context, state) => const KamtibScreen(),
          ),
          // ── Akademik ────────────────────────────────────────────────────
          GoRoute(
            path: AppRoutes.akademik,
            builder: (context, state) => const AkademikScreen(),
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
              'SMARTMU',
              style: TextStyle(
                fontFamily: 'Poppins',
                fontSize: 22,
                fontWeight: FontWeight.w700,
                color: Colors.white,
                letterSpacing: 2,
              ),
            ),
            const SizedBox(height: 40),
            const CircularProgressIndicator(
              color: Colors.white70,
              strokeWidth: 2,
            ),
          ],
        ),
      ),
    );
  }
}

// ─── End of Routes ────────────────────────────────────────────────────────────
