import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

enum SheetWithHandleMode {
  hideOrExpand,
  hideOrPeek,
  peekOrExpand,
}

class SheetWithHandle extends StatelessWidget {

  SheetWithHandle({
    Key? key,
    required this.animation,
    required this.mode,
    this.borderRadius = kDefaultBorderRadius,
    required this.body,
    required this.handleMaterial,
    required this.handle,
    this.peekHandle,
  }) : super(key: key);

  static const kDefaultBorderRadius = BorderRadius.vertical(top: Radius.circular(16.0));

  final Animation<double> animation;
  
  final SheetWithHandleMode mode;

  final BorderRadius borderRadius;

  final Widget body;

  final Widget handleMaterial;

  final Widget handle;

  final Widget? peekHandle;

  static double calculateExpandableHeight({
      required double sheetHeight,
      required double peekHeight,
    }) {
    return sheetHeight - peekHeight;
  }

  @override
  Widget build(BuildContext context) {
    return CustomMultiChildLayout(
      delegate: _SheetWithHandleLayout(
        animation: animation,
        mode: mode),
      children: <Widget>[
        LayoutId(
          id: _SheetWithHandleLayoutSlot.body,
          child: ClipRRect(
            borderRadius: borderRadius,
            child: body)),
        LayoutId(
          id: _SheetWithHandleLayoutSlot.handleMaterial,
          child: handleMaterial),
        LayoutId(
          id: _SheetWithHandleLayoutSlot.handle,
          child: ClipRRect(
            borderRadius: borderRadius,
            child: handle)),
        if (peekHandle != null)
          LayoutId(
            id: _SheetWithHandleLayoutSlot.peekHandle,
            child: ClipRRect(
              borderRadius: borderRadius,
              child: peekHandle!)),
      ]);
  }
}

enum _SheetWithHandleLayoutSlot {
  body,
  handleMaterial,
  handle,
  peekHandle,
}

class _SheetWithHandleLayout extends MultiChildLayoutDelegate {

  _SheetWithHandleLayout({
    required this.animation,
    required this.mode
  }) : super(relayout: animation);

  final Animation<double> animation;

  final SheetWithHandleMode mode;

  @override
  void performLayout(Size size) {
    assert(hasChild(_SheetWithHandleLayoutSlot.body));
    assert(hasChild(_SheetWithHandleLayoutSlot.handle));

    layoutChild(_SheetWithHandleLayoutSlot.body,
        BoxConstraints.tight(size));

    final handleSize = layoutChild(_SheetWithHandleLayoutSlot.handle, BoxConstraints.loose(size));

    Size? peekHandleSize;
    if (hasChild(_SheetWithHandleLayoutSlot.peekHandle)) {
      peekHandleSize = layoutChild(_SheetWithHandleLayoutSlot.peekHandle, BoxConstraints.loose(size));
    }

    double offsetY;
    switch (mode) {
      case SheetWithHandleMode.hideOrExpand:
        layoutChild(_SheetWithHandleLayoutSlot.handleMaterial, BoxConstraints.tight(handleSize));
        offsetY = size.height * (1.0 - animation.value);
        break;
      case SheetWithHandleMode.hideOrPeek:
        if (peekHandleSize != null) {
          layoutChild(_SheetWithHandleLayoutSlot.handleMaterial, BoxConstraints.tight(peekHandleSize));
          offsetY = size.height - (peekHandleSize.height * animation.value);
        } else {
          layoutChild(_SheetWithHandleLayoutSlot.handleMaterial, BoxConstraints.tight(handleSize));
          offsetY = size.height - (handleSize.height * animation.value);
        }
        break;
      case SheetWithHandleMode.peekOrExpand:
        if (peekHandleSize != null) {
          final height = handleSize.height 
              + ((peekHandleSize.height - handleSize.height) * (1.0 - animation.value));
          layoutChild(_SheetWithHandleLayoutSlot.handleMaterial,
              BoxConstraints.tight(Size(size.width, height)));

          final expandableHeight = SheetWithHandle.calculateExpandableHeight(
              sheetHeight: size.height, peekHeight: peekHandleSize.height);
          offsetY = size.height - peekHandleSize.height - (expandableHeight * animation.value);
        } else {
          layoutChild(_SheetWithHandleLayoutSlot.handleMaterial, BoxConstraints.tight(handleSize));

          final expandableHeight = SheetWithHandle.calculateExpandableHeight(
              sheetHeight: size.height, peekHeight: handleSize.height);
          offsetY = size.height - handleSize.height - (expandableHeight * animation.value);
        }
    } 

    final childOffset = Offset(0.0, offsetY);
    positionChild(_SheetWithHandleLayoutSlot.body, childOffset);
    positionChild(_SheetWithHandleLayoutSlot.handleMaterial, childOffset);
    positionChild(_SheetWithHandleLayoutSlot.handle, childOffset);
    if (hasChild(_SheetWithHandleLayoutSlot.peekHandle)) {
      positionChild(_SheetWithHandleLayoutSlot.peekHandle, childOffset);
    }
  }

  @override
  bool shouldRelayout(_SheetWithHandleLayout oldDelegate) {
    return this.animation != oldDelegate.animation ||
           this.mode != oldDelegate.mode;
  }
}
