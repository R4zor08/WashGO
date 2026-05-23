import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:washgo/core/constants/app_colors.dart';
import 'package:washgo/core/layout/responsive_layout.dart';
import 'package:washgo/core/constants/app_text_styles.dart';
import 'package:washgo/core/constants/booking_status.dart';
import 'package:washgo/core/state/app_state.dart';
import 'package:washgo/core/widgets/booking_card.dart';
import 'package:washgo/core/widgets/custom_button.dart';

class ManageBookingsScreen extends StatefulWidget {
  const ManageBookingsScreen({super.key});

  @override
  State<ManageBookingsScreen> createState() => _ManageBookingsScreenState();
}

class _ManageBookingsScreenState extends State<ManageBookingsScreen> {
  final _searchController = TextEditingController();
  String _selectedFilter = 'All';

  static const _filters = ['All', 'Pending', 'Washing', 'Completed', 'Cancelled'];
  static const _statusOptions = [
    BookingStatus.pending,
    BookingStatus.washing,
    BookingStatus.completed,
    BookingStatus.cancelled,
  ];

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _showStatusSheet(BuildContext context, String bookingId, String currentStatus) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.cardDark,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) {
        final booking = context.read<AppState>().getBookingById(bookingId);
        return Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Update Status', style: AppTextStyles.title),
              if (booking != null) ...[
                const SizedBox(height: 8),
                Text(
                  '${booking.userName} — ${booking.serviceName}',
                  style: AppTextStyles.caption,
                ),
              ],
              const SizedBox(height: 16),
              ..._statusOptions.map(
                (status) => ListTile(
                  title: Text(status, style: AppTextStyles.body),
                  trailing: currentStatus == status
                      ? const Icon(Icons.check, color: AppColors.cyan)
                      : null,
                  onTap: () async {
                    await context.read<AppState>().updateBookingStatus(bookingId, status);
                    if (!context.mounted) return;
                    Navigator.pop(ctx);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Status updated to $status')),
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    var bookings = List.from(context.watch<AppState>().bookings);

    if (_selectedFilter != 'All') {
      bookings = bookings.where((b) => b.status == _selectedFilter).toList();
    }

    final q = _searchController.text.toLowerCase();
    if (q.isNotEmpty) {
      bookings = bookings
          .where(
            (b) =>
                b.userName.toLowerCase().contains(q) ||
                b.plateNumber.toLowerCase().contains(q) ||
                b.serviceName.toLowerCase().contains(q),
          )
          .toList();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.fromLTRB(
            ResponsiveLayout.horizontalPadding(context),
            16,
            ResponsiveLayout.horizontalPadding(context),
            0,
          ),
          child: Text('Manage Bookings', style: AppTextStyles.headline.copyWith(fontSize: 24)),
        ),
        Padding(
          padding: const EdgeInsets.all(16),
          child: TextField(
            controller: _searchController,
            onChanged: (_) => setState(() {}),
            style: AppTextStyles.body,
            decoration: InputDecoration(
              hintText: 'Search bookings...',
              prefixIcon: const Icon(Icons.search, color: AppColors.textSecondary),
              filled: true,
              fillColor: AppColors.cardDark,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: BorderSide.none,
              ),
            ),
          ),
        ),
        SizedBox(
          height: 40,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            padding: EdgeInsets.symmetric(horizontal: ResponsiveLayout.horizontalPadding(context)),
            itemCount: _filters.length,
            separatorBuilder: (_, _) => const SizedBox(width: 8),
            itemBuilder: (context, index) {
              final filter = _filters[index];
              return FilterChip(
                label: Text(filter),
                selected: _selectedFilter == filter,
                onSelected: (_) => setState(() => _selectedFilter = filter),
                selectedColor: AppColors.aquaBlue.withValues(alpha: 0.25),
                checkmarkColor: AppColors.cyan,
              );
            },
          ),
        ),
        Expanded(
          child: ListView.builder(
            padding: EdgeInsets.fromLTRB(
              ResponsiveLayout.horizontalPadding(context),
              8,
              ResponsiveLayout.horizontalPadding(context),
              ResponsiveLayout.navigationBottomInset(context),
            ),
            itemCount: bookings.length,
            itemBuilder: (context, index) {
              final booking = bookings[index];
              return BookingCard(
                booking: booking,
                trailing: CustomButton(
                  text: 'Update Status',
                  onPressed: () => _showStatusSheet(context, booking.id, booking.status),
                  width: double.infinity,
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}
