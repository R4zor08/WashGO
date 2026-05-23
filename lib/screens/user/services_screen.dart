import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:washgo/core/layout/responsive_layout.dart';
import 'package:washgo/core/state/app_state.dart';
import 'package:washgo/core/widgets/empty_state.dart';
import 'package:washgo/core/widgets/list_screen_toolbar.dart';
import 'package:washgo/core/widgets/service_card.dart';
import 'package:washgo/models/service_model.dart';
import 'package:washgo/screens/user/booking_screen.dart';

class ServicesScreen extends StatefulWidget {
  const ServicesScreen({super.key});

  @override
  State<ServicesScreen> createState() => _ServicesScreenState();
}

class _ServicesScreenState extends State<ServicesScreen> {
  final _searchController = TextEditingController();
  String _selectedFilter = 'All';

  static const _filters = ['All', 'Basic', 'Premium', 'Interior', 'Detailing'];

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<ServiceModel> _filteredServices(AppState state) {
    var services = state.availableServices;

    if (_selectedFilter != 'All') {
      services = services.where((s) => s.category == _selectedFilter).toList();
    }

    final query = _searchController.text.toLowerCase();
    if (query.isNotEmpty) {
      services = services
          .where(
            (s) =>
                s.name.toLowerCase().contains(query) ||
                s.description.toLowerCase().contains(query),
          )
          .toList();
    }

    return services;
  }

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();
    final services = _filteredServices(state);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const ListScreenHeader(
          title: 'Services',
          subtitle: 'Choose a package and book your wash',
        ),
        ListSearchField(
          controller: _searchController,
          hintText: 'Search services...',
          onChanged: (_) => setState(() {}),
        ),
        const SizedBox(height: 12),
        ListFilterChips(
          filters: _filters,
          selected: _selectedFilter,
          onSelected: (f) => setState(() => _selectedFilter = f),
        ),
        ListResultCount(
          count: services.length,
          singularLabel: 'service available',
          pluralLabel: 'services available',
        ),
        Expanded(
          child: services.isEmpty
              ? const EmptyState(
                  icon: Icons.search_off_outlined,
                  title: 'No services found',
                  subtitle: 'Try adjusting your search or filters',
                )
              : ListView.builder(
                  padding: EdgeInsets.fromLTRB(
                    ResponsiveLayout.horizontalPadding(context),
                    12,
                    ResponsiveLayout.horizontalPadding(context),
                    ResponsiveLayout.navigationBottomInset(context),
                  ),
                  itemCount: services.length,
                  itemBuilder: (context, index) {
                    final service = services[index];
                    return ServiceCard(
                      service: service,
                      onBookNow: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => BookingScreen(service: service),
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
