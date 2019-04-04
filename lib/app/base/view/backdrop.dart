import 'dart:math' as math;

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

import 'custom_render_object.dart';

class Backdrop extends StatefulWidget {

  Backdrop({
    Key key,
    this.bottomMargin = 24.0,
    this.handleHeight = 40.0,
    this.handleStartPadding = 72.0,
    this.handleEndPadding = 24.0,
    @required this.backLayer,
    @required this.frontLayer,
    @required this.handle,
  }) : assert(handleHeight != null),
       assert(handleStartPadding != null),
       assert(handleEndPadding != null),
       assert(backLayer != null),
       assert(frontLayer != null),
       assert(handle != null),
       super(key: key);

  final double bottomMargin;

  final double handleHeight;

  final double handleStartPadding;

  final double handleEndPadding;

  final Widget backLayer;

  final Widget frontLayer;

  final Widget handle;

  @override
  BackdropState createState() => BackdropState();
}

class BackdropState extends State<Backdrop> with SingleTickerProviderStateMixin {

  AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      value: 0.0,
      duration: const Duration(milliseconds: 300),
      vsync: this
    );
  }

  double _draggableExtent;

  void _updateDraggableExtent(double newExtent) => _draggableExtent = newExtent;

  void _handleDragUpdate(DragUpdateDetails details) {
    assert(_draggableExtent != null);
    final double delta = details.primaryDelta / _draggableExtent;
    _controller.value += delta;
  }

  void _handleDragEnd(DragEndDetails details) {
    assert(_draggableExtent != null);
    if (details.velocity.pixelsPerSecond.dy.abs() > 700) {
      final double flingVelocity = details.velocity.pixelsPerSecond.dy / _draggableExtent;
      _controller.fling(velocity: flingVelocity);
    } else if (_controller.value < 0.5) {
      _controller.fling(velocity: -1.0);
    } else {
      _controller.fling(velocity: 1.0);
    }
  }

  @override
  Widget build(BuildContext context) {
    return _BackdropLayout(
      bottomMargin: widget.bottomMargin,
      handleHeight: widget.handleHeight,
      handleStartPadding: widget.handleStartPadding,
      handleEndPadding: widget.handleEndPadding,
      animation: _controller,
      onDraggableExtent: _updateDraggableExtent,
      backLayer: widget.backLayer,
      frontLayer: widget.frontLayer,
      handle: GestureDetector(
        behavior: HitTestBehavior.opaque,
        dragStartBehavior: DragStartBehavior.start,
        onVerticalDragUpdate: _handleDragUpdate,
        onVerticalDragEnd: _handleDragEnd,
        child: widget.handle,
      ),
    );
  }
}

enum _BackdropLayoutSlot {
  backLayer,
  frontLayer,
  handle,
}

class _BackdropLayout extends CustomRenderObjectWidget {

  _BackdropLayout({
    Key key,
    @required this.bottomMargin,
    @required this.handleHeight,
    @required this.handleStartPadding,
    @required this.handleEndPadding,
    @required this.animation,
    @required this.onDraggableExtent,
    @required Widget backLayer,
    @required Widget frontLayer,
    @required Widget handle,
  }) : assert(handleHeight != null),
       assert(handleStartPadding != null),
       assert(handleEndPadding != null),
       assert(animation != null),
       assert(onDraggableExtent != null),
       assert(backLayer != null),
       assert(frontLayer != null),
       assert(handle != null),
       super(
         key: key,
         children: <dynamic, Widget>{
           _BackdropLayoutSlot.backLayer : backLayer,
           _BackdropLayoutSlot.frontLayer : frontLayer,
           _BackdropLayoutSlot.handle : handle,
         }
       );

  final double bottomMargin;

  final double handleHeight;

  final double handleStartPadding;
  
  final double handleEndPadding;

  final Animation<double> animation;

  final ValueChanged<double> onDraggableExtent;

  @override
  _RenderBackdropLayout createRenderObject(BuildContext context) {
    return _RenderBackdropLayout(
      bottomMargin: bottomMargin,
      handleHeight: handleHeight,
      handleStartPadding: handleStartPadding,
      handleEndPadding: handleEndPadding,
      animation: animation,
      onDraggableExtent: onDraggableExtent
    );
  }

  @override
  void updateRenderObject(BuildContext context, _RenderBackdropLayout renderObject) {
    renderObject..bottomMargin = bottomMargin
                ..handleHeight = handleHeight
                ..handleStartPadding = handleStartPadding
                ..handleEndPadding = handleEndPadding
                ..animation = animation
                ..onDraggableExtent = onDraggableExtent;
  }
}

