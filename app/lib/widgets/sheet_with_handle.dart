import 'package:flutter/material.dart';

final kPeekTween = Tween<double>(begin: 0.0, end: 0.5);

final kAlwaysPeekAnimation = kAlwaysCompleteAnimation.drive(kPeekTween);

final kExpandTween = Tween<double>(begin: 0.5, end: 1.0);

class SheetWithHandle extends StatelessWidget {

  SheetWithHandle({
    Key? key,
    required this.animation,
    required this.handle,
    required this.body,
  }) : super(key: key);

  final Animation<double> animation;

  final Widget handle;

  final Widget body;

  @override
  Widget build(BuildContext context) {
    return CustomMultiChildLayout(
      delegate: _Layout(
        animation: animation),
      children: <Widget>[
        LayoutId(
          id: _LayoutSlot.body,
          child: body),
        LayoutId(
          id: _LayoutSlot.handle,
          child: handle),
      ]);
  }
}

enum _LayoutSlot {
  body,
  handle,
}

class _Layout extends MultiChildLayoutDelegate {

  _Layout({
    required this.animation,
  }) : super(relayout: animation);

  final Animation<double> animation;

  @override
  void performLayout(Size size) {
    assert(hasChild(_LayoutSlot.body));
    assert(hasChild(_LayoutSlot.handle));

    final handleSize = layoutChild(_LayoutSlot.handle, BoxConstraints.loose(size));
    layoutChild(_LayoutSlot.body,
        BoxConstraints.tight(Size(size.width, size.height - handleSize.height)));

    double offsetY;
    if (animation.value <= 0.5) {
      offsetY = size.height - (handleSize.height * animation.value * 2);
    } else {
      offsetY = (size.height - handleSize.height) * ((1.0 - animation.value) * 2);
    }
    positionChild(_LayoutSlot.handle, Offset(0.0, offsetY));
    positionChild(_LayoutSlot.body, Offset(0.0, offsetY + handleSize.height));
  }

  @override
  bool shouldRelayout(_Layout oldDelegate) {
    return this.animation != oldDelegate.animation;
  }
}
