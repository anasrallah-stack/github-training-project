import 'package:flutter/material.dart';
import 'package:untitled16/core/constants/app_colors.dart';
import 'package:untitled16/core/utils/date_helper.dart';


class SessionTile extends StatelessWidget {
  final dynamic session;
  final bool isDark;
  const SessionTile({required this.session, required this.isDark});

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