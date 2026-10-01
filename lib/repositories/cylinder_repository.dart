import '../database/database_helper.dart';
import '../models/gas_cylinder.dart';

class CylinderRepository {
  Future<List<GasCylinder>> fetchCylinders({
    bool onlyActive = false,
    String search = '',
  }) async {
    final filters = <String>[];
    if (onlyActive) filters.add('is_active = 1');
    if (search.trim().isNotEmpty) {
      final term = '%${search.trim()}%';
      filters.add(
        '(name LIKE ${DatabaseHelper.sqlValue(term)} '
        'OR description LIKE ${DatabaseHelper.sqlValue(term)})',
      );
    }
    final where = filters.isEmpty ? '' : 'WHERE ${filters.join(' AND ')}';
    final rows = await DatabaseHelper.query(
      'SELECT id, name, size_kg, price, stock, color_hex, description, image_url, '
      'is_active, created_at FROM gas_cylinders $where '
      'ORDER BY size_kg ASC, name ASC',
    );
    return rows.map(GasCylinder.fromRow).toList();
  }

  Future<void> createCylinder(GasCylinder cylinder) async {
    await DatabaseHelper.insertTableRow('gas_cylinders', {
      ...cylinder.toMap(),
      'created_at': DateTime.now().toIso8601String(),
    });
  }

  Future<void> updateCylinder(GasCylinder cylinder) async {
    final values = cylinder.toMap().entries.map((entry) {
      return '${entry.key} = ${DatabaseHelper.sqlValue(entry.value)}';
    }).join(', ');
    await DatabaseHelper.updateTableRow(
      'UPDATE gas_cylinders SET $values '
      'WHERE id = ${DatabaseHelper.sqlValue(cylinder.id)}',
    );
  }

  Future<void> deleteCylinder(String id) async {
    await DatabaseHelper.deleteTableRow(
      'DELETE FROM gas_cylinders WHERE id = ${DatabaseHelper.sqlValue(id)}',
    );
  }

  Future<void> reduceStock(String id, int quantity) async {
    await DatabaseHelper.updateTableRow(
      'UPDATE gas_cylinders SET stock = GREATEST(stock - $quantity, 0) '
      'WHERE id = ${DatabaseHelper.sqlValue(id)}',
    );
  }
}
