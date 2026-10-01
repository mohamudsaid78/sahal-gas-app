import 'package:flutter/material.dart';

import '../../app/app_scope.dart';
import '../../core/enums.dart';
import '../../models/gas_order.dart';
import '../../models/gas_user.dart';
import '../../widgets/api_state.dart';
import '../../widgets/app_page.dart';
import '../../widgets/empty_state.dart';
import '../../widgets/order_tile.dart';
import '../../widgets/status_chip.dart';

class AdminOrdersScreen extends StatefulWidget {
  const AdminOrdersScreen({super.key, this.initialStatuses});

  final Set<OrderStatus>? initialStatuses;

  @override
  State<AdminOrdersScreen> createState() => _AdminOrdersScreenState();
}

class _AdminOrdersScreenState extends State<AdminOrdersScreen> {
  OrderStatus? _status;

  @override
  Widget build(BuildContext context) {
    final controller = AppScope.of(context);
    return AppPage(
      title: 'Manage Orders',
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
                    selected: _status == null,
                    onSelected: (_) => setState(() => _status = null),
                  ),
                  const SizedBox(width: 8),
                  // Exclude the 'Placed' status from the quick filter chips
                  for (final status in OrderStatus.values.where((s) => s != OrderStatus.placed))
                    Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: ChoiceChip(
                        label: Text(status.label),
                        selected: _status == status,
                        onSelected: (_) => setState(() => _status = status),
                      ),
                    ),
                ],
              ),
            ),
            const SizedBox(height: 14),
            ApiState<List<dynamic>>(
              future: Future.wait([
                controller.orderRepository.fetchAllOrders(),
                controller.userRepository.fetchDrivers(),
                controller.notificationRepository.fetchUnreadOrderIds(
                  controller.currentUser!.id,
                ),
              ]),
              isEmpty: (data) => (data.first as List).isEmpty,
              empty: const EmptyState(
                icon: Icons.receipt_long_outlined,
                title: 'No orders yet',
                message: 'Customer orders will appear here.',
              ),
              builder: (context, data) {
                final orders = data[0] as List<GasOrder>;
                final drivers = data[1] as List<GasUser>;
                final newOrderIds = (data[2] as List<String>).toSet();
                final filtered = widget.initialStatuses == null
                  ? (_status == null
                    ? orders
                    : orders.where((order) => order.status == _status).toList())
                  : orders.where((order) => widget.initialStatuses!.contains(order.status)).toList();
                return Column(
                  children: [
                    if (newOrderIds.isNotEmpty)
                      _NewOrdersBanner(count: newOrderIds.length),
                    ...filtered.map((order) {
                      final isNew = newOrderIds.contains(order.id);
                      return Stack(
                        children: [
                          Card(
                            margin: const EdgeInsets.only(bottom: 10),
                            child: Padding(
                              padding: const EdgeInsets.all(12),
                              child: LayoutBuilder(
                                builder: (context, constraints) {
                                  final wide = constraints.maxWidth >= 820;
                                  final details = Column(
                                    crossAxisAlignment: CrossAxisAlignment.stretch,
                                    children: [
                                      OrderTile(
                                        order: order,
                                        trailing: StatusChip(status: order.status),
                                      ),
                                      const SizedBox(height: 10),
                                      _PaymentSummary(order: order),
                                    ],
                                  );
                                  final controls = _OrderControls(
                                    order: order,
                                    drivers: drivers,
                                    onChanged: () => setState(() {}),
                                  );
                                  if (!wide) {
                                    return Column(children: [details, controls]);
                                  }
                                  return Row(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Expanded(flex: 3, child: details),
                                      const SizedBox(width: 12),
                                      Expanded(flex: 2, child: controls),
                                    ],
                                  );
                                },
                              ),
                            ),
                          ),
                          if (isNew)
                            const Positioned(
                              top: 8,
                              right: 8,
                              child: _NewOrderBadge(),
                            ),
                        ],
                      );
                    }),
                  ],
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _NewOrdersBanner extends StatelessWidget {
  const _NewOrdersBanner({required this.count});

  final int count;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: const Color(0xfffff3e8),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xffffc58d)),
      ),
      child: Row(
        children: [
          const Icon(Icons.notifications_active_outlined, color: Colors.deepOrange),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              '$count new order${count == 1 ? '' : 's'} waiting for review',
              style: const TextStyle(fontWeight: FontWeight.w800),
            ),
          ),
          const _NewOrderBadge(),
        ],
      ),
    );
  }
}

