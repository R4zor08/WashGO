import 'package:flutter/foundation.dart';
import 'package:washgo/core/constants/booking_status.dart';
import 'package:washgo/core/services/notification_service.dart';
import 'package:washgo/models/booking_model.dart';
import 'package:washgo/models/profile_notification.dart';
import 'package:washgo/models/service_model.dart';
import 'package:washgo/models/user_model.dart';
import 'package:washgo/repositories/auth_repository.dart';
import 'package:washgo/repositories/booking_repository.dart';
import 'package:washgo/repositories/queue_repository.dart';
import 'package:washgo/repositories/service_repository.dart';

class AppState extends ChangeNotifier {
  final AuthRepository _authRepo = AuthRepository();
  final ServiceRepository _serviceRepo = ServiceRepository();
  final BookingRepository _bookingRepo = BookingRepository();
  final QueueRepository _queueRepo = QueueRepository();
  final NotificationService _notifications = NotificationService.instance;

  UserModel? currentUser;
  List<UserModel> users = [];
  List<ServiceModel> services = [];
  List<BookingModel> bookings = [];
  BookingModel? activeBooking;
  int currentServingQueue = 0;
  List<BookingModel> pendingQueue = [];

  bool isLoading = true;
  String? errorMessage;
  bool notificationsEnabled = true;
  final Set<String> _readNotificationIds = {};

