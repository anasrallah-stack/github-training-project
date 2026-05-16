import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:network_info_plus/network_info_plus.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/theme/theme_provider.dart';
import '../../../auth/presentation/providers/auth_provider.dart';

class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({super.key});
  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen> {
  bool _notificationsEnabled = true;
  String? _currentSsid;

  @override
  void initState() {
    super.initState();
    _loadCurrentSsid();
  }

  Future<void> _loadCurrentSsid() async {
    try {
      final info = NetworkInfo();
      final ssid = await info.getWifiName();
      if (mounted) setState(() => _currentSsid = ssid?.replaceAll('"', ''));
    } catch (_) {}
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final themeMode = ref.watch(themeModeProvider);
    final user = ref.watch(authStateProvider).value;

    return Scaffold(
      backgroundColor: isDark ? AppColors.bgDark : AppColors.bgLight,
      appBar: AppBar(title: const Text(AppStrings.settings)),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Wi-Fi Section
          _SectionHeader(title: AppStrings.wifiSettings, isDark: isDark),
          _SettingsCard(isDark: isDark, children: [
            _InfoTile(
              icon: Icons.wifi_rounded,
              label: 'الشبكة الحالية',
              value: _currentSsid ?? 'غير متصل',
              iconColor: _currentSsid != null ? AppColors.success : AppColors.warning,
              isDark: isDark,
            ),
            const Divider(height: 1, indent: 56),
            _TapTile(
              icon: Icons.add_circle_outline_rounded,
              label: AppStrings.chooseWifi,
              value: user?.workWifiSsid ?? 'لم يتم التحديد',
              iconColor: AppColors.primary,
              isDark: isDark,
              onTap: () => _showWifiPicker(context, user?.workWifiSsid),
            ),
          ]),
          const SizedBox(height: 20),

          // Appearance
          _SectionHeader(title: 'المظهر', isDark: isDark),
          _SettingsCard(isDark: isDark, children: [
            _SwitchTile(
              icon: Icons.dark_mode_outlined,
              label: AppStrings.darkMode,
              value: themeMode == ThemeMode.dark,
              iconColor: AppColors.secondary,
              isDark: isDark,
              onChanged: (_) => ref.read(themeModeProvider.notifier).toggle(),
            ),
          ]),
          const SizedBox(height: 20),

          // Notifications
          _SectionHeader(title: AppStrings.notifications, isDark: isDark),
          _SettingsCard(isDark: isDark, children: [
            _SwitchTile(
              icon: Icons.notifications_outlined,
              label: 'إشعارات الجلسات',
              value: _notificationsEnabled,
              iconColor: AppColors.warning,
              isDark: isDark,
              onChanged: (v) => setState(() => _notificationsEnabled = v),
            ),
            const Divider(height: 1, indent: 56),
            _SwitchTile(
              icon: Icons.alarm_outlined,
              label: 'تذكير يومي',
              value: false,
              iconColor: AppColors.accent,
              isDark: isDark,
              onChanged: (_) {},
            ),
          ]),
          const SizedBox(height: 20),

          // Account
          _SectionHeader(title: 'الحساب', isDark: isDark),
          _SettingsCard(isDark: isDark, children: [
            _InfoTile(
              icon: Icons.person_outline_rounded,
              label: 'الاسم',
              value: user?.fullName ?? '',
              iconColor: AppColors.primary,
              isDark: isDark,
            ),
            const Divider(height: 1, indent: 56),
            _InfoTile(
              icon: Icons.email_outlined,
              label: 'البريد الإلكتروني',
              value: user?.email ?? '',
              iconColor: AppColors.accent,
              isDark: isDark,
            ),
          ]),
          const SizedBox(height: 20),

          // Version
          Center(
            child: Text('TimeSync v1.0.0', style: TextStyle(
              fontFamily: 'Cairo', fontSize: 12,
              color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
            )),
          ),
          const SizedBox(height: 80),
        ],
      ),
    );
  }

  void _showWifiPicker(BuildContext context, String? currentSsid) {
    final ctrl = TextEditingController(text: currentSsid);
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
            const Text('اختر شبكة Wi-Fi للعمل', style: TextStyle(fontFamily: 'Cairo', fontSize: 18, fontWeight: FontWeight.w700)),
            const SizedBox(height: 8),
            Text(
              _currentSsid != null ? 'الشبكة الحالية: $_currentSsid' : 'غير متصل بأي شبكة',
              style: TextStyle(fontFamily: 'Cairo', fontSize: 13, color: AppColors.textSecondaryDark),
            ),
            const SizedBox(height: 20),
            TextField(
              controller: ctrl,
              decoration: const InputDecoration(
                labelText: 'اسم الشبكة (SSID)',
                prefixIcon: Icon(Icons.wifi_rounded),
                hintText: 'أدخل اسم الشبكة يدوياً',
              ),
            ),
            const SizedBox(height: 12),
            if (_currentSsid != null)
              OutlinedButton.icon(
                icon: const Icon(Icons.wifi_rounded),
                label: Text('استخدام الشبكة الحالية: $_currentSsid', style: const TextStyle(fontFamily: 'Cairo')),
                onPressed: () => ctrl.text = _currentSsid!,
              ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () async {
                final ssid = ctrl.text.trim();
                if (ssid.isEmpty) return;
                await ref.read(currentUserProvider.notifier).updateProfile(workWifiSsid: ssid);
                if (ctx.mounted) Navigator.pop(ctx);
              },
              child: const Text('حفظ'),
            ),
          ],
        ),
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;
  final bool isDark;
  const _SectionHeader({required this.title, required this.isDark});

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(bottom: 8, right: 4),
    child: Text(title, style: TextStyle(
      fontFamily: 'Cairo', fontSize: 13, fontWeight: FontWeight.w700,
      color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
    )),
  );
}

