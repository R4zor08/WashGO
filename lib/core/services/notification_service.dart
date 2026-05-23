import 'package:flutter/foundation.dart';
import 'package:washgo/models/booking_model.dart';

/// In-app booking events are always stored in SQLite and shown on the
/// Notifications screen. Native OS toasts are disabled on Windows desktop
/// because [flutter_local_notifications] requires extra Visual Studio ATL
/// components to build. Re-enable a platform plugin when targeting mobile.
class NotificationService {
  NotificationService._();
  static final NotificationService instance = NotificationService._();

  bool _initialized = false;

  Future<void> initialize() async {
    _initialized = true;
    if (kDebugMode) {
      debugPrint('NotificationService: using in-app notifications only.');
    }
  }

  Future<void> showBookingCreatedNotification(BookingModel booking) async {
    if (!_initialized) return;
    if (kDebugMode) {
      debugPrint(
        'Notification: Booking created — Queue #${booking.queueNumber}',
      );
    }
  }

  Future<void> showStatusUpdatedNotification(BookingModel booking) async {
    if (!_initialized) return;
    if (kDebugMode) {
      debugPrint('Notification: Booking status — ${booking.status}');
    }
  }
}
