import 'package:flutter/material.dart';

import '../core/formatters.dart';
import '../models/gas_order.dart';
import 'gas_cylinder_image.dart';
import 'status_chip.dart';

class OrderTile extends StatelessWidget {
  const OrderTile({
    super.key,
    required this.order,
    this.onTap,
    this.trailing,
  });

  final GasOrder order;
  final VoidCallback? onTap;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xffe7e0df)),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Container(
              width: 110,
              height: 120,
              decoration: BoxDecoration(
                color: Colors.transparent,
                borderRadius: BorderRadius.circular(18),
              ),
              child: Center(
                child: Transform.translate(
                  offset: const Offset(0, 6),
                  child: GasCylinderImage(cylinder: order.cylinder, size: 96),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Cylinder Product Name',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.black.withValues(alpha: 0.7),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    order.cylinder.name,
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.w800,
                      color: Color(0xff1c1c1c),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${order.cylinder.sizeKg} KG Size | Model: X-Series',
                    style: const TextStyle(
                      fontSize: 15,
                      color: Color(0xff3d3d3d),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Order: #${order.code} • Qty: ${order.quantity}',
                    style: const TextStyle(fontSize: 14, color: Color(0xff3d3d3d)),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                StatusChip(status: order.status),
                const SizedBox(height: 10),
                Text(
                  AppFormatters.money(order.total),
                  style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 18),
                ),
                const SizedBox(height: 8),
                Text(AppFormatters.dateTime(order.createdAt), style: const TextStyle(color: Color(0xff6d6d6d))),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
