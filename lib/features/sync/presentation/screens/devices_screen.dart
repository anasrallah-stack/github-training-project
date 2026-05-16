import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../auth/presentation/providers/auth_provider.dart';

class DevicesScreen extends ConsumerStatefulWidget {
  const DevicesScreen({super.key});
  @override
  ConsumerState<DevicesScreen> createState() => _DevicesScreenState();
}

class _DevicesScreenState extends ConsumerState<DevicesScreen> {
  List<Map<String, dynamic>> _devices = [];
  String? _thisDeviceId;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadDevices();
  }

  Future<void> _loadDevices() async {
    final prefs = await SharedPreferences.getInstance();
    _thisDeviceId = prefs.getString('device_id');
    final user = ref.read(authStateProvider).value;
    if (user == null) return;

    final snap = await FirebaseFirestore.instance
        .collection('devices')
        .where('userId', isEqualTo: user.uid)
        .get();

    setState(() {
      _devices = snap.docs.map((d) => {...d.data(), 'id': d.id}).toList();
      _loading = false;
    });
  }

  Future<void> _removeDevice(String deviceId) async {
    await FirebaseFirestore.instance.collection('devices').doc(deviceId).delete();
    setState(() => _devices.removeWhere((d) => d['id'] == deviceId));
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Scaffold(
      backgroundColor: isDark ? AppColors.bgDark : AppColors.bgLight,
      appBar: AppBar(title: const Text(AppStrings.deviceSync)),
      body: _loading
        ? const Center(child: CircularProgressIndicator())
        : RefreshIndicator(
            onRefresh: _loadDevices,
            child: _devices.isEmpty
              ? Center(
                  child: Column(mainAxisSize: MainAxisSize.min, children: [
                    Icon(Icons.devices_outlined, size: 64,
                      color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight),
                    const SizedBox(height: 16),
                    const Text('لا توجد أجهزة مسجلة', style: TextStyle(fontFamily: 'Cairo', fontSize: 16)),
                  ]),
                )
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: _devices.length,
                  itemBuilder: (ctx, i) {
                    final device = _devices[i];
                    final isThis = device['id'] == _thisDeviceId;
                    final lastSeen = (device['lastSeen'] as Timestamp?)?.toDate();
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 10),
                      child: Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: isDark ? AppColors.cardDark : Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: isThis ? AppColors.primary.withOpacity(0.4)
                                : (isDark ? AppColors.borderDark : AppColors.borderLight),
                          ),
                        ),
                        child: Row(
                          children: [
                            Container(
                              width: 48, height: 48,
                              decoration: BoxDecoration(
                                color: (isThis ? AppColors.primary : AppColors.accent).withOpacity(0.1),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Icon(
                                device['type'] == 'tablet' ? Icons.tablet_rounded : Icons.smartphone_rounded,
                                color: isThis ? AppColors.primary : AppColors.accent,
                                size: 24,
                              ),
                            ),
                            const SizedBox(width: 14),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(children: [
                                    Expanded(child: Text(
                                      device['name'] ?? 'جهاز غير معروف',
                                      style: const TextStyle(fontFamily: 'Cairo', fontSize: 15, fontWeight: FontWeight.w700),
                                    )),
                                    if (isThis)
                                      Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                        decoration: BoxDecoration(
                                          color: AppColors.primary.withOpacity(0.1),
                                          borderRadius: BorderRadius.circular(6),
                                        ),
                                        child: const Text(AppStrings.thisDevice, style: TextStyle(
                                          fontFamily: 'Cairo', fontSize: 11, color: AppColors.primary, fontWeight: FontWeight.w600,
                                        )),
                                      ),
                                  ]),
                                  const SizedBox(height: 4),
                                  Text(
                                    lastSeen != null
                                      ? '${AppStrings.lastSeen}: ${_formatLastSeen(lastSeen)}'
                                      : 'غير محدد',
                                    style: TextStyle(
                                      fontFamily: 'Cairo', fontSize: 12,
                                      color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            if (!isThis)
                              IconButton(
                                icon: const Icon(Icons.delete_outline_rounded, color: AppColors.error),
                                onPressed: () => _removeDevice(device['id']),
                              ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
          ),
    );
  }

  String _formatLastSeen(DateTime time) {
    final diff = DateTime.now().difference(time);
    if (diff.inMinutes < 1) return 'الآن';
    if (diff.inMinutes < 60) return 'منذ ${diff.inMinutes} دقيقة';
    if (diff.inHours < 24) return 'منذ ${diff.inHours} ساعة';
    return 'منذ ${diff.inDays} يوم';
  }
}
