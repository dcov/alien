import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

import 'basic.dart';
import 'builders.dart';
import 'custom_render_object.dart';

class BottomSheet extends StatefulWidget {
  
  BottomSheet({
    Key key,
    this.startMargin = 0.0,
    this.endMargin = 4.0,
    this.elevation = 4.0,
    this.radius = 24.0,
    this.handleHeight = 48.0,
    @required this.body,
    this.onStatusChanged
  }) : assert(startMargin != null),
       assert(endMargin != null),
       assert(elevation != null),
       assert(radius != null),
       assert(handleHeight != null),
       assert(body != null),
       super(key: key);

  final double startMargin;
  final double endMargin;
  final double elevation;
  final double radius;
  final double handleHeight;
  final Widget body;
  final AnimationStatusListener onStatusChanged;

  @override
  BottomSheetState createState() => BottomSheetState();
}

class BottomSheetState extends State<BottomSheet> with SingleTickerProviderStateMixin {

  static final Animatable<double> _bodyOpacityTween = CurveTween(curve: Interval(0.8, 1.0));
  static final Animatable<double> _headerOpacityTween = CurveTween(curve: Interval(0.0, 0.2));

  Widget _handle = const EmptyBox();
  set handle(Widget value) {
    assert(value != null);
    if (_handle == value)
      return;
    setState(() {
      _handle = value;
    });
  }

  AnimationController _controller;

  AnimationStatus get status => _controller.status;

  void expand() {
    _controller.forward();
  }

  void collapse() {
    _controller.reverse();
  }

  void _addListener(AnimationStatusListener listener) {
    if (listener != null)
      _controller.addStatusListener(listener);
  }

  void _removeListener(AnimationStatusListener listener) {
    if (listener != null)
      _controller.removeStatusListener(listener);
  }

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 300),
      value: 0.0,
      vsync: this
    );
    _addListener(widget.onStatusChanged);
  }

  @override
  void didUpdateWidget(BottomSheet oldWidget) {
    super.didUpdateWidget(oldWidget);
    _removeListener(oldWidget.onStatusChanged);
    _addListener(widget.onStatusChanged);
  }

  @override
  void dispose() {
    _removeListener(widget.onStatusChanged);
    _controller.dispose();
    super.dispose();
  }

  double _draggableHeight;

  void _handleDragUpdate(DragUpdateDetails details) {
    assert(_draggableHeight != null);
    final double delta = details.primaryDelta / _draggableHeight;
    _controller.value -= delta;
  }

  void _handleDragEnd(DragEndDetails details) {
    assert(_draggableHeight != null);
    if (details.velocity.pixelsPerSecond.dy.abs() > 700) {
      final double flingVelocity = details.velocity.pixelsPerSecond.dy / _draggableHeight;
      _controller.fling(velocity: -flingVelocity);
    } else if (_controller.value < 0.5) {
      _controller.fling(velocity: -1.0);
    } else {
      _controller.fling(velocity: 1.0);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: <Widget>[
        ValueListenableBuilder(
          valueListenable: _controller,
          builder: (BuildContext context, double value, Widget _) {
            return IgnorePointer(
              ignoring: value != 1.0,
              child: GestureDetector(
                onTapDown: (_) => _controller.fling(velocity: -1.0),
                child: SizedBox.expand(
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(value * 0.54)
                    ),
                  ),
                )
              ),
            );
          },
        ),
        Padding(
          padding: MediaQuery.of(context).padding,
          child: _BottomSheetLayout(
            animation: _controller,
            startMargin: widget.startMargin,
            endMargin: widget.endMargin,
            handleHeight: widget.handleHeight,
            onDraggableHeight: (double height) {
              _draggableHeight = height;
            },
            shape: Material(
              borderRadius: BorderRadius.circular(widget.handleHeight / 2),
              elevation: widget.elevation,
              color: Theme.of(context).canvasColor,
            ),
            body: ValueBuilder(
              listenable: _controller,
              valueGetter: () => _bodyOpacityTween.evaluate(_controller),
              builder: (BuildContext context, double opacity, Widget child) {
                return IgnorePointer(
                  ignoring: opacity != 1.0,
                  child: Opacity(
                    opacity: opacity,
                    child: child,
                  )
                );
              },
              child: Column(
                children: <Widget>[
                  Expanded(child: widget.body),
                  SizedBox(
                    height: widget.handleHeight,
                    child: Center(
                      child: IconButton(
                        onPressed: _controller.reverse,
                        icon: Icon(Icons.arrow_drop_down),
                      ),
                    ),
                  )
                ]
              )
            ),
            handle: GestureDetector(
              behavior: HitTestBehavior.translucent,
              dragStartBehavior: DragStartBehavior.start,
              onVerticalDragUpdate: _handleDragUpdate,
              onVerticalDragEnd: _handleDragEnd,
              child: ValueBuilder(
                listenable: _controller,
                valueGetter: () => 1.0 - _headerOpacityTween.evaluate(_controller),
                builder: (BuildContext context, double opacity, Widget child) {
                  return IgnorePointer(
                    ignoring: opacity != 1.0,
                    child: Opacity(
                      opacity: opacity,
                      child: child,
                    )
                  );
                },
                child: _handle,
              )
            ),
          )
        )
      ]
    );
  }
}

enum _BottomSheetLayoutSlot {
  shape,
  body,
  handle,
}

class _BottomSheetLayout extends CustomRenderObjectWidget {

