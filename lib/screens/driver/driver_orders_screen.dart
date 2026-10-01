import 'dart:async';

import 'package:flutter/material.dart';

import '../../app/app_scope.dart';
import '../../core/enums.dart';
import '../../models/app_notification.dart';
import '../../models/gas_order.dart';
import '../../widgets/api_state.dart';
import '../../widgets/app_page.dart';
import '../../widgets/empty_state.dart';
import '../../widgets/order_tile.dart';
import '../../widgets/status_chip.dart';

class DriverOrdersScreen extends StatefulWidget {
  const DriverOrdersScreen({super.key});

  @override
  State<DriverOrdersScreen> createState() => _DriverOrdersScreenState();
}

class _DriverOrdersScreenState extends State<DriverOrdersScreen> {
  Timer? _notificationTimer;
  bool _checkingNotifications = false;

  @override
  void initState() {
    super.initState();
    _notificationTimer = Timer.periodic(
      const Duration(seconds: 10),
      (_) => _checkNotifications(),
    );
    WidgetsBinding.instance.addPostFrameCallback((_) => _checkNotifications());
  }

  @override
  void dispose() {
    _notificationTimer?.cancel();
    super.dispose();
  }

  Future<void> _checkNotifications() async {
    if (!mounted || _checkingNotifications) return;
    final user = AppScope.of(context, listen: false).currentUser;
    if (user == null) return;
    _checkingNotifications = true;
    try {
      final notifications = await AppScope.of(context, listen: false)
          .notificationRepository
          .fetchUnread(user.id);
      for (final notification in notifications.reversed) {
        await _showNotification(notification);
      }
    } catch (_) {
      // The order list remains usable if notification polling is unavailable.
    } finally {
      _checkingNotifications = false;
    }
  }

  Future<void> _showNotification(AppNotification notification) async {
    if (!mounted) return;
    await AppScope.of(context, listen: false)
        .notificationRepository
        .markRead(notification.id);
    if (!mounted) return;
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          duration: const Duration(seconds: 6),
          behavior: SnackBarBehavior.floating,
          content: Row(
            children: [
              const Icon(Icons.notifications_active, color: Colors.white),
              const SizedBox(width: 10),
              Expanded(
                child: Text('${notification.title}: ${notification.message}'),
              ),
            ],
          ),
        ),
      );
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final controller = AppScope.of(context);
    final user = controller.currentUser!;
    return AppPage(
      title: 'Assigned Orders',
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
            const _DriverHeader(),
            const SizedBox(height: 16),
            ApiState<List<GasOrder>>(
              future: controller.orderRepository.fetchDriverOrders(user.id),
              isEmpty: (orders) => orders.isEmpty,
              empty: const EmptyState(
                icon: Icons.delivery_dining_outlined,
                title: 'No assigned orders',
                message: 'Orders assigned by the admin will appear here.',
              ),
              builder: (context, orders) {
                return Column(
                  children: orders.map((order) {
                    return Card(
                      margin: const EdgeInsets.only(bottom: 10),
                      child: Padding(
                        padding: const EdgeInsets.all(12),
                        child: LayoutBuilder(
                          builder: (context, constraints) {
                            final wide = constraints.maxWidth >= 760;
                            final detail = OrderTile(
                              order: order,
                              trailing: StatusChip(status: order.status),
                            );
                            final actions = _DriverActions(
                              order: order,
                              onChanged: () => setState(() {}),
                            );
                            if (!wide) return Column(children: [detail, actions]);
                            return Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Expanded(flex: 3, child: detail),
                                const SizedBox(width: 12),
                                Expanded(flex: 2, child: actions),
                              ],
                            );
                          },
                        ),
                      ),
                    );
                  }).toList(),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _DriverHeader extends StatelessWidget {
  const _DriverHeader();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(colors: [Color(0xff0877c9), Color(0xff07528d)]),
        borderRadius: BorderRadius.circular(12),
      ),
      child: const Row(
        children: [
          CircleAvatar(
            radius: 24,
            backgroundColor: Colors.white,
            child: Icon(Icons.local_shipping_outlined, color: Color(0xff0877c9)),
          ),
          SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Delivery Route', style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.w900)),
                SizedBox(height: 4),
                Text('Review assigned orders and update delivery status.', style: TextStyle(color: Colors.white70)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _DriverActions extends StatelessWidget {
  const _DriverActions({required this.order, required this.onChanged});

  final GasOrder order;
  final VoidCallback onChanged;

  @override
  Widget build(BuildContext context) {
    final controller = AppScope.of(context);
    final canRespond = order.status == OrderStatus.placed ||
        order.status == OrderStatus.confirmed;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(order.deliveryAddress, style: const TextStyle(fontWeight: FontWeight.w800)),
        const SizedBox(height: 8),
        Text(order.customerPhone.isEmpty ? 'No customer phone' : order.customerPhone),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            FilledButton.icon(
              onPressed: !canRespond
                  ? null
                  : () async {
                      await controller.orderRepository.acceptDriverOrder(
                        order.id,
                        controller.currentUser!.id,
                      );
                      onChanged();
                    },
              icon: const Icon(Icons.check_circle_outline),
              label: const Text('Accept'),
            ),
            OutlinedButton.icon(
              onPressed: !canRespond
                  ? null
                  : () async {
                      await controller.orderRepository.rejectDriverOrder(
                        order.id,
                        controller.currentUser!.id,
                      );
                      onChanged();
                    },
              icon: const Icon(Icons.close),
              label: const Text('Reject'),
            ),
            _StatusButton(
              label: 'On the way',
              icon: Icons.route_outlined,
              status: OrderStatus.onTheWay,
              order: order,
              onChanged: onChanged,
            ),
            FilledButton.icon(
              onPressed: order.status == OrderStatus.delivered
                  ? null
                  : () async {
                      await controller.orderRepository.updateStatus(order.id, OrderStatus.delivered);
                      onChanged();
                    },
              icon: const Icon(Icons.done_all),
              label: const Text('Delivered'),
            ),
          ],
        ),
      ],
    );
  }
}

class _StatusButton extends StatelessWidget {
  const _StatusButton({
    required this.label,
    required this.icon,
    required this.status,
    required this.order,
    required this.onChanged,
  });

  final String label;
  final IconData icon;
  final OrderStatus status;
  final GasOrder order;
  final VoidCallback onChanged;

  @override
  Widget build(BuildContext context) {
    return OutlinedButton.icon(
      onPressed: order.status == status
          ? null
          : () async {
              await AppScope.of(context, listen: false).orderRepository.updateStatus(order.id, status);
              onChanged();
            },
      icon: Icon(icon),
      label: Text(label),
    );
  }
}
