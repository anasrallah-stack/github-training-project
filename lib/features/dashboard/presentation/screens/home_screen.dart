import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_background_service/flutter_background_service.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:untitled16/features/dashboard/presentation/widgets/empty_session_card.dart';
import 'package:untitled16/features/dashboard/presentation/widgets/session_tile.dart';
import 'package:untitled16/features/dashboard/presentation/widgets/stat_card.dart';
import 'package:untitled16/features/dashboard/presentation/widgets/tracking_status_card.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/services/background_service.dart';
import '../../../../core/services/wifi_tracking_service.dart';
import '../../../../core/utils/date_helper.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../../tracking/presentation/providers/tracking_provider.dart';
import '../../../../routes/route_names.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});
  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen>
    with WidgetsBindingObserver {

  late Timer _clockTimer;
  DateTime _now = DateTime.now();


  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _clockTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (mounted) setState(() => _now = DateTime.now());
    });
    WidgetsBinding.instance.addPostFrameCallback((_) => _initTracking());
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _clockTimer.cancel();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    switch (state) {
      case AppLifecycleState.resumed:
        FlutterBackgroundService().startService();
        break;
      case AppLifecycleState.paused:
        break;
      case AppLifecycleState.detached:
        stopBackgroundService();
        break;
      default:
        break;
    }
  }

  Future<void> _initTracking() async {
    final user = ref.read(authStateProvider).value;
    if (user == null) return;

    final prefs = await SharedPreferences.getInstance();
    final deviceId = prefs.getString('device_id') ?? 'device_${user.uid}';
    await prefs.setString('device_id', deviceId);
    await prefs.setString('userId', user.uid);
    if (user.workWifiSsid != null) {
      await prefs.setString('work_ssid', user.workWifiSsid!);
    }

    final service = ref.read(wifiTrackingServiceProvider);
    await service.initialize(user.uid, user.workWifiSsid, deviceId);

    await startBackgroundService();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final user = ref.watch(authStateProvider).value;
    final todayHours = ref.watch(todayHoursProvider);
    final weekHours = ref.watch(weekHoursProvider);
    final sessions = ref.watch(todaySessionsProvider).value ?? [];
    final hasActive = sessions.any((s) => s.isActive);

    return Scaffold(
      backgroundColor: isDark ? AppColors.bgDark : AppColors.bgLight,
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(AppStrings.welcomeBack, style: TextStyle(
                            fontFamily: 'Cairo', fontSize: 13,
                            color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                          )),
                          Text(user?.fullName ?? '...', style: const TextStyle(
                            fontFamily: 'Cairo', fontSize: 22, fontWeight: FontWeight.w800,
                          )),
                        ],
                      ),
                    ),
                    GestureDetector(
                      onTap: () => context.push(RouteNames.settings),
                      child: Container(
                        width: 44, height: 44,
                        decoration: BoxDecoration(
                          color: isDark ? AppColors.cardDark : Colors.white,
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(color: isDark ? AppColors.borderDark : AppColors.borderLight),
                        ),
                        child: const Icon(Icons.settings_outlined, size: 20),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
                child: _HeroClockCard(now: _now, hasActive: hasActive, isDark: isDark),
              ),
            ),

            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 14, 20, 0),
                child: TrackingStatusCard(hasActive: hasActive, user: user, isDark: isDark),
              ),
            ),

            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 14, 20, 0),
                child: Row(
                  children: [
                    Expanded(child: StatCard(
                      label: AppStrings.todayHours,
                      value: DateHelper.formatHours(todayHours),
                      icon: Icons.today_rounded,
                      color: AppColors.accent,
                      isDark: isDark,
                    )),
                    const SizedBox(width: 12),
                    Expanded(child: StatCard(
                      label: AppStrings.weeklyHours,
                      value: DateHelper.formatHours(weekHours),
                      icon: Icons.date_range_rounded,
                      color: AppColors.secondary,
                      isDark: isDark,
                    )),
                  ],
                ),
              ),
            ),

            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 24, 20, 10),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('جلسات اليوم', style: TextStyle(
                      fontFamily: 'Cairo', fontSize: 16, fontWeight: FontWeight.w700,
                    )),
                    TextButton(
                      onPressed: () => context.push(RouteNames.history),
                      child: const Text('عرض الكل', style: TextStyle(fontFamily: 'Cairo', fontSize: 13)),
                    ),
                  ],
                ),
              ),
            ),

            sessions.isEmpty
                ? SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: EmptySessionsCard(isDark: isDark),
              ),
            )
                : SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              sliver: SliverList(
                delegate: SliverChildBuilderDelegate(
                      (ctx, i) {
                    final s = sessions[sessions.length - 1 - i];
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: SessionTile(session: s, isDark: isDark),
                    );
                  },
                  childCount: sessions.length.clamp(0, 5),
                ),
              ),
            ),

            const SliverToBoxAdapter(child: SizedBox(height: 100)),
          ],
        ),
      ),
    );
  }
}


class _HeroClockCard extends StatelessWidget {
  final DateTime now;
  final bool hasActive;
  final bool isDark;
  const _HeroClockCard({required this.now, required this.hasActive, required this.isDark});

  @override
  Widget build(BuildContext context) {
    final timeStr =
        '${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}:${now.second.toString().padLeft(2, '0')}';
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF1A2540), Color(0xFF0F1A35)],
          begin: Alignment.topLeft, end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withOpacity(0.07)),
        boxShadow: [BoxShadow(
          color: AppColors.primary.withOpacity(0.15),
          blurRadius: 30, offset: const Offset(0, 8),
        )],
      ),
      child: Column(
        children: [
          Text(timeStr, style: const TextStyle(
            fontFamily: 'Cairo', fontSize: 52, fontWeight: FontWeight.w300,
            color: Colors.white, letterSpacing: 2,
          )),
          const SizedBox(height: 4),
          Text(DateHelper.formatDate(now), style: TextStyle(
            fontFamily: 'Cairo', fontSize: 13,
            color: Colors.white.withOpacity(0.55),
          )),
          if (hasActive) ...[
            const SizedBox(height: 14),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
              decoration: BoxDecoration(
                color: AppColors.success.withOpacity(0.15),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: AppColors.success.withOpacity(0.3)),
              ),
              child: Row(mainAxisSize: MainAxisSize.min, children: [
                Container(width: 8, height: 8,
                    decoration: const BoxDecoration(color: AppColors.success, shape: BoxShape.circle)),
                const SizedBox(width: 8),
                const Text('جارٍ تتبع الوقت', style: TextStyle(
                  fontFamily: 'Cairo', fontSize: 12,
                  color: AppColors.success, fontWeight: FontWeight.w600,
                )),
              ]),
            ),
          ],
        ],
      ),
    );
  }
}

