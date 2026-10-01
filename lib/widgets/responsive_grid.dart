import 'package:flutter/material.dart';

class ResponsiveGrid extends StatelessWidget {
  const ResponsiveGrid({
    super.key,
    required this.children,
    this.minItemWidth = 240,
    this.spacing = 12,
    this.mobileAspectRatio = .78,
    this.desktopAspectRatio = 1.55,
  });

  final List<Widget> children;
  final double minItemWidth;
  final double spacing;
  final double mobileAspectRatio;
  final double desktopAspectRatio;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final count = (constraints.maxWidth / minItemWidth).floor().clamp(1, 6);
        return GridView.count(
          crossAxisCount: count,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          childAspectRatio:
              minItemWidth < 180 ? mobileAspectRatio : desktopAspectRatio,
          crossAxisSpacing: spacing,
          mainAxisSpacing: spacing,
          children: children,
        );
      },
    );
  }
}
