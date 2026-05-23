import 'package:flutter/material.dart';
import 'package:washgo/core/widgets/adaptive_app_shell.dart';
import 'package:washgo/core/widgets/app_bottom_nav.dart';
import 'package:washgo/screens/user/booking_history_screen.dart';
import 'package:washgo/screens/user/profile_screen.dart';
import 'package:washgo/screens/user/queue_tracking_screen.dart';
import 'package:washgo/screens/user/services_screen.dart';
import 'package:washgo/screens/user/user_dashboard_screen.dart';

class UserMainScreen extends StatefulWidget {
  final int initialTab;

  const UserMainScreen({super.key, this.initialTab = 0});

  @override
  State<UserMainScreen> createState() => UserMainScreenState();
}

class UserMainScreenState extends State<UserMainScreen> {
  late int _currentIndex;

  static const _navItems = [
    AppBottomNavItem(
      icon: Icons.home_outlined,
      activeIcon: Icons.home,
      label: 'Home',
    ),
    AppBottomNavItem(
      icon: Icons.local_car_wash_outlined,
      activeIcon: Icons.local_car_wash,
      label: 'Services',
    ),
    AppBottomNavItem(
      icon: Icons.queue_outlined,
      activeIcon: Icons.queue,
      label: 'Queue',
    ),
    AppBottomNavItem(
      icon: Icons.history_outlined,
      activeIcon: Icons.history,
      label: 'History',
    ),
    AppBottomNavItem(
      icon: Icons.person_outline,
      activeIcon: Icons.person,
      label: 'Profile',
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
    return AdaptiveAppShell(
      currentIndex: _currentIndex,
      onTabChanged: switchTab,
      navItems: _navItems,
      children: [
        UserDashboardScreen(onNavigate: switchTab),
        const ServicesScreen(),
        const QueueTrackingScreen(),
        const BookingHistoryScreen(),
        ProfileScreen(onNavigateToHistory: () => switchTab(3)),
      ],
    );
  }
}
