import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:washgo/core/constants/app_colors.dart';
import 'package:washgo/core/constants/app_text_styles.dart';
import 'package:washgo/core/state/app_state.dart';
import 'package:washgo/core/widgets/custom_button.dart';
import 'package:washgo/core/widgets/status_badge.dart';
import 'package:washgo/models/booking_model.dart';

class QueueControlScreen extends StatelessWidget {
  const QueueControlScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();
    final current = state.getCurrentWashingBooking();
    final pending = state.getPendingQueue();
    final serving = state.currentServingQueue;

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Queue Control', style: AppTextStyles.headline.copyWith(fontSize: 24)),
          const SizedBox(height: 20),
          if (current != null)
            _CurrentCustomerCard(booking: current, servingNumber: serving)
          else
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AppColors.cardDark,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
              ),
              child: Text(
                'No customer currently being washed.\nTap Next Customer to start.',
                style: AppTextStyles.body.copyWith(fontSize: 14),
              ),
            ),
          const SizedBox(height: 20),
          CustomButton(
            text: 'Next Customer',
            icon: Icons.skip_next_outlined,
            onPressed: () async {
              final msg = await state.nextCustomer();
              if (!context.mounted) return;
              if (msg != null) {
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Next customer is now being served.')),
                );
              }
            },
          ),
          const SizedBox(height: 12),
          CustomButton(
            text: 'Mark Completed',
            icon: Icons.check_circle_outline,
            style: CustomButtonStyle.secondary,
            onPressed: () async {
              final msg = await state.markCurrentCompleted();
              if (!context.mounted) return;
              if (msg != null) {
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Current customer marked as completed.')),
                );
              }
            },
          ),
          const SizedBox(height: 24),
          Text('Pending Queue', style: AppTextStyles.title.copyWith(fontSize: 18)),
          const SizedBox(height: 12),
          if (pending.isEmpty)
            Text('No pending customers.', style: AppTextStyles.caption)
          else
            ...pending.map(
              (b) => _PendingQueueItem(
                booking: b,
                servingNumber: serving,
                state: state,
              ),
            ),
        ],
      ),
    );
  }
}

class _CurrentCustomerCard extends StatelessWidget {
  final BookingModel booking;
  final int servingNumber;

  const _CurrentCustomerCard({
    required this.booking,
    required this.servingNumber,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: AppColors.heroCardGradient,
        borderRadius: BorderRadius.circular(20),
        boxShadow: AppColors.glowShadow(blur: 24),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Current Customer', style: AppTextStyles.title.copyWith(fontSize: 16)),
                    StatusBadge(status: booking.status, onGradient: true),
            ],
          ),
          const SizedBox(height: 16),
          Text('Queue #$servingNumber', style: AppTextStyles.headline.copyWith(fontSize: 40)),
          const SizedBox(height: 12),
          _infoRow(Icons.person_outline, booking.userName),
          _infoRow(Icons.local_car_wash_outlined, booking.serviceName),
          _infoRow(Icons.pin_outlined, booking.plateNumber),
        ],
      ),
    );
  }

  Widget _infoRow(IconData icon, String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Icon(icon, size: 18, color: AppColors.textLight.withValues(alpha: 0.8)),
          const SizedBox(width: 8),
          Text(text, style: AppTextStyles.body.copyWith(fontSize: 14)),
        ],
      ),
    );
  }
}

class _PendingQueueItem extends StatelessWidget {
  final BookingModel booking;
  final int servingNumber;
  final AppState state;

  const _PendingQueueItem({
    required this.booking,
    required this.servingNumber,
    required this.state,
  });

  @override
  Widget build(BuildContext context) {
    final waitMins = state.getEstimatedWaitMinutesForUser(booking);

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.cardDark,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: AppColors.warningOrange.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Center(
              child: Text(
                '#${booking.queueNumber}',
                style: AppTextStyles.badge.copyWith(color: AppColors.warningOrange),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(booking.userName, style: AppTextStyles.body.copyWith(fontSize: 14)),
                Text(
                  '${booking.serviceName} • ${booking.plateNumber}',
                  style: AppTextStyles.caption,
                ),
              ],
            ),
          ),
          Text('~$waitMins min', style: AppTextStyles.caption.copyWith(color: AppColors.cyan)),
        ],
      ),
    );
  }
}
