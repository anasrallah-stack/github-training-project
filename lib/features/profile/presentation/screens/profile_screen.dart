import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/utils/date_helper.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../../tracking/presentation/providers/tracking_provider.dart';
import '../../../../routes/route_names.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final user = ref.watch(authStateProvider).value;
    final todayHours = ref.watch(todayHoursProvider);
    final weekHours = ref.watch(weekHoursProvider);

    if (user == null) return const SizedBox();

    return Scaffold(
      backgroundColor: isDark ? AppColors.bgDark : AppColors.bgLight,
      appBar: AppBar(
        title: const Text(AppStrings.myProfile),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit_outlined),
            onPressed: () => _showEditDialog(context, ref, user),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            // Avatar + name
            Center(
              child: Column(
                children: [
                  Stack(
                    children: [
                      Container(
                        width: 90, height: 90,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: const LinearGradient(
                            colors: AppColors.primaryGradient,
                            begin: Alignment.topLeft, end: Alignment.bottomRight,
                          ),
                          boxShadow: [BoxShadow(color: AppColors.primary.withOpacity(0.3), blurRadius: 20)],
                        ),
                        child: user.photoUrl != null
                          ? ClipOval(child: Image.network(user.photoUrl!, fit: BoxFit.cover))
                          : Center(child: Text(
                              user.fullName.isNotEmpty ? user.fullName[0].toUpperCase() : 'U',
                              style: const TextStyle(fontSize: 36, fontWeight: FontWeight.w700, color: Colors.white),
                            )),
                      ),
                      Positioned(
                        bottom: 0, right: 0,
                        child: Container(
                          width: 26, height: 26,
                          decoration: BoxDecoration(
                            color: AppColors.success,
                            shape: BoxShape.circle,
                            border: Border.all(color: isDark ? AppColors.bgDark : Colors.white, width: 2),
                          ),
                          child: const Icon(Icons.check, size: 14, color: Colors.white),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),
                  Text(user.fullName, style: const TextStyle(
                    fontFamily: 'Cairo', fontSize: 22, fontWeight: FontWeight.w800,
                  )),
                  const SizedBox(height: 4),
                  Text(user.email, style: TextStyle(
                    fontFamily: 'Cairo', fontSize: 14,
                    color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                  )),
                ],
              ),
            ),
            const SizedBox(height: 28),

            // Stats
            Row(children: [
              Expanded(child: _StatBox(label: 'اليوم', value: DateHelper.formatHours(todayHours), isDark: isDark)),
              const SizedBox(width: 12),
              Expanded(child: _StatBox(label: 'هذا الأسبوع', value: DateHelper.formatHours(weekHours), isDark: isDark)),
              const SizedBox(width: 12),
              Expanded(child: _StatBox(
                label: 'الإنتاجية',
                value: '${((weekHours / 40) * 100).clamp(0, 100).round()}%',
                isDark: isDark,
              )),
            ]),
            const SizedBox(height: 20),

            // Info card
            _InfoCard(isDark: isDark, children: [
              _InfoRow(icon: Icons.email_outlined, label: 'البريد الإلكتروني', value: user.email, isDark: isDark),
              _InfoRow(icon: Icons.wifi_rounded, label: 'شبكة العمل', value: user.workWifiSsid ?? 'لم يتم التحديد', isDark: isDark),
              _InfoRow(icon: Icons.devices_rounded, label: 'الأجهزة المرتبطة', value: '${user.deviceIds.length} جهاز', isDark: isDark),
            ]),
            const SizedBox(height: 16),

            // Actions
            _InfoCard(isDark: isDark, children: [
              _ActionRow(
                icon: Icons.sync_rounded,
                label: AppStrings.deviceSync,
                color: AppColors.primary,
                onTap: () => context.push(RouteNames.devices),
                isDark: isDark,
              ),
              _ActionRow(
                icon: Icons.settings_outlined,
                label: AppStrings.settings,
                color: AppColors.accent,
                onTap: () => context.push(RouteNames.settings),
                isDark: isDark,
              ),
              _ActionRow(
                icon: Icons.logout_rounded,
                label: AppStrings.logout,
                color: AppColors.error,
                onTap: () => _confirmLogout(context, ref),
                isDark: isDark,
              ),
            ]),
          ],
        ),
      ),
    );
  }

  void _showEditDialog(BuildContext context, WidgetRef ref, user) {
    final nameCtrl = TextEditingController(text: user.fullName);
    final ssidCtrl = TextEditingController(text: user.workWifiSsid ?? '');
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (ctx) => Padding(
        padding: EdgeInsets.fromLTRB(20, 20, 20, MediaQuery.of(ctx).viewInsets.bottom + 20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text('تعديل الملف الشخصي', style: TextStyle(fontFamily: 'Cairo', fontSize: 18, fontWeight: FontWeight.w700)),
            const SizedBox(height: 20),
            TextField(
              controller: nameCtrl,
              decoration: const InputDecoration(labelText: AppStrings.fullName, prefixIcon: Icon(Icons.person_outline)),
            ),
            const SizedBox(height: 14),
            TextField(
              controller: ssidCtrl,
              decoration: const InputDecoration(labelText: 'اسم شبكة Wi-Fi العمل', prefixIcon: Icon(Icons.wifi_rounded)),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () async {
                await ref.read(currentUserProvider.notifier).updateProfile(
                  fullName: nameCtrl.text.trim(),
                  workWifiSsid: ssidCtrl.text.trim(),
                );
                if (ctx.mounted) Navigator.pop(ctx);
              },
              child: const Text('حفظ التغييرات'),
            ),
          ],
        ),
      ),
    );
  }

  void _confirmLogout(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('تسجيل الخروج', style: TextStyle(fontFamily: 'Cairo', fontWeight: FontWeight.w700)),
        content: const Text('هل أنت متأكد من تسجيل الخروج؟', style: TextStyle(fontFamily: 'Cairo')),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('إلغاء', style: TextStyle(fontFamily: 'Cairo'))),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(ctx);
              await ref.read(currentUserProvider.notifier).logout();
            },
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.error),
            child: const Text(AppStrings.logout, style: TextStyle(fontFamily: 'Cairo')),
          ),
        ],
      ),
    );
  }
}

