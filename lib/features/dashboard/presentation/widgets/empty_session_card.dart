import 'package:flutter/material.dart';
import 'package:untitled16/core/constants/app_colors.dart';
import 'package:untitled16/core/constants/app_strings.dart';



class EmptySessionsCard extends StatelessWidget {
  final bool isDark;
  const EmptySessionsCard({required this.isDark});

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