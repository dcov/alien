import 'dart:math' as math;

import 'package:flutter/rendering.dart';
import 'package:flutter/material.dart';

import 'custom_render_object.dart';

enum _SlidableLayoutSlot {
  foreground,
  background
}

class _SlidableLayout extends CustomRenderObjectWidget {

  _SlidableLayout({
    Key key,
    @required Widget foreground,
    @required Widget background,
    @required this.animation,
    @required this.onDraggableExtent
  }) : assert(foreground != null),
       assert(background != null),
       assert(animation != null),
       assert(onDraggableExtent != null),
       super(
         key: key,
         children: <dynamic, Widget>{
           _SlidableLayoutSlot.foreground : foreground,
           _SlidableLayoutSlot.background : background
         });

  final Animation<double> animation;

  final ValueChanged<double> onDraggableExtent;

  @override
  _RenderSlidableLayout createRenderObject(BuildContext context) {
    return _RenderSlidableLayout(
      animation: animation,
      onDraggableExtent: onDraggableExtent);
  }

  @override
  void updateRenderObject(BuildContext context, _RenderSlidableLayout renderObject) {
    renderObject..animation = animation
                ..onDraggableExtent = onDraggableExtent;
  }
}

class _RenderSlidableLayout extends RenderBox
    with CustomRenderObjectMixin<RenderBox>,
         CustomRenderBoxDefaultsMixin {

  _RenderSlidableLayout({
    @required Animation<double> animation,
    @required ValueChanged<double> onDraggableExtent
  }) : assert(animation != null),
       assert(onDraggableExtent != null),
       _animation = animation,
       _onDraggableExtent = onDraggableExtent;

  Animation<double> _animation;
  set animation(Animation<double> value) {
    assert(value != null);
    if (value == _animation)
      return;
    _animation = value;
    if (attached)
      _animation.addListener(markNeedsLayout);
    markNeedsLayout();
  }

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
    _animation.removeListener(markNeedsLayout);
    super.detach();
  }

  @override
  List<dynamic> get hitTestOrdering {
    return const <dynamic>[
      _SlidableLayoutSlot.foreground,
      _SlidableLayoutSlot.background
    ];
  }

  @override
  void performLayout() {
    assert(hasChild(_SlidableLayoutSlot.foreground));
    assert(hasChild(_SlidableLayoutSlot.background));

    final maxSize = constraints.biggest;

    /// The draggable extent is 80% of the width
    final draggableExtent = maxSize.width * 0.8;
    _onDraggableExtent(draggableExtent);

    /// The foreground child is always as big as can be width-wise
    final foregroundSize = layoutChild(
        _SlidableLayoutSlot.foreground,
        BoxConstraints.tightFor(width: maxSize.width),
        parentUsesSize: true);

    /// How much draggable extent has been consumed
    final draggableProgress = draggableExtent * _animation.value;
    positionChild(
        _SlidableLayoutSlot.foreground,
        Offset(-draggableProgress, 0.0));

    layoutChild(
        _SlidableLayoutSlot.background,
        BoxConstraints.tight(Size(
          draggableProgress,
          foregroundSize.height)));

    positionChild(
        _SlidableLayoutSlot.background,
        Offset(maxSize.width - draggableProgress, 0.0));

    size = foregroundSize;
  }
}

class SlidableAction {

  SlidableAction({
    @required this.onTriggered,
    @required this.icon,
    @required this.iconColor,
    @required this.backgroundColor,
    this.preBackgroundColor
  }) : assert(onTriggered != null),
       assert(icon != null),
       assert(iconColor != null),
       assert(backgroundColor != null);

  final VoidCallback onTriggered;

  final IconData icon;

  final Color iconColor;

  final Color backgroundColor;

  final Color preBackgroundColor;
}

class Slidable extends StatefulWidget {

  Slidable({
    Key key,
    @required this.child,
    this.actions = const <SlidableAction>[]
  }) : assert(child != null),
       assert(actions != null),
       super(key: key);

  final Widget child;

  final List<SlidableAction> actions;

  @override
  _SlidableState createState() => _SlidableState();
}

class _SlidableState extends State<Slidable> with SingleTickerProviderStateMixin {

  AnimationController _controller;
  ValueNotifier<SlidableAction> _currentAction;

  /// The number of sections that a user can drag through. It's determined by the number of actions, and an
  /// initial 'blank' section.
  int get _numOfSections => widget.actions.length + 1;

  /// The size of each section relative to the controller's upperBound. This is relatively cheap to calculate, but is
  /// still memoized because it's used by multiple components.
  double _sectionSize;

  /// This should be called in [initState] and [didUpdateWidget] to update the size of the sections which can change
  /// based on how many actions are passed in.
  void _setSectionSize() {
    _sectionSize = _controller.upperBound / _numOfSections;
  }

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(
        milliseconds: 250),
      value: 0.0,
      vsync: this);
    _currentAction = ValueNotifier<SlidableAction>(null);
    _setSectionSize();
  }

  @override
  void didUpdateWidget(Slidable oldWidget) {
    super.didUpdateWidget(oldWidget);
    _setSectionSize();
  }

  @override
  void dispose() {
    _currentAction.dispose();
    _controller.dispose();
    super.dispose();
  }

  void _determineCurrentAction() {
    final sectionsPassed = math.min((_controller.value / _sectionSize).floor(), _numOfSections - 1);
    _currentAction.value = sectionsPassed > 0 ? widget.actions[sectionsPassed - 1] : null;
  }

  double _draggableExtent = 0.0;
  void _setDraggableExtent(double value) {
    _draggableExtent = value;
  }

  void _handleDragUpdate(DragUpdateDetails details) {
    assert(_draggableExtent > 0);
    _controller.value -= details.primaryDelta / _draggableExtent;
    _determineCurrentAction();
  }

  void _handleDragEnd(DragEndDetails details) {
    if (_currentAction.value != null) {
      _currentAction.value.onTriggered();
    }
    _controller.fling(velocity: -1.0);
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onHorizontalDragUpdate: _handleDragUpdate,
      onHorizontalDragEnd: _handleDragEnd,
      child: _SlidableLayout(
        animation: _controller,
        onDraggableExtent: _setDraggableExtent,
        foreground: widget.child,
        background: ValueListenableBuilder(
          valueListenable: _currentAction,
          builder: (_, SlidableAction action, __) {
            if (action == null) {
              if (widget.actions.isEmpty) {
                return Material();
              }

              final firstAction = widget.actions[0];
              return ValueListenableBuilder(
                valueListenable: CurvedAnimation(
                  parent: _controller,
                  curve: Interval(0.0, _sectionSize)),
                builder: (_, double value, __) {
                  return Material(
                    color: firstAction.preBackgroundColor.withOpacity(value),
                    child: Center(
                      child: Icon(
                        firstAction.icon,
                        color: firstAction.iconColor)));
                });
            }

            return Material(
              color: action.backgroundColor,
              child: Center(
                child: Icon(
                  action.icon,
                  color: action.iconColor)));
          })));
  }
}

