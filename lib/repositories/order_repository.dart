import '../core/enums.dart';
import '../database/database_helper.dart';
import '../models/cart_line.dart';
import '../models/gas_order.dart';

class OrderRepository {
  static const _selectOrders = '''
SELECT
  o.id AS order_id,
  o.order_code,
  o.customer_id,
  o.driver_id,
  o.quantity,
  o.delivery_fee,
  o.total,
  o.status,
  o.delivery_address,
  o.payment_method,
  o.payment_status,
  o.payment_reference,
  o.payment_account,
  o.payment_last4,
  o.payment_paid_at,
  o.created_at,
  c.id AS cylinder_id,
  c.name AS cylinder_name,
  c.size_kg,
  c.price AS cylinder_price,
  c.stock,
  c.color_hex,
  c.description AS cylinder_description,
  c.image_url,
  c.is_active,
  customer.full_name AS customer_name,
  customer.phone AS customer_phone,
  driver.full_name AS driver_name,
  driver.phone AS driver_phone
FROM orders o
LEFT JOIN gas_cylinders c ON c.id = o.cylinder_id
LEFT JOIN users customer ON customer.id = o.customer_id
LEFT JOIN users driver ON driver.id = o.driver_id
''';

  Future<List<GasOrder>> fetchAllOrders() {
    return _fetch('$_selectOrders ORDER BY o.created_at DESC, o.id DESC');
  }

  Future<List<GasOrder>> fetchCustomerOrders(String customerId) {
    return _fetch(
      '$_selectOrders WHERE o.customer_id = ${DatabaseHelper.sqlValue(customerId)} '
      'ORDER BY o.created_at DESC, o.id DESC',
    );
  }

  Future<List<GasOrder>> fetchDriverOrders(String driverId) {
    return _fetch(
      '$_selectOrders WHERE o.driver_id = ${DatabaseHelper.sqlValue(driverId)} '
      'ORDER BY o.created_at DESC, o.id DESC',
    );
  }

  Future<void> createOrders({
    required String customerId,
    required List<CartLine> cart,
    required String deliveryAddress,
    required String paymentMethod,
    required Map<String, dynamic> paymentDetails,
  }) async {
    for (final line in cart) {
      final deliveryFee = 2.0;
      final total = line.subtotal + deliveryFee;
      final orderCode = _newOrderCode();
      await DatabaseHelper.insertTableRow('orders', {
        'order_code': orderCode,
        'customer_id': customerId,
        'driver_id': null,
        'cylinder_id': line.cylinder.id,
        'quantity': line.quantity,
        'delivery_fee': deliveryFee,
        'total': total,
        'status': OrderStatus.placed.databaseValue,
        'delivery_address': deliveryAddress,
        'payment_method': paymentMethod,
        'payment_status': paymentDetails['status'] ?? 'pending',
        'payment_reference': paymentDetails['reference'],
        'payment_account': paymentDetails['account'],
        'payment_last4': paymentDetails['last4'],
        'payment_paid_at': paymentDetails['paidAt'],
        'created_at': DateTime.now().toIso8601String(),
      });
      final orderId = await _findOrderId(orderCode);
      await DatabaseHelper.insertTableRow('notifications', {
        'user_id': customerId,
        'order_id': orderId,
        'title': 'Order placed',
        'message':
            '$orderCode - ${line.cylinder.name} order placed successfully.',
        'is_read': 0,
        'created_at': DateTime.now().toIso8601String(),
      });
      final admins = await DatabaseHelper.query(
        "SELECT id FROM users WHERE role = 'admin' AND is_active = 1",
      );
      for (final admin in admins) {
        final adminId = admin['id']?.toString() ?? '';
        if (adminId.isEmpty) continue;
        await DatabaseHelper.insertTableRow('notifications', {
          'user_id': adminId,
          'order_id': orderId,
          'title': 'New order',
          'message':
              '$orderCode - ${line.cylinder.name} (${line.quantity}) received from customer.',
          'is_read': 0,
          'created_at': DateTime.now().toIso8601String(),
        });
      }
      await DatabaseHelper.updateTableRow(
        'UPDATE gas_cylinders SET stock = GREATEST(stock - ${line.quantity}, 0) '
        'WHERE id = ${DatabaseHelper.sqlValue(line.cylinder.id)}',
      );
    }
  }

