import 'package:flutter/material.dart';

import '../core/formatters.dart';
import '../models/gas_cylinder.dart';
import 'gas_cylinder_image.dart';

class CylinderCard extends StatelessWidget {
  const CylinderCard({
    super.key,
    required this.cylinder,
    required this.onAdd,
    this.onTap,
  });

  final GasCylinder cylinder;
  final VoidCallback onAdd;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: GasCylinderImage(cylinder: cylinder, size: 76),
              ),
              const SizedBox(height: 10),
              Text(
                cylinder.name,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(fontWeight: FontWeight.w800),
              ),
              const SizedBox(height: 4),
              Text(
                cylinder.description,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(color: Colors.black54, fontSize: 12),
              ),
              const Spacer(),
              Row(
                children: [
                  Text(
                    AppFormatters.money(cylinder.price),
                    style: const TextStyle(fontWeight: FontWeight.w800),
                  ),
                  const Spacer(),
                  IconButton.filled(
                    visualDensity: VisualDensity.compact,
                    tooltip: 'Add to cart',
                    onPressed: cylinder.stock > 0 ? onAdd : null,
                    icon: const Icon(Icons.add),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
