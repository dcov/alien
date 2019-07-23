import 'dart:math' as math;

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart'; 
import 'package:flutter/rendering.dart';

@immutable
class SlidableAction {
  
  SlidableAction({
    this.onTrigger,
    this.icon,
    this.backgroundColor,
  });

  final VoidCallback onTrigger;
  final IconData icon;
  final Color backgroundColor;
}

/// The behvior of the [Slidable] that determines when the action is triggered.
enum SlidableBehavior {
  /// Trigger the action as soon as the drag is released
  release,

  /// Trigger the action once the animation to close the [Slidable] ends.
  end
}

class Slidable extends StatefulWidget {

  Slidable({
    Key key,
    this.behavior = SlidableBehavior.release,
    this.elevation = 1.0,
    this.backgroundColor,
    this.inactiveColor,
    this.triggerExtent = 48.0,
    this.startActions = const <SlidableAction>[],
    this.endActions = const <SlidableAction>[],
    this.child,
  }) : assert(elevation != null),
       assert(startActions != null),
       assert(endActions != null),
       super(key: key);

  final SlidableBehavior behavior;
  final double elevation;
  final Color backgroundColor;
  final Color inactiveColor;
  final double triggerExtent;
  final List<SlidableAction> startActions;
  final List<SlidableAction> endActions;
  final Widget child;

  @override
  _SlidableState createState() => _SlidableState();
}

class _SlidableState extends State<Slidable> with SingleTickerProviderStateMixin {

  static const double _centeredValue = 0.5;

  AnimationController _controller;
  List<SlidableAction> _leftActions;
  List<SlidableAction> _rightActions;
  bool _canDragLeft;
  bool _canDragRight;

  bool get _isCentered => _controller.value == _centeredValue;

  /// The latest max width of the [\_SlidableLayout] child. Is only safe to use
  /// during event handlers or if [\_controller.value] isn't [\_centeredValue];
  double _layoutWidth;

  /// The current amount dragged where a value of -1.0 means that the user has
  /// dragged the full [\_layoutWidth] amount to the left, a value of 1.0 means
  /// that the user has dragged the full [\_layoutWidth] amount to the right,
  /// and a value of of 0.0 means that no amount has been dragged.
  double get _progress => (_controller.value - 0.5) * 2;

  /// The amount of pixels that have been dragged. Is only safe to use during
  /// event handlers or if [\_progress] isn't 0;
  double get _extentDragged => _layoutWidth * _progress;

