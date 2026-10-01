import 'dart:convert';

import 'package:crypto/crypto.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../core/enums.dart';
import '../database/database_helper.dart';
import '../models/gas_user.dart';

class AuthRepository {
  static const _sessionUserIdKey = 'sahal_gas_user_id';

  Future<GasUser?> restoreSession() async {
    final prefs = await SharedPreferences.getInstance();
    final userId = prefs.getString(_sessionUserIdKey);
    if (userId == null || userId.isEmpty) return null;
    return fetchUserById(userId);
  }

  Future<GasUser> signIn({
    required String username,
    required String password,
  }) async {
    final rows = await DatabaseHelper.query(
      'SELECT id, full_name, username, phone, role, address, is_active, created_at '
      'FROM users '
      'WHERE username = ${DatabaseHelper.sqlValue(username.trim())} '
      'AND password_hash = ${DatabaseHelper.sqlValue(_hash(password))} '
      'LIMIT 1',
    );
    if (rows.isEmpty) {
      throw Exception('Invalid username or password.');
    }
    final user = GasUser.fromRow(rows.first);
    if (!user.active) {
      throw Exception('This account is disabled. Contact the admin.');
    }
    await _saveSession(user.id);
    return user;
  }

  Future<GasUser> signUp({
    required String name,
    required String username,
    required String phone,
    required String password,
    String address = '',
  }) async {
    final existing = await DatabaseHelper.query(
      'SELECT id FROM users WHERE username = ${DatabaseHelper.sqlValue(username.trim())} LIMIT 1',
    );
    if (existing.isNotEmpty) {
      throw Exception('An account with this username already exists.');
    }

    final user = GasUser(
      id: '',
      name: name.trim(),
      username: username.trim(),
      phone: phone.trim(),
      role: UserRole.customer,
      active: true,
      address: address.trim(),
    );
    await DatabaseHelper.insertTableRow(
      'users',
      user.toInsertMap(passwordHash: _hash(password)),
    );
    return signIn(username: username, password: password);
  }

  Future<GasUser?> fetchUserById(String userId) async {
    final rows = await DatabaseHelper.query(
      'SELECT id, full_name, username, phone, role, address, is_active, created_at '
      'FROM users WHERE id = ${DatabaseHelper.sqlValue(userId)} LIMIT 1',
    );
    if (rows.isEmpty) return null;
    final user = GasUser.fromRow(rows.first);
    return user.active ? user : null;
  }

  Future<void> changePassword({
    required String userId,
    required String currentPassword,
    required String newPassword,
  }) async {
    final rows = await DatabaseHelper.query(
      'SELECT id FROM users '
      'WHERE id = ${DatabaseHelper.sqlValue(userId)} '
      'AND password_hash = ${DatabaseHelper.sqlValue(_hash(currentPassword))} '
      'LIMIT 1',
    );
    if (rows.isEmpty) {
      throw Exception('Current password is incorrect.');
    }

    await DatabaseHelper.updateTableRow(
      'UPDATE users SET password_hash = '
      '${DatabaseHelper.sqlValue(_hash(newPassword))} '
      'WHERE id = ${DatabaseHelper.sqlValue(userId)}',
    );
  }

  Future<void> signOut() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_sessionUserIdKey);
  }

  Future<void> _saveSession(String userId) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_sessionUserIdKey, userId);
  }

  String _hash(String value) {
    return sha256.convert(utf8.encode(value)).toString();
  }
}
