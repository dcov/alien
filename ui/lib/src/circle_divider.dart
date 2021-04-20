import 'package:flutter/material.dart';

class HorizontalCircleDivider extends StatelessWidget {

  HorizontalCircleDivider({
    Key? key,
    this.padding = 4.0,
    this.size = 2.0,
    this.color = Colors.grey,
  }) : super(key: key);

  final double padding;

  final double size;

  final Color color;

  static List<Widget> divide(List<Widget> children,
      { double padding = 4.0, double size = 2.0, Color color = Colors.grey }) {
    if (children.length < 2)
      return children;

    final result = <Widget>[];
    for (var i = 0; i < children.length; i++) {
      result.add(children[i]);
      if (i < children.length - 1)
        result.add(
          HorizontalCircleDivider(
            padding: padding,
            size: size,
            color: color));
    }
    return result;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: padding),
      decoration: ShapeDecoration(
          color: color,
          shape: CircleBorder(
            side: BorderSide(
              color: color))),
      width: size);
  }
}