  SlidableAction _markedAction;
  bool _actionTriggered;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      value: _centeredValue,
      vsync: this
    )..addListener(_checkEndAction);
  }

  void _checkEndAction() {
    if (_controller.value == _centeredValue
        && widget.behavior == SlidableBehavior.end
        && _markedAction != null
        && !_actionTriggered) {
      _triggerAction();
    }
  }

  void _triggerAction() {
    assert(_markedAction != null);
    if (_markedAction.onTrigger != null) {
      _markedAction.onTrigger();
    }
    _actionTriggered = true;
  }

  void _handleDragDown(DragDownDetails details) {
    if (_controller.isAnimating) {
      _controller.stop();
    }
    if (_markedAction != null) {
      _markedAction = null;
      _actionTriggered = null;
      _controller.notifyListeners();
    }
  }

  void _handleDragCancel() {
    if(_controller.value != _centeredValue) {
      _animateToCenter();
    }
  }

  void _animateToCenter() {
    final double duration = _extentDragged.abs() / _layoutWidth * 300;
    _controller.animateTo(
      _centeredValue,
      curve: Curves.easeInOut,
      duration: Duration(milliseconds: duration.round())
    );
  }

  void _handleDragUpdate(DragUpdateDetails details) {
    final double value = _controller.value + (details.primaryDelta / _layoutWidth / 2);
    if ((value > _centeredValue && _canDragRight) || (value < _centeredValue && _canDragLeft))
      _controller.value = value; 
    else if (_controller.value != _centeredValue)
      _controller.value = _centeredValue;
  }

  void _handleDragEnd(DragEndDetails details) {
    _markAction();

    if (_markedAction != null
        && !_actionTriggered
        && widget.behavior == SlidableBehavior.release) {
      _triggerAction();
    }

    _animateToCenter();
  }

  void _markAction() {
    final double extentDragged = _extentDragged;
    if (!_extentIsArmed(extentDragged))
      return;

    _markedAction = _actionFromExtent(extentDragged);
    _actionTriggered = false;
  }

  bool _extentIsArmed(double extent) {
    return extent.abs() > widget.triggerExtent;
  }

  SlidableAction _actionFromExtent(double extent) {
    if (extent == 0)
      return null;
      
    List<SlidableAction> actions = extent > 0 ? _leftActions : _rightActions;

    final int index = ((extent.abs() / widget.triggerExtent) - 1).floor().clamp(0, actions.length - 1);
    return actions[index];
  }

  Widget _buildAction(
    SlidableAction action,
    bool isArmed,
    Color fallbackColor,
    Color inactiveColor,
    bool wrapWithPainter
  ) {

    final Color backgroundColor = isArmed ? (action.backgroundColor ?? fallbackColor) : inactiveColor;
    Widget icon = Icon(action.icon);

    /// We're building a left-side [SlidableAction] so we'll wrap the icon in an
    /// [_OffscreenPainter] so that it forces the icon to paint offscreen.
    /// Otherwise the icon would 'stick' to the left edge.
    if (wrapWithPainter)
      icon = _OffScreenPainter(minWidth: 24.0, child: icon);

    return DecoratedBox(
      decoration: BoxDecoration(color: backgroundColor),
      child: Center(child: icon)
    );
  }

  @override
  Widget build(BuildContext context) {

    final Color inactiveColor = widget.inactiveColor ?? Theme.of(context).backgroundColor;
    final Color fallbackColor = Theme.of(context).accentColor;

    final TextDirection direction = Directionality.of(context);
    switch (direction) {
      case TextDirection.ltr:
        _leftActions = widget.startActions;
        _rightActions = widget.endActions;
        break;
      case TextDirection.rtl:
        _rightActions = widget.startActions;
        _leftActions = widget.endActions;
        break;
    }

    _canDragLeft = _rightActions.isNotEmpty;
    _canDragRight = _leftActions.isNotEmpty;

    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {

        final bool isNotCentered = !_isCentered;

        Widget left, right;
        left = right = const SizedBox(width: 0.0, height: 0.0);
        if (isNotCentered) {
          final double extentDragged = _extentDragged;
          final SlidableAction action = _markedAction ?? _actionFromExtent(extentDragged);
          final bool isArmed = _markedAction != null || _extentIsArmed(extentDragged);
          extentDragged > 0 
            ? left = _buildAction(action, isArmed, fallbackColor, inactiveColor, true)
            : right = _buildAction(action, isArmed, fallbackColor, inactiveColor, false);
        }

        final Widget center = GestureDetector(
          behavior: HitTestBehavior.translucent,
          dragStartBehavior: DragStartBehavior.start,
          onHorizontalDragDown: _handleDragDown,
          onHorizontalDragCancel:  _handleDragCancel,
          onHorizontalDragUpdate: _handleDragUpdate,
          onHorizontalDragEnd: _handleDragEnd,
          child: Material(
            type: MaterialType.canvas,
            elevation: widget.elevation,
            color: widget.backgroundColor,
            child: AbsorbPointer(
              absorbing: isNotCentered,
              child: widget.child,
            )
          )
        );

        return _SlidableLayout(
          progress: _progress,
          onLayoutWidth: (width) => _layoutWidth = width,
          left: left,
          right: right,
          center: center
        );
      }
    );
  }
}

enum _SlidableLayoutSlot {
  left,
  right,
  center,
}

class _SlidableLayout extends RenderObjectWidget {

  _SlidableLayout({
    Key key,
    @required this.progress,
    @required this.onLayoutWidth,
    @required this.left,
    @required this.right,
    @required this.center
  }) : super(key: key);

  final double progress;
  final ValueChanged<double> onLayoutWidth;
  final Widget left;
  final Widget right;
  final Widget center;

  @override
  _SlidableLayoutElement createElement() => _SlidableLayoutElement(this);

  @override
  _RenderSlidableLayout createRenderObject(BuildContext context) {
    return _RenderSlidableLayout(
      progress: progress,
      onLayoutWidth: onLayoutWidth
    );
  }

  @override
  void updateRenderObject(BuildContext context, _RenderSlidableLayout renderObject) {
    renderObject
      ..progress = progress
      ..onLayoutWidth = onLayoutWidth;
  }
}

class _SlidableLayoutElement extends RenderObjectElement {

  _SlidableLayoutElement(_SlidableLayout widget) : super(widget);

  final Map<_SlidableLayoutSlot, Element> slotToChild = Map<_SlidableLayoutSlot, Element>();
  final Map<Element, _SlidableLayoutSlot> childToSlot = Map<Element, _SlidableLayoutSlot>();

  @override
  _SlidableLayout get widget => super.widget;

  @override
  _RenderSlidableLayout get renderObject => super.renderObject;

  @override
  void visitChildren(ElementVisitor visitor) {
    slotToChild.values.forEach(visitor);
  }

