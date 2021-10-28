import 'dart:math' as math;
import 'dart:ui' show lerpDouble;

import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';

import 'ltr_drag_detector.dart';

const double _kMinFlingVelocity = 1.0;
const int _kMaxDroppedSwipePageForwardAnimationTime = 800;
const int _kMaxPageBackAnimationTime = 300;

class _DraggablePageController<T> extends StatefulWidget {

  _DraggablePageController({
    Key? key,
    required this.isPopGestureEnabled,
    required this.navigator,
    required this.controller,
    required this.child
  }) : super(key: key);

  final ValueGetter<bool> isPopGestureEnabled;

  final NavigatorState navigator;

  final AnimationController controller;

  final Widget child;

  @override
  _DraggablePageControllerState<T> createState() => _DraggablePageControllerState<T>();
}

class _DraggablePageControllerState<T> extends State<_DraggablePageController<T>> {

  double _convertToLogical(double value) {
    if (Directionality.of(context) == TextDirection.rtl) {
      return -value;
    }
    return value;
  }

  void _handleDragStart(DragStartDetails _) {
    widget.navigator.didStartUserGesture();
  }

  void _handleDragUpdate(DragUpdateDetails details) {
    final delta = _convertToLogical(details.primaryDelta! / context.size!.width);
    widget.controller.value -= delta;
  }

  void _handleDragEnd(DragEndDetails details) {
    final velocity = _convertToLogical(details.velocity.pixelsPerSecond.dx / context.size!.width);
    _finishDrag(velocity);
  }

  void _handleDragCancel() {
    if (widget.navigator.userGestureInProgress)
      _finishDrag(0.0);
  }

  void _finishDrag(double velocity) {
    final navigator = widget.navigator;
    final controller = widget.controller;
    // Fling in the appropriate direction.
    // AnimationController.fling is guaranteed to
    // take at least one frame.
    //
    // This curve has been determined through rigorously eyeballing native iOS
    // animations.
    const Curve animationCurve = Curves.fastLinearToSlowEaseIn;
    bool animateForward;

    // If the user releases the page before mid screen with sufficient velocity,
    // or after mid screen, we should animate the page out. Otherwise, the page
    // should be animated back in.
    if (velocity.abs() >= _kMinFlingVelocity)
      animateForward = velocity <= 0;
    else
      animateForward = widget.controller.value > 0.5;

    if (animateForward) {
      // The closer the panel is to dismissing, the shorter the animation is.
      // We want to cap the animation time, but we want to use a linear curve
      // to determine it.
      final int droppedPageForwardAnimationTime = math.min(
        lerpDouble(_kMaxDroppedSwipePageForwardAnimationTime, 0, controller.value)!.floor(),
        _kMaxPageBackAnimationTime,
      );
      controller.animateTo(1.0, duration: Duration(milliseconds: droppedPageForwardAnimationTime), curve: animationCurve);
    } else {
      // This route is destined to pop at this point. Reuse navigator's pop.
      navigator.pop();

      // The popping may have finished inline if already at the target destination.
      if (controller.isAnimating) {
        // Otherwise, use a custom popping animation duration and curve.
        final int droppedPageBackAnimationTime = lerpDouble(0, _kMaxDroppedSwipePageForwardAnimationTime, controller.value)!.floor();
        controller.animateBack(0.0, duration: Duration(milliseconds: droppedPageBackAnimationTime), curve: animationCurve);
      }
    }

    if (controller.isAnimating) {
      // Keep the userGestureInProgress in true state so we don't change the
      // curve of the page transition mid-flight since CupertinoPageTransition
      // depends on userGestureInProgress.
      late AnimationStatusListener animationStatusCallback;
      animationStatusCallback = (AnimationStatus status) {
        navigator.didStopUserGesture();
        controller.removeStatusListener(animationStatusCallback);
      };
      controller.addStatusListener(animationStatusCallback);
    } else {
      navigator.didStopUserGesture();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.passthrough,
      children: <Widget>[
        widget.child,
        LTRDragDetector(
          onDragStart: _handleDragStart,
          onDragUpdate: _handleDragUpdate,
          onDragEnd: _handleDragEnd,
          onDragCancel: _handleDragCancel,
          child: const SizedBox.expand())
      ]);
  }
}

class DraggablePageRoute<T> extends PageRoute<T> {

  DraggablePageRoute({
    required this.builder,
    RouteSettings? settings,
    this.maintainState = true,
  }) : super(settings: settings, fullscreenDialog: false);

  final WidgetBuilder builder;

  @override
  final bool maintainState;

  @override
  bool get opaque => true;

  @override
  Duration get transitionDuration => const Duration(milliseconds: 400);

  @override
  Color? get barrierColor => null;

  @override
  String? get barrierLabel => null;

  @override
  bool canTransitionTo(TransitionRoute<dynamic> nextRoute) {
    return nextRoute is DraggablePageRoute;
  }

  @override
  Widget buildPage(BuildContext context, Animation<double> animation, Animation<double> secondaryAnimation) {
    final child = builder(context);
    return Semantics(
      scopesRoute: true,
      explicitChildNodes: true,
      child: child);
  }

  bool get _isPopGestureInProgress => navigator!.userGestureInProgress;

  bool get _isPopGestureEnabled {
    return !isFirst &&
           !willHandlePopInternally &&
           !hasScopedWillPopCallback &&
           !fullscreenDialog &&
           (animation!.status == AnimationStatus.completed ||
            secondaryAnimation!.status == AnimationStatus.dismissed) &&
           !_isPopGestureInProgress;
  }

  @override
  Widget buildTransitions(
      BuildContext context,
      Animation<double> animation,
      Animation<double> secondaryAnimation,
      Widget child) {
    return CupertinoPageTransition(
      primaryRouteAnimation: animation,
      secondaryRouteAnimation: secondaryAnimation,
      linearTransition: _isPopGestureInProgress,
      child: _DraggablePageController<T>(
        isPopGestureEnabled: () => _isPopGestureEnabled,
        navigator: navigator!,
        controller: controller!,
        child: child));
  }
}
