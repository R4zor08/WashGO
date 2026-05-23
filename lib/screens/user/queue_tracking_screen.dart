import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:washgo/core/constants/app_colors.dart';
import 'package:washgo/core/constants/app_text_styles.dart';
import 'package:washgo/core/constants/booking_status.dart';
import 'package:washgo/core/state/app_state.dart';
import 'package:washgo/core/widgets/empty_state.dart';
import 'package:washgo/core/widgets/list_screen_toolbar.dart';
import 'package:washgo/core/widgets/status_badge.dart';
import 'package:washgo/models/booking_model.dart';
import 'package:washgo/models/service_model.dart';

class QueueTrackingScreen extends StatefulWidget {
  const QueueTrackingScreen({super.key});

  @override
  State<QueueTrackingScreen> createState() => _QueueTrackingScreenState();
}

class _QueueTrackingScreenState extends State<QueueTrackingScreen> {
  String _selectedFilter = 'All';

  static const _filters = ['All', 'Basic', 'Premium', 'Interior', 'Detailing'];

  String _bookingCategory(BookingModel booking, AppState state) {
    for (final s in state.availableServices) {
      if (s.id == booking.serviceId) return s.category;
    }
    return ServiceModel.categoryFromName(booking.serviceName);
  }

  int _pendingCountForFilter(AppState state, String filter) {
    final pending = state.getPendingQueue();
    if (filter == 'All') return pending.length;
    return pending
        .where((b) => ServiceModel.categoryFromName(b.serviceName) == filter)
        .length;
  }

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();
    final activeBooking = state.getActiveBookingForCurrentUser();
    final pendingInFilter = _pendingCountForFilter(state, _selectedFilter);

    return SingleChildScrollView(
      padding: const EdgeInsets.only(bottom: 100),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const ListScreenHeader(
            title: 'Queue Tracking',
            subtitle: 'Live status for your wash and the bay queue',
          ),
          ListFilterChips(
            filters: _filters,
            selected: _selectedFilter,
            onSelected: (f) => setState(() => _selectedFilter = f),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 10, 16, 0),
            child: Text(
              _selectedFilter == 'All'
                  ? '$pendingInFilter in queue total'
                  : '$pendingInFilter in $_selectedFilter queue',
              style: AppTextStyles.caption.copyWith(
                color: AppColors.cyan,
                fontWeight: FontWeight.w600,
                fontSize: 12,
              ),
            ),
          ),
          const SizedBox(height: 16),
          if (activeBooking == null)
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16),
              child: EmptyState(
                icon: Icons.queue_outlined,
                title: 'No active booking',
                subtitle: 'Book a wash to track your queue status here',
              ),
            )
          else if (_selectedFilter != 'All' &&
              _bookingCategory(activeBooking, state) != _selectedFilter)
            _CategoryMismatchCard(
              booking: activeBooking,
              category: _bookingCategory(activeBooking, state),
              selectedFilter: _selectedFilter,
              onViewBooking: () => setState(
                () => _selectedFilter = _bookingCategory(activeBooking, state),
              ),
            )
          else
            _ActiveQueueContent(
              booking: activeBooking,
              state: state,
              category: _bookingCategory(activeBooking, state),
            ),
        ],
      ),
    );
  }
}

class _CategoryMismatchCard extends StatelessWidget {
  final BookingModel booking;
  final String category;
  final String selectedFilter;
  final VoidCallback onViewBooking;

