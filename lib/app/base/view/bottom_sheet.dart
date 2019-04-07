import 'dart:math' as math;

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

import 'basic.dart';

class BottomSheet extends StatefulWidget {
  
  BottomSheet({
    Key key,
    this.endMargin = 8.0,
    this.elevation = 4.0,
    this.handleHeight = 48.0,
    @required this.body,
    this.onStatusChanged
  }) : assert(endMargin != null),
       assert(elevation != null),
       assert(handleHeight != null),
       assert(body != null),
       super(key: key);

  final double endMargin;
  final double elevation;
  final double handleHeight;
  final Widget body;
  final AnimationStatusListener onStatusChanged;

  @override
  BottomSheetState createState() => BottomSheetState();
}

class BottomSheetState extends State<BottomSheet> with SingleTickerProviderStateMixin {

  static final CurveTween _bodyOpacityTween = CurveTween(curve: Interval(0.8, 1.0));
  static final CurveTween _handleOpacityTween = CurveTween(curve: Interval(0.0, 0.2));

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

  double _bodyHeight;
  double get _draggableExtent {
    if (_bodyHeight == null)
        return 0.0;
    return math.max(0.0, _bodyHeight - widget.handleHeight + widget.endMargin);
  }

  void _handleDragUpdate(DragUpdateDetails details) {
    final double delta = details.primaryDelta / _draggableExtent;
    _controller.value -= delta;
  }

  void _handleDragEnd(DragEndDetails details) {
    if (details.velocity.pixelsPerSecond.dy.abs() > 700) {
      final double flingVelocity = details.velocity.pixelsPerSecond.dy / _draggableExtent;
      _controller.fling(velocity: -flingVelocity);
    } else if (_controller.value < 0.5) {
      _controller.fling(velocity: -1.0);
    } else {
      _controller.fling(velocity: 1.0);
    }
  }

  Widget _buildBottomSheet(BuildContext context, double value) {
    final double marginValue =
      (value * (_draggableExtent / widget.endMargin)).clamp(0.0, 1.0);
    final double horizontalMargin = widget.endMargin * marginValue;
    final double bottomMargin = widget.endMargin * marginValue;

    final double maxCornerRadius = widget.handleHeight / 2;
    final double bottomCornerRadius = maxCornerRadius * marginValue;

    double bodyHeightFactor;
    if (_bodyHeight == 0.0) {
      bodyHeightFactor = 0.0;
    } else {
      final double addableHeight = _bodyHeight - widget.handleHeight;
      if (addableHeight <= 0) {
        bodyHeightFactor = 0.0;
      } else {
        final double heightValue =
          math.max(0.0, value - (widget.endMargin / _draggableExtent));
        bodyHeightFactor = heightValue * (_draggableExtent / addableHeight);
      }
    }

    final double bodyOpacity = _bodyOpacityTween.transform(value);
    final double handleOpacity = 1.0 - _handleOpacityTween.transform(value);

    return Padding(
      padding: EdgeInsets.fromLTRB(
        horizontalMargin,
        widget.endMargin,
        horizontalMargin,
        bottomMargin
      ),
      child: Material(
        clipBehavior: Clip.antiAlias,
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(maxCornerRadius),
          bottom: Radius.circular(bottomCornerRadius)
        ),
        elevation: widget.elevation,
        child: Stack(
          fit: StackFit.loose,
          children: <Widget>[
            Align(
              // We align it [topCenter] instead of [bottomCenter] because it's
              // already aligned [bottomCenter] in the original build function, and
              // we want it to align normally within the [Material].
              alignment: Alignment.topCenter,
              widthFactor: 1.0,
              heightFactor: bodyHeightFactor,
              child: IgnorePointer(
                ignoring: bodyOpacity != 1.0,
                child: Opacity(
                  opacity: bodyOpacity,
                  // Normally a [GlobalKey] is used to get the [Size] of a
                  // [RenderBox], but since we need the size during build/layout
                  // and querying a [RenderBox] for it's size while it's
                  // building/doing layout, is not allowed, the best we can do
                  // is use the previous build/layout size. This means that for
                  // the initial build we won't have a size to work with, and
                  // if the child changes size there will be an inconsistency
                  // for one build, which can be noticeable if the change is
                  // drastic. Or worst case the child changes after every build
                  // in which case it'll always be off, and the material library's
                  // [BottomSheet] is probably a better option.
                  child: SizeNotifier(
                    onSize: (Size size) => _bodyHeight = size.height,
                    child: widget.body,
                  )
                )
              )
            ),
            GestureDetector(
              behavior: HitTestBehavior.translucent,
              dragStartBehavior: DragStartBehavior.start,
              onVerticalDragUpdate: _handleDragUpdate,
              onVerticalDragEnd: _handleDragEnd,
              child: SizedBox(
                height: widget.handleHeight,
                child: IgnorePointer(
                  ignoring: handleOpacity != 1.0,
                  child: Opacity(
                    opacity: handleOpacity,
                    child: _handle,
                  )
                )
              )
            ),
          ]
        )
      )
    );
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: <Widget>[
        ValueListenableBuilder<double>(
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
          child: Align(
            alignment: Alignment.bottomCenter,
            child: ValueListenableBuilder(
              valueListenable: _controller,
              builder: (BuildContext context, double value, _) {
                return _buildBottomSheet(context, value);
              }
            )
          )
        ),
      ]
    );
  }
}
