import 'package:flutter/material.dart';

class StitchesPainter extends CustomPainter {
  final double progress;

  StitchesPainter(this.progress);

  @override
  void paint(Canvas canvas, Size size) {
    final clipLeft = size.width * progress;
    canvas.clipRect(
      Rect.fromLTWH(clipLeft, 0, size.width - clipLeft, size.height),
    );

    const double stitchWidth = 16;
    const double gap = 8;
    final paint = Paint()
      ..color = Colors.black
      ..strokeWidth = 5;

    double x = 0;
    final y = size.height / 2;

    while (x + stitchWidth <= size.width) {
      canvas.drawLine(Offset(x, y), Offset(x + stitchWidth, y), paint);
      x += stitchWidth + gap;
    }
    if (x < size.width) {
      canvas.drawLine(Offset(x, y), Offset(size.width, y), paint);
    }
  }

  @override
  bool shouldRepaint(covariant StitchesPainter oldDelegate) =>
      oldDelegate.progress != progress;
}
