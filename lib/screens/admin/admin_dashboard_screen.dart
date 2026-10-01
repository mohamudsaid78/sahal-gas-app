import 'package:flutter/material.dart';

import '../../app/app_controller.dart';
import '../../app/app_scope.dart';
import '../../app/app_theme.dart';
import '../../core/enums.dart';
import '../../core/formatters.dart';
import '../../models/gas_cylinder.dart';
import '../../models/gas_order.dart';
import '../../models/gas_user.dart';
import '../../widgets/api_state.dart';
import '../../widgets/app_navigation.dart';
import '../../widgets/app_page.dart';
import '../../widgets/gas_cylinder_image.dart';
import '../../widgets/order_tile.dart';
import '../../widgets/responsive_grid.dart';

class AdminDashboardScreen extends StatefulWidget {
  const AdminDashboardScreen({super.key});

  @override
  State<AdminDashboardScreen> createState() => _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends State<AdminDashboardScreen> {
  int _chartDays = 7;
  DateTimeRange? _chartRange;
  DateTime _customerDate = DateTime.now();
  @override
  Widget build(BuildContext context) {
    final controller = AppScope.of(context);
    return AppPage(
      title: 'Admin Dashboard',
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
          padding: const EdgeInsets.fromLTRB(18, 4, 18, 28),
          children: [
            ApiState<_DashboardData>(
              future: _load(controller),
              builder: (context, data) {
                // Compute metrics scoped to the selected dashboard date (`_customerDate`).
                final ordersForDate = data.orders.where((order) {
                  final created = order.createdAt;
                  if (created == null) return false;
                  return created.year == _customerDate.year &&
                      created.month == _customerDate.month &&
                      created.day == _customerDate.day;
                }).toList();

                final cancelledCount = ordersForDate
                    .where((order) => order.status == OrderStatus.cancelled)
                    .length;
                final revenue = ordersForDate.fold<double>(
                  0,
                  (total, order) => total + order.total,
                );
                // Total revenue across all non-cancelled orders (all time)
                final totalRevenue = data.orders
                    .where((o) => o.status != OrderStatus.cancelled)
                    .fold<double>(0, (sum, o) => sum + o.total);
                final pending = ordersForDate
                    .where(
                      (order) =>
                          order.status != OrderStatus.delivered &&
                          order.status != OrderStatus.cancelled,
                    )
                    .length;
                final lowStock = data.cylinders
                    .where((item) => item.stock <= 3)
                    .length;
                final totalStock = data.cylinders.fold<int>(
                  0,
                  (sum, c) => sum + c.stock,
                );
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _DashboardGreeting(
                      name: controller.currentUser?.name ?? 'Admin',
                      userCount: data.users.where((u) {
                        final c = u.createdAt;
                        if (c == null) return false;
                        return c.year == _customerDate.year &&
                            c.month == _customerDate.month &&
                            c.day == _customerDate.day;
                      }).length,
                      selectedDate: _customerDate,
                      onDateSelected: (picked) =>
                          setState(() => _customerDate = picked),
                    ),
                    const SizedBox(height: 18),
                    ResponsiveGrid(
                      minItemWidth: 240,
                      desktopAspectRatio: 1.35,
                      mobileAspectRatio: 1.35,
                      children: [
                        _MetricCard(
                          icon: Icons.receipt_long_outlined,
                          label: 'Orders',
                          value: '${ordersForDate.length}',
                          color: AppTheme.orange,
                          trend: '100%',
                        ),
                        _MetricCard(
                          icon: Icons.cancel_outlined,
                          label: 'Cancelled Orders',
                          value: '$cancelledCount',
                          color: Colors.red,
                          trend: cancelledCount == 0
                              ? 'All clear'
                              : 'Needs attention',
                        ),
                        _MetricCard(
                          icon: Icons.inventory_2_outlined,
                          label: 'Total Stock',
                          value: '$totalStock',
                          color: const Color(0xff6a3ab6),
                          trend: 'Current',
                        ),
                        _MetricCard(
                          icon: Icons.attach_money,
                          label: 'Revenue',
                          value: AppFormatters.money(revenue),
                          color: AppTheme.green,
                          trend: '100%',
                        ),
                        _MetricCard(
                          icon: Icons.account_balance_wallet_outlined,
                          label: 'Total Revenue',
                          value: AppFormatters.money(totalRevenue),
                          color: AppTheme.green,
                          trend: 'All time',
                        ),
                        _MetricCard(
                          icon: Icons.hourglass_top_rounded,
                          label: 'Active Orders',
                          value: '$pending',
                          color: AppTheme.blue,
                          trend: '100%',
                        ),
                        _MetricCard(
                          icon: Icons.warning_rounded,
                          label: 'Low Stock',
                          value: '$lowStock',
                          color: Colors.red,
                          trend: lowStock == 0
                              ? 'All clear'
                              : 'Needs attention',
                        ),
                      ],
                    ),
                    const SizedBox(height: 18),
                    _Panel(
                      title: 'Sales Overview',
                      subtitle: 'Revenue for the selected period',
                      trailing: _PeriodSelector(
                        days: _chartRange == null
                            ? _chartDays
                            : _chartRange!.duration.inDays + 1,
                        label: _chartRange == null
                            ? null
                            : '${_chartRange!.start.day}/${_chartRange!.start.month} - ${_chartRange!.end.day}/${_chartRange!.end.month}',
                        onChanged: (d) async {
                          if (d > 0) {
                            setState(() {
                              _chartDays = d;
                              _chartRange = null;
                            });
                            return;
                          }
                          final picked = await showDateRangePicker(
                            context: context,
                            firstDate: DateTime.now().subtract(
                              const Duration(days: 365),
                            ),
                            lastDate: DateTime.now(),
                            initialDateRange: _chartRange,
                          );
                          if (picked == null) return;
                          setState(() {
                            _chartRange = picked;
                            _chartDays = picked.duration.inDays + 1;
                          });
                        },
                      ),
                      child: _SalesChart(
                        orders: data.orders,
                        days: _chartDays,
                        startDate: _chartRange?.start,
                      ),
                    ),
                    const SizedBox(height: 2),
                    LayoutBuilder(
                      builder: (context, constraints) {
                        final wide = constraints.maxWidth >= 900;
                        final recentOrders = _Panel(
                          title: 'Recent Orders',
                          subtitle: 'Latest activity from customers',
                          trailing: TextButton(
                            onPressed: () =>
                                AppNavigation.maybeOf(context)?.onSelect(4),
                            child: const Text('View all'),
                          ),
                          child: Column(
                            children: ordersForDate
                                .take(5)
                                .map((order) => OrderTile(order: order))
                                .toList(),
                          ),
                        );
                        final stock = _Panel(
                          title: 'Cylinder Stock',
                          subtitle: 'Inventory at a glance',
                          child: Column(
                            children: data.cylinders.take(6).map((cylinder) {
                              return ListTile(
                                contentPadding: EdgeInsets.zero,
                                leading: CircleAvatar(
                                  backgroundColor: cylinder.color.withValues(
                                    alpha: .15,
                                  ),
                                  child: GasCylinderImage(
                                    cylinder: cylinder,
                                    size: 34,
                                  ),
                                ),
                                title: Text(cylinder.name),
                                subtitle: Text('${cylinder.sizeKg} KG'),
                                trailing: Text(
                                  '${cylinder.stock}',
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w900,
                                  ),
                                ),
                              );
                            }).toList(),
                          ),
                        );
                        if (!wide)
                          return Column(children: [recentOrders, stock]);
                        return Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(flex: 3, child: recentOrders),
                            const SizedBox(width: 14),
                            Expanded(flex: 2, child: stock),
                          ],
                        );
                      },
                    ),
                    const SizedBox(height: 2),
                    _Panel(
                      title: 'Quick Actions',
                      subtitle: 'Manage your gas delivery system',
                      child: Wrap(
                        spacing: 10,
                        runSpacing: 10,
                        children: [
                          _QuickAction(
                            label: 'New Order',
                            caption: 'Create an order',
                            icon: Icons.add_circle_outline,
                            color: Color(0xffed1c24),
                            onTap: () =>
                                AppNavigation.maybeOf(context)?.onSelect(4),
                          ),
                          _QuickAction(
                            label: 'Add Customer',
                            caption: 'Register a customer',
                            icon: Icons.person_add_alt_1,
                            color: Color(0xff11b86a),
                            onTap: () =>
                                AppNavigation.maybeOf(context)?.onSelect(1),
                          ),
                          _QuickAction(
                            label: 'Manage Products',
                            caption: 'View and edit products',
                            icon: Icons.inventory_2_outlined,
                            color: Color(0xffff9e16),
                            onTap: () =>
                                AppNavigation.maybeOf(context)?.onSelect(2),
                          ),
                          _QuickAction(
                            label: 'View Reports',
                            caption: 'Check detailed reports',
                            icon: Icons.description_outlined,
                            color: Color(0xff0877c9),
                            onTap: () =>
                                AppNavigation.maybeOf(context)?.onSelect(7),
                          ),
                        ],
                      ),
                    ),
                  ],
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Future<_DashboardData> _load(AppController controller) async {
    final results = await Future.wait<Object>([
      controller.orderRepository.fetchAllOrders(),
      controller.cylinderRepository.fetchCylinders(),
      controller.userRepository.fetchUsers(),
    ]);
    return _DashboardData(
      orders: results[0] as List<GasOrder>,
      cylinders: results[1] as List<GasCylinder>,
      users: results[2] as List<GasUser>,
    );
  }
}

class _DashboardGreeting extends StatelessWidget {
  const _DashboardGreeting({
    required this.name,
    required this.userCount,
    required this.selectedDate,
    required this.onDateSelected,
  });

  final String name;
  final int userCount;
  final DateTime selectedDate;
  final ValueChanged<DateTime> onDateSelected;

  @override
  Widget build(BuildContext context) {
    final isLarge = MediaQuery.sizeOf(context).width >= 500;
    String dateLabel(DateTime d) {
      final now = DateTime.now();
      if (d.year == now.year && d.month == now.month && d.day == now.day)
        return 'Today';
      return '${d.day}/${d.month}/${d.year}';
    }

    return Container(
      padding: const EdgeInsets.fromLTRB(2, 10, 2, 0),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Welcome back,',
                  style: TextStyle(
                    color: Theme.of(
                      context,
                    ).colorScheme.primary.withValues(alpha: .72),
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  '$name! 👋',
                  style: const TextStyle(
                    color: Color(0xff13233d),
                    fontSize: 28,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  "Here's what's happening with your gas delivery system today.",
                  style: TextStyle(
                    color: Colors.blueGrey.shade500,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          if (isLarge)
            InkWell(
              onTap: () async {
                final picked = await showDatePicker(
                  context: context,
                  initialDate: selectedDate,
                  firstDate: DateTime.now().subtract(const Duration(days: 365)),
                  lastDate: DateTime.now(),
                );
                if (picked != null) onDateSelected(picked);
              },
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 11,
                ),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: const Color(0xffe8edf4)),
                  boxShadow: const [
                    BoxShadow(
                      color: Color(0x0a20334d),
                      blurRadius: 12,
                      offset: Offset(0, 4),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.calendar_month_outlined,
                      color: Color(0xff35577f),
                      size: 19,
                    ),
                    const SizedBox(width: 10),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          dateLabel(selectedDate),
                          style: const TextStyle(
                            fontWeight: FontWeight.w800,
                            fontSize: 12,
                          ),
                        ),
                        Text(
                          '$userCount customers',
                          style: TextStyle(
                            color: Colors.blueGrey.shade500,
                            fontSize: 11,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(width: 12),
                    const Icon(Icons.keyboard_arrow_down, size: 18),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _DashboardData {
  const _DashboardData({
    required this.orders,
    required this.cylinders,
    required this.users,
  });

  final List<GasOrder> orders;
  final List<GasCylinder> cylinders;
  final List<GasUser> users;
}

class _MetricCard extends StatelessWidget {
  const _MetricCard({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
    required this.trend,
  });

  final IconData icon;
  final String label;
  final String value;
  final Color color;
  final String trend;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: color.withValues(alpha: .035),
        borderRadius: BorderRadius.circular(13),
        border: Border.all(color: color.withValues(alpha: .28)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 22,
                backgroundColor: color,
                child: Icon(icon, color: Colors.white, size: 22),
              ),
              const Spacer(),
              Icon(
                Icons.arrow_forward_ios_rounded,
                color: color.withValues(alpha: .6),
                size: 14,
              ),
            ],
          ),
          Text(
            label,
            style: const TextStyle(color: Color(0xff30486a), fontSize: 13),
          ),
          const SizedBox(height: 2),
          Text(
            value,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontSize: 25,
              color: Color(0xff13233d),
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 3),
          Row(
            children: [
              Icon(
                trend == 'Needs attention'
                    ? Icons.priority_high
                    : Icons.arrow_upward,
                color: trend == 'Needs attention' ? Colors.red : AppTheme.green,
                size: 14,
              ),
              const SizedBox(width: 3),
              Text(
                trend,
                style: TextStyle(
                  color: trend == 'Needs attention'
                      ? Colors.red
                      : AppTheme.green,
                  fontSize: 11,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _Panel extends StatelessWidget {
  const _Panel({
    required this.title,
    this.subtitle,
    this.trailing,
    required this.child,
  });

  final String title;
  final String? subtitle;
  final Widget? trailing;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 14),
      elevation: 0,
      color: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(13),
        side: const BorderSide(color: Color(0xffe7edf3)),
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(14, 15, 14, 13),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w900,
                          color: Color(0xff1b2638),
                        ),
                      ),
                      _PanelSubtitle(text: subtitle),
                    ],
                  ),
                ),
                if (trailing != null) trailing!,
              ],
            ),
            const SizedBox(height: 14),
            child,
          ],
        ),
      ),
    );
  }
}

