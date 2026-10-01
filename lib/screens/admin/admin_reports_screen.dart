import 'dart:convert';
import 'dart:typed_data';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';

import '../../app/app_scope.dart';
import '../../app/app_theme.dart';
import '../../core/enums.dart';
import '../../core/formatters.dart';
import '../../models/gas_cylinder.dart';
import '../../models/gas_order.dart';
import '../../widgets/api_state.dart';
import '../../widgets/app_page.dart';
import '../../widgets/gas_cylinder_image.dart';
import 'admin_orders_screen.dart';

class AdminReportsScreen extends StatefulWidget {
  const AdminReportsScreen({super.key});

  @override
  State<AdminReportsScreen> createState() => _AdminReportsScreenState();
}

class _AdminReportsScreenState extends State<AdminReportsScreen> {
  Future<List<GasOrder>>? _future;
  _ReportPeriod _period = _ReportPeriod.all;
  int? _selectedKg;
  _ReportSort _sort = _ReportSort.mostOrdered;

  @override
  Widget build(BuildContext context) {
    final controller = AppScope.of(context);
    _future ??= controller.orderRepository.fetchAllOrders();
    return AppPage(
      title: 'Reports',
      actions: [
        IconButton(
          tooltip: 'Export report',
          onPressed: () async {
            final orders = await _future;
            if (!context.mounted || orders == null) return;
            await _exportReport(_filterOrders(orders));
          },
          icon: const Icon(Icons.download_outlined),
        ),
        IconButton(
          tooltip: 'Refresh reports',
          onPressed: _refresh,
          icon: const Icon(Icons.refresh),
        ),
      ],
      child: ApiState<List<GasOrder>>(
        future: _future!,
        builder: (context, orders) {
          final filteredOrders = _filterOrders(orders);
          final delivered = filteredOrders
              .where((order) => order.status == OrderStatus.delivered)
              .length;
          final active = filteredOrders
              .where(
                (order) =>
                    order.status != OrderStatus.delivered &&
                    order.status != OrderStatus.cancelled,
              )
              .length;
          final cancelled = filteredOrders
              .where((order) => order.status == OrderStatus.cancelled)
              .length;
          final popularCylinder = _topCylinder(
            filteredOrders,
            byRevenue: false,
          );
          final topRevenueCylinder = _topCylinder(
            filteredOrders,
            byRevenue: true,
          );
          final sortedOrders = [...filteredOrders]
            ..sort(
              (a, b) => _sort == _ReportSort.mostOrdered
                  ? b.quantity.compareTo(a.quantity)
                  : _orderRevenue(b).compareTo(_orderRevenue(a)),
            );
          return RefreshIndicator(
            onRefresh: _refresh,
            child: ListView(
              padding: const EdgeInsets.fromLTRB(18, 10, 18, 24),
              children: [
                const Text(
                  'Operations Summary',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.w900),
                ),
                const SizedBox(height: 4),
                Text(
                  'A quick view of delivery performance and orders.',
                  style: TextStyle(color: Colors.blueGrey.shade500),
                ),
                const SizedBox(height: 18),
                _ReportFilters(
                  period: _period,
                  selectedKg: _selectedKg,
                  sort: _sort,
                  availableKg:
                      orders
                          .map((order) => order.cylinder.sizeKg)
                          .toSet()
                          .toList()
                        ..sort(),
                  onPeriodChanged: (value) => setState(() => _period = value),
                  onKgChanged: (value) => setState(() => _selectedKg = value),
                  onSortChanged: (value) => setState(() => _sort = value),
                ),
                const SizedBox(height: 16),
                _ReportRow(
                  icon: Icons.receipt_long,
                  title: 'All Orders',
                  value: '${filteredOrders.length}',
                  color: AppTheme.orange,
                  onTap: () => Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => const AdminOrdersScreen(),
                    ),
                  ),
                ),
                _ReportRow(
                  icon: Icons.check_circle_outline,
                  title: 'Delivered Orders',
                  value: '$delivered',
                  color: AppTheme.green,
                  onTap: () => Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => const AdminOrdersScreen(
                        initialStatuses: {OrderStatus.delivered},
                      ),
                    ),
                  ),
                ),
                _ReportRow(
                  icon: Icons.local_shipping_outlined,
                  title: 'Active Deliveries',
                  value: '$active',
                  color: AppTheme.blue,
                  onTap: () => Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => AdminOrdersScreen(
                        initialStatuses: OrderStatus.values
                            .where(
                              (s) =>
                                  s != OrderStatus.delivered &&
                                  s != OrderStatus.cancelled,
                            )
                            .toSet(),
                      ),
                    ),
                  ),
                ),
                _ReportRow(
                  icon: Icons.cancel_outlined,
                  title: 'Cancelled Orders',
                  value: '$cancelled',
                  color: Colors.red,
                  onTap: () => Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => const AdminOrdersScreen(
                        initialStatuses: {OrderStatus.cancelled},
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                if (popularCylinder != null || topRevenueCylinder != null)
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (popularCylinder != null)
                        Expanded(
                          child: _MetricCard(
                            cylinder: popularCylinder.cylinder,
                            icon: Icons.local_fire_department_outlined,
                            label: 'Most ordered',
                            value: popularCylinder.name,
                            detail:
                                '${popularCylinder.quantity} cylinders (${popularCylinder.quantity * popularCylinder.sizeKg} kg)',
                            color: AppTheme.orange,
                          ),
                        ),
                      if (popularCylinder != null && topRevenueCylinder != null)
                        const SizedBox(width: 10),
                      if (topRevenueCylinder != null)
                        Expanded(
                          child: _MetricCard(
                            cylinder: topRevenueCylinder.cylinder,
                            icon: Icons.payments_outlined,
                            label: 'Highest revenue',
                            value: topRevenueCylinder.name,
                            detail: AppFormatters.money(
                              topRevenueCylinder.revenue,
                            ),
                            color: AppTheme.green,
                          ),
                        ),
                    ],
                  ),
                const SizedBox(height: 12),
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Text(
                      'Reported order value: ${AppFormatters.money(filteredOrders.fold<double>(0, (sum, order) => sum + order.total))}',
                      style: const TextStyle(fontWeight: FontWeight.w800),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                _ReportCharts(orders: filteredOrders),
                if (sortedOrders.isNotEmpty) ...[
                  const SizedBox(height: 12),
                  Text(
                    _sort == _ReportSort.mostOrdered
                        ? 'Orders by quantity'
                        : 'Orders by revenue',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  const SizedBox(height: 6),
                  ...sortedOrders
                      .take(5)
                      .map(
                        (order) => ListTile(
                          contentPadding: EdgeInsets.zero,
                          leading: SizedBox(
                            width: 52,
                            height: 52,
                            child: GasCylinderImage(
                              cylinder: order.cylinder,
                              size: 52,
                            ),
                          ),
                          title: Text(
                            order.cylinder.name,
                            style: const TextStyle(fontWeight: FontWeight.w700),
                          ),
                          subtitle: Text(
                            '${order.quantity} cylinders • ${order.code}',
                          ),
                          trailing: Text(
                            _sort == _ReportSort.mostOrdered
                                ? '${order.quantity}'
                                : AppFormatters.money(_orderRevenue(order)),
                            style: const TextStyle(fontWeight: FontWeight.w900),
                          ),
                        ),
                      ),
                ],
              ],
            ),
          );
        },
      ),
    );
  }

  List<GasOrder> _filterOrders(List<GasOrder> orders) {
    final now = DateTime.now();
    final start = switch (_period) {
      _ReportPeriod.all => null,
      _ReportPeriod.today => DateTime(now.year, now.month, now.day),
      _ReportPeriod.week => DateTime(
        now.year,
        now.month,
        now.day - now.weekday + 1,
      ),
      _ReportPeriod.month => DateTime(now.year, now.month),
    };
    return orders.where((order) {
      final matchesPeriod =
          start == null ||
          (order.createdAt != null && !order.createdAt!.isBefore(start));
      final matchesKg =
          _selectedKg == null || order.cylinder.sizeKg == _selectedKg;
      return matchesPeriod && matchesKg;
    }).toList();
  }

  _CylinderMetric? _topCylinder(
    List<GasOrder> orders, {
    required bool byRevenue,
  }) {
    final metrics = <String, _CylinderMetric>{};
    for (final order in orders.where(
      (order) => order.status != OrderStatus.cancelled,
    )) {
      final key = order.cylinder.id.isEmpty
          ? order.cylinder.name
          : order.cylinder.id;
      final current = metrics[key];
      metrics[key] = _CylinderMetric(
        cylinder: order.cylinder,
        name: order.cylinder.name,
        sizeKg: order.cylinder.sizeKg,
        quantity: (current?.quantity ?? 0) + order.quantity,
        revenue:
            (current?.revenue ?? 0) + order.cylinder.price * order.quantity,
      );
    }
    if (metrics.isEmpty) return null;
    final values = metrics.values.toList()
      ..sort(
        (a, b) => byRevenue
            ? b.revenue.compareTo(a.revenue)
            : b.quantity.compareTo(a.quantity),
      );
    return values.first;
  }

  double _orderRevenue(GasOrder order) => order.cylinder.price * order.quantity;

  Future<void> _exportReport(List<GasOrder> orders) async {
    final rows = <List<String>>[
      ['Report period', _period.name],
      ['Cylinder size', _selectedKg == null ? 'All sizes' : '${_selectedKg}kg'],
      [
        'Ranking',
        _sort == _ReportSort.mostOrdered ? 'Most ordered' : 'Highest revenue',
      ],
      [],
      [
        'Date',
        'Order',
        'Cylinder',
        'Size (kg)',
        'Quantity',
        'Revenue',
        'Status',
        'Payment method',
      ],
      ...orders.map(
        (order) => [
          order.createdAt?.toIso8601String() ?? '',
          order.code,
          order.cylinder.name,
          '${order.cylinder.sizeKg}',
          '${order.quantity}',
          _orderRevenue(order).toStringAsFixed(2),
          order.status.name,
          order.paymentMethod,
        ],
      ),
    ];
    final csv = rows.map((row) => row.map(_escapeCsv).join(',')).join('\r\n');
    final timestamp = DateTime.now()
        .toIso8601String()
        .replaceAll(':', '-')
        .split('.')
        .first;
    final path = await FilePicker.saveFile(
      dialogTitle: 'Export report',
      fileName: 'sahal-gas-report-$timestamp.csv',
      type: FileType.custom,
      allowedExtensions: ['csv'],
      bytes: Uint8List.fromList(utf8.encode(csv)),
    );
    if (!mounted || path == null) return;
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text('Report exported to $path')));
  }

  String _escapeCsv(String value) {
    final escaped = value.replaceAll('"', '""');
    return '"$escaped"';
  }

  Future<void> _refresh() async {
    final controller = AppScope.of(context);
    setState(() {
      _future = controller.orderRepository.fetchAllOrders();
    });
    await _future;
  }
}

