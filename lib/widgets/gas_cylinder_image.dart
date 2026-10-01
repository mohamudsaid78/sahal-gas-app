import 'package:flutter/material.dart';

import '../models/gas_cylinder.dart';
import 'cylinder_illustration.dart';

class GasCylinderImage extends StatelessWidget {
  const GasCylinderImage({
    super.key,
    required this.cylinder,
    required this.size,
  });

  final GasCylinder cylinder;
  final double size;

  @override
  Widget build(BuildContext context) {
    final imageUrl = cylinder.imageUrl?.trim() ?? '';
    if (imageUrl.isEmpty) {
      return CylinderIllustration(color: cylinder.color, size: size);
    }

    return Image.network(
      imageUrl,
      width: size,
      height: size,
      fit: BoxFit.contain,
      errorBuilder: (context, error, stackTrace) =>
          CylinderIllustration(color: cylinder.color, size: size),
    );
  }
}
