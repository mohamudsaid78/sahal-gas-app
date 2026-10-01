import '../core/enums.dart';
import '../core/row_reader.dart';

class GasUser {
  const GasUser({
    required this.id,
    required this.name,
    required this.username,
    required this.phone,
    required this.role,
    required this.active,
    this.address = '',
    this.createdAt,
  });

  final String id;
  final String name;
  final String username;
  final String phone;
  final UserRole role;
  final bool active;
  final String address;
  final DateTime? createdAt;

  factory GasUser.fromRow(Map<String, dynamic> row) {
    return GasUser(
      id: RowReader.text(row, ['user_id', 'id']),
      name: RowReader.text(row, ['full_name', 'name', 'username']),
      username: RowReader.text(row, ['username', 'user_name']),
      phone: RowReader.text(row, ['phone', 'mobile']),
      role: UserRole.fromValue(RowReader.text(row, ['role'], fallback: 'customer')),
      active: RowReader.boolean(row, ['is_active', 'active', 'status']),
      address: RowReader.text(row, ['address', 'delivery_address']),
      createdAt: RowReader.date(row, ['created_at', 'created']),
    );
  }

  Map<String, dynamic> toInsertMap({required String passwordHash}) {
    return {
      'full_name': name,
      'username': username,
      'phone': phone,
      'password_hash': passwordHash,
      'role': role.databaseValue,
      'address': address,
      'is_active': active ? 1 : 0,
      'created_at': DateTime.now().toIso8601String(),
    };
  }
}