  @override
  void forgetChild(Element child) {
    assert(slotToChild.values.contains(child));
    assert(childToSlot.keys.contains(child));
    final _SlidableLayoutSlot slot = childToSlot[child];
    childToSlot.remove(child);
    slotToChild.remove(slot);
  }

  void _updateChild(Widget widget, _SlidableLayoutSlot slot) {
    final Element oldChild = slotToChild[slot];
    final Element newChild = updateChild(oldChild, widget, slot);
    if (oldChild != null) {
      childToSlot.remove(oldChild);
      slotToChild.remove(slot);
    }
    if (newChild != null) {
      slotToChild[slot] = newChild;
      childToSlot[newChild] = slot;
    }
  }

  @override
  void mount(Element parent, dynamic newSlot) {
    super.mount(parent, newSlot);
    _updateChild(widget.left, _SlidableLayoutSlot.left );
    _updateChild(widget.right, _SlidableLayoutSlot.right);
    _updateChild(widget.center, _SlidableLayoutSlot.center);
  }

  @override
  void update(_SlidableLayout newWidget) {
    super.update(newWidget);
    assert(widget == newWidget);
    _updateChild(widget.left, _SlidableLayoutSlot.left);
    _updateChild(widget.right, _SlidableLayoutSlot.right);
    _updateChild(widget.center, _SlidableLayoutSlot.center);
  }

  void _updateRenderObject(RenderObject child, _SlidableLayoutSlot slot) {
    switch (slot) {
      case _SlidableLayoutSlot.left:
        renderObject.left = child;
        break;
      case _SlidableLayoutSlot.right:
        renderObject.right = child;
        break;
      case _SlidableLayoutSlot.center:
        renderObject.center = child;
        break;
    }
  }

  @override
  void insertChildRenderObject(RenderObject child, _SlidableLayoutSlot slot) {
    assert(child is RenderBox);
    _updateRenderObject(child, slot);
    assert(renderObject.childToSlot.keys.contains(child));
    assert(renderObject.slotToChild.keys.contains(slot));
  }

  @override
  void removeChildRenderObject(RenderObject child) {
    assert(child is RenderBox);
    assert(renderObject.childToSlot.keys.contains(child));
    _SlidableLayoutSlot slot = renderObject.childToSlot[child];
    _updateRenderObject(null, slot);
    assert(!renderObject.childToSlot.keys.contains(child));
    assert(!renderObject.slotToChild.keys.contains(slot));
  }

  @override
  void moveChildRenderObject(RenderObject child, slot) {
    assert(false, 'not reachable');
  }
}

class _RenderSlidableLayout extends RenderBox {

  _RenderSlidableLayout({
    double progress,
    this.onLayoutWidth
  }) : assert(progress != null),
       assert(onLayoutWidth != null),
       _progress = progress;

  final Map<_SlidableLayoutSlot, RenderBox> slotToChild = Map<_SlidableLayoutSlot, RenderBox>();
  final Map<RenderBox, _SlidableLayoutSlot> childToSlot = Map<RenderBox, _SlidableLayoutSlot>();

  RenderBox get left => _left;
  RenderBox _left;
  set left(RenderBox value) {
    _left = _updateChild(_left, value, _SlidableLayoutSlot.left);
  }

  RenderBox get right => _right;
  RenderBox _right;
  set right(RenderBox value) {
    _right = _updateChild(_right, value, _SlidableLayoutSlot.right);
  }

  RenderBox get center => _center;
  RenderBox _center;
  set center(RenderBox value) {
    _center = _updateChild(_center, value, _SlidableLayoutSlot.center);
  }

  RenderBox _updateChild(RenderBox oldChild, RenderBox newChild, _SlidableLayoutSlot slot) {
    if (oldChild != null) {
      dropChild(oldChild);
      childToSlot.remove(oldChild);
      slotToChild.remove(slot);
    }
    if (newChild != null) {
      childToSlot[newChild] = slot;
      slotToChild[slot] = newChild;
      adoptChild(newChild);
    }
    return newChild;
  }

  Iterable<RenderBox> get _children sync* {
    if (left != null)
      yield left;

    if (right != null)
      yield right;

    if (center != null)
      yield center;
  }

  double get progress => _progress;
  double _progress;
  set progress(double value) {
    assert(value != null);
    if (value == _progress)
      return;
    _progress = value;
    markNeedsLayout();
  }
  
  ValueChanged<double> onLayoutWidth;

  @override
  void attach(PipelineOwner owner) {
    super.attach(owner);
    for (RenderBox child in _children)
      child.attach(owner);
  }

  @override
  void detach() {
    super.detach();
    for (RenderBox child in _children)
      child.detach();
  }

