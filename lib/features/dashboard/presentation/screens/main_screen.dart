import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../app/routes/app_router.dart';
/// Shell utama yang berisi Bottom Navigation Bar.
/// Digunakan sebagai wrapper untuk semua halaman yang butuh navigasi bawah.
class MainScreen extends ConsumerWidget {
  final Widget child;

  const MainScreen({super.key, required this.child});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final navItems = _buildNavItems();
    final currentIndex = _getCurrentIndex(context);

    return Scaffold(
      body: child,
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.08),
              blurRadius: 20,
              offset: const Offset(0, -5),
            ),
          ],
        ),
        child: BottomNavigationBar(
          currentIndex: currentIndex,
          onTap: (index) => _onNavTap(context, index),
          items: navItems,
        ),
      ),
    );
  }

  List<BottomNavigationBarItem> _buildNavItems() {
    return const [
      BottomNavigationBarItem(
        icon: Icon(Icons.dashboard_outlined),
        activeIcon: Icon(Icons.dashboard),
        label: 'Dashboard',
      ),
      BottomNavigationBarItem(
        icon: Icon(Icons.people_outline),
        activeIcon: Icon(Icons.people),
        label: 'Santri',
      ),
      BottomNavigationBarItem(
        icon: Icon(Icons.shield_outlined),
        activeIcon: Icon(Icons.shield),
        label: 'Kamtib',
      ),
      BottomNavigationBarItem(
        icon: Icon(Icons.account_balance_wallet_outlined),
        activeIcon: Icon(Icons.account_balance_wallet),
        label: 'Keuangan',
      ),
      BottomNavigationBarItem(
        icon: Icon(Icons.campaign_outlined),
        activeIcon: Icon(Icons.campaign),
        label: 'Informasi',
      ),
      BottomNavigationBarItem(
        icon: Icon(Icons.person_outline),
        activeIcon: Icon(Icons.person),
        label: 'Profil',
      ),
    ];
  }

  int _getCurrentIndex(BuildContext context) {
    final location = GoRouterState.of(context).matchedLocation;
    if (location.startsWith(AppRoutes.santri)) return 1;
    if (location.startsWith(AppRoutes.kamtib)) return 2;
    if (location.startsWith(AppRoutes.keuangan)) return 3;
    if (location.startsWith(AppRoutes.informasi)) return 4;
    if (location.startsWith(AppRoutes.profil)) return 5;
    return 0;
  }

  void _onNavTap(BuildContext context, int index) {
    switch (index) {
      case 0:
        context.go(AppRoutes.dashboard);
      case 1:
        context.go(AppRoutes.santri);
      case 2:
        context.go(AppRoutes.kamtib);
      case 3:
        context.go(AppRoutes.keuangan);
      case 4:
        context.go(AppRoutes.informasi);
      case 5:
        context.go(AppRoutes.profil);
      default:
        context.go(AppRoutes.dashboard);
    }
  }
}
