import 'package:flutter/material.dart';
import 'package:untitled16/core/constants/app_colors.dart';
import 'package:untitled16/core/constants/app_strings.dart';
import 'package:untitled16/features/auth/domain/entities/user_entity.dart';


class TrackingStatusCard extends StatelessWidget {
  final bool hasActive;
  final UserEntity? user;
  final bool isDark;
  const TrackingStatusCard({required this.hasActive, required this.user, required this.isDark});

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
