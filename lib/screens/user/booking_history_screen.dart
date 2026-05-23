import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:washgo/core/state/app_state.dart';
import 'package:washgo/core/widgets/booking_card.dart';
import 'package:washgo/core/widgets/empty_state.dart';
import 'package:washgo/core/widgets/list_screen_toolbar.dart';
import 'package:washgo/models/booking_model.dart';
import 'package:washgo/screens/user/qr_receipt_screen.dart';

class BookingHistoryScreen extends StatefulWidget {
  const BookingHistoryScreen({super.key});

  @override
  State<BookingHistoryScreen> createState() => _BookingHistoryScreenState();
}

class _BookingHistoryScreenState extends State<BookingHistoryScreen> {
  final _searchController = TextEditingController();
  String _selectedFilter = 'All';

  static const _filters = [
    'All',
    'Pending',
    'Washing',
    'Completed',
    'Cancelled',
  ];

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<BookingModel> _filteredBookings(AppState state) {
    var bookings = state.getBookingsForCurrentUser();

    if (_selectedFilter != 'All') {
      bookings = bookings
          .where((b) => b.status.toLowerCase() == _selectedFilter.toLowerCase())
          .toList();
    }

    final query = _searchController.text.toLowerCase();
    if (query.isNotEmpty) {
      bookings = bookings
          .where(
            (b) =>
                b.serviceName.toLowerCase().contains(query) ||
                b.plateNumber.toLowerCase().contains(query),
          )
          .toList();
    }

    return bookings;
  }

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();
    final bookings = _filteredBookings(state);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const ListScreenHeader(
          title: 'Booking History',
          subtitle: 'View receipts and track your washes',
        ),
        ListSearchField(
          controller: _searchController,
          hintText: 'Search by service or plate...',
          onChanged: (_) => setState(() {}),
        ),
        const SizedBox(height: 12),
        ListFilterChips(
          filters: _filters,
          selected: _selectedFilter,
          onSelected: (f) => setState(() => _selectedFilter = f),
        ),
        ListResultCount(
          count: bookings.length,
          singularLabel: 'booking',
          pluralLabel: 'bookings',
        ),
        Expanded(
          child: bookings.isEmpty
              ? const EmptyState(
                  icon: Icons.history_outlined,
                  title: 'No bookings found',
                  subtitle: 'Try adjusting your search or filters',
                )
              : ListView.builder(
                  padding: const EdgeInsets.fromLTRB(16, 12, 16, 100),
                  itemCount: bookings.length,
                  itemBuilder: (context, index) {
                    final booking = bookings[index];
                    return BookingCard(
                      booking: booking,
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => QRReceiptScreen(booking: booking),
                        ),
                      ),
                    );
                  },
                ),
        ),
      ],
    );
  }
}
