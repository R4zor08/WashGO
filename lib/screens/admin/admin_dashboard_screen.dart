import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:washgo/core/constants/app_colors.dart';
import 'package:washgo/core/constants/app_text_styles.dart';
import 'package:washgo/core/layout/responsive_layout.dart';
import 'package:washgo/core/state/app_state.dart';
import 'package:washgo/core/widgets/app_scaffold.dart';
import 'package:washgo/core/widgets/booking_card.dart';
import 'package:washgo/core/widgets/quick_action_card.dart';
import 'package:washgo/core/widgets/section_header.dart';
import 'package:washgo/core/widgets/stat_card.dart';
import 'package:washgo/screens/auth/login_screen.dart';

class AdminDashboardScreen extends StatelessWidget {
  final void Function(int tabIndex) onNavigate;

  const AdminDashboardScreen({super.key, required this.onNavigate});

  Future<void> _confirmLogout(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.cardDark,
        title: Text('Logout', style: AppTextStyles.title),
        content: Text(
          'Are you sure you want to logout?',
          style: AppTextStyles.body,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Logout', style: TextStyle(color: AppColors.dangerRed)),
          ),
        ],
      ),
    );

    if (confirmed == true && context.mounted) {
      context.read<AppState>().logout();
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (_) => const LoginScreen()),
        (route) => false,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();
    final admin = state.currentUser;

    if (admin == null) {
      return const Center(child: Text('Not logged in', style: AppTextStyles.body));
    }

    final gridCols = ResponsiveLayout.gridCrossAxisCount(context, compact: 2, medium: 3, expanded: 4);
    final narrowHeader = MediaQuery.sizeOf(context).width < 400;

    return SingleChildScrollView(
      padding: ResponsiveLayout.screenPadding(context),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (narrowHeader)
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        'Hello, ${admin.firstName}',
                        style: AppTextStyles.headline.copyWith(fontSize: 22),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    IconButton(
                      onPressed: () => _confirmLogout(context),
                      tooltip: 'Logout',
                      icon: const Icon(Icons.logout, color: AppColors.dangerRed),
                    ),
                  ],
                ),
                Text('Admin Control Panel', style: AppTextStyles.subtitle),
              ],
            )
          else
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Hello, ${admin.firstName}',
                        style: AppTextStyles.headline.copyWith(fontSize: 22),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Text('Admin Control Panel', style: AppTextStyles.subtitle),
                    ],
                  ),
                ),
                IconButton(
                  onPressed: () => _confirmLogout(context),
                  tooltip: 'Logout',
                  icon: const Icon(Icons.logout, color: AppColors.dangerRed),
                ),
                const SizedBox(width: 4),
                const WashGoLogo(height: 36),
              ],
            ),
          const SizedBox(height: 20),
          GridView.count(
            crossAxisCount: gridCols,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            mainAxisSpacing: 12,
            crossAxisSpacing: 12,
            childAspectRatio: 1.15,
            children: [
              StatCard(
                icon: Icons.event_available_outlined,
                iconColor: AppColors.aquaBlue,
                title: 'Bookings Today',
                value: '${state.totalBookingsToday}',
              ),
              StatCard(
                icon: Icons.queue_outlined,
                iconColor: AppColors.cyan,
                title: 'Active Queue',
                value: '${state.activeQueueCount}',
              ),
              StatCard(
                icon: Icons.hourglass_top_outlined,
                iconColor: AppColors.warningOrange,
                title: 'Pending',
                value: '${state.pendingBookingsCount}',
              ),
              StatCard(
                icon: Icons.check_circle_outline,
                iconColor: AppColors.successGreen,
                title: 'Completed',
                value: '${state.completedBookingsCount}',
              ),
            ],
          ),
          const SizedBox(height: 24),
          const SectionHeader(title: 'Quick Actions'),
          Row(
            children: [
              Expanded(
                child: QuickActionCard(
                  icon: Icons.local_car_wash_outlined,
                  label: 'Manage Services',
                  color: AppColors.aquaBlue,
                  onTap: () => onNavigate(1),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: QuickActionCard(
                  icon: Icons.event_note_outlined,
                  label: 'Manage Bookings',
                  color: AppColors.cyan,
                  onTap: () => onNavigate(2),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: QuickActionCard(
                  icon: Icons.queue_play_next_outlined,
                  label: 'Queue Control',
                  color: AppColors.teal,
                  onTap: () => onNavigate(3),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: QuickActionCard(
                  icon: Icons.bar_chart_outlined,
                  label: 'Reports',
                  color: AppColors.deepBlue,
                  onTap: () => onNavigate(4),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          const SectionHeader(title: 'Recent Bookings'),
          ...state.recentBookings.map((b) => BookingCard(booking: b)),
          const SizedBox(height: 28),
          SizedBox(
            width: double.infinity,
            height: 50,
            child: OutlinedButton.icon(
              onPressed: () => _confirmLogout(context),
              icon: const Icon(Icons.logout, size: 20),
              label: const Text('Logout'),
              style: OutlinedButton.styleFrom(
                foregroundColor: AppColors.dangerRed,
                side: BorderSide(color: AppColors.dangerRed.withValues(alpha: 0.6)),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
