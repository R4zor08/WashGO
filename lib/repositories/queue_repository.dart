import 'package:washgo/core/constants/booking_status.dart';
import 'package:washgo/core/database/database_helper.dart';
import 'package:washgo/models/booking_model.dart';
import 'package:washgo/repositories/booking_repository.dart';

class QueueRepository {
  final DatabaseHelper _db = DatabaseHelper.instance;
  final BookingRepository _bookingRepo = BookingRepository();

  Future<int> getCurrentServingQueue() async {
    final db = await _db.database;
    final rows = await db.query('queue_settings', where: 'id = ?', whereArgs: [1], limit: 1);
    if (rows.isEmpty) return 0;
    return rows.first['current_serving_queue'] as int;
  }

  Future<void> updateCurrentServingQueue(int queueNumber) async {
    final db = await _db.database;
    await db.update(
      'queue_settings',
      {
        'current_serving_queue': queueNumber,
        'updated_at': DateTime.now().toIso8601String(),
      },
      where: 'id = ?',
      whereArgs: [1],
    );
  }

  Future<void> resetQueueIfNeeded() async {
    final pending = await _bookingRepo.getPendingQueue();
    final washing = await _bookingRepo.getCurrentWashingBooking();
    if (pending.isEmpty && washing == null) {
      await updateCurrentServingQueue(0);
    }
  }

  Future<BookingModel?> nextCustomer() async {
    final db = await _db.database;

    return db.transaction<BookingModel?>((txn) async {
      final washingRows = await txn.query(
        'bookings',
        where: 'status = ?',
        whereArgs: [BookingStatus.washing],
        orderBy: 'queue_number ASC',
        limit: 1,
      );

      if (washingRows.isNotEmpty) {
        final currentId = washingRows.first['id'] as String;
        await txn.update(
          'bookings',
          {
            'status': BookingStatus.completed,
            'updated_at': DateTime.now().toIso8601String(),
          },
          where: 'id = ?',
          whereArgs: [currentId],
        );
      }

      final pendingRows = await txn.query(
        'bookings',
        where: 'status = ?',
        whereArgs: [BookingStatus.pending],
        orderBy: 'queue_number ASC',
        limit: 1,
      );

      if (pendingRows.isEmpty) return null;

      final nextId = pendingRows.first['id'] as String;
      final queueNum = pendingRows.first['queue_number'] as int;
      final now = DateTime.now().toIso8601String();

      await txn.update(
        'bookings',
        {'status': BookingStatus.washing, 'updated_at': now},
        where: 'id = ?',
        whereArgs: [nextId],
      );

      await txn.update(
        'queue_settings',
        {
          'current_serving_queue': queueNum,
          'updated_at': now,
        },
        where: 'id = ?',
        whereArgs: [1],
      );

      final updated = await txn.query(
        'bookings',
        where: 'id = ?',
        whereArgs: [nextId],
        limit: 1,
      );
      return BookingModel.fromMap(updated.first);
    });
  }

  Future<BookingModel?> markCurrentCompleted() async {
    final washing = await _bookingRepo.getCurrentWashingBooking();
    if (washing == null) return null;

    final db = await _db.database;
    await db.update(
      'bookings',
      {
        'status': BookingStatus.completed,
        'updated_at': DateTime.now().toIso8601String(),
      },
      where: 'id = ?',
      whereArgs: [washing.id],
    );

    return washing.copyWith(
      status: BookingStatus.completed,
      updatedAt: DateTime.now(),
    );
  }
}
