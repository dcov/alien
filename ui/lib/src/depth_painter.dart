import 'package:flutter/widgets.dart';

class DepthPainter extends CustomPainter {
  
  DepthPainter({
    required this.padding,
    required this.linePaint
  });

  final double padding;

  final Paint linePaint;

  @override
  void paint(Canvas canvas, Size size) {
    final lineCount = size.width / padding;
    for (int i = 1; i <= lineCount; i++) {
      final dx = padding * i;
      canvas.drawLine(
        Offset(dx, 0.0),
        Offset(dx, size.height),
        linePaint);
    }
  }

  @override
  bool shouldRepaint(DepthPainter oldPainter) {
    return this.padding != oldPainter.padding ||
           this.linePaint != oldPainter.linePaint;
  }
}