class _RenderBackdropLayout extends RenderBox with CustomRenderObjectMixin<RenderBox>,
                                                   CustomRenderBoxDefaultsMixin {
  
  _RenderBackdropLayout({
    @required double bottomMargin,
    @required double handleHeight,
    @required double handleStartPadding,
    @required double handleEndPadding,
    @required Animation<double> animation,
    @required ValueChanged<double> onDraggableExtent,
  }) : assert(bottomMargin != null),
       assert(handleHeight != null),
       assert(handleStartPadding != null),
       assert(handleEndPadding != null),
       assert(animation != null),
       assert(onDraggableExtent != null),
       _bottomMargin = bottomMargin,
       _handleHeight = handleHeight,
       _handleStartPadding = handleStartPadding,
       _handleEndPadding = handleEndPadding,
       _animation = animation,
       _onDraggableExtent = onDraggableExtent;

  double get bottomMargin => _bottomMargin;
  double _bottomMargin;
  set bottomMargin(double value) {
    assert(value != null);
    if (_bottomMargin == value)
      return;
    _bottomMargin = value;
    markNeedsLayout();
  }

  double get handleHeight => _handleHeight;
  double _handleHeight;
  set handleHeight(double value) {
    assert(value != null);
    if (_handleHeight == value)
      return;
    _handleHeight = value;
    markNeedsLayout();
  }

  double get handleStartPadding => _handleStartPadding;
  double _handleStartPadding;
  set handleStartPadding(double value) {
    assert(value != null);
    if(_handleStartPadding == value)
      return;
    _handleStartPadding = value;
    markNeedsLayout();
  }

  double get handleEndPadding => _handleEndPadding;
  double _handleEndPadding;
  set handleEndPadding(double value) {
    assert(value != null);
    if (_handleEndPadding == value)
      return;
    _handleEndPadding = value;
    markNeedsLayout();
  }

  Animation<double> get animation => _animation;
  Animation<double> _animation;
  set animation(Animation<double> value) {
    assert(value != null);
    if (_animation == value)
      return;
    _animation = value;
    if (attached)
      _animation.addListener(markNeedsLayout);
    markNeedsLayout();
  }

  ValueChanged<double> get onDraggableExtent => _onDraggableExtent;
  ValueChanged<double> _onDraggableExtent;
  set onDraggableExtent(ValueChanged<double> value) {
    assert(value != null);
    _onDraggableExtent = value;
  }

  @override
  void attach(PipelineOwner owner) {
    super.attach(owner);
    _animation.addListener(markNeedsLayout);
  }

  @override
  void detach() {
    super.detach();
    _animation.removeListener(markNeedsLayout);
  }

  double get _animationValue => animation.value;

  double _latestDraggableExtent;

  @override
  void performLayout() {
    assert(constraints.hasBoundedHeight);
    assert(constraints.hasBoundedWidth);
    assert(hasChild(_BackdropLayoutSlot.backLayer));
    assert(hasChild(_BackdropLayoutSlot.frontLayer));
    assert(hasChild(_BackdropLayoutSlot.handle));

    final Size biggestSize = constraints.biggest;

    final double minBackLayerHeight = handleStartPadding + handleHeight;
    final Size backLayerSize = layoutChild(
      _BackdropLayoutSlot.backLayer,
      BoxConstraints(
        maxWidth: biggestSize.width,
        minHeight: minBackLayerHeight,
        maxHeight: biggestSize.height - handleEndPadding - bottomMargin
      ),
      parentUsesSize: true
    );

    final double frontLayerHeight = biggestSize.height - minBackLayerHeight - bottomMargin;
    layoutChild(
      _BackdropLayoutSlot.frontLayer,
      BoxConstraints(
        maxWidth: biggestSize.width,
        minHeight: frontLayerHeight,
        maxHeight: frontLayerHeight
      ),
    );

    layoutChild(
      _BackdropLayoutSlot.handle,
      BoxConstraints(
        minWidth: biggestSize.width,
        maxWidth: biggestSize.width,
        minHeight: handleHeight,
        maxHeight: handleHeight
      ),
    );

    final double draggableExtent = backLayerSize.height - minBackLayerHeight;
    if (_latestDraggableExtent != draggableExtent) {
      _latestDraggableExtent = draggableExtent;
      onDraggableExtent(draggableExtent);
    }

    final double amountDragged = draggableExtent * _animationValue;

    positionChild(
      _BackdropLayoutSlot.frontLayer,
      Offset(0.0, minBackLayerHeight + amountDragged)
    );

    positionChild(
      _BackdropLayoutSlot.handle,
      Offset(0.0, handleStartPadding + amountDragged)
    );

    size = Size(biggestSize.width, minBackLayerHeight + frontLayerHeight);
  }

  @override
  bool hitTestChildren(HitTestResult result, { Offset position }) {
    assert(hasChild(_BackdropLayoutSlot.backLayer));
    assert(hasChild(_BackdropLayoutSlot.frontLayer));
    assert(hasChild(_BackdropLayoutSlot.handle));
    return hitTestChild(_BackdropLayoutSlot.handle, result, position: position)
        || hitTestChild(_BackdropLayoutSlot.frontLayer, result, position: position)
        || hitTestChild(_BackdropLayoutSlot.backLayer, result, position: position);
  }

  void _paintChildren(PaintingContext context, Offset offset) {
    paintChild(_BackdropLayoutSlot.backLayer, context, offset);
    paintChild(_BackdropLayoutSlot.frontLayer, context, offset);
    paintChild(_BackdropLayoutSlot.handle, context, offset);
  }

  @override
  void paint(PaintingContext context, Offset offset) {
    assert(hasChild(_BackdropLayoutSlot.backLayer));
    assert(hasChild(_BackdropLayoutSlot.frontLayer));
    assert(hasChild(_BackdropLayoutSlot.handle));
    if (_animationValue != 0.0) {
      context.pushClipRect(
        needsCompositing,
        offset,
        Offset.zero & size,
        _paintChildren
      );
    } else {
      _paintChildren(context, offset);
    }
  }
}