class _ReportRow extends StatelessWidget {
  const _ReportRow({
    required this.icon,
    required this.title,
    required this.value,
    required this.color,
    this.onTap,
  });

  final IconData icon;
  final String title;
  final String value;
  final Color color;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      child: ListTile(
        onTap: onTap,
        leading: CircleAvatar(
          backgroundColor: color.withValues(alpha: .12),
          child: Icon(icon, color: color),
        ),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.w700)),
        trailing: Text(
          value,
          style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w900),
        ),
      ),
    );
  }
}

class _ReportCharts extends StatelessWidget {
  const _ReportCharts({required this.orders});

  final List<GasOrder> orders;

  @override
  Widget build(BuildContext context) {
    final activeOrders = orders
        .where((order) => order.status != OrderStatus.cancelled)
        .toList();
    final dailyValues = _dailyRevenue(activeOrders);
    final cylinderValues = _cylinderRevenue(activeOrders);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _ChartCard(
          title: 'Revenue trend',
          subtitle: 'Sales from the selected filters',
          child: dailyValues.isEmpty
              ? const _EmptyChart()
              : SizedBox(
                  height: 210,
                  child: CustomPaint(
                    painter: _RevenueChartPainter(values: dailyValues),
                    child: const SizedBox.expand(),
                  ),
                ),
        ),
        const SizedBox(height: 12),
        _ChartCard(
          title: 'Revenue by cylinder',
          subtitle: 'Top cylinder sizes in the selected filters',
          child: cylinderValues.isEmpty
              ? const _EmptyChart()
              : SizedBox(
                  height: 230,
                  child: CustomPaint(
                    painter: _CylinderChartPainter(values: cylinderValues),
                    child: const SizedBox.expand(),
                  ),
                ),
        ),
      ],
    );
  }

  List<_ChartPoint> _dailyRevenue(List<GasOrder> orders) {
    final dates =
        orders
            .where((order) => order.createdAt != null)
            .map(
              (order) => DateTime(
                order.createdAt!.year,
                order.createdAt!.month,
                order.createdAt!.day,
              ),
            )
            .toSet()
            .toList()
          ..sort();
    if (dates.isEmpty) return [];
    var start = dates.first;
    final end = dates.last;
    if (end.difference(start).inDays > 13) {
      start = end.subtract(const Duration(days: 13));
    }
    final points = <_ChartPoint>[];
    for (
      var day = start;
      !day.isAfter(end);
      day = day.add(const Duration(days: 1))
    ) {
      final value = orders
          .where((order) {
            final created = order.createdAt;
            return created != null &&
                created.year == day.year &&
                created.month == day.month &&
                created.day == day.day;
          })
          .fold<double>(0, (sum, order) => sum + _orderRevenue(order));
      points.add(_ChartPoint('${day.day}/${day.month}', value));
    }
    return points;
  }

  List<_ChartPoint> _cylinderRevenue(List<GasOrder> orders) {
    final values = <String, double>{};
    for (final order in orders) {
      final label = '${order.cylinder.sizeKg}kg';
      values[label] = (values[label] ?? 0) + _orderRevenue(order);
    }
    final points =
        values.entries
            .map((entry) => _ChartPoint(entry.key, entry.value))
            .toList()
          ..sort((a, b) => b.value.compareTo(a.value));
    return points.take(6).toList();
  }

  double _orderRevenue(GasOrder order) => order.cylinder.price * order.quantity;
}

