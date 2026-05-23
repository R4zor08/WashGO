import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:washgo/core/constants/app_colors.dart';
import 'package:washgo/core/constants/app_text_styles.dart';
import 'package:washgo/core/state/app_state.dart';
import 'package:washgo/core/widgets/app_scaffold.dart';
import 'package:washgo/core/widgets/booking_card.dart';
import 'package:washgo/core/widgets/gradient_header.dart';
import 'package:washgo/core/widgets/profile_avatar.dart';
import 'package:washgo/core/widgets/quick_action_card.dart';
import 'package:washgo/core/widgets/section_header.dart';
import 'package:washgo/core/widgets/service_card.dart';
import 'package:washgo/models/service_model.dart';
import 'package:washgo/screens/user/booking_screen.dart';
import 'package:washgo/screens/user/qr_receipt_screen.dart';

class UserDashboardScreen extends StatelessWidget {
  final void Function(int tabIndex) onNavigate;

  const UserDashboardScreen({super.key, required this.onNavigate});

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();
    final user = state.currentUser;
    final active = state.getActiveBookingForCurrentUser();
    final previewServices = state.availableServices.take(2).toList();

    if (user == null) {
      return const Center(child: Text('Not logged in', style: AppTextStyles.body));
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _DashboardHeader(
            firstName: user.firstName,
            profileImagePath: user.profileImagePath,
          ),
          const SizedBox(height: 20),
          if (active != null) ...[
            GradientHeader(
              title: 'Active Booking',
              subtitle: active.serviceName,
              queueNumber: '#${active.queueNumber}',
              estimatedWait: state.formatEstimatedWait(active),
              status: active.status,
            ),
          ] else
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AppColors.cardDark,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
              ),
              child: Column(
                children: [
                  const Icon(Icons.local_car_wash_outlined, color: AppColors.cyan, size: 40),
                  const SizedBox(height: 12),
                  Text('No active booking', style: AppTextStyles.title.copyWith(fontSize: 16)),
                  const SizedBox(height: 4),
                  Text('Book a wash to get started', style: AppTextStyles.caption),
                ],
              ),
            ),
          const SizedBox(height: 24),
          const SectionHeader(title: 'Quick Actions'),
          Row(
            children: [
              Expanded(
                child: QuickActionCard(
                  icon: Icons.calendar_today_outlined,
                  label: 'Book Wash',
                  color: AppColors.aquaBlue,
                  onTap: () => onNavigate(1),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: QuickActionCard(
                  icon: Icons.queue_outlined,
                  label: 'Track Queue',
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
                  icon: Icons.history_outlined,
                  label: 'History',
                  color: AppColors.teal,
                  onTap: () => onNavigate(3),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: QuickActionCard(
                  icon: Icons.qr_code_2_outlined,
                  label: 'QR Receipt',
                  color: AppColors.deepBlue,
                  onTap: () {
                    if (active == null) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('No active booking for QR receipt.')),
                      );
                      return;
                    }
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => QRReceiptScreen(booking: active),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          SectionHeader(
            title: 'Available Services',
            actionLabel: 'View all',
            onAction: () => onNavigate(1),
          ),
          ...previewServices.map(
            (s) => ServiceCard(
              service: s,
              onBookNow: () => _openBooking(context, s),
            ),
          ),
          if (active != null) ...[
            const SizedBox(height: 8),
            const SectionHeader(title: 'Active Booking'),
            BookingCard(booking: active),
          ],
        ],
      ),
    );
  }

  void _openBooking(BuildContext context, ServiceModel service) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => BookingScreen(service: service)),
    );
  }
}

class _DashboardHeader extends StatelessWidget {
  final String firstName;
  final String? profileImagePath;

  const _DashboardHeader({
    required this.firstName,
    this.profileImagePath,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Hello, $firstName',
                style: AppTextStyles.headline.copyWith(fontSize: 22),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 4),
              Text(
                'Ready to make your car shine today?',
                style: AppTextStyles.subtitle,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
        const SizedBox(width: 8),
        const WashGoLogo(height: 36),
        const SizedBox(width: 8),
        ProfileAvatar(
          key: ValueKey(profileImagePath ?? 'no-photo'),
          profileImagePath: profileImagePath,
          radius: 22,
        ),
      ],
    );
  }
}
