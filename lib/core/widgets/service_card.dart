import 'package:flutter/material.dart';
import 'package:washgo/core/constants/app_colors.dart';
import 'package:washgo/core/constants/app_text_styles.dart';
import 'package:washgo/core/widgets/custom_button.dart';
import 'package:washgo/models/service_model.dart';

class ServiceCard extends StatelessWidget {
  final ServiceModel service;
  final VoidCallback? onBookNow;
  final bool showBookButton;

  const ServiceCard({
    super.key,
    required this.service,
    this.onBookNow,
    this.showBookButton = true,
  });

  IconData _iconForCategory(String category) {
    switch (category.toLowerCase()) {
      case 'basic':
        return Icons.local_car_wash_outlined;
      case 'premium':
        return Icons.auto_awesome_outlined;
      case 'interior':
        return Icons.airline_seat_recline_normal_outlined;
      case 'detailing':
        return Icons.cleaning_services_outlined;
      default:
        return Icons.directions_car_outlined;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.cardDark,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 52,
                height: 52,
                decoration: BoxDecoration(
                  gradient: AppColors.primaryGradient,
                  borderRadius: BorderRadius.circular(14),
                  boxShadow: AppColors.glowShadow(blur: 12),
                ),
                child: Icon(
                  _iconForCategory(service.category),
                  color: AppColors.textLight,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            service.name,
                            style: AppTextStyles.title.copyWith(fontSize: 17),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        const SizedBox(width: 8),
                        _CategoryBadge(category: service.category),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Text(
                      service.description,
                      style: AppTextStyles.caption.copyWith(
                        color: AppColors.textLight.withValues(alpha: 0.7),
                        height: 1.35,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _InfoChip(
                icon: Icons.payments_outlined,
                label: '₱${service.price.toStringAsFixed(0)}',
                highlight: true,
              ),
              _InfoChip(
                icon: Icons.schedule_outlined,
                label: '${service.durationMinutes} min',
              ),
              _InfoChip(
                icon: Icons.directions_car_outlined,
                label: service.vehicleType,
              ),
            ],
          ),
          if (showBookButton && onBookNow != null) ...[
            const SizedBox(height: 16),
            CustomButton(
              text: 'Book Now',
              icon: Icons.calendar_today_outlined,
              onPressed: onBookNow,
            ),
          ],
        ],
      ),
    );
  }
}

class _CategoryBadge extends StatelessWidget {
  final String category;

  const _CategoryBadge({required this.category});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: AppColors.aquaBlue.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.cyan.withValues(alpha: 0.35)),
      ),
      child: Text(
        category,
        style: AppTextStyles.caption.copyWith(
          fontSize: 10,
          color: AppColors.cyan,
          fontWeight: FontWeight.w600,
          letterSpacing: 0.3,
        ),
      ),
    );
  }
}

class _InfoChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool highlight;

  const _InfoChip({
    required this.icon,
    required this.label,
    this.highlight = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: const BoxConstraints(maxWidth: 200),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: highlight
            ? AppColors.aquaBlue.withValues(alpha: 0.15)
            : AppColors.midnightBlue,
        borderRadius: BorderRadius.circular(8),
        border: highlight
            ? Border.all(color: AppColors.cyan.withValues(alpha: 0.25))
            : null,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 13,
            color: highlight ? AppColors.limeAccent : AppColors.cyan,
          ),
          const SizedBox(width: 5),
          Text(
            label,
            style: AppTextStyles.caption.copyWith(
              fontSize: 11,
              color: highlight ? AppColors.cyan : AppColors.textLight.withValues(alpha: 0.85),
              fontWeight: highlight ? FontWeight.w600 : FontWeight.w400,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}
