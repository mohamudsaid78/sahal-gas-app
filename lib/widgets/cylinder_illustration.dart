import 'package:flutter/material.dart';

class CylinderIllustration extends StatelessWidget {
  const CylinderIllustration({
    super.key,
    required this.color,
    required this.size,
  });

  final Color color;
  final double size;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size * 1.32,
      child: CustomPaint(painter: _CylinderPainter(color)),
    );
  }
}

class _CylinderPainter extends CustomPainter {
  const _CylinderPainter(this.color);

  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = color;
    final dark = Paint()..color = Color.alphaBlend(Colors.black26, color);
    final body = RRect.fromRectAndRadius(
      Rect.fromLTWH(
        size.width * .18,
        size.height * .22,
        size.width * .64,
        size.height * .68,
      ),
      Radius.circular(size.width * .18),
    );
    canvas.drawRRect(body, paint);
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(
          size.width * .28,
          size.height * .1,
          size.width * .44,
          size.height * .2,
        ),
        Radius.circular(size.width * .08),
      ),
      dark,
    );
    canvas.drawRect(
      Rect.fromLTWH(
        size.width * .38,
        size.height * .02,
        size.width * .24,
        size.height * .13,
      ),
      dark,
    );
    canvas.drawOval(
      Rect.fromLTWH(
        size.width * .22,
        size.height * .84,
        size.width * .56,
        size.height * .12,
      ),
      dark,
    );
    final flame = Path()
      ..moveTo(size.width * .5, size.height * .48)
      ..cubicTo(
        size.width * .35,
        size.height * .61,
        size.width * .42,
        size.height * .72,
        size.width * .5,
        size.height * .75,
      )
      ..cubicTo(
        size.width * .63,
        size.height * .68,
        size.width * .62,
        size.height * .56,
        size.width * .5,
        size.height * .48,
      );
    canvas.drawPath(flame, Paint()..color = Colors.white);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