  _BottomSheetLayout({
    Key key,
    @required this.animation,
    @required this.startMargin,
    @required this.endMargin,
    @required this.handleHeight,
    @required this.onDraggableHeight,
    @required Widget shape,
    @required Widget body,
    @required Widget handle
  }) : assert(animation != null),
       assert(startMargin != null),
       assert(endMargin != null),
       assert(handleHeight != null),
       assert(onDraggableHeight != null),
       assert(body != null),
       assert(handle != null),
       super(
         key: key,
         children: <dynamic, Widget> {
           _BottomSheetLayoutSlot.shape : shape,
           _BottomSheetLayoutSlot.body : body,
           _BottomSheetLayoutSlot.handle : handle
         }
       );

  final Animation<double> animation;

  final double startMargin;
  
  final double endMargin;

  final double handleHeight;

  final ValueChanged<double> onDraggableHeight;

  @override
  _RenderBottomSheetLayout createRenderObject(BuildContext context) {
    return _RenderBottomSheetLayout(
      animation: animation,
      startMargin: startMargin,
      endMargin: endMargin,
      handleHeight: handleHeight,
      onDraggableHeight: onDraggableHeight
    );
  }

  @override
  void updateRenderObject(BuildContext context, _RenderBottomSheetLayout renderObject) {
    renderObject..animation = animation
                ..startMargin = startMargin
                ..endMargin = endMargin
                ..handleHeight = handleHeight
                ..onDraggableHeight = onDraggableHeight;
  }
}

class _RenderBottomSheetLayout extends RenderBox with CustomRenderObjectMixin<RenderBox>,
                                                      CustomRenderBoxDefaultsMixin {

  _RenderBottomSheetLayout({
    @required Animation<double> animation,
    @required double startMargin,
    @required double endMargin,
    @required double handleHeight,
    @required ValueChanged<double> onDraggableHeight,
  }) : assert(animation != null),
       assert(startMargin != null),
       assert(endMargin != null),
       assert(handleHeight != null),
       assert(onDraggableHeight != null),
       _animation = animation,
       _startMargin = startMargin,
       _endMargin = endMargin,
       _handleHeight = handleHeight,
       _onDraggableHeight = onDraggableHeight;

  Animation<double> get animation => _animation;
  Animation<double> _animation;
  set animation(Animation<double> value) {
    assert(value != null);
    if (_animation == value)
      return;
    _animation.removeListener(markNeedsLayout);
    _animation = value;
    _animation.addListener(markNeedsLayout);
    markNeedsLayout();
  }

  double get startMargin => _startMargin;
  double _startMargin;
  set startMargin(double value) {
    assert(value != null);
    if (_startMargin == value)
      return;
    _startMargin = value;
    markNeedsLayout();
  }

  double get endMargin => _endMargin;
  double _endMargin;
  set endMargin(double value) {
    assert(value != null);
    if (_endMargin == value)
      return;
    _endMargin = value;
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

  ValueChanged<double> get onDraggableHeight => _onDraggableHeight;
  ValueChanged<double> _onDraggableHeight;
  set onDraggableHeight(ValueChanged<double> value) {
    assert(value != null);
    _onDraggableHeight = value;
  }

  @override
  void attach(PipelineOwner owner) {
    super.attach(owner);
    _animation.addListener(markNeedsLayout);
  }

  @override
  void detach() {
    _animation.removeListener(markNeedsLayout);
    super.detach();
  }

  @override
  bool get sizedByParent => true;

  @override
  void performResize() {
    size = constraints.biggest;
    assert(size.isFinite);
  }

  double get _animationValue => animation.value;

  double _previousDraggableHeight;

  @override
  void performLayout() {
    assert(hasChild(_BottomSheetLayoutSlot.shape));
    assert(hasChild(_BottomSheetLayoutSlot.body));
    assert(hasChild(_BottomSheetLayoutSlot.handle));
    assert(size.isFinite);

    layoutChild(
      _BottomSheetLayoutSlot.handle,
      BoxConstraints.tightFor(
        width: size.width,
        height: handleHeight,
      ),
    );

    final double bodyWidth = size.width - endMargin * 2;
    final Size bodySize = layoutChild(
      _BottomSheetLayoutSlot.body,
      BoxConstraints(
        minWidth: bodyWidth,
        maxWidth: bodyWidth,
        minHeight: handleHeight,
        maxHeight: size.height - (endMargin * 2)
      ),
      parentUsesSize: true
    );

    final double shapeProgress = endMargin * 2 * (1.0 - _animationValue);
    layoutChild(
      _BottomSheetLayoutSlot.shape,
      BoxConstraints.tightFor(
        width: bodyWidth + shapeProgress,
        height: bodySize.height
      ),
    );

    final double draggableHeight = (bodySize.height + endMargin - handleHeight).clamp(0.0, bodySize.height + endMargin);
    final double dx = endMargin * _animationValue;
    final double dyProgress = draggableHeight * _animationValue;
    final double dy = size.height - handleHeight - dyProgress;
    final Offset offset = Offset(dx, dy);

    positionChild(_BottomSheetLayoutSlot.shape, offset);
    positionChild(_BottomSheetLayoutSlot.body, offset);
    positionChild(_BottomSheetLayoutSlot.handle, offset);

    if (_previousDraggableHeight != draggableHeight)
      onDraggableHeight(draggableHeight);
  }

  @override
  bool hitTestChildren(HitTestResult result, { Offset position }) {
    return hitTestChild(_BottomSheetLayoutSlot.handle, result, position: position)
        || hitTestChild(_BottomSheetLayoutSlot.body, result, position: position)
        || hitTestChild(_BottomSheetLayoutSlot.shape, result, position: position);
  }

  void _paintChildren(PaintingContext context, Offset offset) {
    paintChild(_BottomSheetLayoutSlot.shape, context, offset);
    paintChild(_BottomSheetLayoutSlot.body, context, offset);
    paintChild(_BottomSheetLayoutSlot.handle, context, offset);
  }

  @override
  void paint(PaintingContext context, Offset offset) {
    if (_animationValue != 1.0) {
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