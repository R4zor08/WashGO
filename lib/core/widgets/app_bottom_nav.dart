import 'package:flutter/material.dart';
import 'package:washgo/core/constants/app_colors.dart';
import 'package:washgo/core/constants/app_text_styles.dart';
import 'package:washgo/core/layout/responsive_layout.dart';

class AppBottomNavItem {
  final IconData icon;
  final IconData activeIcon;
  final String label;

  const AppBottomNavItem({
    required this.icon,
    required this.activeIcon,
    required this.label,
  });
}

class AppBottomNav extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;
  final List<AppBottomNavItem> items;

  const AppBottomNav({
    super.key,
    required this.currentIndex,
    required this.onTap,
    required this.items,
  });

  @override
  Widget build(BuildContext context) {
    final showLabels = ResponsiveLayout.showBottomNavLabels(context);
    final hMargin = ResponsiveLayout.horizontalPadding(context);
    final iconSize = showLabels ? 22.0 : 24.0;

    return Container(
      margin: EdgeInsets.fromLTRB(hMargin, 0, hMargin, 16),
      padding: EdgeInsets.symmetric(horizontal: showLabels ? 8 : 4, vertical: 10),
      decoration: BoxDecoration(
        color: AppColors.cardDark,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.3),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: List.generate(items.length, (index) {
          final item = items[index];
          final isActive = currentIndex == index;

          return Expanded(
            child: GestureDetector(
              onTap: () => onTap(index),
              behavior: HitTestBehavior.opaque,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: EdgeInsets.symmetric(vertical: showLabels ? 8 : 10),
                decoration: BoxDecoration(
                  color: isActive
                      ? AppColors.aquaBlue.withValues(alpha: 0.15)
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      isActive ? item.activeIcon : item.icon,
                      color: isActive ? AppColors.cyan : AppColors.textSecondary,
                      size: iconSize,
                    ),
                    if (showLabels) ...[
                      const SizedBox(height: 4),
                      Text(
                        item.label,
                        style: AppTextStyles.caption.copyWith(
                          fontSize: 10,
                          color: isActive ? AppColors.cyan : AppColors.textSecondary,
                          fontWeight:
                              isActive ? FontWeight.w600 : FontWeight.w400,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ],
                ),
              ),
            ),
          );
        }),
      ),
    );
  }
}