class _StatBox extends StatelessWidget {
  final String label, value;
  final bool isDark;
  const _StatBox({required this.label, required this.value, required this.isDark});

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
    decoration: BoxDecoration(
      color: isDark ? AppColors.cardDark : Colors.white,
      borderRadius: BorderRadius.circular(14),
      border: Border.all(color: isDark ? AppColors.borderDark : AppColors.borderLight),
    ),
    child: Column(
      children: [
        Text(value, style: const TextStyle(fontFamily: 'Cairo', fontSize: 20, fontWeight: FontWeight.w800)),
        const SizedBox(height: 4),
        Text(label, style: TextStyle(
          fontFamily: 'Cairo', fontSize: 11,
          color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
        )),
      ],
    ),
  );
}

class _InfoCard extends StatelessWidget {
  final bool isDark;
  final List<Widget> children;
  const _InfoCard({required this.isDark, required this.children});

  @override
  Widget build(BuildContext context) => Container(
    decoration: BoxDecoration(
      color: isDark ? AppColors.cardDark : Colors.white,
      borderRadius: BorderRadius.circular(16),
      border: Border.all(color: isDark ? AppColors.borderDark : AppColors.borderLight),
    ),
    child: Column(children: children),
  );
}

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String label, value;
  final bool isDark;
  const _InfoRow({required this.icon, required this.label, required this.value, required this.isDark});

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
    child: Row(children: [
      Icon(icon, size: 20, color: AppColors.primary),
      const SizedBox(width: 14),
      Expanded(child: Text(label, style: const TextStyle(fontFamily: 'Cairo', fontSize: 14))),
      Text(value, style: TextStyle(
        fontFamily: 'Cairo', fontSize: 13, fontWeight: FontWeight.w600,
        color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
      )),
    ]),
  );
}

class _ActionRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;
  final bool isDark;
  const _ActionRow({required this.icon, required this.label, required this.color, required this.onTap, required this.isDark});

  @override
  Widget build(BuildContext context) => InkWell(
    onTap: onTap,
    borderRadius: BorderRadius.circular(16),
    child: Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      child: Row(children: [
        Container(
          width: 36, height: 36,
          decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(10)),
          child: Icon(icon, size: 18, color: color),
        ),
        const SizedBox(width: 14),
        Expanded(child: Text(label, style: TextStyle(fontFamily: 'Cairo', fontSize: 14, color: color, fontWeight: FontWeight.w600))),
        Icon(Icons.arrow_forward_ios_rounded, size: 14, color: color.withOpacity(0.6)),
      ]),
    ),
  );
}