class _ChartCard extends StatelessWidget {
  const _ChartCard({
    required this.title,
    required this.subtitle,
    required this.child,
  });

  final String title;
  final String subtitle;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(14, 14, 14, 8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w900),
            ),
            const SizedBox(height: 3),
            Text(
              subtitle,
              style: TextStyle(fontSize: 12, color: Colors.blueGrey.shade600),
            ),
            const SizedBox(height: 8),
            child,
          ],
        ),
      ),
    );
  }
}

class _EmptyChart extends StatelessWidget {
  const _EmptyChart();

  @override
  Widget build(BuildContext context) {
    return const SizedBox(
      height: 100,
      child: Center(child: Text('No chart data for these filters.')),
    );
  }
}

class _ChartPoint {
  const _ChartPoint(this.label, this.value);

  final String label;
  final double value;
}

class _RevenueChartPainter extends CustomPainter {
  const _RevenueChartPainter({required this.values});

  final List<_ChartPoint> values;

  @override
  void paint(Canvas canvas, Size size) {
    const left = 42.0;
    const right = 8.0;
    const top = 10.0;
    const bottom = 30.0;
    final chart = Rect.fromLTRB(
      left,
      top,
      size.width - right,
      size.height - bottom,
    );
    final maxValue = values.fold<double>(
      0,
      (max, point) => point.value > max ? point.value : max,
    );
    final scale = maxValue == 0 ? 1 : maxValue * 1.2;
    final gridPaint = Paint()..color = const Color(0xffe8eef5);
    final labelPainter = TextPainter(textDirection: TextDirection.ltr);
    for (var row = 0; row <= 3; row++) {
      final y = chart.top + chart.height * row / 3;
      canvas.drawLine(Offset(chart.left, y), Offset(chart.right, y), gridPaint);
      labelPainter.text = TextSpan(
        text: AppFormatters.money(scale * (3 - row) / 3),
        style: const TextStyle(color: Color(0xff71839b), fontSize: 9),
      );
      labelPainter.layout(maxWidth: left - 4);
      labelPainter.paint(canvas, Offset(0, y - 6));
    }
    final points = <Offset>[];
    for (var index = 0; index < values.length; index++) {
      final x =
          chart.left +
          chart.width * (values.length == 1 ? .5 : index / (values.length - 1));
      final y = chart.bottom - chart.height * values[index].value / scale;
      points.add(Offset(x, y));
      if (values.length <= 8 || index.isEven) {
        labelPainter.text = TextSpan(
          text: values[index].label,
          style: const TextStyle(color: Color(0xff71839b), fontSize: 9),
        );
        labelPainter.layout();
        labelPainter.paint(
          canvas,
          Offset(x - labelPainter.width / 2, chart.bottom + 8),
        );
      }
    }
    final linePath = Path()..moveTo(points.first.dx, points.first.dy);
    for (var index = 1; index < points.length; index++) {
      linePath.lineTo(points[index].dx, points[index].dy);
    }
    final fillPath = Path.from(linePath)
      ..lineTo(points.last.dx, chart.bottom)
      ..lineTo(points.first.dx, chart.bottom)
      ..close();
    canvas.drawPath(fillPath, Paint()..color = const Color(0x33ed1c24));
    canvas.drawPath(
      linePath,
      Paint()
        ..color = const Color(0xffed1c24)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.4,
    );
    for (final point in points) {
      canvas.drawCircle(point, 4, Paint()..color = Colors.white);
      canvas.drawCircle(point, 2.5, Paint()..color = const Color(0xffed1c24));
    }
  }

