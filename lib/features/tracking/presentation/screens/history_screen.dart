import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/utils/date_helper.dart';
import '../../../tracking/presentation/providers/tracking_provider.dart';

class HistoryScreen extends ConsumerWidget {
  const HistoryScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final sessionsAsync = ref.watch(historySessionsProvider);

    return Scaffold(
      backgroundColor: isDark ? AppColors.bgDark : AppColors.bgLight,
      appBar: AppBar(title: const Text(AppStrings.sessionHistory)),
      body: sessionsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('خطأ: $e')),
        data: (sessions) {
          if (sessions.isEmpty) {
            return Center(
              child: Column(mainAxisSize: MainAxisSize.min, children: [
                Icon(Icons.history, size: 64, color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight),
                const SizedBox(height: 16),
                const Text(AppStrings.noSessions, style: TextStyle(fontFamily: 'Cairo', fontSize: 16)),
              ]),
            );
          }

          // Group by date
          final grouped = <String, List<dynamic>>{};
          for (final s in sessions) {
            final key = DateHelper.formatDate(s.startTime);
            grouped.putIfAbsent(key, () => []).add(s);
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: grouped.length,
            itemBuilder: (ctx, i) {
              final date = grouped.keys.elementAt(i);
              final daySessions = grouped[date]!;
              final totalHours = daySessions.fold(0.0, (sum, s) => sum + (s as dynamic).hours);

              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(bottom: 8, top: 8),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(date, style: const TextStyle(fontFamily: 'Cairo', fontSize: 13, fontWeight: FontWeight.w700)),
                        Text(DateHelper.formatHours(totalHours), style: const TextStyle(
                          fontFamily: 'Cairo', fontSize: 13, color: AppColors.primary, fontWeight: FontWeight.w700,
                        )),
                      ],
                    ),
                  ),
                  ...daySessions.map((s) => Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: isDark ? AppColors.cardDark : Colors.white,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: isDark ? AppColors.borderDark : AppColors.borderLight),
                      ),
                      child: Row(
                        children: [
                          Container(
                            width: 40, height: 40,
                            decoration: BoxDecoration(
                              color: AppColors.primary.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: const Icon(Icons.work_outlined, color: AppColors.primary, size: 20),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  '${DateHelper.formatTime(s.startTime)}  ←  ${s.endTime != null ? DateHelper.formatTime(s.endTime!) : 'جارٍ'}',
                                  style: const TextStyle(fontFamily: 'Cairo', fontSize: 13, fontWeight: FontWeight.w600),
                                ),
                                Text(s.wifiSsid, style: TextStyle(
                                  fontFamily: 'Cairo', fontSize: 11,
                                  color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                                )),
                              ],
                            ),
                          ),
                          Text(DateHelper.formatDuration(s.duration),
                            style: const TextStyle(fontFamily: 'Cairo', fontSize: 14, fontWeight: FontWeight.w700)),
                        ],
                      ),
                    ),
                  )),
                  const SizedBox(height: 8),
                ],
              );
            },
          );
        },
      ),
    );
  }
}
