import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/utils/date_helper.dart';
import '../../../tracking/presentation/providers/tracking_provider.dart';

class WeeklyReportScreen extends ConsumerWidget {
  const WeeklyReportScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final weekHours = ref.watch(weekHoursProvider);
    final chartData = ref.watch(weekChartDataProvider);
    final sessions = ref.watch(weekSessionsProvider).value ?? [];

    final workedDays =
        chartData.values.where((h) => h > 0).length;

    final avgHours =
    workedDays > 0 ? weekHours / workedDays : 0.0;
    final score = ((weekHours / 40) * 100).clamp(0, 100).round();

    return Scaffold(
      backgroundColor: isDark ? AppColors.bgDark : AppColors.bgLight,
      appBar: AppBar(
        title: const Text(AppStrings.weeklyReport),
        actions: [
          IconButton(
            icon: const Icon(Icons.picture_as_pdf_outlined),
            onPressed: () {},
            tooltip: AppStrings.exportPdf,
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // Summary cards
            Row(children: [
              Expanded(child: _SummaryCard(
                label: AppStrings.totalHours,
                value: DateHelper.formatHours(weekHours),
                icon: Icons.schedule_rounded,
                color: AppColors.primary,
                isDark: isDark,
              )),
              const SizedBox(width: 10),
              Expanded(child: _SummaryCard(
                label: AppStrings.dailyAverage,
                value: DateHelper.formatHours(avgHours),
                icon: Icons.trending_up_rounded,
                color: AppColors.accent,
                isDark: isDark,
              )),
              const SizedBox(width: 10),
              Expanded(child: _SummaryCard(
                label: AppStrings.productivityScore,
                value: '$score%',
                icon: Icons.star_rounded,
                color: AppColors.warning,
                isDark: isDark,
              )),
            ]),
            const SizedBox(height: 20),

            // Chart
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: isDark ? AppColors.cardDark : Colors.white,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: isDark ? AppColors.borderDark : AppColors.borderLight),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('ساعات العمل هذا الأسبوع', style: TextStyle(
                    fontFamily: 'Cairo', fontSize: 15, fontWeight: FontWeight.w700,
                  )),
                  const SizedBox(height: 24),
                  SizedBox(
                    height: 200,
                    child: BarChart(
                      BarChartData(
                        alignment: BarChartAlignment.spaceAround,
                        maxY: 12,
                        barTouchData: BarTouchData(enabled: true),
                        titlesData: FlTitlesData(
                          show: true,
                          bottomTitles: AxisTitles(
                            sideTitles: SideTitles(
                              showTitles: true,
                              getTitlesWidget: (value, meta) {
                                final days = AppStrings.daysShort;
                                final idx = value.toInt();
                                if (idx < 0 || idx >= days.length) return const SizedBox();
                                return Text(days[idx], style: TextStyle(
                                  fontFamily: 'Cairo', fontSize: 11,
                                  color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                                ));
                              },
                            ),
                          ),
                          leftTitles: AxisTitles(
                            sideTitles: SideTitles(
                              showTitles: true,
                              reservedSize: 32,
                              getTitlesWidget: (value, meta) => Text('${value.toInt()}س', style: TextStyle(
                                fontFamily: 'Cairo', fontSize: 10,
                                color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                              )),
                            ),
                          ),
                          topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                          rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                        ),
                        gridData: FlGridData(
                          show: true,
                          drawVerticalLine: false,
                          getDrawingHorizontalLine: (_) => FlLine(
                            color: (isDark ? Colors.white : Colors.black).withOpacity(0.05),
                            strokeWidth: 1,
                          ),
                        ),
                        borderData: FlBorderData(show: false),
                        barGroups: List.generate(7, (i) {
                          final hours = chartData[i] ?? 0.0;
                          return BarChartGroupData(
                            x: i,
                            barRods: [
                              BarChartRodData(
                                toY: hours,
                                width: 28,
                                borderRadius: const BorderRadius.vertical(top: Radius.circular(8)),
                                gradient: const LinearGradient(
                                  colors: AppColors.primaryGradient,
                                  begin: Alignment.bottomCenter,
                                  end: Alignment.topCenter,
                                ),
                              ),
                            ],
                          );
                        }),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Daily breakdown
            Container(
              decoration: BoxDecoration(
                color: isDark ? AppColors.cardDark : Colors.white,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: isDark ? AppColors.borderDark : AppColors.borderLight),
              ),
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      children: [
                        const Text('التوزيع اليومي', style: TextStyle(fontFamily: 'Cairo', fontSize: 15, fontWeight: FontWeight.w700)),
                      ],
                    ),
                  ),
                  const Divider(height: 1),
                  ...List.generate(7, (i) {
                    final hours = chartData[i] ?? 0.0;
                    final dayName = AppStrings.days[i];
                    return _DayRow(dayName: dayName, hours: hours, maxHours: 10, isDark: isDark);
                  }),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SummaryCard extends StatelessWidget {
  final String label, value;
  final IconData icon;
  final Color color;
  final bool isDark;
  const _SummaryCard({required this.label, required this.value, required this.icon, required this.color, required this.isDark});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isDark ? AppColors.cardDark : Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: isDark ? AppColors.borderDark : AppColors.borderLight),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(height: 8),
          Text(value, style: const TextStyle(fontFamily: 'Cairo', fontSize: 18, fontWeight: FontWeight.w800)),
          Text(label, style: TextStyle(
            fontFamily: 'Cairo', fontSize: 10,
            color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
          )),
        ],
      ),
    );
  }
}

class _DayRow extends StatelessWidget {
  final String dayName;
  final double hours;
  final double maxHours;
  final bool isDark;
  const _DayRow({required this.dayName, required this.hours, required this.maxHours, required this.isDark});

  @override
  Widget build(BuildContext context) {
    final pct = (hours / maxHours).clamp(0.0, 1.0);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      child: Row(
        children: [
          SizedBox(width: 50, child: Text(dayName, style: const TextStyle(fontFamily: 'Cairo', fontSize: 13))),
          const SizedBox(width: 12),
          Expanded(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: LinearProgressIndicator(
                value: pct,
                minHeight: 8,
                backgroundColor: isDark ? AppColors.borderDark : AppColors.borderLight,
                valueColor: const AlwaysStoppedAnimation(AppColors.primary),
              ),
            ),
          ),
          const SizedBox(width: 12),
          SizedBox(
            width: 36,
            child: Text(DateHelper.formatHours(hours), style: const TextStyle(
              fontFamily: 'Cairo', fontSize: 12, fontWeight: FontWeight.w600,
            ), textAlign: TextAlign.end),
          ),
        ],
      ),
    );
  }
}