class _SettingsCard extends StatelessWidget {
  final bool isDark;
  final List<Widget> children;
  const _SettingsCard({required this.isDark, required this.children});

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

class _SwitchTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool value;
  final Color iconColor;
  final bool isDark;
  final ValueChanged<bool> onChanged;
  const _SwitchTile({required this.icon, required this.label, required this.value, required this.iconColor, required this.isDark, required this.onChanged});

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
    child: Row(children: [
      Container(
        width: 36, height: 36,
        decoration: BoxDecoration(color: iconColor.withOpacity(0.1), borderRadius: BorderRadius.circular(10)),
        child: Icon(icon, size: 18, color: iconColor),
      ),
      const SizedBox(width: 14),
      Expanded(child: Text(label, style: const TextStyle(fontFamily: 'Cairo', fontSize: 14))),
      Switch.adaptive(value: value, onChanged: onChanged, activeColor: AppColors.primary),
    ]),
  );
}

class _InfoTile extends StatelessWidget {
  final IconData icon;
  final String label, value;
  final Color iconColor;
  final bool isDark;
  const _InfoTile({required this.icon, required this.label, required this.value, required this.iconColor, required this.isDark});

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
    child: Row(children: [
      Container(
        width: 36, height: 36,
        decoration: BoxDecoration(color: iconColor.withOpacity(0.1), borderRadius: BorderRadius.circular(10)),
        child: Icon(icon, size: 18, color: iconColor),
      ),
      const SizedBox(width: 14),
      Expanded(child: Text(label, style: const TextStyle(fontFamily: 'Cairo', fontSize: 14))),
      Text(value, style: TextStyle(
        fontFamily: 'Cairo', fontSize: 13, fontWeight: FontWeight.w600,
        color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
      )),
    ]),
  );
}

class _TapTile extends StatelessWidget {
  final IconData icon;
  final String label, value;
  final Color iconColor;
  final bool isDark;
  final VoidCallback onTap;
  const _TapTile({required this.icon, required this.label, required this.value, required this.iconColor, required this.isDark, required this.onTap});

  @override
  Widget build(BuildContext context) => InkWell(
    onTap: onTap,
    borderRadius: BorderRadius.circular(16),
    child: Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      child: Row(children: [
        Container(
          width: 36, height: 36,
          decoration: BoxDecoration(color: iconColor.withOpacity(0.1), borderRadius: BorderRadius.circular(10)),
          child: Icon(icon, size: 18, color: iconColor),
        ),
        const SizedBox(width: 14),
        Expanded(child: Text(label, style: const TextStyle(fontFamily: 'Cairo', fontSize: 14))),
        Text(value, style: TextStyle(
          fontFamily: 'Cairo', fontSize: 13, fontWeight: FontWeight.w600,
          color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
        )),
        const SizedBox(width: 6),
        Icon(Icons.arrow_forward_ios_rounded, size: 12,
          color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight),
      ]),
    ),
  );
}
