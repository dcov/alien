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
    this.bodyDecoration,
    this.handleDecoration,
    required this.body,
    required this.handle,
    this.peekHandle,
    required this.onDraggableExtent,
    required this.ignoreDrag,
    required this.onDragStart,
    required this.onDragUpdate,
    required this.onDragEnd,
    required this.onDragCancel
  }) : super(key: key);

  static const kDefaultBorderRadius = BorderRadius.vertical(top: Radius.circular(16.0));

  final Animation<double> animation;
  
  final SheetWithHandleMode mode;

  final BoxDecoration? bodyDecoration;

  final BoxDecoration? handleDecoration;

  final bool ignoreDrag;

  final ValueChanged<double> onDraggableExtent;

  final GestureDragStartCallback onDragStart;

  final GestureDragUpdateCallback onDragUpdate;

  final GestureDragEndCallback onDragEnd;

  final GestureDragCancelCallback onDragCancel;

  final Widget body;

  final Widget handle;

  final Widget? peekHandle;

  Widget _buildBody() {
    if (bodyDecoration != null) {
      return DecoratedBox(
        decoration: bodyDecoration!,
        child: body);
    }

    return body;
  }

  Widget _buildDrag() {
    final child = IgnorePointer(
      ignoring: ignoreDrag,
      child: GestureDetector(
        behavior: HitTestBehavior.translucent,
        onVerticalDragStart: onDragStart,
        onVerticalDragUpdate: onDragUpdate,
        onVerticalDragEnd: onDragEnd,
        onVerticalDragCancel: onDragCancel,
        child: const SizedBox.expand()));
    if (handleDecoration != null) {
      return DecoratedBox(
        decoration: handleDecoration!,
        child: child);
    }

    return child;
  }

  @override
  Widget build(BuildContext context) {
    return CustomMultiChildLayout(
      delegate: _SheetWithHandleLayout(
        animation: animation,
        mode: mode,
        onDraggableExtent: onDraggableExtent),
      children: <Widget>[
        LayoutId(
          id: _SheetWithHandleLayoutSlot.body,
          child: _buildBody()),
        LayoutId(
          id: _SheetWithHandleLayoutSlot.drag,
          child: _buildDrag()),
        LayoutId(
          id: _SheetWithHandleLayoutSlot.handle,
          child: handle),
        if (peekHandle != null)
          LayoutId(
            id: _SheetWithHandleLayoutSlot.peekHandle,
            child: peekHandle!),
      ]);
  }
}

enum _SheetWithHandleLayoutSlot {
  body,
  drag,
  handle,
  peekHandle,
}

class _SheetWithHandleLayout extends MultiChildLayoutDelegate {

  _SheetWithHandleLayout({
    required this.animation,
    required this.mode,
    required this.onDraggableExtent
  }) : super(relayout: animation);

  final Animation<double> animation;

  final SheetWithHandleMode mode;

  final ValueChanged<double> onDraggableExtent;

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
        layoutChild(_SheetWithHandleLayoutSlot.drag, BoxConstraints.tight(handleSize));
        final draggableExtent = size.height;
        onDraggableExtent(draggableExtent);
        offsetY = draggableExtent * (1.0 - animation.value);
        break;
      case SheetWithHandleMode.hideOrPeek:
        if (peekHandleSize != null) {
          layoutChild(_SheetWithHandleLayoutSlot.drag, BoxConstraints.tight(peekHandleSize));
          final draggableExtent = peekHandleSize.height;
          onDraggableExtent(draggableExtent);
          offsetY = size.height - (draggableExtent * animation.value);
        } else {
          layoutChild(_SheetWithHandleLayoutSlot.drag, BoxConstraints.tight(handleSize));
          final draggableExtent = handleSize.height;
          onDraggableExtent(draggableExtent);
          offsetY = size.height - (draggableExtent * animation.value);
        }
        break;
      case SheetWithHandleMode.peekOrExpand:
        if (peekHandleSize != null) {
          final height = handleSize.height 
              + ((peekHandleSize.height - handleSize.height) * (1.0 - animation.value));
          layoutChild(_SheetWithHandleLayoutSlot.drag,
              BoxConstraints.tight(Size(size.width, height)));

          final draggableExtent = size.height - peekHandleSize.height;
          onDraggableExtent(draggableExtent);
          offsetY = size.height - peekHandleSize.height - (draggableExtent * animation.value);
        } else {
          layoutChild(_SheetWithHandleLayoutSlot.drag, BoxConstraints.tight(handleSize));

          final draggableExtent = size.height - handleSize.height;
          onDraggableExtent(draggableExtent);
          offsetY = size.height - handleSize.height - (draggableExtent * animation.value);
        }
    } 

    final childOffset = Offset(0.0, offsetY);
    positionChild(_SheetWithHandleLayoutSlot.body, childOffset);
    positionChild(_SheetWithHandleLayoutSlot.drag, childOffset);
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
