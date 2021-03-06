import 'dart:math' as math;

import 'package:flutter/widgets.dart';

class _RRectTopBorderPainter extends CustomPainter {

  _RRectTopBorderPainter({
    required this.radius,
    required this.width,
    required this.color
  });

  final double radius;

  final double width;

  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final rectWH = radius * 2;
    canvas.drawPath(
      Path()
        ..moveTo(0.0, 0.0)
        ..arcTo(
            Rect.fromLTWH(0.0, 0.0, rectWH, rectWH),
            math.pi,
            math.pi/2,
            false)
        ..lineTo(radius + (size.width - (radius * 2)), 0.0)
        ..arcTo(
            Rect.fromLTWH(size.width-rectWH, 0.0, rectWH, rectWH),
            math.pi + (math.pi / 2),
            math.pi / 2,
            false),
      Paint()
        ..color = color
        ..strokeWidth = width
        ..style = PaintingStyle.stroke);
  }

  @override
  bool shouldRepaint(_RRectTopBorderPainter oldPainter) {
    return this.radius != oldPainter.radius ||
           this.width != oldPainter.width ||
           this.color != oldPainter.color;
  }
}

class RRectTopBorder extends StatelessWidget {

  RRectTopBorder({
    Key? key,
    required this.radius,
    required this.width,
    required this.color,
    required this.child
  }) : super(key: key);

  final double radius;

  final double width;

  final Color color;

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: <Widget>[
        child,
        IgnorePointer(
          ignoring: true,
          child: CustomPaint(
            painter: _RRectTopBorderPainter(
              radius: radius,
              width: width,
              color: color),
            child: SizedBox.expand())),
      ]);
  }
}