  @override
  bool shouldRepaint(covariant _RevenueChartPainter oldDelegate) =>
      oldDelegate.values != values;
}

class _CylinderChartPainter extends CustomPainter {
  const _CylinderChartPainter({required this.values});

  final List<_ChartPoint> values;

  @override
  void paint(Canvas canvas, Size size) {
    const left = 42.0;
    const right = 8.0;
    const top = 10.0;
    const bottom = 34.0;
    final chart = Rect.fromLTRB(
      left,
      top,
      size.width - right,
      size.height - bottom,
    );
    final maxValue = values.fold<double>(
      0,
      (max, point) => point.value > max ? point.value : max,
    );
    final labelPainter = TextPainter(textDirection: TextDirection.ltr);
    final barWidth = chart.width / (values.length * 1.7);
    for (var index = 0; index < values.length; index++) {
      final point = values[index];
      final x = chart.left + chart.width * (index + .5) / values.length;
      final double barHeight = maxValue == 0
          ? 0.0
          : chart.height * point.value / (maxValue * 1.15);
      final bar = Rect.fromLTWH(
        x - barWidth / 2,
        chart.bottom - barHeight,
        barWidth,
        barHeight,
      );
      canvas.drawRRect(
        RRect.fromRectAndRadius(bar, const Radius.circular(5)),
        Paint()..color = AppTheme.orange,
      );
      labelPainter.text = TextSpan(
        text: point.label,
        style: const TextStyle(color: Color(0xff71839b), fontSize: 10),
      );
      labelPainter.layout();
      labelPainter.paint(
        canvas,
        Offset(x - labelPainter.width / 2, chart.bottom + 8),
      );
      labelPainter.text = TextSpan(
        text: AppFormatters.money(point.value),
        style: const TextStyle(
          color: Color(0xff2a2a2a),
          fontSize: 9,
          fontWeight: FontWeight.w700,
        ),
      );
      labelPainter.layout(maxWidth: chart.width / values.length);
      labelPainter.paint(
        canvas,
        Offset(x - labelPainter.width / 2, bar.top - 16),
      );
    }
  }

