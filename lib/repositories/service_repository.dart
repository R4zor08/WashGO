import 'package:washgo/core/database/database_helper.dart';
import 'package:washgo/models/service_model.dart';

class ServiceRepository {
  final DatabaseHelper _db = DatabaseHelper.instance;

  Future<List<ServiceModel>> getServices() async {
    final db = await _db.database;
    final rows = await db.query('services', orderBy: 'name ASC');
    return rows.map(ServiceModel.fromMap).toList();
  }

  Future<ServiceModel> addService(ServiceModel service) async {
    final db = await _db.database;
    await db.insert('services', service.toMap());
    return service;
  }

  Future<void> updateService(ServiceModel service) async {
    final db = await _db.database;
    await db.update(
      'services',
      service.toMap(),
      where: 'id = ?',
      whereArgs: [service.id],
    );
  }

  Future<void> deleteService(String serviceId) async {
    final db = await _db.database;
    await db.delete('services', where: 'id = ?', whereArgs: [serviceId]);
  }

  Future<ServiceModel?> getServiceById(String serviceId) async {
    final db = await _db.database;
    final rows = await db.query(
      'services',
      where: 'id = ?',
      whereArgs: [serviceId],
      limit: 1,
    );
    if (rows.isEmpty) return null;
    return ServiceModel.fromMap(rows.first);
  }
}
