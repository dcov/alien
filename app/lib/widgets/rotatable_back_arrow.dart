import 'dart:math' as math;

import 'package:flutter/material.dart';

import 'pressable.dart';

class RotatableBackArrow extends StatefulWidget {

  RotatableBackArrow({
    Key? key,
    required this.rotated,
    this.onPress
  }) : super(key: key);

  final bool rotated;

  final VoidCallback? onPress;

  @override
  _RotatableBackArrowState createState() => _RotatableBackArrowState();
}

class _RotatableBackArrowState extends State<RotatableBackArrow> with SingleTickerProviderStateMixin {

  late final _controller = AnimationController(
      duration: const Duration(milliseconds: 300),
      lowerBound: 0.0,
      upperBound: 1.0,
      value: widget.rotated ? 1.0 : 0.0,
      vsync: this);

  @override
  void didUpdateWidget(RotatableBackArrow oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.rotated != oldWidget.rotated) {
      if (widget.rotated) {
        _controller.forward();
      } else {
        _controller.reverse();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Pressable(
      child: ValueListenableBuilder(
        valueListenable: _controller,
        builder: (BuildContext context, double value, Widget? child) {
          const endAngle = 90 * (math.pi / 180);
          return Transform.rotate(
            angle: value * endAngle,
            child: child);
        },
        child: Icon(
          Icons.arrow_back_ios_rounded,
          color: Colors.black)));
  }
}
