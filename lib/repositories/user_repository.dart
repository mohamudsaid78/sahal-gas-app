import 'dart:convert';

import 'package:crypto/crypto.dart';

import '../core/enums.dart';
import '../database/database_helper.dart';
import '../models/gas_user.dart';

class UserRepository {
  Future<void> createUser({
    required String name,
    required String username,
    required String phone,
    required String password,
    required UserRole role,
    required String address,
  }) async {
    final normalizedUsername = username.trim();
    final normalizedPhone = phone.trim();
    final existing = await DatabaseHelper.query(
      'SELECT id FROM users WHERE username = ${DatabaseHelper.sqlValue(normalizedUsername)} '
      'OR phone = ${DatabaseHelper.sqlValue(normalizedPhone)} LIMIT 1',
    );
    if (existing.isNotEmpty) {
      throw Exception('Username or phone number already exists.');
    }

    await DatabaseHelper.insertTableRow('users', {
      'full_name': name.trim(),
      'username': normalizedUsername,
      'phone': normalizedPhone,
      'password_hash': _hash(password),
      'role': role.databaseValue,
      'address': address.trim(),
      'is_active': 1,
      'created_at': DateTime.now().toIso8601String(),
    });
  }

  Future<List<GasUser>> fetchUsers({UserRole? role, String search = ''}) async {
    final filters = <String>[];
    if (role != null) {
      filters.add('role = ${DatabaseHelper.sqlValue(role.databaseValue)}');
    }
    if (search.trim().isNotEmpty) {
      final term = '%${search.trim()}%';
      filters.add(
        '(full_name LIKE ${DatabaseHelper.sqlValue(term)} '
        'OR username LIKE ${DatabaseHelper.sqlValue(term)} '
        'OR phone LIKE ${DatabaseHelper.sqlValue(term)})',
      );
    }
    final where = filters.isEmpty ? '' : 'WHERE ${filters.join(' AND ')}';
    final rows = await DatabaseHelper.query(
      'SELECT id, full_name, username, phone, role, address, is_active, created_at '
      'FROM users $where ORDER BY created_at DESC, id DESC',
    );
    return rows.map(GasUser.fromRow).toList();
  }

  Future<List<GasUser>> fetchDrivers() {
    return fetchUsers(role: UserRole.driver);
  }

  Future<void> updateRole(String userId, UserRole role) async {
    await DatabaseHelper.updateTableRow(
      'UPDATE users SET role = ${DatabaseHelper.sqlValue(role.databaseValue)} '
      'WHERE id = ${DatabaseHelper.sqlValue(userId)}',
    );
  }

  Future<void> updateActive(String userId, bool active) async {
    await DatabaseHelper.updateTableRow(
      'UPDATE users SET is_active = ${active ? 1 : 0} '
      'WHERE id = ${DatabaseHelper.sqlValue(userId)}',
    );
  }

  Future<GasUser?> fetchUserById(String userId) async {
    final rows = await DatabaseHelper.query(
      'SELECT id, full_name, username, phone, role, address, is_active, created_at '
      'FROM users WHERE id = ${DatabaseHelper.sqlValue(userId)} LIMIT 1',
    );
    if (rows.isEmpty) return null;
    return GasUser.fromRow(rows.first);
  }

  Future<void> deleteUser(String userId) async {
    await DatabaseHelper.deleteTableRow(
      'DELETE FROM users WHERE id = ${DatabaseHelper.sqlValue(userId)}',
    );
  }

  Future<void> updateProfile({
    required String userId,
    required String name,
    required String phone,
    required String address,
  }) async {
    await DatabaseHelper.updateTableRow(
      'UPDATE users SET '
      'full_name = ${DatabaseHelper.sqlValue(name)}, '
      'phone = ${DatabaseHelper.sqlValue(phone)}, '
      'address = ${DatabaseHelper.sqlValue(address)} '
      'WHERE id = ${DatabaseHelper.sqlValue(userId)}',
    );
  }

  String _hash(String value) {
    return sha256.convert(utf8.encode(value)).toString();
  }
}
