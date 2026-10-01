import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../app/app_scope.dart';
import '../../app/app_theme.dart';
import '../../core/formatters.dart';
import '../../models/app_notification.dart';
import '../../models/gas_cylinder.dart';
import '../../models/gas_order.dart';
import '../../widgets/api_state.dart';
import '../../widgets/app_page.dart';
import '../../widgets/gas_cylinder_image.dart';
import '../../widgets/section_header.dart';
import 'customer_orders_screen.dart';
import 'offers_screen.dart';
import 'products_screen.dart';

class CustomerHomeScreen extends StatefulWidget {
  const CustomerHomeScreen({super.key});

  @override
  State<CustomerHomeScreen> createState() => _CustomerHomeScreenState();
}

class _CustomerHomeScreenState extends State<CustomerHomeScreen> {
  @override
  Widget build(BuildContext context) {
    final controller = AppScope.of(context);
    final user = controller.currentUser!;
    return AppPage(
      title: 'Garowe, Somalia',
      actions: [
        IconButton(
          tooltip: 'Notifications',
          onPressed: () async {
            await showDialog<void>(
              context: context,
              builder: (dialogContext) {
                return _CustomerNotificationsDialog(userId: user.id);
              },
            );
            if (mounted) setState(() {});
          },
          icon: const Icon(Icons.notifications_none),
        ),
      ],
      child: RefreshIndicator(
        onRefresh: () async => setState(() {}),
        child: ListView(
          padding: const EdgeInsets.fromLTRB(14, 4, 14, 24),
          children: [
            _WelcomeBanner(name: user.name),
            const SizedBox(height: 20),
            SectionHeader(
              title: 'Gas Cylinders',
              action: 'View All',
              onTap: () => _openProducts(context),
            ),
            ApiState<List<GasCylinder>>(
              future: controller.cylinderRepository.fetchCylinders(
                onlyActive: true,
              ),
              isEmpty: (items) => items.isEmpty,
              builder: (context, cylinders) {
                return SizedBox(
                  height: 202,
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    itemCount: cylinders.take(6).length,
                    separatorBuilder: (_, _) => const SizedBox(width: 10),
                    itemBuilder: (context, index) {
                      final cylinder = cylinders[index];
                      return _HomeCylinderCard(
                        cylinder: cylinder,
                        onTap: () => showProductDetails(context, cylinder),
                        onAdd: () => controller.addToCart(cylinder),
                      );
                    },
                  ),
                );
              },
            ),
            const SizedBox(height: 18),
            const SectionHeader(title: 'Quick Actions'),
            const _QuickActions(),
            const SizedBox(height: 18),
            const SectionHeader(title: 'Recent Orders'),
            ApiState<List<GasOrder>>(
              future: controller.orderRepository.fetchCustomerOrders(user.id),
              isEmpty: (orders) => orders.isEmpty,
              builder: (context, orders) {
                return Column(
                  children: orders.take(4).map((order) {
                    return _RecentOrderCard(order: order);
                  }).toList(),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  void _openProducts(BuildContext context) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      builder: (context) {
        return const SizedBox(
          height: 720,
          child: ProductsScreen(embedded: true),
        );
      },
    );
  }
}

class _CustomerNotificationsDialog extends StatefulWidget {
  const _CustomerNotificationsDialog({required this.userId});

  final String userId;

  @override
  State<_CustomerNotificationsDialog> createState() =>
      _CustomerNotificationsDialogState();
}

class _CustomerNotificationsDialogState
    extends State<_CustomerNotificationsDialog> {
  late Future<List<AppNotification>> _notifications;

  @override
  void initState() {
    super.initState();
    _reload();
  }

  void _reload() {
    _notifications = AppScope.of(
      context,
      listen: false,
    ).notificationRepository.fetchUnread(widget.userId);
  }

  Future<void> _markRead(AppNotification notification) async {
    final repository = AppScope.of(
      context,
      listen: false,
    ).notificationRepository;
    await repository.markRead(notification.id);
    if (!mounted) return;
    setState(_reload);
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Notifications'),
      content: SizedBox(
        width: 420,
        child: FutureBuilder<List<AppNotification>>(
          future: _notifications,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const SizedBox(
                height: 90,
                child: Center(child: CircularProgressIndicator()),
              );
            }
            if (snapshot.hasError) {
              return const Text('Could not load notifications.');
            }
            final notifications = snapshot.data ?? const <AppNotification>[];
            if (notifications.isEmpty) {
              return const Text('You have no new notifications.');
            }
            return ConstrainedBox(
              constraints: const BoxConstraints(maxHeight: 380),
              child: ListView.separated(
                shrinkWrap: true,
                itemCount: notifications.length,
                separatorBuilder: (_, _) => const Divider(height: 1),
                itemBuilder: (context, index) {
                  final notification = notifications[index];
                  return ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: const CircleAvatar(
                      backgroundColor: Color(0xffffebe6),
                      child: Icon(
                        Icons.notifications_none,
                        color: AppTheme.orange,
                      ),
                    ),
                    title: Text(
                      notification.title,
                      style: const TextStyle(fontWeight: FontWeight.w800),
                    ),
                    subtitle: Text(
                      '${notification.message}\n${AppFormatters.dateTime(notification.createdAt)}',
                    ),
                    isThreeLine: true,
                    onTap: () => _markRead(notification),
                  );
                },
              ),
            );
          },
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Close'),
        ),
      ],
    );
  }
}

class _WelcomeBanner extends StatelessWidget {
  const _WelcomeBanner({required this.name});

