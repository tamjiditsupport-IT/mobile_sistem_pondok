import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../app/routes/app_router.dart';
import '../../../auth/presentation/providers/auth_provider.dart';

/// Shell utama yang berisi Bottom Navigation Bar.
/// Digunakan sebagai wrapper untuk semua halaman yang butuh navigasi bawah.
class MainScreen extends ConsumerWidget {
  final Widget child;

  const MainScreen({super.key, required this.child});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authProvider);
    final user = authState.user;

    // Tentukan menu berdasarkan role
    final navItems = _buildNavItems(user?.role);
    final currentIndex = _getCurrentIndex(context);

    return Scaffold(
      body: child,
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.08),
              blurRadius: 20,
              offset: const Offset(0, -5),
            ),
          ],
        ),
        child: BottomNavigationBar(
          currentIndex: currentIndex,
          onTap: (index) => _onNavTap(context, index, user?.role),
          items: navItems,
        ),
      ),
    );
  }

  List<BottomNavigationBarItem> _buildNavItems(String? role) {
    final isWali = role?.toLowerCase().contains('wali') ?? false;

    return [
      const BottomNavigationBarItem(
        icon: Icon(Icons.dashboard_outlined),
        activeIcon: Icon(Icons.dashboard),
        label: 'Dashboard',
      ),
      const BottomNavigationBarItem(
        icon: Icon(Icons.account_balance_wallet_outlined),
        activeIcon: Icon(Icons.account_balance_wallet),
        label: 'Keuangan',
      ),
      if (!isWali)
        const BottomNavigationBarItem(
          icon: Icon(Icons.people_outline),
          activeIcon: Icon(Icons.people),
          label: 'Santri',
        ),
      if (!isWali)
        const BottomNavigationBarItem(
          icon: Icon(Icons.shield_outlined),
          activeIcon: Icon(Icons.shield),
          label: 'Kamtib',
        ),
      const BottomNavigationBarItem(
        icon: Icon(Icons.person_outline),
        activeIcon: Icon(Icons.person),
        label: 'Profil',
      ),
    ];
  }

  int _getCurrentIndex(BuildContext context) {
    final location = GoRouterState.of(context).matchedLocation;
    if (location.startsWith(AppRoutes.keuangan)) return 1;
    if (location.startsWith(AppRoutes.santri)) return 2;
    if (location.startsWith(AppRoutes.kamtib)) return 3;
    if (location.startsWith(AppRoutes.profil)) return 4;
    return 0;
  }

  void _onNavTap(BuildContext context, int index, String? role) {
    final isWali = role?.toLowerCase().contains('wali') ?? false;
    switch (index) {
      case 0:
        context.go(AppRoutes.dashboard);
      case 1:
        context.go(AppRoutes.keuangan);
      case 2:
        if (!isWali) context.go(AppRoutes.santri);
      case 3:
        if (!isWali) context.go(AppRoutes.kamtib);
        else context.go(AppRoutes.profil);
      default:
        context.go(AppRoutes.profil);
    }
  }
}