  const _CategoryMismatchCard({
    required this.booking,
    required this.category,
    required this.selectedFilter,
    required this.onViewBooking,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: AppColors.cardDark,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
            ),
            child: Column(
              children: [
                Icon(
                  Icons.filter_alt_outlined,
                  color: AppColors.cyan.withValues(alpha: 0.8),
                  size: 36,
                ),
                const SizedBox(height: 12),
                Text(
                  'No active $selectedFilter booking',
                  style: AppTextStyles.title.copyWith(fontSize: 16),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                Text(
                  'Your current wash is $category (${booking.serviceName}).',
                  style: AppTextStyles.caption.copyWith(
                    color: AppColors.textLight.withValues(alpha: 0.7),
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                OutlinedButton(
                  onPressed: onViewBooking,
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.cyan,
                    side: const BorderSide(color: AppColors.cyan),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: Text('View my $category queue'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ActiveQueueContent extends StatelessWidget {
  final BookingModel booking;
  final AppState state;
  final String category;

  const _ActiveQueueContent({
    required this.booking,
    required this.state,
    required this.category,
  });

  double _progressForStatus(String status) {
    switch (status.toLowerCase()) {
      case 'pending':
        return 0.25;
      case 'washing':
        return 0.65;
      case 'completed':
        return 1.0;
      default:
        return 0.0;
    }
  }

  String _statusMessage(String status) {
    switch (status.toLowerCase()) {
      case 'pending':
        return 'Your car is in the queue. Please wait for your turn.';
      case 'washing':
        return 'Your car is being washed right now. Almost done!';
      case 'completed':
        return 'Your wash is complete. Thank you for choosing WashGo!';
      case 'cancelled':
        return 'This booking has been cancelled.';
      default:
        return 'Track your queue status here.';
    }
  }

  @override
  Widget build(BuildContext context) {
    final progress = _progressForStatus(booking.status);
    final serving = state.currentServingQueue;
    final waitText = state.formatEstimatedWait(booking);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              gradient: AppColors.heroCardGradient,
              borderRadius: BorderRadius.circular(20),
              boxShadow: AppColors.glowShadow(blur: 24),
            ),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: AppColors.midnightBlue.withValues(alpha: 0.55),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: AppColors.cyan.withValues(alpha: 0.4)),
                      ),
                      child: Text(
                        category,
                        style: AppTextStyles.caption.copyWith(
                          color: AppColors.limeAccent,
                          fontWeight: FontWeight.w600,
                          fontSize: 11,
                        ),
                      ),
                    ),
                    StatusBadge(status: booking.status, onGradient: true),
                  ],
                ),
                const SizedBox(height: 16),
                Text(
                  'Your Queue Number',
                  style: AppTextStyles.caption.copyWith(
                    color: AppColors.textLight.withValues(alpha: 0.9),
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  '#${booking.queueNumber}',
                  style: AppTextStyles.headline.copyWith(
                    fontSize: 56,
                    height: 1,
                    shadows: [
                      Shadow(
                        color: Colors.black.withValues(alpha: 0.2),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                  decoration: BoxDecoration(
                    color: AppColors.midnightBlue.withValues(alpha: 0.5),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.people_outline, color: AppColors.textLight, size: 18),
                      const SizedBox(width: 8),
                      Text(
                        'Now Serving: #$serving',
                        style: AppTextStyles.body.copyWith(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 10),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    color: AppColors.midnightBlue.withValues(alpha: 0.65),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: AppColors.limeAccent.withValues(alpha: 0.5)),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.timer_outlined, color: AppColors.limeAccent, size: 16),
                      const SizedBox(width: 6),
                      Text(
                        'Estimated Wait: $waitText',
                        style: AppTextStyles.caption.copyWith(
                          color: AppColors.textLight,
                          fontWeight: FontWeight.w600,
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          Text('Progress', style: AppTextStyles.title.copyWith(fontSize: 16)),
          const SizedBox(height: 4),
          Text(
            booking.serviceName,
            style: AppTextStyles.caption.copyWith(
              color: AppColors.textLight.withValues(alpha: 0.65),
            ),
          ),
          const SizedBox(height: 16),
          _TimelineStep(
            label: 'Pending',
            icon: Icons.hourglass_top_outlined,
            isActive: progress >= 0.25,
            isCurrent: booking.status == BookingStatus.pending,
          ),
          _TimelineStep(
            label: 'Washing',
            icon: Icons.local_car_wash_outlined,
            isActive: progress >= 0.65,
            isCurrent: booking.status == BookingStatus.washing,
          ),
          _TimelineStep(
            label: 'Completed',
            icon: Icons.check_circle_outline,
            isActive: progress >= 1.0,
            isCurrent: booking.status == BookingStatus.completed,
            isLast: true,
          ),
          const SizedBox(height: 14),
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: SizedBox(
              height: 10,
              child: Stack(
                children: [
                  Container(color: AppColors.cardDark),
                  FractionallySizedBox(
                    widthFactor: progress.clamp(0.0, 1.0),
                    child: Container(
                      decoration: const BoxDecoration(
                        gradient: AppColors.primaryGradient,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),
          _BookingDetailsCard(booking: booking),
          const SizedBox(height: 16),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.aquaBlue.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: AppColors.cyan.withValues(alpha: 0.35)),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: AppColors.cyan.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(Icons.info_outline, color: AppColors.cyan, size: 20),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    _statusMessage(booking.status),
                    style: AppTextStyles.body.copyWith(fontSize: 14, height: 1.4),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _BookingDetailsCard extends StatelessWidget {
  final BookingModel booking;

  const _BookingDetailsCard({required this.booking});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.cardDark,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Booking Details', style: AppTextStyles.title.copyWith(fontSize: 16)),
          const SizedBox(height: 14),
          _detailRow(Icons.local_car_wash_outlined, 'Service', booking.serviceName),
          _detailRow(Icons.directions_car_outlined, 'Vehicle', booking.vehicleType),
          _detailRow(Icons.pin_outlined, 'Plate', booking.plateNumber),
          _detailRow(
            Icons.calendar_today_outlined,
            'Schedule',
            '${booking.bookingDate} • ${booking.bookingTime}',
          ),
        ],
      ),
    );
  }

  Widget _detailRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Icon(icon, size: 16, color: AppColors.cyan),
          const SizedBox(width: 10),
          Expanded(
            flex: 2,
            child: Text(
              label,
              style: AppTextStyles.caption.copyWith(
                color: AppColors.textSecondary,
                fontSize: 12,
              ),
            ),
          ),
          Expanded(
            flex: 3,
            child: Text(
              value,
              style: AppTextStyles.body.copyWith(fontSize: 13),
              textAlign: TextAlign.right,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}

class _TimelineStep extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool isActive;
  final bool isCurrent;
  final bool isLast;

  const _TimelineStep({
    required this.label,
    required this.icon,
    required this.isActive,
    required this.isCurrent,
    this.isLast = false,
  });

  @override
  Widget build(BuildContext context) {
    final activeColor = isCurrent ? AppColors.limeAccent : AppColors.aquaBlue;
    final iconColor = isActive ? activeColor : AppColors.textSecondary;
    final lineColor = isActive
        ? AppColors.aquaBlue
        : AppColors.textSecondary.withValues(alpha: 0.25);

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Column(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: isCurrent
                    ? AppColors.aquaBlue.withValues(alpha: 0.3)
                    : isActive
                        ? AppColors.aquaBlue.withValues(alpha: 0.15)
                        : AppColors.cardDark,
                shape: BoxShape.circle,
                border: Border.all(
                  color: isActive ? activeColor : AppColors.textSecondary.withValues(alpha: 0.4),
                  width: isCurrent ? 2.5 : 1,
                ),
                boxShadow: isCurrent ? AppColors.glowShadow(color: AppColors.limeAccent, blur: 12) : null,
              ),
              child: Icon(icon, size: 20, color: iconColor),
            ),
            if (!isLast)
              Container(
                width: 2,
                height: 36,
                color: lineColor,
              ),
          ],
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.only(top: 10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: AppTextStyles.body.copyWith(
                    fontSize: 15,
                    color: isActive ? AppColors.textLight : AppColors.textSecondary,
                    fontWeight: isCurrent ? FontWeight.w700 : FontWeight.w400,
                  ),
                ),
                if (isCurrent)
                  Text(
                    'In progress',
                    style: AppTextStyles.caption.copyWith(
                      color: AppColors.cyan,
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
