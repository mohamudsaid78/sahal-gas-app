import '../core/enums.dart';
import '../core/row_reader.dart';
import 'gas_cylinder.dart';

class GasOrder {
  const GasOrder({
    required this.id,
    required this.code,
    required this.customerId,
    required this.customerName,
    required this.customerPhone,
    required this.driverId,
    required this.driverName,
    required this.driverPhone,
    required this.cylinder,
    required this.quantity,
    required this.deliveryFee,
    required this.total,
    required this.status,
    required this.deliveryAddress,
    required this.paymentMethod,
    this.paymentStatus = 'pending',
    this.paymentReference,
    this.paymentAccount,
    this.paymentLast4,
    this.paymentPaidAt,
    this.createdAt,
  });

  final String id;
  final String code;
  final String customerId;
  final String customerName;
  final String customerPhone;
  final String? driverId;
  final String driverName;
  final String driverPhone;
  final GasCylinder cylinder;
  final int quantity;
  final double deliveryFee;
  final double total;
  final OrderStatus status;
  final String deliveryAddress;
  final String paymentMethod;
  final String paymentStatus;
  final String? paymentReference;
  final String? paymentAccount;
  final String? paymentLast4;
  final DateTime? paymentPaidAt;
  final DateTime? createdAt;

  factory GasOrder.fromRow(Map<String, dynamic> row) {
    final id = RowReader.text(row, ['order_id', 'id']);
    return GasOrder(
      id: id,
      code: RowReader.text(row, ['order_code', 'code'], fallback: 'GAS$id'),
      customerId: RowReader.text(row, ['customer_id', 'user_id']),
      customerName: RowReader.text(row, ['customer_name', 'full_name', 'name']),
      customerPhone: RowReader.text(row, ['customer_phone', 'phone']),
      driverId: RowReader.text(row, ['driver_id']).isEmpty
          ? null
          : RowReader.text(row, ['driver_id']),
      driverName: RowReader.text(row, ['driver_name'], fallback: 'Unassigned'),
      driverPhone: RowReader.text(row, ['driver_phone']),
      cylinder: GasCylinder.fromRow(row),
      quantity: RowReader.integer(row, ['quantity'], fallback: 1),
      deliveryFee: RowReader.decimal(row, ['delivery_fee'], fallback: 0),
      total: RowReader.decimal(row, ['total'], fallback: 0),
      status: OrderStatus.fromValue(RowReader.text(row, ['status'])),
      deliveryAddress: RowReader.text(row, ['delivery_address', 'address']),
      paymentMethod: RowReader.text(
        row,
        ['payment_method'],
        fallback: 'Cash on Delivery',
      ),
        paymentStatus: RowReader.text(row, ['payment_status'], fallback: 'pending'),
        paymentReference: RowReader.text(row, ['payment_reference']).isEmpty
          ? null
          : RowReader.text(row, ['payment_reference']),
        paymentAccount: RowReader.text(row, ['payment_account']).isEmpty
          ? null
          : RowReader.text(row, ['payment_account']),
        paymentLast4: RowReader.text(row, ['payment_last4']).isEmpty
          ? null
          : RowReader.text(row, ['payment_last4']),
        paymentPaidAt: RowReader.date(row, ['payment_paid_at']),
      createdAt: RowReader.date(row, ['created_at', 'created']),
    );
  }
}
