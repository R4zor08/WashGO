import 'package:flutter/material.dart';
import 'package:washgo/core/constants/app_colors.dart';
import 'package:washgo/core/constants/app_text_styles.dart';
import 'package:washgo/core/widgets/app_scaffold.dart';

class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});

  static const _features = [
  'Browse and book car wash services',
  'Track your queue in real time',
  'View booking history and QR receipts',
  'Premium wash packages and detailing',
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: AppColors.screenBackgroundGradient,
        ),
        child: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                child: Row(
                  children: [
                    IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: const Icon(Icons.arrow_back_ios_new, color: AppColors.textLight),
                    ),
                    Text('About WashGo', style: AppTextStyles.title),
                  ],
                ),
              ),
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(24),
                        decoration: BoxDecoration(
                          color: AppColors.cardDark,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
                        ),
                        child: Column(
                          children: [
                            const WashGoLogo(height: 80),
                            const SizedBox(height: 16),
                            Text('WashGo', style: AppTextStyles.headline.copyWith(fontSize: 28)),
                            const SizedBox(height: 4),
                            Text(
                              'Book. Wash. Go.',
                              style: AppTextStyles.subtitle.copyWith(color: AppColors.cyan),
                            ),
                            const SizedBox(height: 8),
                            Text('Version 1.0.0', style: AppTextStyles.caption),
                          ],
                        ),
                      ),
                      const SizedBox(height: 20),
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: AppColors.cardDark,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('About', style: AppTextStyles.title.copyWith(fontSize: 16)),
                            const SizedBox(height: 8),
                            Text(
                              'WashGo is a car wash booking and queue management system. '
                              'Book your wash, track your queue, and get back on the road faster.',
                              style: AppTextStyles.body.copyWith(fontSize: 14, height: 1.5),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: AppColors.cardDark,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Features', style: AppTextStyles.title.copyWith(fontSize: 16)),
                            const SizedBox(height: 12),
                            ..._features.map(
                              (f) => Padding(
                                padding: const EdgeInsets.symmetric(vertical: 6),
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Icon(Icons.check_circle_outline, color: AppColors.cyan, size: 18),
                                    const SizedBox(width: 10),
                                    Expanded(
                                      child: Text(f, style: AppTextStyles.body.copyWith(fontSize: 14)),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
