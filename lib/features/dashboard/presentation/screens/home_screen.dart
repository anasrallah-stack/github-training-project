import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_background_service/flutter_background_service.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/services/background_service.dart';
import '../../../../core/services/wifi_tracking_service.dart';
import '../../../../core/utils/date_helper.dart';
import '../../../auth/domain/entities/user_entity.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../../tracking/presentation/providers/tracking_provider.dart';
import '../../../../routes/route_names.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});
  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen>
    with WidgetsBindingObserver {  // ✅ لمراقبة حالة التطبيق

  late Timer _clockTimer;
  DateTime _now = DateTime.now();


  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this); // ← أضف
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

  // ✅ يُستدعى عند تغيّر حالة التطبيق
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    switch (state) {
      case AppLifecycleState.resumed:
      // التطبيق رجع للواجهة — ابدأ الـ Service
        FlutterBackgroundService().startService();
        break;
      case AppLifecycleState.paused:
      // التطبيق انتقل للخلفية — لا تفعل شيء، Service تضل شغالة
        break;
      case AppLifecycleState.detached:
      // ✅ التطبيق أُغلق نهائياً — أوقف الـ Service
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

    // ابدأ الـ foreground tracking
    final service = ref.read(wifiTrackingServiceProvider);
    await service.initialize(user.uid, user.workWifiSsid, deviceId);

    // ابدأ الـ background service
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
                child: _TrackingStatusCard(hasActive: hasActive, user: user, isDark: isDark),
              ),
            ),

            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 14, 20, 0),
                child: Row(
                  children: [
                    Expanded(child: _StatCard(
                      label: AppStrings.todayHours,
                      value: DateHelper.formatHours(todayHours),
                      icon: Icons.today_rounded,
                      color: AppColors.accent,
                      isDark: isDark,
                    )),
                    const SizedBox(width: 12),
                    Expanded(child: _StatCard(
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
                child: _EmptySessionsCard(isDark: isDark),
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
                      child: _SessionTile(session: s, isDark: isDark),
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

// ── Widgets ──────────────────────────────────────────────

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

class _TrackingStatusCard extends StatelessWidget {
  final bool hasActive;
  final UserEntity? user;
  final bool isDark;
  const _TrackingStatusCard({required this.hasActive, required this.user, required this.isDark});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? AppColors.cardDark : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: hasActive ? AppColors.success.withOpacity(0.4)
              : (isDark ? AppColors.borderDark : AppColors.borderLight),
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 44, height: 44,
            decoration: BoxDecoration(
              color: (hasActive ? AppColors.success : AppColors.warning).withOpacity(0.12),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              hasActive ? Icons.wifi_rounded : Icons.wifi_off_rounded,
              color: hasActive ? AppColors.success : AppColors.warning, size: 22,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  hasActive ? AppStrings.tracking : AppStrings.notTracking,
                  style: TextStyle(
                    fontFamily: 'Cairo', fontSize: 15, fontWeight: FontWeight.w700,
                    color: hasActive ? AppColors.success
                        : (isDark ? AppColors.textDark : AppColors.textLight),
                  ),
                ),
                Text(
                  hasActive ? '${AppStrings.connectedTo} ${user?.workWifiSsid ?? 'Wi-Fi'}'
                      : 'في انتظار الاتصال بشبكة العمل',
                  style: TextStyle(
                    fontFamily: 'Cairo', fontSize: 12,
                    color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                  ),
                ),
              ],
            ),
          ),
          if (user != null)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(user!.fullName.split(' ').first, style: const TextStyle(
                fontFamily: 'Cairo', fontSize: 12,
                color: AppColors.primary, fontWeight: FontWeight.w600,
              )),
            ),
        ],
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final String label, value;
  final IconData icon;
  final Color color;
  final bool isDark;
  const _StatCard({required this.label, required this.value, required this.icon,
    required this.color, required this.isDark});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? AppColors.cardDark : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: isDark ? AppColors.borderDark : AppColors.borderLight),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 36, height: 36,
            decoration: BoxDecoration(
              color: color.withOpacity(0.12), borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: color, size: 18),
          ),
          const SizedBox(height: 12),
          Text(value, style: const TextStyle(
            fontFamily: 'Cairo', fontSize: 26, fontWeight: FontWeight.w800,
          )),
          Text(label, style: TextStyle(
            fontFamily: 'Cairo', fontSize: 12,
            color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
          )),
        ],
      ),
    );
  }
}

class _SessionTile extends StatelessWidget {
  final dynamic session;
  final bool isDark;
  const _SessionTile({required this.session, required this.isDark});

  @override
  Widget build(BuildContext context) {
    final start = DateHelper.formatTime(session.startTime);
    final end = session.endTime != null ? DateHelper.formatTime(session.endTime!) : 'جارٍ...';
    final dur = DateHelper.formatDuration(session.duration);
    final active = session.isActive;

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: isDark ? AppColors.cardDark : Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: active ? AppColors.success.withOpacity(0.3)
              : (isDark ? AppColors.borderDark : AppColors.borderLight),
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 40, height: 40,
            decoration: BoxDecoration(
              color: (active ? AppColors.success : AppColors.primary).withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(
              active ? Icons.play_arrow_rounded : Icons.check_circle_outline_rounded,
              color: active ? AppColors.success : AppColors.primary, size: 20,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('$start  ←  $end', style: const TextStyle(
                  fontFamily: 'Cairo', fontSize: 13, fontWeight: FontWeight.w600,
                )),
                Text(session.wifiSsid, style: TextStyle(
                  fontFamily: 'Cairo', fontSize: 11,
                  color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                )),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(dur, style: const TextStyle(
                fontFamily: 'Cairo', fontSize: 14, fontWeight: FontWeight.w700,
              )),
              if (active)
                Container(
                  margin: const EdgeInsets.only(top: 2),
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: AppColors.success.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: const Text('مباشر', style: TextStyle(
                    fontFamily: 'Cairo', fontSize: 10, color: AppColors.success,
                  )),
                ),
            ],
          ),
        ],
      ),
    );
  }
}

class _EmptySessionsCard extends StatelessWidget {
  final bool isDark;
  const _EmptySessionsCard({required this.isDark});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: isDark ? AppColors.cardDark : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: isDark ? AppColors.borderDark : AppColors.borderLight),
      ),
      child: Column(children: [
        Icon(Icons.work_history_outlined, size: 44,
            color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight),
        const SizedBox(height: 12),
        const Text(AppStrings.noSessions, style: TextStyle(
          fontFamily: 'Cairo', fontSize: 15, fontWeight: FontWeight.w600,
        )),
        const SizedBox(height: 6),
        Text('اتصل بشبكة Wi-Fi الخاصة بالعمل لبدء التتبع', style: TextStyle(
          fontFamily: 'Cairo', fontSize: 12,
          color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
        ), textAlign: TextAlign.center),
      ]),
    );
  }
}