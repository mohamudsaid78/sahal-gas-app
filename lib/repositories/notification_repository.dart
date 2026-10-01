import '../database/database_helper.dart';
import '../models/app_notification.dart';

class NotificationRepository {
  Future<int> fetchUnreadOrderCount(String userId) async {
    final orderIds = await fetchUnreadOrderIds(userId);
    return orderIds.length;
  }

  Future<List<String>> fetchUnreadOrderIds(String userId) async {
    final rows = await DatabaseHelper.query(
      'SELECT order_id FROM notifications '
      'WHERE user_id = ${DatabaseHelper.sqlValue(userId)} '
      'AND is_read = 0 AND order_id IS NOT NULL '
      'ORDER BY created_at DESC, id DESC',
    );
    return rows
        .map((row) => row['order_id']?.toString() ?? '')
        .where((id) => id.isNotEmpty)
        .toSet()
        .toList();
  }

  Future<List<AppNotification>> fetchUnread(String userId) async {
    final rows = await DatabaseHelper.query(
      'SELECT id AS notification_id, title, message, order_id, created_at '
      'FROM notifications '
      'WHERE user_id = ${DatabaseHelper.sqlValue(userId)} AND is_read = 0 '
      'ORDER BY created_at DESC, id DESC',
    );
    return rows.map(AppNotification.fromRow).toList();
  }

  Future<void> markRead(String notificationId) async {
    await DatabaseHelper.updateTableRow(
      'UPDATE notifications SET is_read = 1 '
      'WHERE id = ${DatabaseHelper.sqlValue(notificationId)}',
    );
  }

  Future<void> markOrderRead({
    required String userId,
    required String orderId,
  }) async {
    await DatabaseHelper.updateTableRow(
      'UPDATE notifications SET is_read = 1 '
      'WHERE user_id = ${DatabaseHelper.sqlValue(userId)} '
      'AND order_id = ${DatabaseHelper.sqlValue(orderId)}',
    );
  }
}