  @override
  void redepthChildren() {
    _children.forEach(redepthChild);
  }

  @override
  void visitChildren(RenderObjectVisitor visitor) {
    _children.forEach(visitor);
  }

  @override
  List<DiagnosticsNode> debugDescribeChildren() {
    final List<DiagnosticsNode> value = <DiagnosticsNode>[];
    void add(RenderBox child, String name) {
      if (child != null)
        value.add(child.toDiagnosticsNode(name: name));
    }
    add(left, 'left');
    add(right, 'right');
    add(center, 'center');
    return value;
  }

  @override
  bool get sizedByParent => false;

  @override
  double computeMinIntrinsicWidth(double height) {
    return center?.computeMinIntrinsicWidth(height) ?? 0.0;
  }

  @override
  double computeMaxIntrinsicWidth(double height) {
    return center?.computeMaxIntrinsicWidth(height) ?? 0.0;
  }

  @override
  double computeMinIntrinsicHeight(double width) {
    return center?.computeMinIntrinsicHeight(width) ?? 0.0;
  }

  @override
  double computeMaxIntrinsicHeight(double width) {
    return center?.computeMaxIntrinsicHeight(width) ?? 0.0;
  }

  @override
  double computeDistanceToActualBaseline(TextBaseline baseline) {
    return center?.computeDistanceToActualBaseline(baseline) ?? null;
  }

  Size _layoutChild(RenderBox child, BoxConstraints constraints) {
    assert(child != null);
    child.layout(constraints, parentUsesSize: true);
    return child.size;
  }

  void _positionChild(RenderBox child, Offset offset) {
    assert(child != null);
    final BoxParentData parentData = child.parentData;
    parentData.offset = offset;
  }

  @override
  void performLayout() {
    assert(constraints.hasBoundedWidth);
    size = _layoutChild(center, BoxConstraints.tightFor(width: constraints.maxWidth));
    assert(onLayoutWidth != null);
    onLayoutWidth(size.width);

    final double leftWidth = progress > 0 ? size.width * progress : 0.0;
    _layoutChild(left, BoxConstraints.tight(Size(leftWidth, size.height)));

    final double rightWidth = progress < 0 ? size.width * -progress : 0.0;
    _layoutChild(right, BoxConstraints.tight(Size(rightWidth, size.height)));

    _positionChild(left, Offset(0.0, 0.0));
    _positionChild(right, Offset(size.width - rightWidth,0.0));
    _positionChild(center, Offset(leftWidth - rightWidth, 0.0));
  }

  void _paintChild(PaintingContext context, RenderBox child, Offset offset) {
    assert(child != null);
    final BoxParentData parentData = child.parentData;
    context.paintChild(child, parentData.offset + offset);
  }

  void _paintChildren(PaintingContext context, Offset offset) {
    if (progress > 0)
      _paintChild(context, left, offset);
    else
      _paintChild(context, right, offset);
    _paintChild(context, center, offset);
  }

  @override
  void paint(PaintingContext context, Offset offset) {
    if (progress != 0.0)
      context.pushClipRect(needsCompositing, offset, Offset.zero & size, _paintChildren);
    else
      _paintChild(context, center, offset);
  }

  @override
  bool hitTestChildren(HitTestResult result, {Offset position}) {
    assert(position != null);
    for (final RenderBox child in _children) {
      final BoxParentData parentData = child.parentData;
      if (child.hitTest(result, position: position - parentData.offset))
        return true;
    }
    return false;
  }
}

class _OffScreenPainter extends SingleChildRenderObjectWidget {

  _OffScreenPainter({
    Key key,
    this.minWidth,
    Widget child
  }) : super(key: key, child: child);

  final double minWidth;

  @override
  _RenderOffScreenPainter createRenderObject(BuildContext context) {
    return _RenderOffScreenPainter(minWidth: minWidth);
  }

  @override
  void updateRenderObject(BuildContext context, _RenderOffScreenPainter renderObject) {
    renderObject.minWidth = minWidth;
  }
}

class _RenderOffScreenPainter extends RenderProxyBox {

  _RenderOffScreenPainter({
    RenderBox child,
    double minWidth
  }) : assert(minWidth != null),
       _minWidth = minWidth,
       super(child);

  double get minWidth => _minWidth;
  double _minWidth;
  set minWidth(double value) {
    assert(value != null);
    if (value == _minWidth)
      return;
    _minWidth = value;
    markNeedsPaint();
  }

  @override
  void paint(PaintingContext context, Offset offset) {
    assert(child != null);
    final double width = size.width;
    final double offScreenDx = math.max(minWidth - width, 0.0);
    context.paintChild(child, offset - Offset(offScreenDx, 0.0));
  }
}