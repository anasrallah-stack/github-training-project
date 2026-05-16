import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../features/auth/presentation/providers/auth_provider.dart';
import '../features/auth/presentation/screens/splash_screen.dart';
import '../features/auth/presentation/screens/login_screen.dart';
import '../features/auth/presentation/screens/register_screen.dart';
import '../features/dashboard/presentation/screens/home_screen.dart';
import '../features/tracking/presentation/screens/history_screen.dart';
import '../features/reports/presentation/screens/weekly_report_screen.dart';
import '../features/profile/presentation/screens/profile_screen.dart';
import '../features/settings/presentation/screens/settings_screen.dart';
import '../features/sync/presentation/screens/devices_screen.dart';
import 'route_names.dart';

final appRouterProvider = Provider<GoRouter>((ref) {
  final authState = ref.watch(authStateProvider);

  return GoRouter(
    initialLocation: RouteNames.splash,
    redirect: (context, state) {
      final isLoading = authState.isLoading;
      if (isLoading) return RouteNames.splash;

      final isLoggedIn = authState.value != null;
      final onAuth = state.uri.path == RouteNames.login ||
          state.uri.path == RouteNames.register ||
          state.uri.path == RouteNames.splash;

      if (!isLoggedIn && !onAuth) return RouteNames.login;
      if (isLoggedIn && onAuth) return RouteNames.home;
      return null;
    },
    routes: [
      GoRoute(path: RouteNames.splash, builder: (_, __) => const SplashScreen()),
      GoRoute(path: RouteNames.login, builder: (_, __) => const LoginScreen()),
      GoRoute(path: RouteNames.register, builder: (_, __) => const RegisterScreen()),
      ShellRoute(
        builder: (context, state, child) => MainShell(child: child),
        routes: [
          GoRoute(path: RouteNames.home, builder: (_, __) => const HomeScreen()),
          GoRoute(path: RouteNames.history, builder: (_, __) => const HistoryScreen()),
          GoRoute(path: RouteNames.reports, builder: (_, __) => const WeeklyReportScreen()),
          GoRoute(path: RouteNames.profile, builder: (_, __) => const ProfileScreen()),
          GoRoute(path: RouteNames.settings, builder: (_, __) => const SettingsScreen()),
          GoRoute(path: RouteNames.devices, builder: (_, __) => const DevicesScreen()),
        ],
      ),
    ],
  );
});

class MainShell extends StatefulWidget {
  final Widget child;
  const MainShell({super.key, required this.child});

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  int _selectedIndex = 0;

  final _routes = [
    RouteNames.home,
    RouteNames.history,
    RouteNames.reports,
    RouteNames.profile,
  ];

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Scaffold(
      body: widget.child,
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF0F1420) : Colors.white,
          border: Border(
            top: BorderSide(
              color: isDark ? const Color(0xFF1E2A42) : const Color(0xFFE2E8F0),
            ),
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _NavItem(icon: Icons.home_rounded, label: 'الرئيسية', index: 0, selected: _selectedIndex == 0, onTap: () => _navigate(0)),
                _NavItem(icon: Icons.history_rounded, label: 'السجل', index: 1, selected: _selectedIndex == 1, onTap: () => _navigate(1)),
                _NavItem(icon: Icons.bar_chart_rounded, label: 'التقارير', index: 2, selected: _selectedIndex == 2, onTap: () => _navigate(2)),
                _NavItem(icon: Icons.person_rounded, label: 'ملفي', index: 3, selected: _selectedIndex == 3, onTap: () => _navigate(3)),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _navigate(int index) {
    setState(() => _selectedIndex = index);
    context.go(_routes[index]);
  }
}

class _NavItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final int index;
  final bool selected;
  final VoidCallback onTap;

  const _NavItem({required this.icon, required this.label, required this.index, required this.selected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final color = selected ? const Color(0xFF4F8EF7) : const Color(0xFF8892A4);
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
        decoration: BoxDecoration(
          color: selected ? const Color(0xFF4F8EF7).withOpacity(0.12) : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: color, size: 22),
            const SizedBox(height: 2),
            Text(label, style: TextStyle(color: color, fontSize: 11, fontFamily: 'Cairo', fontWeight: FontWeight.w600)),
          ],
        ),
      ),
    );
  }
}
