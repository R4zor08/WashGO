import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:washgo/core/constants/app_colors.dart';
import 'package:washgo/core/constants/app_text_styles.dart';
import 'package:washgo/core/state/app_state.dart';
import 'package:washgo/core/widgets/app_scaffold.dart';
import 'package:washgo/core/widgets/profile_avatar.dart';
import 'package:washgo/models/user_model.dart';
import 'package:washgo/screens/auth/login_screen.dart';
import 'package:washgo/screens/user/profile/about_screen.dart';
import 'package:washgo/screens/user/profile/edit_profile_screen.dart';
import 'package:washgo/screens/user/profile/help_support_screen.dart';
import 'package:washgo/screens/user/profile/notifications_screen.dart';

class ProfileScreen extends StatelessWidget {
  final VoidCallback? onNavigateToHistory;

  const ProfileScreen({super.key, this.onNavigateToHistory});

  static const _onGradientSubtext = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w400,
    color: AppColors.textLight,
  );

  static const _onGradientLabel = TextStyle(
    fontSize: 11,
    fontWeight: FontWeight.w500,
    color: AppColors.textLight,
  );

  void _openEditProfile(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const EditProfileScreen()),
    );
  }

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
    final user = state.currentUser;

    if (user == null) {
      return const Center(child: Text('Not logged in', style: AppTextStyles.body));
    }

    final bookingCount = state.currentUserBookingCount;
    final completedCount = state.currentUserCompletedCount;
    final activeStatus = state.currentUserActiveStatusLabel;
    final unreadCount = state.unreadNotificationCount;

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Profile', style: AppTextStyles.headline.copyWith(fontSize: 24)),
          const SizedBox(height: 4),
          Text(
            'Manage your account and preferences',
            style: AppTextStyles.subtitle.copyWith(
              fontSize: 13,
              color: AppColors.textLight.withValues(alpha: 0.75),
            ),
          ),
          const SizedBox(height: 16),
          _ProfileHeroCard(
            user: user,
            totalBookings: bookingCount,
            completed: completedCount,
            activeStatus: activeStatus,
            onEdit: () => _openEditProfile(context),
          ),
          const SizedBox(height: 24),
          Text(
            'QUICK LINKS',
            style: AppTextStyles.caption.copyWith(
              color: AppColors.cyan,
              fontWeight: FontWeight.w600,
              letterSpacing: 0.6,
              fontSize: 12,
            ),
          ),
          const SizedBox(height: 10),
          _MenuItem(
            icon: Icons.calendar_month_outlined,
            title: 'My Bookings',
            subtitle: '$bookingCount ${bookingCount == 1 ? 'booking' : 'bookings'}',
            onTap: () => onNavigateToHistory?.call(),
          ),
          _MenuItem(
            icon: Icons.notifications_outlined,
            title: 'Notifications',
            subtitle: unreadCount > 0 ? '$unreadCount unread' : 'Booking updates',
            showBadge: unreadCount > 0,
            badgeCount: unreadCount,
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const NotificationsScreen()),
            ),
          ),
          _MenuItem(
            icon: Icons.help_outline,
            title: 'Help & Support',
            subtitle: 'FAQ and contact info',
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const HelpSupportScreen()),
            ),
          ),
          _MenuItem(
            icon: Icons.info_outline,
            title: 'About WashGo',
            subtitle: 'Version 1.0.0',
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const AboutScreen()),
            ),
          ),
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

class _ProfileHeroCard extends StatelessWidget {
  final UserModel user;
  final int totalBookings;
  final int completed;
  final String activeStatus;
  final VoidCallback onEdit;

