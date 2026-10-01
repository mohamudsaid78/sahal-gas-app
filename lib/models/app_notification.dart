import '../core/row_reader.dart';

class AppNotification {
  const AppNotification({
    required this.id,
    required this.title,
    required this.message,
    required this.orderId,
    this.createdAt,
  });

  final String id;
  final String title;
  final String message;
  final String orderId;
  final DateTime? createdAt;

  factory AppNotification.fromRow(Map<String, dynamic> row) {
    return AppNotification(
      id: RowReader.text(row, ['notification_id', 'id']),
      title: RowReader.text(row, ['title']),
      message: RowReader.text(row, ['message']),
      orderId: RowReader.text(row, ['order_id']),
      createdAt: RowReader.date(row, ['created_at']),
    );
  }
}