class _PanelSubtitle extends StatelessWidget {
  const _PanelSubtitle({required this.text});

  final String? text;

  @override
  Widget build(BuildContext context) {
    if (text == null) return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.only(top: 3),
      child: Text(
        text!,
        style: TextStyle(fontSize: 11, color: Colors.blueGrey.shade400),
      ),
    );
  }
}

class _PeriodSelector extends StatelessWidget {
  const _PeriodSelector({
    required this.days,
    required this.onChanged,
    this.label,
  });

  final int days;
  final ValueChanged<int> onChanged;
  final String? label;

  String get _defaultLabel {
    return switch (days) {
      7 => 'Last 7 Days',
      30 => 'Last 30 Days',
      90 => 'Last 90 Days',
      _ => '$days days',
    };
  }

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<int>(
      tooltip: 'Select period',
      onSelected: onChanged,
      itemBuilder: (context) => [
        const PopupMenuItem(value: 7, child: Text('Last 7 Days')),
        const PopupMenuItem(value: 30, child: Text('Last 30 Days')),
        const PopupMenuItem(value: 90, child: Text('Last 90 Days')),
        const PopupMenuDivider(),
        const PopupMenuItem(value: -1, child: Text('Custom range')),
      ],
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
        decoration: BoxDecoration(
          color: const Color(0xfff8fafc),
          borderRadius: BorderRadius.circular(9),
          border: Border.all(color: const Color(0xffe6ebf1)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              label ?? _defaultLabel,
              style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700),
            ),
            const SizedBox(width: 5),
            const Icon(Icons.keyboard_arrow_down, size: 16),
          ],
        ),
      ),
    );
  }
}

