import 'package:washgo/core/database/database_helper.dart';
import 'package:washgo/models/user_model.dart';

/// Plain text passwords are used only for demo purposes.
/// In production, passwords must be securely hashed.
class AuthRepository {
  final DatabaseHelper _db = DatabaseHelper.instance;

  Future<UserModel?> login(String email, String password) async {
    final db = await _db.database;
    final rows = await db.query(
      'users',
      where: 'LOWER(email) = ? AND password = ?',
      whereArgs: [email.trim().toLowerCase(), password],
      limit: 1,
    );
    if (rows.isEmpty) return null;
    return UserModel.fromMap(rows.first);
  }

  Future<UserModel> register(UserModel user) async {
    final db = await _db.database;
    await db.insert('users', user.toMap());
    return user;
  }

  Future<bool> emailExists(String email) async {
    final db = await _db.database;
    final rows = await db.query(
      'users',
      where: 'LOWER(email) = ?',
      whereArgs: [email.trim().toLowerCase()],
      limit: 1,
    );
    return rows.isNotEmpty;
  }

  Future<bool> emailExistsForOtherUser(String email, String userId) async {
    final db = await _db.database;
    final rows = await db.query(
      'users',
      where: 'LOWER(email) = ? AND id != ?',
      whereArgs: [email.trim().toLowerCase(), userId],
      limit: 1,
    );
    return rows.isNotEmpty;
  }

  Future<List<UserModel>> getUsers() async {
    final db = await _db.database;
    final rows = await db.query('users', orderBy: 'created_at ASC');
    return rows.map(UserModel.fromMap).toList();
  }

  Future<UserModel?> getUserById(String id) async {
    final db = await _db.database;
    final rows = await db.query('users', where: 'id = ?', whereArgs: [id], limit: 1);
    if (rows.isEmpty) return null;
    return UserModel.fromMap(rows.first);
  }

  Future<UserModel?> getUserByEmail(String email) async {
    final db = await _db.database;
    final rows = await db.query(
      'users',
      where: 'LOWER(email) = ?',
      whereArgs: [email.trim().toLowerCase()],
      limit: 1,
    );
    if (rows.isEmpty) return null;
    return UserModel.fromMap(rows.first);
  }

  Future<void> updateUser(UserModel user) async {
    final db = await _db.database;
    await db.update('users', user.toMap(), where: 'id = ?', whereArgs: [user.id]);
  }
}