class _NewOrderBadge extends StatelessWidget {
  const _NewOrderBadge();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
      decoration: BoxDecoration(
        color: Colors.deepOrange,
        borderRadius: BorderRadius.circular(8),
      ),
      child: const Text(
        'NEW',
        style: TextStyle(
          color: Colors.white,
          fontSize: 11,
          fontWeight: FontWeight.w900,
          letterSpacing: 0.5,
        ),
      ),
    );
  }
}

class _PaymentSummary extends StatelessWidget {
  const _PaymentSummary({required this.order});

  final GasOrder order;

  @override
  Widget build(BuildContext context) {
    final isPaid = order.paymentStatus.toLowerCase() == 'paid';
    final statusColor = isPaid ? Colors.green.shade700 : Colors.orange.shade800;
    final account = order.paymentAccount;
    final accountLabel = account == null || account.isEmpty ? 'Not provided' : account;

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xfffaf8f7),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xffe5dedb)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.account_balance_wallet_outlined, size: 18),
              const SizedBox(width: 8),
              const Text(
                'Payment transaction',
                style: TextStyle(fontWeight: FontWeight.w800),
              ),
              const Spacer(),
              Text(
                isPaid ? 'PAID' : 'PENDING',
                style: TextStyle(
                  color: statusColor,
                  fontWeight: FontWeight.w900,
                  fontSize: 12,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 16,
            runSpacing: 6,
            children: [
              Text('Method: ${order.paymentMethod}'),
              Text('Reference: ${order.paymentReference ?? 'N/A'}'),
              Text(
                order.paymentLast4 == null
                    ? 'Account: $accountLabel'
                    : 'Card: **** ${order.paymentLast4}',
              ),
              if (order.paymentPaidAt != null)
                Text('Paid: ${order.paymentPaidAt!.toLocal()}'),
            ],
          ),
        ],
      ),
    );
  }
}

class _OrderControls extends StatelessWidget {
  const _OrderControls({
    required this.order,
    required this.drivers,
    required this.onChanged,
  });

  final GasOrder order;
  final List<GasUser> drivers;
  final VoidCallback onChanged;

  @override
  Widget build(BuildContext context) {
    final controller = AppScope.of(context);
    final uniqueDrivers = <GasUser>[];
    for (final driver in drivers) {
      final trimmedId = driver.id.trim();
      if (trimmedId.isEmpty) continue;
      if (!uniqueDrivers.any((existing) => existing.id == trimmedId)) {
        uniqueDrivers.add(driver);
      }
    }

    final initialDriverId = (order.driverId ?? '').trim();
    final validDriverId = uniqueDrivers.any((driver) => driver.id == initialDriverId)
        ? initialDriverId
        : null;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        DropdownButtonFormField<String?>(
          value: validDriverId,
          decoration: const InputDecoration(labelText: 'Assigned driver'),
          items: [
            const DropdownMenuItem<String?>(
              value: null,
              child: Text('Unassigned'),
            ),
            ...uniqueDrivers.map((driver) {
              return DropdownMenuItem<String?>(
                value: driver.id,
                child: Text(driver.name),
              );
            }),
          ],
          onChanged: (driverId) async {
            await controller.orderRepository.assignDriver(order.id, driverId);
            await controller.notificationRepository.markOrderRead(
              userId: controller.currentUser!.id,
              orderId: order.id,
            );
            await controller.refreshAdminNewOrderCount();
            onChanged();
          },
        ),
        const SizedBox(height: 10),
        DropdownButtonFormField<OrderStatus>(
          initialValue: order.status,
          decoration: const InputDecoration(labelText: 'Status'),
          items: OrderStatus.values.map((status) {
            return DropdownMenuItem(value: status, child: Text(status.label));
          }).toList(),
          onChanged: (status) async {
            if (status == null) return;
            await controller.orderRepository.updateStatus(order.id, status);
            await controller.notificationRepository.markOrderRead(
              userId: controller.currentUser!.id,
              orderId: order.id,
            );
            await controller.refreshAdminNewOrderCount();
            onChanged();
          },
        ),
      ],
    );
  }
}
