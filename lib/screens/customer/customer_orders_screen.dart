import 'package:flutter/material.dart';

import '../../app/app_scope.dart';
import '../../core/enums.dart';
import '../../core/formatters.dart';
import '../../models/gas_order.dart';
import '../../widgets/api_state.dart';
import '../../widgets/app_page.dart';
import '../../widgets/empty_state.dart';
import '../../widgets/order_tile.dart';
import '../../widgets/status_chip.dart';

class CustomerOrdersScreen extends StatefulWidget {
  const CustomerOrdersScreen({super.key});

  @override
  State<CustomerOrdersScreen> createState() => _CustomerOrdersScreenState();
}

class _CustomerOrdersScreenState extends State<CustomerOrdersScreen> {
  OrderStatus? _filter;

  @override
  Widget build(BuildContext context) {
    final controller = AppScope.of(context);
    final user = controller.currentUser!;
    return AppPage(
      title: 'My Orders',
      actions: [
        IconButton(
          tooltip: 'Refresh',
          onPressed: () => setState(() {}),
          icon: const Icon(Icons.refresh),
        ),
      ],
      child: RefreshIndicator(
        onRefresh: () async => setState(() {}),
        child: ListView(
          padding: const EdgeInsets.fromLTRB(18, 8, 18, 24),
          children: [
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  ChoiceChip(
                    label: const Text('All'),
                    selected: _filter == null,
                    onSelected: (_) => setState(() => _filter = null),
                  ),
                  const SizedBox(width: 8),
                  for (final status in OrderStatus.values)
                    Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: ChoiceChip(
                        label: Text(status.label),
                        selected: _filter == status,
                        onSelected: (_) => setState(() => _filter = status),
                      ),
                    ),
                ],
              ),
            ),
            const SizedBox(height: 14),
            ApiState<List<GasOrder>>(
              future: controller.orderRepository.fetchCustomerOrders(user.id),
              isEmpty: (orders) => orders.isEmpty,
              empty: const EmptyState(
                icon: Icons.receipt_long_outlined,
                title: 'No orders yet',
                message: 'Your order history will appear here.',
              ),
              builder: (context, orders) {
                final filtered = _filter == null
                    ? orders
                    : orders.where((order) => order.status == _filter).toList();
                if (filtered.isEmpty) {
                  return const EmptyState(
                    icon: Icons.filter_alt_off_outlined,
                    title: 'No matching orders',
                    message: 'Choose another status to continue.',
                  );
                }
                return Column(
                  children: filtered.map((order) {
                    return OrderTile(order: order, onTap: () => _showTracking(context, order));
                  }).toList(),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showTracking(BuildContext context, GasOrder order) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      builder: (context) => _TrackingSheet(order: order),
    );
  }
}

class _TrackingSheet extends StatelessWidget {
  const _TrackingSheet({required this.order});

  final GasOrder order;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(18),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 640),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                IconButton(
                  tooltip: 'Close',
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.close),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Order #${order.code}',
                    style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w900),
                  ),
                ),
                StatusChip(status: order.status),
              ],
            ),
            const SizedBox(height: 12),
            Container(
              height: 220,
              decoration: BoxDecoration(
                color: const Color(0xffe8f1f4),
                borderRadius: BorderRadius.circular(8),
              ),
              child: CustomPaint(
                painter: _MapPainter(),
                child: const Center(
                  child: Icon(Icons.location_on, color: Colors.deepOrange, size: 42),
                ),
              ),
            ),
            const SizedBox(height: 14),
            Text(
              order.status == OrderStatus.delivered
                  ? 'Your order was delivered.'
                  : 'Your order is being prepared for delivery.',
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w900),
            ),
            const SizedBox(height: 8),
            Text(order.deliveryAddress, style: const TextStyle(color: Colors.black54)),
            const SizedBox(height: 14),
            _DetailRow(label: 'Driver', value: order.driverName),
            _DetailRow(label: 'Phone', value: order.driverPhone.isEmpty ? 'Not assigned' : order.driverPhone),
            _DetailRow(label: 'Cylinder', value: '${order.cylinder.name} x${order.quantity}'),
            _DetailRow(label: 'Total', value: AppFormatters.money(order.total)),
            const SizedBox(height: 16),
            FilledButton.icon(
              onPressed: () => Navigator.pop(context),
              icon: const Icon(Icons.done),
              label: const Text('Done'),
            ),
          ],
        ),
      ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  const _DetailRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Row(
        children: [
          Text(label, style: const TextStyle(color: Colors.black54)),
          const Spacer(),
          Flexible(
            child: Text(
              value,
              textAlign: TextAlign.end,
              style: const TextStyle(fontWeight: FontWeight.w800),
            ),
          ),
        ],
      ),
    );
  }
}

class _MapPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final road = Paint()
      ..color = Colors.white
      ..strokeWidth = 5
      ..style = PaintingStyle.stroke;
    for (var i = 0; i < 6; i++) {
      final y = size.height * (i + 1) / 7;
      canvas.drawLine(Offset(0, y), Offset(size.width, y + 30), road);
    }
    for (var i = 0; i < 5; i++) {
      final x = size.width * (i + 1) / 6;
      canvas.drawLine(Offset(x, 0), Offset(x - 40, size.height), road);
    }
    final route = Paint()
      ..color = Colors.blue
      ..strokeWidth = 5
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;
    final path = Path()
      ..moveTo(size.width * .25, size.height * .72)
      ..quadraticBezierTo(size.width * .42, size.height * .45, size.width * .58, size.height * .55)
      ..quadraticBezierTo(size.width * .72, size.height * .62, size.width * .82, size.height * .28);
    canvas.drawPath(path, route);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