  Future<void> initialize() async {
    isLoading = true;
    errorMessage = null;
    notifyListeners();

    try {
      await loadServices();
      await loadBookings();
      await loadQueue();
      users = await _authRepo.getUsers();
      rebuildQueue();
    } catch (e) {
      errorMessage = 'Failed to load app data.';
      if (kDebugMode) debugPrint('AppState.initialize error: $e');
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<void> loadServices() async {
    services = await _serviceRepo.getServices();
  }

  Future<void> loadBookings() async {
    bookings = await _bookingRepo.getAllBookings();
    rebuildQueue();
  }

  Future<void> loadQueue() async {
    currentServingQueue = await _queueRepo.getCurrentServingQueue();
    activeBooking = await _bookingRepo.getCurrentWashingBooking();
    if (activeBooking != null) {
      currentServingQueue = activeBooking!.queueNumber;
    }
    pendingQueue = await _bookingRepo.getPendingQueue();
  }

  // ——— Auth ———

  Future<bool> loginUser(String email, String password) async {
    errorMessage = null;
    final trimmedEmail = email.trim().toLowerCase();
    if (trimmedEmail.isEmpty) {
      errorMessage = 'Please enter your email.';
      notifyListeners();
      return false;
    }
    if (password.isEmpty) {
      errorMessage = 'Please enter your password.';
      notifyListeners();
      return false;
    }

    try {
      final user = await _authRepo.login(trimmedEmail, password);
      if (user == null) {
        errorMessage = 'Invalid email or password.';
        notifyListeners();
        return false;
      }
      currentUser = user;
      notifyListeners();
      return true;
    } catch (e) {
      errorMessage = 'Login failed. Please try again.';
      if (kDebugMode) debugPrint('loginUser error: $e');
      notifyListeners();
      return false;
    }
  }

  Future<bool> registerUser({
    required String fullName,
    required String email,
    required String password,
  }) async {
    errorMessage = null;
    if (fullName.trim().isEmpty) {
      errorMessage = 'Please enter your full name.';
      notifyListeners();
      return false;
    }
    if (email.trim().isEmpty) {
      errorMessage = 'Please enter your email.';
      notifyListeners();
      return false;
    }
    if (password.isEmpty) {
      errorMessage = 'Please enter a password.';
      notifyListeners();
      return false;
    }

    final trimmedEmail = email.trim().toLowerCase();
    try {
      if (await _authRepo.emailExists(trimmedEmail)) {
        errorMessage = 'This email is already registered.';
        notifyListeners();
        return false;
      }

      final user = UserModel(
        id: 'u${DateTime.now().millisecondsSinceEpoch}',
        fullName: fullName.trim(),
        email: trimmedEmail,
        password: password,
        role: 'user',
        createdAt: DateTime.now(),
      );

      await _authRepo.register(user);
      users = await _authRepo.getUsers();
      currentUser = user;
      notifyListeners();
      return true;
    } catch (e) {
      errorMessage = 'Registration failed. Please try again.';
      if (kDebugMode) debugPrint('registerUser error: $e');
      notifyListeners();
      return false;
    }
  }

  void logout() {
    currentUser = null;
    notifyListeners();
  }

  Future<String?> updateCurrentUserProfile({
    required String fullName,
    required String email,
    String? newPassword,
    String? profileImagePath,
    bool clearProfileImage = false,
  }) async {
    final user = currentUser;
    if (user == null) return 'Not logged in.';

    final trimmedName = fullName.trim();
    final trimmedEmail = email.trim().toLowerCase();
    if (trimmedName.isEmpty) return 'Please enter your full name.';
    if (trimmedEmail.isEmpty) return 'Please enter your email.';

    try {
      if (await _authRepo.emailExistsForOtherUser(trimmedEmail, user.id)) {
        return 'This email is already registered.';
      }

      final updated = user.copyWith(
        fullName: trimmedName,
        email: trimmedEmail,
        password: newPassword != null && newPassword.isNotEmpty ? newPassword : null,
        profileImagePath: profileImagePath,
        clearProfileImage: clearProfileImage,
      );

      await _authRepo.updateUser(updated);
      await _bookingRepo.updateUserNameForUserId(user.id, trimmedName);
      await loadBookings();

      users = await _authRepo.getUsers();
      currentUser = updated;
      notifyListeners();
      return null;
    } catch (e) {
      if (kDebugMode) debugPrint('updateCurrentUserProfile error: $e');
      return 'Failed to update profile.';
    }
  }

  // ——— Bookings ———

  Future<BookingModel?> createBooking({
    required ServiceModel service,
    required String vehicleType,
    required String plateNumber,
    required String bookingDate,
    required String bookingTime,
    String? notes,
  }) async {
    if (currentUser == null) return null;

    try {
      final queueNumber = await _bookingRepo.getNextQueueNumber();
      final now = DateTime.now();
      final booking = BookingModel(
        id: 'WG-${now.millisecondsSinceEpoch}',
        userId: currentUser!.id,
        userName: currentUser!.fullName,
        serviceId: service.id,
        serviceName: service.name,
        vehicleType: vehicleType,
        plateNumber: plateNumber.trim(),
        bookingDate: bookingDate,
        bookingTime: bookingTime,
        queueNumber: queueNumber,
        status: BookingStatus.pending,
        price: service.price,
        notes: (notes == null || notes.trim().isEmpty) ? null : notes.trim(),
        createdAt: now,
      );

      await _bookingRepo.createBooking(booking);
      await loadBookings();
      await _notifications.showBookingCreatedNotification(booking);
      notifyListeners();
      return booking;
    } catch (e) {
      errorMessage = 'Failed to create booking.';
      if (kDebugMode) debugPrint('createBooking error: $e');
      notifyListeners();
      return null;
    }
  }

  Future<void> updateBookingStatus(String bookingId, String newStatus) async {
    try {
      await _bookingRepo.updateBookingStatus(bookingId, newStatus);
      await loadBookings();
      await loadQueue();

      final booking = getBookingById(bookingId);
      if (booking != null) {
        await _notifications.showStatusUpdatedNotification(booking);
      }
      notifyListeners();
    } catch (e) {
      errorMessage = 'Failed to update booking status.';
      if (kDebugMode) debugPrint('updateBookingStatus error: $e');
      notifyListeners();
    }
  }

  List<BookingModel> getBookingsForCurrentUser() {
    if (currentUser == null) return [];
    return bookings.where((b) => b.userId == currentUser!.id).toList()
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
  }

  BookingModel? getActiveBookingForCurrentUser() {
    if (currentUser == null) return null;
    final userBookings = getBookingsForCurrentUser();
    for (final b in userBookings) {
      if (b.status != BookingStatus.completed &&
          b.status != BookingStatus.cancelled) {
        return b;
      }
    }
    return null;
  }

  BookingModel? getBookingById(String bookingId) {
    try {
      return bookings.firstWhere((b) => b.id == bookingId);
    } catch (_) {
      return null;
    }
  }

  // ——— Queue ———

  void rebuildQueue() {
    pendingQueue = bookings
        .where((b) => b.status == BookingStatus.pending)
        .toList()
      ..sort((a, b) => a.queueNumber.compareTo(b.queueNumber));

    final washing = getCurrentWashingBooking();
    if (washing != null) {
      activeBooking = washing;
      currentServingQueue = washing.queueNumber;
    }
  }

  BookingModel? getCurrentWashingBooking() {
    final washing = bookings
        .where((b) => b.status == BookingStatus.washing)
        .toList()
      ..sort((a, b) => a.queueNumber.compareTo(b.queueNumber));
    return washing.isEmpty ? null : washing.first;
  }

  List<BookingModel> getPendingQueue() => List.unmodifiable(pendingQueue);

  Future<String?> nextCustomer() async {
    try {
      final result = await _queueRepo.nextCustomer();
      await loadBookings();
      await loadQueue();

      if (result == null) {
        activeBooking = null;
        notifyListeners();
        return 'No more customers in the pending queue.';
      }

      await _notifications.showStatusUpdatedNotification(result);
      notifyListeners();
      return null;
    } catch (e) {
      if (kDebugMode) debugPrint('nextCustomer error: $e');
      return 'Failed to advance queue.';
    }
  }

  Future<String?> markCurrentCompleted() async {
    try {
      final result = await _queueRepo.markCurrentCompleted();
      if (result == null) {
        return 'No customer is currently being washed.';
      }

      await loadBookings();
      await loadQueue();
      await _notifications.showStatusUpdatedNotification(result);
      notifyListeners();
      return null;
    } catch (e) {
      if (kDebugMode) debugPrint('markCurrentCompleted error: $e');
      return 'Failed to mark booking completed.';
    }
  }

  int getEstimatedWaitMinutesForUser(BookingModel booking) {
    if (booking.status == BookingStatus.washing) return 0;
    if (booking.status == BookingStatus.completed ||
        booking.status == BookingStatus.cancelled) {
      return 0;
    }

    final pending = getPendingQueue();
    final index = pending.indexWhere((b) => b.id == booking.id);
    if (index < 0) {
      final ahead =
          pending.where((b) => b.queueNumber < booking.queueNumber).length;
      return ahead * 15;
    }
    return (index + 1) * 15;
  }

  String formatEstimatedWait(BookingModel booking) {
    final mins = getEstimatedWaitMinutesForUser(booking);
    if (mins <= 0) {
      if (booking.status == BookingStatus.washing) return 'In progress';
      return '—';
    }
    return '$mins mins';
  }

  // ——— Services ———

  Future<void> addService(ServiceModel service) async {
    try {
      final now = DateTime.now();
      final toAdd = service.copyWith(createdAt: now);
      await _serviceRepo.addService(toAdd);
      await loadServices();
      notifyListeners();
    } catch (e) {
      errorMessage = 'Failed to add service.';
      if (kDebugMode) debugPrint('addService error: $e');
      notifyListeners();
    }
  }

  Future<void> editService(ServiceModel service) async {
    try {
      final updated = service.copyWith(updatedAt: DateTime.now());
      await _serviceRepo.updateService(updated);
      await loadServices();
      notifyListeners();
    } catch (e) {
      errorMessage = 'Failed to update service.';
      if (kDebugMode) debugPrint('editService error: $e');
      notifyListeners();
    }
  }

  Future<void> deleteService(String serviceId) async {
    try {
      await _serviceRepo.deleteService(serviceId);
      await loadServices();
      notifyListeners();
    } catch (e) {
      errorMessage = 'Failed to delete service.';
      if (kDebugMode) debugPrint('deleteService error: $e');
      notifyListeners();
    }
  }

  ServiceModel? getServiceById(String id) {
    try {
      return services.firstWhere((s) => s.id == id);
    } catch (_) {
      return null;
    }
  }

  // ——— Reports / stats ———

  bool _isToday(DateTime date) {
    final now = DateTime.now();
    return date.year == now.year &&
        date.month == now.month &&
        date.day == now.day;
  }

  int get totalBookingsToday =>
      bookings.where((b) => _isToday(b.createdAt)).length;

  int get pendingBookingsCount =>
      bookings.where((b) => b.status == BookingStatus.pending).length;

  int get completedBookingsCount =>
      bookings.where((b) => b.status == BookingStatus.completed).length;

  int get activeQueueCount => bookings
      .where(
        (b) =>
            b.status == BookingStatus.pending ||
            b.status == BookingStatus.washing,
      )
      .length;

  double get estimatedEarnings => bookings
      .where((b) => b.status == BookingStatus.completed)
      .fold(0.0, (sum, b) => sum + b.price);

  List<BookingModel> get recentBookings {
    final sorted = List<BookingModel>.from(bookings)
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return sorted.take(5).toList();
  }

  List<ServiceModel> get availableServices => List.unmodifiable(services);

  List<int> get weeklyBookings {
    final now = DateTime.now();
    return List.generate(7, (i) {
      final day = DateTime(now.year, now.month, now.day - (6 - i));
      return bookings.where((b) {
        final d = b.createdAt;
        return d.year == day.year && d.month == day.month && d.day == day.day;
      }).length;
    });
  }

  String qrPayloadForBooking(BookingModel booking) {
    return [
      'WASHGO',
      'ID:${booking.id}',
      'Customer:${booking.userName}',
      'Service:${booking.serviceName}',
      'Vehicle:${booking.vehicleType}',
      'Plate:${booking.plateNumber}',
      'DateTime:${booking.bookingDate} ${booking.bookingTime}',
      'Queue:#${booking.queueNumber}',
      'Status:${booking.status}',
      'Price:₱${booking.price.toStringAsFixed(0)}',
    ].join('|');
  }

  // ——— Profile ———

  int get currentUserBookingCount => getBookingsForCurrentUser().length;

  int get currentUserCompletedCount => getBookingsForCurrentUser()
      .where((b) => b.status == BookingStatus.completed)
      .length;

  BookingModel? get currentUserActiveBooking => getActiveBookingForCurrentUser();

  String get currentUserActiveStatusLabel {
    final active = currentUserActiveBooking;
    if (active == null) return 'None';
    return active.status;
  }

  void toggleNotifications(bool enabled) {
    notificationsEnabled = enabled;
    notifyListeners();
  }

  void markNotificationRead(String id) {
    _readNotificationIds.add(id);
    notifyListeners();
  }

  int get unreadNotificationCount =>
      profileNotifications.where((n) => !n.isRead).length;

  List<ProfileNotification> get profileNotifications {
    if (currentUser == null) return [];

    final userBookings = getBookingsForCurrentUser().take(5);
    return userBookings.map((b) {
      final id = 'notif-${b.id}';
      String title;
      String message;

      switch (b.status) {
        case BookingStatus.washing:
          title = 'Wash in progress';
          message = 'Your ${b.serviceName} is now being washed.';
        case BookingStatus.completed:
          title = 'Wash completed';
          message = 'Your ${b.serviceName} has been completed. Thank you!';
        case BookingStatus.cancelled:
          title = 'Booking cancelled';
          message = 'Your ${b.serviceName} booking was cancelled.';
        default:
          title = 'Booking confirmed';
          message =
              'Your ${b.serviceName} is queued at #${b.queueNumber}. Est. wait: ${formatEstimatedWait(b)}.';
      }

      return ProfileNotification(
        id: id,
        title: title,
        message: message,
        time: b.updatedAt ?? b.createdAt,
        isRead: _readNotificationIds.contains(id),
      );
    }).toList();
  }
}
