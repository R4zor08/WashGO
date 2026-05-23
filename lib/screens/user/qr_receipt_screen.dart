import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:washgo/core/constants/app_colors.dart';
import 'package:washgo/core/constants/app_text_styles.dart';
import 'package:washgo/core/state/app_state.dart';
import 'package:washgo/core/widgets/app_scaffold.dart';
import 'package:washgo/core/widgets/custom_button.dart';
import 'package:washgo/core/widgets/status_badge.dart';
import 'package:washgo/models/booking_model.dart';

class QRReceiptScreen extends StatelessWidget {
  final BookingModel booking;

  const QRReceiptScreen({super.key, required this.booking});

  @override
  Widget build(BuildContext context) {
    final qrData = context.read<AppState>().qrPayloadForBooking(booking);

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: AppColors.screenBackgroundGradient,
        ),
        child: SafeArea(
          child: Column(
            children: [
              _buildHeader(context),
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
                  child: _ReceiptTicket(booking: booking, qrData: qrData),
                ),
              ),
              _buildActionBar(context),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(4, 4, 16, 4),
      child: Row(
        children: [
          IconButton(
            onPressed: () => Navigator.pop(context),
            icon: const Icon(Icons.arrow_back_ios_new, color: AppColors.textLight, size: 20),
          ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Booking Receipt', style: AppTextStyles.title),
                const SizedBox(height: 2),
                Text(
                  'Show this QR at check-in',
                  style: AppTextStyles.subtitle.copyWith(fontSize: 13),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionBar(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
      decoration: BoxDecoration(
        color: AppColors.cardDark.withValues(alpha: 0.95),
        border: Border(top: BorderSide(color: Colors.white.withValues(alpha: 0.08))),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.2),
            blurRadius: 12,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final stackVertically = constraints.maxWidth < 340;

          final download = CustomButton(
            text: 'Download',
            icon: Icons.download_outlined,
            style: CustomButtonStyle.secondary,
            compact: true,
            onPressed: () => _showSnack(
              context,
              'Receipt download is not available in Phase 1.',
            ),
          );

          final share = CustomButton(
            text: 'Share',
            icon: Icons.share_outlined,
            compact: true,
            onPressed: () => _showSnack(
              context,
              'Share feature coming in a future phase.',
            ),
          );

          if (stackVertically) {
            return Column(
              children: [
                download,
                const SizedBox(height: 8),
                share,
              ],
            );
          }

          return Row(
            children: [
              Expanded(child: download),
              const SizedBox(width: 8),
              Expanded(child: share),
            ],
          );
        },
      ),
    );
  }

  void _showSnack(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: AppColors.cardDark,
      ),
    );
  }
}

class _ReceiptTicket extends StatelessWidget {
  final BookingModel booking;
  final String qrData;

  const _ReceiptTicket({required this.booking, required this.qrData});

  @override
  Widget build(BuildContext context) {
    return Container(
        width: double.infinity,
        decoration: BoxDecoration(
          color: AppColors.cardLight,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.15),
              blurRadius: 24,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 28, 24, 20),
              child: Column(
                children: [
                  const WashGoLogo(height: 56),
                  const SizedBox(height: 10),
                  Text(
                    'WashGo Digital Receipt',
                    style: AppTextStyles.titleDark.copyWith(fontSize: 17),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    booking.id,
                    style: AppTextStyles.caption.copyWith(
                      color: AppColors.textSecondary,
                      fontWeight: FontWeight.w500,
                      letterSpacing: 0.3,
                    ),
                  ),
                  const SizedBox(height: 20),
                  const _TicketTearLine(),
                  const SizedBox(height: 20),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppColors.lightBackground,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: AppColors.textSecondary.withValues(alpha: 0.15),
                      ),
                    ),
                    child: SizedBox(
                      width: 168,
                      height: 168,
                      child: QrImageView(
                        data: qrData,
                        version: QrVersions.auto,
                        size: 168,
                        backgroundColor: AppColors.lightBackground,
                        eyeStyle: const QrEyeStyle(
                          eyeShape: QrEyeShape.square,
                          color: AppColors.textPrimary,
                        ),
                        dataModuleStyle: const QrDataModuleStyle(
                          dataModuleShape: QrDataModuleShape.square,
                          color: AppColors.textPrimary,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Scan at the wash bay',
                    style: AppTextStyles.caption.copyWith(
                      color: AppColors.deepBlue,
                      fontWeight: FontWeight.w600,
                      fontSize: 11,
                    ),
                  ),
                  const SizedBox(height: 20),
                  const _TicketTearLine(),
                  const SizedBox(height: 8),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                children: [
                  _ReceiptRow(label: 'Customer', value: booking.userName),
                  _ReceiptRow(label: 'Service', value: booking.serviceName),
                  _ReceiptRow(label: 'Vehicle', value: booking.vehicleType),
                  _ReceiptRow(label: 'Plate No.', value: booking.plateNumber),
                  _ReceiptRow(
                    label: 'Date & Time',
                    value: '${booking.bookingDate} • ${booking.bookingTime}',
                  ),
                  _ReceiptRow(
                    label: 'Queue No.',
                    value: '#${booking.queueNumber}',
                    highlight: true,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 24),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    AppColors.aquaBlue.withValues(alpha: 0.12),
                    AppColors.cyan.withValues(alpha: 0.08),
                  ],
                ),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.aquaBlue.withValues(alpha: 0.25)),
              ),
              child: Row(
                children: [
                  Flexible(
                    child: Text(
                      'Total Amount',
                      style: AppTextStyles.bodyDark.copyWith(
                        fontWeight: FontWeight.w600,
                        fontSize: 15,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    '₱${booking.price.toStringAsFixed(0)}',
                    style: AppTextStyles.titleDark.copyWith(
                      fontSize: 22,
                      color: AppColors.deepBlue,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 14),
              decoration: BoxDecoration(
                color: AppColors.lightBackground,
                border: Border(
                  top: BorderSide(color: AppColors.textSecondary.withValues(alpha: 0.2)),
                ),
              ),
              child: Center(child: StatusBadge(status: booking.status)),
            ),
          ],
        ),
    );
  }
}

class _ReceiptRow extends StatelessWidget {
  final String label;
  final String value;
  final bool highlight;

  const _ReceiptRow({
    required this.label,
    required this.value,
    this.highlight = false,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 2,
            child: Text(
              label,
              style: AppTextStyles.caption.copyWith(
                color: AppColors.textSecondary,
                fontSize: 13,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Expanded(
            flex: 3,
            child: Text(
              value,
              style: highlight
                  ? AppTextStyles.titleDark.copyWith(
                      color: AppColors.deepBlue,
                      fontSize: 15,
                    )
                  : AppTextStyles.bodyDark.copyWith(fontSize: 14, height: 1.3),
              textAlign: TextAlign.right,
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}

/// Horizontal perforation line between receipt sections.
class _TicketTearLine extends StatelessWidget {
  const _TicketTearLine();

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final lineWidth = constraints.maxWidth;
        if (!lineWidth.isFinite || lineWidth <= 0) {
          return const SizedBox(height: 1);
        }
        return CustomPaint(
          size: Size(lineWidth, 1),
          painter: _DashedLinePainter(),
        );
      },
    );
  }
}

class _DashedLinePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = AppColors.textSecondary.withValues(alpha: 0.35)
      ..strokeWidth = 1;
    const dashWidth = 5.0;
    const dashSpace = 4.0;
    double x = 0;
    while (x < size.width) {
      canvas.drawLine(Offset(x, 0), Offset(x + dashWidth, 0), paint);
      x += dashWidth + dashSpace;
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