  @override
  bool shouldRepaint(covariant _CylinderChartPainter oldDelegate) =>
      oldDelegate.values != values;
}

enum _ReportPeriod { all, today, week, month }

enum _ReportSort { mostOrdered, highestRevenue }

class _ReportFilters extends StatelessWidget {
  const _ReportFilters({
    required this.period,
    required this.selectedKg,
    required this.sort,
    required this.availableKg,
    required this.onPeriodChanged,
    required this.onKgChanged,
    required this.onSortChanged,
  });

  final _ReportPeriod period;
  final int? selectedKg;
  final _ReportSort sort;
  final List<int> availableKg;
  final ValueChanged<_ReportPeriod> onPeriodChanged;
  final ValueChanged<int?> onKgChanged;
  final ValueChanged<_ReportSort> onSortChanged;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Filter reports',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w900),
            ),
            const SizedBox(height: 10),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                for (final option in _ReportPeriod.values)
                  ChoiceChip(
                    label: Text(_periodLabel(option)),
                    selected: period == option,
                    onSelected: (_) => onPeriodChanged(option),
                  ),
              ],
            ),
            const SizedBox(height: 10),
            DropdownButtonFormField<int?>(
              value: selectedKg,
              decoration: const InputDecoration(
                labelText: 'Cylinder size',
                border: OutlineInputBorder(),
              ),
              items: [
                const DropdownMenuItem<int?>(
                  value: null,
                  child: Text('All sizes'),
                ),
                ...availableKg.map(
                  (kg) =>
                      DropdownMenuItem<int?>(value: kg, child: Text('$kg kg')),
                ),
              ],
              onChanged: onKgChanged,
            ),
            const SizedBox(height: 10),
            DropdownButtonFormField<_ReportSort>(
              value: sort,
              decoration: const InputDecoration(
                labelText: 'Rank reports by',
                border: OutlineInputBorder(),
              ),
              items: const [
                DropdownMenuItem(
                  value: _ReportSort.mostOrdered,
                  child: Text('Most ordered'),
                ),
                DropdownMenuItem(
                  value: _ReportSort.highestRevenue,
                  child: Text('Highest revenue'),
                ),
              ],
              onChanged: (value) {
                if (value != null) onSortChanged(value);
              },
            ),
          ],
        ),
      ),
    );
  }

  String _periodLabel(_ReportPeriod value) {
    switch (value) {
      case _ReportPeriod.all:
        return 'All';
      case _ReportPeriod.today:
        return 'Today';
      case _ReportPeriod.week:
        return 'This week';
      case _ReportPeriod.month:
        return 'This month';
    }
  }
}

class _CylinderMetric {
  const _CylinderMetric({
    required this.cylinder,
    required this.name,
    required this.sizeKg,
    required this.quantity,
    required this.revenue,
  });

  final GasCylinder cylinder;
  final String name;
  final int sizeKg;
  final int quantity;
  final double revenue;
}

class _MetricCard extends StatelessWidget {
  const _MetricCard({
    required this.cylinder,
    required this.icon,
    required this.label,
    required this.value,
    required this.detail,
    required this.color,
  });

  final GasCylinder cylinder;
  final IconData icon;
  final String label;
  final String value;
  final String detail;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                SizedBox(
                  width: 58,
                  height: 58,
                  child: GasCylinderImage(cylinder: cylinder, size: 58),
                ),
                const SizedBox(width: 8),
                Icon(icon, color: color),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              label,
              style: TextStyle(color: color, fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 4),
            Text(
              value,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(fontWeight: FontWeight.w900),
            ),
            const SizedBox(height: 4),
            Text(
              detail,
              style: TextStyle(color: Colors.blueGrey.shade600, fontSize: 12),
            ),
          ],
        ),
      ),
    );
  }
}
