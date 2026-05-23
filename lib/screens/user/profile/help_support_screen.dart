import 'package:flutter/material.dart';
import 'package:washgo/core/constants/app_colors.dart';
import 'package:washgo/core/constants/app_text_styles.dart';
import 'package:washgo/core/widgets/custom_button.dart';

class HelpSupportScreen extends StatelessWidget {
  const HelpSupportScreen({super.key});

  static const _faqs = [
    (
      'How do I book a car wash?',
      'Go to Services, choose a package, and tap Book Now. Fill in your vehicle details and confirm.',
    ),
    (
      'How does queue tracking work?',
      'After booking, open the Queue tab to see your queue number, estimated wait, and wash progress.',
    ),
    (
      'Can I cancel a booking?',
      'Contact our support team or ask an admin to update your booking status during your visit.',
    ),
    (
      'Where can I find my receipt?',
      'Open History and tap a booking, or use the QR Receipt quick action on your dashboard.',
    ),
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
                    Text('Help & Support', style: AppTextStyles.title),
                  ],
                ),
              ),
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          gradient: AppColors.heroCardGradient,
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Contact Us', style: AppTextStyles.title.copyWith(fontSize: 16)),
                            const SizedBox(height: 12),
                            _ContactRow(icon: Icons.email_outlined, label: 'support@washgo.com'),
                            _ContactRow(icon: Icons.phone_outlined, label: '+63 945 347 7555'),
                            _ContactRow(icon: Icons.schedule_outlined, label: 'Mon–Sat, 8:00 AM – 6:00 PM'),
                          ],
                        ),
                      ),
                      const SizedBox(height: 24),
                      Text('Frequently Asked Questions', style: AppTextStyles.title.copyWith(fontSize: 16)),
                      const SizedBox(height: 12),
                      ..._faqs.map((faq) => _FaqTile(question: faq.$1, answer: faq.$2)),
                      const SizedBox(height: 24),
                      CustomButton(
                        text: 'Report an Issue',
                        icon: Icons.report_outlined,
                        style: CustomButtonStyle.secondary,
                        onPressed: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Issue report submitted. Our team will contact you soon.'),
                            ),
                          );
                        },
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

class _ContactRow extends StatelessWidget {
  final IconData icon;
  final String label;

  const _ContactRow({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Icon(icon, size: 18, color: AppColors.textLight.withValues(alpha: 0.8)),
          const SizedBox(width: 10),
          Text(label, style: AppTextStyles.body.copyWith(fontSize: 14)),
        ],
      ),
    );
  }
}

class _FaqTile extends StatefulWidget {
  final String question;
  final String answer;

  const _FaqTile({required this.question, required this.answer});

  @override
  State<_FaqTile> createState() => _FaqTileState();
}

class _FaqTileState extends State<_FaqTile> {
  bool _expanded = false;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: AppColors.cardDark,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
      ),
      child: Theme(
        data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          tilePadding: const EdgeInsets.symmetric(horizontal: 16),
          title: Text(widget.question, style: AppTextStyles.body.copyWith(fontSize: 14)),
          iconColor: AppColors.cyan,
          collapsedIconColor: AppColors.textSecondary,
          initiallyExpanded: _expanded,
          onExpansionChanged: (v) => setState(() => _expanded = v),
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(widget.answer, style: AppTextStyles.caption),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