  final String name;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 164,
      padding: const EdgeInsets.fromLTRB(18, 18, 14, 12),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xffff7a1a), Color(0xfff55a1d)],
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: const [
          BoxShadow(
            color: Color(0x1f000000),
            blurRadius: 14,
            offset: Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Fast, safe gas\ndelivery',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 23,
                    height: 1.12,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  'Hello, ${name.split(' ').first}',
                  style: const TextStyle(
                    color: Colors.white70,
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const Spacer(),
                SizedBox(
                  height: 36,
                  child: FilledButton(
                    onPressed: () => _openProducts(context),
                    style: FilledButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: const Color(0xffef5d1b),
                      padding: const EdgeInsets.symmetric(horizontal: 18),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text(
                      'Order Now',
                      style: TextStyle(
                        fontWeight: FontWeight.w800,
                        fontSize: 15,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _openProducts(BuildContext context) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      builder: (context) {
        return const SizedBox(
          height: 720,
          child: ProductsScreen(embedded: true),
        );
      },
    );
  }
}

class _HomeCylinderCard extends StatelessWidget {
  const _HomeCylinderCard({
    required this.cylinder,
    required this.onTap,
    required this.onAdd,
  });

  final GasCylinder cylinder;
  final VoidCallback onTap;
  final VoidCallback onAdd;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 120,
      child: Card(
        margin: EdgeInsets.zero,
        elevation: 0,
        color: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14),
          side: BorderSide(color: const Color(0xffe9e5e2), width: 1.1),
        ),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(14),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(10, 10, 10, 8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(child: GasCylinderImage(cylinder: cylinder, size: 80)),
                const SizedBox(height: 8),
                Text(
                  '${cylinder.sizeKg} KG',
                  style: const TextStyle(
                    fontWeight: FontWeight.w900,
                    fontSize: 13,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  cylinder.description,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(color: Colors.black54, fontSize: 11),
                ),
                const Spacer(),
                Row(
                  children: [
                    Text(
                      AppFormatters.money(cylinder.price),
                      style: const TextStyle(
                        fontWeight: FontWeight.w900,
                        fontSize: 14,
                      ),
                    ),
                    const Spacer(),
                    GestureDetector(
                      onTap: cylinder.stock > 0 ? onAdd : null,
                      child: Container(
                        width: 28,
                        height: 28,
                        decoration: BoxDecoration(
                          color: cylinder.stock > 0
                              ? AppTheme.orange
                              : Colors.grey.shade400,
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color:
                                  (cylinder.stock > 0
                                          ? AppTheme.orange
                                          : Colors.grey)
                                      .withOpacity(0.28),
                              blurRadius: 8,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: const Icon(
                          Icons.add,
                          color: Colors.white,
                          size: 18,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _RecentOrderCard extends StatelessWidget {
  const _RecentOrderCard({required this.order});

  final GasOrder order;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
        leading: GasCylinderImage(cylinder: order.cylinder, size: 40),
        title: Text(
          order.cylinder.name,
          style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 13),
        ),
        subtitle: Text(
          'Order ${order.code}',
          style: const TextStyle(fontSize: 11),
        ),
        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              AppFormatters.money(order.total),
              style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 12),
            ),
            const SizedBox(height: 4),
            Text(
              order.status.label,
              style: const TextStyle(
                color: AppTheme.green,
                fontSize: 11,
                fontWeight: FontWeight.w800,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _QuickActions extends StatelessWidget {
  const _QuickActions();

  @override
  Widget build(BuildContext context) {
    final items = [
      (
        Icons.local_fire_department_outlined,
        'Quick Order',
        AppTheme.orange,
        () => showModalBottomSheet<void>(
          context: context,
          isScrollControlled: true,
          useSafeArea: true,
          builder: (_) => const SizedBox(
            height: 720,
            child: ProductsScreen(embedded: true),
          ),
        ),
      ),
      (
        Icons.route_outlined,
        'Track Order',
        AppTheme.blue,
        () => Navigator.of(
          context,
        ).push(MaterialPageRoute(builder: (_) => CustomerOrdersScreen())),
      ),
      (
        Icons.verified_outlined,
        'Offers',
        AppTheme.green,
        () => Navigator.of(
          context,
        ).push(MaterialPageRoute(builder: (_) => OffersScreen())),
      ),
      (
        Icons.favorite_outline,
        'Support',
        Colors.red,
        () async {
          await showDialog<void>(
            context: context,
            builder: (dialogContext) {
              return AlertDialog(
                title: const Text('Support'),
                content: const Text(
                  'Choose how you want to contact the admin.',
                ),
                actions: [
                  TextButton.icon(
                    onPressed: () async {
                      Navigator.of(dialogContext).pop();
                      final uri = Uri(
                        scheme: 'mailto',
                        path: 'zamiir12@gmail.com',
                        queryParameters: {
                          'subject': 'Support Request',
                          'body':
                              'Hello Admin,\n\nI need support.\nPhone: 0907144419\n',
                        },
                      );
                      if (await canLaunchUrl(uri)) {
                        await launchUrl(
                          uri,
                          mode: LaunchMode.externalApplication,
                        );
                      }
                    },
                    icon: const Icon(Icons.email_outlined),
                    label: const Text('Email'),
                  ),
                  TextButton.icon(
                    onPressed: () async {
                      Navigator.of(dialogContext).pop();
                      final uri = Uri(scheme: 'tel', path: '0907144419');
                      if (await canLaunchUrl(uri)) {
                        await launchUrl(
                          uri,
                          mode: LaunchMode.externalApplication,
                        );
                      }
                    },
                    icon: const Icon(Icons.phone_outlined),
                    label: const Text('Phone'),
                  ),
                ],
              );
            },
          );
        },
      ),
    ];

    return LayoutBuilder(
      builder: (context, constraints) {
        final count = (constraints.maxWidth / 160).floor().clamp(2, 4);
        return GridView.count(
          crossAxisCount: count,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          childAspectRatio: 2.8,
          crossAxisSpacing: 10,
          mainAxisSpacing: 10,
          children: items.map((item) {
            final icon = item.$1;
            final label = item.$2;
            final color = item.$3;
            final onTap = item.$4;

            return InkWell(
              onTap: onTap,
              borderRadius: BorderRadius.circular(14),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: AppTheme.border),
                  boxShadow: const [
                    BoxShadow(
                      color: Color(0x0f000000),
                      blurRadius: 8,
                      offset: Offset(0, 4),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    Container(
                      width: 34,
                      height: 34,
                      decoration: BoxDecoration(
                        color: color.withOpacity(0.12),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(icon, color: color, size: 20),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        label,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontWeight: FontWeight.w800,
                          fontSize: 14,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          }).toList(),
        );
      },
    );
  }
}

class MiniTotal extends StatelessWidget {
  const MiniTotal({super.key, required this.label, required this.value});

  final String label;
  final num value;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text(label, style: const TextStyle(color: Colors.black54)),
        const Spacer(),
        Text(
          AppFormatters.money(value),
          style: const TextStyle(fontWeight: FontWeight.w900),
        ),
      ],
    );
  }
}
