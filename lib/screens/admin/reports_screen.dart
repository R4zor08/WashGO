import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:washgo/core/constants/app_colors.dart';
import 'package:washgo/core/constants/app_text_styles.dart';
import 'package:washgo/core/state/app_state.dart';
import 'package:washgo/core/widgets/stat_card.dart';

class ReportsScreen extends StatelessWidget {
  const ReportsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();
    final weekly = state.weeklyBookings;
    final maxBar = weekly.isEmpty
        ? 1.0
        : weekly.reduce((a, b) => a > b ? a : b).toDouble().clamp(1, double.infinity);

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Reports', style: AppTextStyles.headline.copyWith(fontSize: 24)),
          const SizedBox(height: 20),
          GridView.count(
            crossAxisCount: 2,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            mainAxisSpacing: 12,
            crossAxisSpacing: 12,
            childAspectRatio: 1.15,
            children: [
              StatCard(
                icon: Icons.today_outlined,
                iconColor: AppColors.aquaBlue,
                title: 'Daily Bookings',
                value: '${state.totalBookingsToday}',
              ),
              StatCard(
                icon: Icons.check_circle_outline,
                iconColor: AppColors.successGreen,
                title: 'Completed',
                value: '${state.completedBookingsCount}',
              ),
              StatCard(
                icon: Icons.pending_outlined,
                iconColor: AppColors.warningOrange,
                title: 'Pending',
                value: '${state.pendingBookingsCount}',
              ),
              StatCard(
                icon: Icons.queue_outlined,
                iconColor: AppColors.cyan,
                title: 'Active Queue',
                value: '${state.activeQueueCount}',
              ),
            ],
          ),
          const SizedBox(height: 16),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: AppColors.heroCardGradient,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Estimated Earnings', style: AppTextStyles.caption),
                    const SizedBox(height: 4),
                    Text(
                      '₱${state.estimatedEarnings.toStringAsFixed(0)}',
                      style: AppTextStyles.headline.copyWith(fontSize: 28),
                    ),
                  ],
                ),
                const Icon(Icons.trending_up, color: AppColors.cyan, size: 36),
              ],
            ),
          ),
          const SizedBox(height: 24),
          Text('Weekly Bookings', style: AppTextStyles.title.copyWith(fontSize: 16)),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: AppColors.cardDark,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
            ),
            child: SizedBox(
              height: 160,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: List.generate(weekly.length, (index) {
                  final value = weekly[index];
                  final height = (value / maxBar) * 120;
                  const days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
                  return Column(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Text('$value', style: AppTextStyles.caption.copyWith(fontSize: 10)),
                      const SizedBox(height: 4),
                      Container(
                        width: 28,
                        height: height,
                        decoration: BoxDecoration(
                          gradient: AppColors.primaryGradient,
                          borderRadius: BorderRadius.circular(6),
                          boxShadow: AppColors.glowShadow(blur: 8),
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(days[index], style: AppTextStyles.caption.copyWith(fontSize: 10)),
                    ],
                  );
                }),
              ),
            ),
          ),
          const SizedBox(height: 24),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.cardDark,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Recent Summary', style: AppTextStyles.title.copyWith(fontSize: 16)),
                const SizedBox(height: 12),
                Text(
                  'Today WashGo processed ${state.totalBookingsToday} bookings with '
                  '${state.completedBookingsCount} completed and ${state.pendingBookingsCount} still pending. '
                  'The active queue has ${state.activeQueueCount} customers. '
                  'Estimated earnings from completed washes: ₱${state.estimatedEarnings.toStringAsFixed(0)}.',
                  style: AppTextStyles.body.copyWith(fontSize: 14, height: 1.5),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
