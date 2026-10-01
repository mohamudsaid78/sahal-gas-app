import 'package:flutter/material.dart';

import '../../app/app_scope.dart';
import '../../app/app_theme.dart';
import '../../core/enums.dart';
import '../../core/formatters.dart';
import '../../models/gas_order.dart';
import '../../widgets/api_state.dart';
import '../../widgets/app_page.dart';

class AdminRevenueScreen extends StatelessWidget {
  const AdminRevenueScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = AppScope.of(context);
    return AppPage(
      title: 'Revenue',
      child: ApiState<List<GasOrder>>(
        future: controller.orderRepository.fetchAllOrders(),
        builder: (context, orders) {
          final validOrders = orders
              .where((order) => order.status != OrderStatus.cancelled)
              .toList();
          final revenue = validOrders.fold<double>(
            0,
            (sum, order) => sum + order.total,
          );
          final average = validOrders.isEmpty ? 0 : revenue / validOrders.length;
          return ListView(
            padding: const EdgeInsets.fromLTRB(18, 10, 18, 24),
            children: [
              Row(
                children: [
                  Expanded(child: _RevenueCard(title: 'Total Revenue', value: AppFormatters.money(revenue), icon: Icons.attach_money, color: AppTheme.green)),
                  const SizedBox(width: 12),
                  Expanded(child: _RevenueCard(title: 'Average Order', value: AppFormatters.money(average), icon: Icons.shopping_bag_outlined, color: AppTheme.blue)),
                ],
              ),
              const SizedBox(height: 18),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Revenue by order', style: TextStyle(fontSize: 17, fontWeight: FontWeight.w900)),
                      const SizedBox(height: 12),
                        ...validOrders.take(10).map((order) => ListTile(
                        contentPadding: EdgeInsets.zero,
                        leading: const CircleAvatar(backgroundColor: Color(0x1a2e9b47), child: Icon(Icons.trending_up, color: AppTheme.green)),
                        title: Text('#${order.code}', style: const TextStyle(fontWeight: FontWeight.w700)),
                        subtitle: Text(order.customerName),
                        trailing: Text(AppFormatters.money(order.total), style: const TextStyle(fontWeight: FontWeight.w900)),
                      )),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _RevenueCard extends StatelessWidget {
  const _RevenueCard({required this.title, required this.value, required this.icon, required this.color});

  final String title;
  final String value;
  final IconData icon;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: color.withValues(alpha: .07), borderRadius: BorderRadius.circular(12), border: Border.all(color: color.withValues(alpha: .25))),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        CircleAvatar(backgroundColor: color, child: Icon(icon, color: Colors.white)),
        const SizedBox(height: 13),
        Text(title, style: const TextStyle(color: Color(0xff40516b), fontSize: 12)),
        const SizedBox(height: 3),
        Text(value, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w900)),
      ]),
    );
  }
}