  const _ProfileHeroCard({
    required this.user,
    required this.totalBookings,
    required this.completed,
    required this.activeStatus,
    required this.onEdit,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: AppColors.heroCardGradient,
        borderRadius: BorderRadius.circular(20),
        boxShadow: AppColors.glowShadow(blur: 20),
      ),
      child: Column(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: const WashGoLogo(height: 44),
          ),
          const SizedBox(height: 18),
          GestureDetector(
            onTap: onEdit,
            child: Stack(
              clipBehavior: Clip.none,
              alignment: Alignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: AppColors.primaryGradient,
                    boxShadow: AppColors.glowShadow(blur: 16),
                  ),
                  child: Container(
                    padding: const EdgeInsets.all(3),
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      color: AppColors.cardDark,
                    ),
                    child: ProfileAvatar(
                      key: ValueKey(user.profileImagePath ?? 'no-photo'),
                      profileImagePath: user.profileImagePath,
                      radius: 40,
                    ),
                  ),
                ),
                Positioned(
                  right: 0,
                  bottom: 0,
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: AppColors.cardDark,
                      shape: BoxShape.circle,
                      border: Border.all(color: AppColors.cyan, width: 1.5),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.25),
                          blurRadius: 6,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: const Icon(Icons.edit_outlined, size: 16, color: AppColors.cyan),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Tap photo to edit profile',
            style: AppTextStyles.caption.copyWith(
              color: AppColors.textLight.withValues(alpha: 0.75),
              fontSize: 11,
            ),
          ),
          const SizedBox(height: 14),
          Text(
            'Hello, ${user.firstName}',
            style: AppTextStyles.headline.copyWith(fontSize: 22),
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 4),
          Text(
            user.fullName,
            style: ProfileScreen._onGradientSubtext.copyWith(
              color: AppColors.textLight.withValues(alpha: 0.9),
              fontSize: 15,
            ),
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 6),
          Text(
            user.email,
            style: ProfileScreen._onGradientSubtext.copyWith(
              color: AppColors.textLight.withValues(alpha: 0.85),
            ),
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
            decoration: BoxDecoration(
              color: AppColors.midnightBlue.withValues(alpha: 0.45),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: AppColors.limeAccent.withValues(alpha: 0.4)),
            ),
            child: Text(
              user.role.toUpperCase(),
              style: AppTextStyles.badge.copyWith(
                color: AppColors.limeAccent,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          const SizedBox(height: 18),
          _AccountStatsRow(
            totalBookings: totalBookings,
            completed: completed,
            activeStatus: activeStatus,
          ),
        ],
      ),
    );
  }
}

class _AccountStatsRow extends StatelessWidget {
  final int totalBookings;
  final int completed;
  final String activeStatus;

  const _AccountStatsRow({
    required this.totalBookings,
    required this.completed,
    required this.activeStatus,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 8),
      decoration: BoxDecoration(
        color: AppColors.midnightBlue.withValues(alpha: 0.4),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.white.withValues(alpha: 0.12)),
      ),
      child: Row(
        children: [
          Expanded(
            child: _StatItem(
              icon: Icons.calendar_today_outlined,
              label: 'Total',
              value: '$totalBookings',
            ),
          ),
          Container(
            width: 1,
            height: 40,
            color: Colors.white.withValues(alpha: 0.2),
          ),
          Expanded(
            child: _StatItem(
              icon: Icons.check_circle_outline,
              label: 'Completed',
              value: '$completed',
            ),
          ),
          Container(
            width: 1,
            height: 40,
            color: Colors.white.withValues(alpha: 0.2),
          ),
          Expanded(
            child: _StatItem(
              icon: Icons.local_car_wash_outlined,
              label: 'Active',
              value: activeStatus,
            ),
          ),
        ],
      ),
    );
  }
}

class _StatItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _StatItem({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Icon(icon, size: 18, color: AppColors.limeAccent),
        const SizedBox(height: 6),
        Text(
          value,
          style: AppTextStyles.statValue.copyWith(fontSize: 16),
          textAlign: TextAlign.center,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: ProfileScreen._onGradientLabel.copyWith(
            color: AppColors.textLight.withValues(alpha: 0.8),
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}

class _MenuItem extends StatelessWidget {
  final IconData icon;
  final String title;
  final String? subtitle;
  final VoidCallback onTap;
  final bool showBadge;
  final int badgeCount;

  const _MenuItem({
    required this.icon,
    required this.title,
    this.subtitle,
    required this.onTap,
    this.showBadge = false,
    this.badgeCount = 0,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: AppColors.cardDark,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: AppColors.aquaBlue.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(icon, color: AppColors.cyan, size: 22),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(title, style: AppTextStyles.body.copyWith(fontSize: 15)),
                      if (subtitle != null) ...[
                        const SizedBox(height: 2),
                        Text(
                          subtitle!,
                          style: AppTextStyles.caption.copyWith(
                            fontSize: 12,
                            color: AppColors.textLight.withValues(alpha: 0.55),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                if (showBadge && badgeCount > 0)
                  Container(
                    margin: const EdgeInsets.only(right: 8),
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppColors.dangerRed,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      '$badgeCount',
                      style: const TextStyle(
                        color: AppColors.textLight,
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                Icon(
                  Icons.chevron_right,
                  color: AppColors.textSecondary.withValues(alpha: 0.7),
                  size: 22,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
