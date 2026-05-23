import 'package:washgo/core/constants/booking_status.dart';
import 'package:washgo/core/database/database_helper.dart';
import 'package:washgo/models/booking_model.dart';

class BookingRepository {
  final DatabaseHelper _db = DatabaseHelper.instance;

  Future<List<BookingModel>> getAllBookings() async {
    final db = await _db.database;
    final rows = await db.query('bookings', orderBy: 'created_at DESC');
    return rows.map(BookingModel.fromMap).toList();
  }

  Future<List<BookingModel>> getBookingsByUserId(String userId) async {
    final db = await _db.database;
    final rows = await db.query(
      'bookings',
      where: 'user_id = ?',
      whereArgs: [userId],
      orderBy: 'created_at DESC',
    );
    return rows.map(BookingModel.fromMap).toList();
  }

  Future<BookingModel?> getBookingById(String bookingId) async {
    final db = await _db.database;
    final rows = await db.query(
      'bookings',
      where: 'id = ?',
      whereArgs: [bookingId],
      limit: 1,
    );
    if (rows.isEmpty) return null;
    return BookingModel.fromMap(rows.first);
  }

  Future<BookingModel> createBooking(BookingModel booking) async {
    final db = await _db.database;
    await db.insert('bookings', booking.toMap());
    return booking;
  }

  Future<void> updateBooking(BookingModel booking) async {
    final db = await _db.database;
    await db.update(
      'bookings',
      booking.toMap(),
      where: 'id = ?',
      whereArgs: [booking.id],
    );
  }

  Future<void> updateBookingStatus(String bookingId, String status) async {
    final db = await _db.database;
    await db.update(
      'bookings',
      {
        'status': status,
        'updated_at': DateTime.now().toIso8601String(),
      },
      where: 'id = ?',
      whereArgs: [bookingId],
    );
  }

  Future<void> updateUserNameForUserId(String userId, String userName) async {
    final db = await _db.database;
    await db.update(
      'bookings',
      {'user_name': userName},
      where: 'user_id = ?',
      whereArgs: [userId],
    );
  }

  Future<void> deleteBooking(String bookingId) async {
    final db = await _db.database;
    await db.delete('bookings', where: 'id = ?', whereArgs: [bookingId]);
  }

  Future<int> getNextQueueNumber() async {
    final db = await _db.database;
    final result = await db.rawQuery(
      'SELECT MAX(queue_number) as max_q FROM bookings',
    );
    final max = result.first['max_q'] as int?;
    return (max ?? 0) + 1;
  }

  Future<BookingModel?> getActiveBookingByUserId(String userId) async {
    final db = await _db.database;
    final rows = await db.query(
      'bookings',
      where:
          'user_id = ? AND status NOT IN (?, ?)',
      whereArgs: [userId, BookingStatus.completed, BookingStatus.cancelled],
      orderBy: 'created_at DESC',
      limit: 1,
    );
    if (rows.isEmpty) return null;
    return BookingModel.fromMap(rows.first);
  }

  Future<List<BookingModel>> getPendingQueue() async {
    final db = await _db.database;
    final rows = await db.query(
      'bookings',
      where: 'status = ?',
      whereArgs: [BookingStatus.pending],
      orderBy: 'queue_number ASC',
    );
    return rows.map(BookingModel.fromMap).toList();
  }

  Future<BookingModel?> getCurrentWashingBooking() async {
    final db = await _db.database;
    final rows = await db.query(
      'bookings',
      where: 'status = ?',
      whereArgs: [BookingStatus.washing],
      orderBy: 'queue_number ASC',
      limit: 1,
    );
    if (rows.isEmpty) return null;
    return BookingModel.fromMap(rows.first);
  }
}