class _SalesChart extends StatelessWidget {
  const _SalesChart({required this.orders, required this.days, this.startDate});

  final List<GasOrder> orders;
  final int days;
  final DateTime? startDate;

  @override
  Widget build(BuildContext context) {
    final values = List<double>.generate(days, (index) {
      final day = startDate != null
          ? DateTime(
              startDate!.year,
              startDate!.month,
              startDate!.day,
            ).add(Duration(days: index))
          : DateTime.now().subtract(Duration(days: days - 1 - index));
      return orders
          .where((order) {
            final created = order.createdAt;
            return created != null &&
                created.year == day.year &&
                created.month == day.month &&
                created.day == day.day;
          })
          .fold<double>(0, (total, order) => total + order.total);
    });
    final hasData = values.any((value) => value > 0);
    final chartValues = hasData ? values : List<double>.filled(days, 0);
    return SizedBox(
      height: 185,
      child: CustomPaint(
        painter: _SalesChartPainter(values: chartValues, days: days),
        child: const SizedBox.expand(),
      ),
    );
  }
}

class _SalesChartPainter extends CustomPainter {
  const _SalesChartPainter({required this.values, required this.days});

  final List<double> values;
  final int days;

  @override
  void paint(Canvas canvas, Size size) {
    const left = 30.0;
    const right = 5.0;
    const top = 10.0;
    const bottom = 24.0;
    final chart = Rect.fromLTRB(
      left,
      top,
      size.width - right,
      size.height - bottom,
    );
    final maxValue = values.fold<double>(
      0,
      (max, value) => value > max ? value : max,
    );
    final scale = maxValue == 0 ? 1 : maxValue * 1.25;
    final linePaint = Paint()
      ..color = const Color(0xffe8eef5)
      ..strokeWidth = 1;
    final labelStyle = const TextStyle(color: Color(0xff71839b), fontSize: 9);
    final labelPainter = TextPainter(textDirection: TextDirection.ltr);

    for (var row = 0; row <= 4; row++) {
      final y = chart.top + chart.height * row / 4;
      canvas.drawLine(Offset(chart.left, y), Offset(chart.right, y), linePaint);
      labelPainter.text = TextSpan(
        text: '\$${(scale * (4 - row) / 4).round()}',
        style: labelStyle,
      );
      labelPainter.layout();
      labelPainter.paint(canvas, Offset(0, y - 6));
    }

    final points = <Offset>[];
    for (var index = 0; index < values.length; index++) {
      final x =
          chart.left +
          chart.width *
              (values.length == 1 ? 0.5 : index / (values.length - 1));
      final y = chart.bottom - chart.height * values[index] / scale;
      points.add(Offset(x, y));
      labelPainter.text = TextSpan(text: _dayLabel(index), style: labelStyle);
      labelPainter.layout();
      labelPainter.paint(
        canvas,
        Offset(x - labelPainter.width / 2, chart.bottom + 8),
      );
    }

    final linePath = Path()..moveTo(points.first.dx, points.first.dy);
    for (var index = 1; index < points.length; index++) {
      final previous = points[index - 1];
      final current = points[index];
      final midpoint = (previous.dx + current.dx) / 2;
      linePath.cubicTo(
        midpoint,
        previous.dy,
        midpoint,
        current.dy,
        current.dx,
        current.dy,
      );
    }
    final fillPath = Path.from(linePath)
      ..lineTo(points.last.dx, chart.bottom)
      ..lineTo(points.first.dx, chart.bottom)
      ..close();
    canvas.drawPath(
      fillPath,
      Paint()
        ..shader = const LinearGradient(
          colors: [Color(0x44ed1c24), Color(0x00ed1c24)],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ).createShader(chart),
    );
    canvas.drawPath(
      linePath,
      Paint()
        ..color = const Color(0xffed1c24)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.2,
    );
    for (final point in points) {
      canvas.drawCircle(point, 4, Paint()..color = Colors.white);
      canvas.drawCircle(point, 2.5, Paint()..color = const Color(0xffed1c24));
    }
  }

  String _dayLabel(int index) {
    final day = DateTime.now().subtract(Duration(days: days - 1 - index));
    if (days <= 7) {
      const names = ['Sun', 'Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat'];
      return names[day.weekday % 7];
    }
    // For longer periods show day/month
    return '${day.day}/${day.month}';
  }

  @override
  bool shouldRepaint(covariant _SalesChartPainter oldDelegate) {
    return oldDelegate.values != values;
  }
}

class _QuickAction extends StatelessWidget {
  const _QuickAction({
    required this.label,
    required this.caption,
    required this.icon,
    required this.color,
    required this.onTap,
  });

  final String label;
  final String caption;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 145,
      child: Material(
        color: color,
        borderRadius: BorderRadius.circular(10),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(10),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(12, 12, 10, 11),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(icon, color: Colors.white, size: 23),
                const SizedBox(height: 9),
                Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w800,
                    fontSize: 12,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  caption,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(color: Colors.white70, fontSize: 9),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
