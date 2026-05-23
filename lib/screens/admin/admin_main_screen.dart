import 'package:flutter/material.dart';
import 'package:washgo/core/widgets/app_bottom_nav.dart';
import 'package:washgo/core/widgets/app_scaffold.dart';
import 'package:washgo/screens/admin/admin_dashboard_screen.dart';
import 'package:washgo/screens/admin/manage_bookings_screen.dart';
import 'package:washgo/screens/admin/manage_services_screen.dart';
import 'package:washgo/screens/admin/queue_control_screen.dart';
import 'package:washgo/screens/admin/reports_screen.dart';

class AdminMainScreen extends StatefulWidget {
  final int initialTab;

  const AdminMainScreen({super.key, this.initialTab = 0});

  @override
  State<AdminMainScreen> createState() => AdminMainScreenState();
}

class AdminMainScreenState extends State<AdminMainScreen> {
  late int _currentIndex;

  static const _navItems = [
    AppBottomNavItem(
      icon: Icons.dashboard_outlined,
      activeIcon: Icons.dashboard,
      label: 'Dashboard',
    ),
    AppBottomNavItem(
      icon: Icons.local_car_wash_outlined,
      activeIcon: Icons.local_car_wash,
      label: 'Services',
    ),
    AppBottomNavItem(
      icon: Icons.event_note_outlined,
      activeIcon: Icons.event_note,
      label: 'Bookings',
    ),
    AppBottomNavItem(
      icon: Icons.queue_play_next_outlined,
      activeIcon: Icons.queue_play_next,
      label: 'Queue',
    ),
    AppBottomNavItem(
      icon: Icons.bar_chart_outlined,
      activeIcon: Icons.bar_chart,
      label: 'Reports',
    ),
  ];

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialTab;
  }

  void switchTab(int index) {
    setState(() => _currentIndex = index);
  }

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      padding: EdgeInsets.zero,
      extendBody: true,
      body: IndexedStack(
        index: _currentIndex,
        children: [
          AdminDashboardScreen(onNavigate: switchTab),
          const ManageServicesScreen(),
          const ManageBookingsScreen(),
          const QueueControlScreen(),
          const ReportsScreen(),
        ],
      ),
      bottomNavigationBar: AppBottomNav(
        currentIndex: _currentIndex,
        onTap: switchTab,
        items: _navItems,
      ),
    );
  }
}
