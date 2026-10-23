
import 'package:sqflite/sqflite.dart';

import '../models/user_model.dart';
import 'database_helper.dart';

class UserDAO {
  final DatabaseHelper _dbHelper = DatabaseHelper();

  Future<void> insertUser(UserModel user) async {
    final db = await _dbHelper.database;

    await db.insert(
      'users',
      user.toMap(),
      conflictAlgorithm: ConflictAlgorithm.fail,
    );
  }

  Future<UserModel?> getUserByEmail(
    String email,
  ) async {
    final db = await _dbHelper.database;

    final results = await db.query(
      'users',
      where: 'LOWER(email) = ?',
      whereArgs: [email.trim().toLowerCase()],
      limit: 1,
    );

    if (results.isEmpty) {
      return null;
    }

    return UserModel.fromMap(results.first);
  }

  Future<bool> updatePassword(
    String email,
    String newPassword,
  ) async {
    final db = await _dbHelper.database;

    final rowsAffected = await db.update(
      'users',
      {'password': newPassword},
      where: 'LOWER(email) = ?',
      whereArgs: [email.trim().toLowerCase()],
    );

    return rowsAffected > 0;
  }
}