  Future<void> updateStatus(String orderId, OrderStatus status) async {
    final currentOrder = await _fetchOrder(orderId);
    if (currentOrder == null) return;
    if (currentOrder.status == status) return;

    if (status == OrderStatus.cancelled &&
        currentOrder.status != OrderStatus.cancelled) {
      await DatabaseHelper.updateTableRow(
        'UPDATE gas_cylinders SET stock = stock + ${currentOrder.quantity} '
        'WHERE id = ${DatabaseHelper.sqlValue(currentOrder.cylinder.id)}',
      );
    }

    await DatabaseHelper.updateTableRow(
      'UPDATE orders SET status = ${DatabaseHelper.sqlValue(status.databaseValue)} '
      'WHERE id = ${DatabaseHelper.sqlValue(orderId)}',
    );
    await DatabaseHelper.insertTableRow('notifications', {
      'user_id': currentOrder.customerId,
      'order_id': orderId,
      'title': 'Order ${status.label.toLowerCase()}',
      'message': '${currentOrder.code} is now ${status.label.toLowerCase()}.',
      'is_read': 0,
      'created_at': DateTime.now().toIso8601String(),
    });
  }

  Future<void> assignDriver(String orderId, String? driverId) async {
    final currentOrder = await _fetchOrder(orderId);
    final previousDriverId = currentOrder?.driverId;
    await DatabaseHelper.updateTableRow(
      'UPDATE orders SET driver_id = ${DatabaseHelper.sqlValue(driverId)} '
      'WHERE id = ${DatabaseHelper.sqlValue(orderId)}',
    );
    if (driverId != null &&
        driverId.trim().isNotEmpty &&
        driverId != previousDriverId &&
        currentOrder != null) {
      await DatabaseHelper.insertTableRow('notifications', {
        'user_id': driverId,
        'order_id': orderId,
        'title': 'New order assigned',
        'message':
            '${currentOrder.code} - ${currentOrder.cylinder.name} (${currentOrder.quantity})',
        'is_read': 0,
        'created_at': DateTime.now().toIso8601String(),
      });
    }
  }

  Future<void> rejectDriverOrder(String orderId, String driverId) async {
    final currentOrder = await _fetchOrder(orderId);
    if (currentOrder == null || currentOrder.driverId != driverId) return;
    if (currentOrder.status != OrderStatus.placed &&
        currentOrder.status != OrderStatus.confirmed) {
      return;
    }

    await DatabaseHelper.updateTableRow(
      "UPDATE orders SET driver_id = NULL, status = 'placed' "
      'WHERE id = ${DatabaseHelper.sqlValue(orderId)} '
      'AND driver_id = ${DatabaseHelper.sqlValue(driverId)}',
    );

    final admins = await DatabaseHelper.query(
      "SELECT id FROM users WHERE role = 'admin' AND is_active = 1",
    );
    for (final admin in admins) {
      final adminId = admin['id']?.toString() ?? '';
      if (adminId.isEmpty) continue;
      await DatabaseHelper.insertTableRow('notifications', {
        'user_id': adminId,
        'order_id': orderId,
        'title': 'Driver rejected order',
        'message': '${currentOrder.code} needs another driver assignment.',
        'is_read': 0,
        'created_at': DateTime.now().toIso8601String(),
      });
    }
  }

  Future<void> acceptDriverOrder(String orderId, String driverId) async {
    final currentOrder = await _fetchOrder(orderId);
    if (currentOrder == null || currentOrder.driverId != driverId) return;
    if (currentOrder.status != OrderStatus.placed &&
        currentOrder.status != OrderStatus.confirmed) {
      return;
    }

    if (currentOrder.status == OrderStatus.placed) {
      await updateStatus(orderId, OrderStatus.confirmed);
      return;
    }

    await DatabaseHelper.insertTableRow('notifications', {
      'user_id': currentOrder.customerId,
      'order_id': orderId,
      'title': 'Driver accepted order',
      'message': '${currentOrder.code} has been accepted for delivery.',
      'is_read': 0,
      'created_at': DateTime.now().toIso8601String(),
    });
  }

  Future<List<GasOrder>> _fetch(String query) async {
    final rows = await DatabaseHelper.query(query);
    return rows.map(GasOrder.fromRow).toList();
  }

  Future<GasOrder?> _fetchOrder(String orderId) async {
    final orders = await _fetch(
      '$_selectOrders WHERE o.id = ${DatabaseHelper.sqlValue(orderId)}',
    );
    return orders.isEmpty ? null : orders.first;
  }

  Future<String?> _findOrderId(String orderCode) async {
    final rows = await DatabaseHelper.query(
      'SELECT id FROM orders '
      'WHERE order_code = ${DatabaseHelper.sqlValue(orderCode)} LIMIT 1',
    );
    return rows.isEmpty ? null : rows.first['id']?.toString();
  }

  String _newOrderCode() {
    final now = DateTime.now().millisecondsSinceEpoch;
    return 'GAS$now';
  }
}
