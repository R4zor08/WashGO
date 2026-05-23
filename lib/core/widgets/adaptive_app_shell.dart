import 'package:flutter/material.dart';
import 'package:washgo/core/constants/app_colors.dart';
import 'package:washgo/core/constants/app_text_styles.dart';
import 'package:washgo/core/layout/responsive_layout.dart';
import 'package:washgo/core/widgets/app_bottom_nav.dart';
import 'package:washgo/core/widgets/app_scaffold.dart';
import 'package:washgo/core/widgets/responsive_content.dart';

class AdaptiveAppShell extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTabChanged;
  final List<AppBottomNavItem> navItems;
  final List<Widget> children;

  const AdaptiveAppShell({
    super.key,
    required this.currentIndex,
    required this.onTabChanged,
    required this.navItems,
    required this.children,
  });

  @override
  Widget build(BuildContext context) {
    if (ResponsiveLayout.isExpanded(context)) {
      return AppScaffold(
        padding: EdgeInsets.zero,
        body: Row(
          children: [
            NavigationRail(
              selectedIndex: currentIndex,
              onDestinationSelected: onTabChanged,
              backgroundColor: AppColors.cardDark,
              indicatorColor: AppColors.aquaBlue.withValues(alpha: 0.25),
              selectedIconTheme: const IconThemeData(color: AppColors.cyan),
              unselectedIconTheme: IconThemeData(
                color: AppColors.textSecondary.withValues(alpha: 0.9),
              ),
              selectedLabelTextStyle: AppTextStyles.caption.copyWith(
                color: AppColors.cyan,
                fontWeight: FontWeight.w600,
              ),
              unselectedLabelTextStyle: AppTextStyles.caption.copyWith(
                color: AppColors.textSecondary,
              ),
              labelType: NavigationRailLabelType.all,
              destinations: [
                for (final item in navItems)
                  NavigationRailDestination(
                    icon: Icon(item.icon),
                    selectedIcon: Icon(item.activeIcon),
                    label: Text(item.label),
                  ),
              ],
            ),
            const VerticalDivider(width: 1, thickness: 1),
            Expanded(
              child: ResponsiveContent(
                size: ContentSize.wide,
                alignTop: true,
                padding: EdgeInsets.zero,
                child: IndexedStack(
                  index: currentIndex,
                  children: children,
                ),
              ),
            ),
          ],
        ),
      );
    }

    return AppScaffold(
      padding: EdgeInsets.zero,
      extendBody: true,
      body: IndexedStack(
        index: currentIndex,
        children: children,
      ),
      bottomNavigationBar: AppBottomNav(
        currentIndex: currentIndex,
        onTap: onTabChanged,
        items: navItems,
      ),
    );
  }
}
