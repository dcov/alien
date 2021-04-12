import 'dart:math' as math;
import 'dart:ui' show lerpDouble;

import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';

const double _kMinFlingVelocity = 1.0;
const int _kMaxDroppedSwipePageForwardAnimationTime = 800;
const int _kMaxPageBackAnimationTime = 300;

enum _DragState {
  ready,
  possible,
  accepted
}

class _DraggablePageRecognizer extends OneSequenceGestureRecognizer {

  _DraggablePageRecognizer({
    Object? debugOwner,
    PointerDeviceKind? kind
  }) : super(debugOwner: debugOwner, kind: kind);

  GestureDragStartCallback? onStart;
  GestureDragUpdateCallback? onUpdate;
  GestureDragEndCallback? onEnd;
  GestureDragCancelCallback? onCancel;
  _DragState _state = _DragState.ready;
  late OffsetPair _initialPosition;
  late OffsetPair _pendingDragOffset;
  Duration? _lastPendingEventTimestamp;
  int? _initialButtons;
  Matrix4? _lastTransform;
  late double _globalDistanceMoved;

  bool _hasSufficientGlobalDistanceToAccept(PointerDeviceKind pointerDeviceKind) {
    return _globalDistanceMoved > computeHitSlop(pointerDeviceKind);
  }

  bool _isFlingGesture(VelocityEstimate estimate, PointerDeviceKind kind) {
    final minVelocity = kMinFlingVelocity;
    final minDistance = computeHitSlop(kind);
    return estimate.pixelsPerSecond.dx.abs() > minVelocity && estimate.offset.dx.abs() > minDistance;
  }
  
  Offset _getDeltaForDetails(Offset delta) => Offset(delta.dx, 0.0);

  double? _getPrimaryValueFromOffset(Offset value) => value.dx;

  final Map<int, VelocityTracker> _velocityTrackers = <int, VelocityTracker>{};

  @override
  bool isPointerAllowed(PointerEvent event) {
    if (_initialButtons == null) {
      switch (event.buttons) {
        case kPrimaryButton:
          if (onStart == null &&
              onUpdate == null &&
              onEnd == null &&
              onCancel == null)
            return false;
          break;
        default:
          return false;
      }
    } else {
      // There can be multiple drags simultaneously. Their effects are combined.
      if (event.buttons != _initialButtons) {
        return false;
      }
    }
    return super.isPointerAllowed(event as PointerDownEvent);
  }

  @override
  void addAllowedPointer(PointerEvent event) {
    startTrackingPointer(event.pointer, event.transform);
    _velocityTrackers[event.pointer] = VelocityTracker.withKind(event.kind);
    if (_state == _DragState.ready) {
      _state = _DragState.possible;
      _initialPosition = OffsetPair(global: event.position, local: event.localPosition);
      _initialButtons = event.buttons;
      _pendingDragOffset = OffsetPair.zero;
      _globalDistanceMoved = 0.0;
      _lastPendingEventTimestamp = event.timeStamp;
      _lastTransform = event.transform;
    } else if (_state == _DragState.accepted) {
      resolve(GestureDisposition.accepted);
    }
  }

  @override
  void handleEvent(PointerEvent event) {
    assert(_state != _DragState.ready);
    if (!event.synthesized
        && (event is PointerDownEvent || event is PointerMoveEvent)) {
      final VelocityTracker tracker = _velocityTrackers[event.pointer]!;
      tracker.addPosition(event.timeStamp, event.localPosition);
    }

    if (event is PointerMoveEvent) {
      if (event.buttons != _initialButtons) {
        _giveUpPointer(event.pointer);
        return;
      }
      if (_state == _DragState.accepted) {
        _checkUpdate(
          sourceTimeStamp: event.timeStamp,
          delta: _getDeltaForDetails(event.localDelta),
          primaryDelta: _getPrimaryValueFromOffset(event.localDelta),
          globalPosition: event.position,
          localPosition: event.localPosition,
        );
      } else {
        _pendingDragOffset += OffsetPair(local: event.localDelta, global: event.delta);
        _lastPendingEventTimestamp = event.timeStamp;
        _lastTransform = event.transform;
        final Offset movedLocally = _getDeltaForDetails(event.localDelta);
        final Matrix4? localToGlobalTransform = event.transform == null ? null : Matrix4.tryInvert(event.transform!);
        _globalDistanceMoved += PointerEvent.transformDeltaViaPositions(
          transform: localToGlobalTransform,
          untransformedDelta: movedLocally,
          untransformedEndPosition: event.localPosition,
        ).distance * (_getPrimaryValueFromOffset(movedLocally) ?? 1).sign;
        if (_hasSufficientGlobalDistanceToAccept(event.kind))
          resolve(GestureDisposition.accepted);
      }
    }
    if (event is PointerUpEvent || event is PointerCancelEvent) {
      _giveUpPointer(
        event.pointer,
        reject: event is PointerCancelEvent || _state ==_DragState.possible,
      );
    }
  }

  @override
  void acceptGesture(int pointer) {
    if (_state != _DragState.accepted) {
      _state = _DragState.accepted;
      final OffsetPair delta = _pendingDragOffset;
      final Duration timestamp = _lastPendingEventTimestamp!;
      final Matrix4? transform = _lastTransform;
      Offset localUpdateDelta = Offset.zero;
      _initialPosition = _initialPosition + delta;
      _pendingDragOffset = OffsetPair.zero;
      _lastPendingEventTimestamp = null;
      _lastTransform = null;
      _checkStart(timestamp);
      if (localUpdateDelta != Offset.zero && onUpdate != null) {
        final Matrix4? localToGlobal = transform != null ? Matrix4.tryInvert(transform) : null;
        final Offset correctedLocalPosition = _initialPosition.local + localUpdateDelta;
        final Offset globalUpdateDelta = PointerEvent.transformDeltaViaPositions(
          untransformedEndPosition: correctedLocalPosition,
          untransformedDelta: localUpdateDelta,
          transform: localToGlobal,
        );
        final OffsetPair updateDelta = OffsetPair(local: localUpdateDelta, global: globalUpdateDelta);
        final OffsetPair correctedPosition = _initialPosition + updateDelta; // Only adds delta for down behaviour
        _checkUpdate(
          sourceTimeStamp: timestamp,
          delta: localUpdateDelta,
          primaryDelta: _getPrimaryValueFromOffset(localUpdateDelta),
          globalPosition: correctedPosition.global,
          localPosition: correctedPosition.local,
        );
      }
    }
  }

  @override
  void rejectGesture(int pointer) {
    _giveUpPointer(pointer);
  }

  @override
  void didStopTrackingLastPointer(int pointer) {
    assert(_state != _DragState.ready);
    switch(_state) {
      case _DragState.ready:
        break;

      case _DragState.possible:
        resolve(GestureDisposition.rejected);
        _checkCancel();
        break;

      case _DragState.accepted:
        _checkEnd(pointer);
        break;
    }
    _velocityTrackers.clear();
    _initialButtons = null;
    _state = _DragState.ready;
  }

  void _giveUpPointer(int pointer, {bool reject = true}) {
    stopTrackingPointer(pointer);
    if (reject) {
      if (_velocityTrackers.containsKey(pointer)) {
        _velocityTrackers.remove(pointer);
        resolvePointer(pointer, GestureDisposition.rejected);
      }
    }
  }

  void _checkStart(Duration timestamp) {
    assert(_initialButtons == kPrimaryButton);
    final DragStartDetails details = DragStartDetails(
      sourceTimeStamp: timestamp,
      globalPosition: _initialPosition.global,
      localPosition: _initialPosition.local,
    );
    if (onStart != null)
      invokeCallback<void>('onStart', () => onStart!(details));
  }

  void _checkUpdate({
    Duration? sourceTimeStamp,
    required Offset delta,
    double? primaryDelta,
    required Offset globalPosition,
    Offset? localPosition,
  }) {
    assert(_initialButtons == kPrimaryButton);
    final DragUpdateDetails details = DragUpdateDetails(
      sourceTimeStamp: sourceTimeStamp,
      delta: delta,
      primaryDelta: primaryDelta,
      globalPosition: globalPosition,
      localPosition: localPosition,
    );
    if (onUpdate != null)
      invokeCallback<void>('onUpdate', () => onUpdate!(details));
  }

  void _checkEnd(int pointer) {
    assert(_initialButtons == kPrimaryButton);
    if (onEnd == null)
      return;

    final VelocityTracker tracker = _velocityTrackers[pointer]!;

    DragEndDetails details;
    String Function() debugReport;

    final VelocityEstimate? estimate = tracker.getVelocityEstimate();
    if (estimate != null && _isFlingGesture(estimate, tracker.kind)) {
      final Velocity velocity = Velocity(pixelsPerSecond: estimate.pixelsPerSecond)
        .clampMagnitude(kMinFlingVelocity, kMaxFlingVelocity);
      details = DragEndDetails(
        velocity: velocity,
        primaryVelocity: _getPrimaryValueFromOffset(velocity.pixelsPerSecond),
      );
      debugReport = () {
        return '$estimate; fling at $velocity.';
      };
    } else {
      details = DragEndDetails(
        velocity: Velocity.zero,
        primaryVelocity: 0.0,
      );
      debugReport = () {
        if (estimate == null)
          return 'Could not estimate velocity.';
        return '$estimate; judged to not be a fling.';
      };
    }
    invokeCallback<void>('onEnd', () => onEnd!(details), debugReport: debugReport);
  }

  void _checkCancel() {
    assert(_initialButtons == kPrimaryButton);
    if (onCancel != null)
      invokeCallback<void>('onCancel', onCancel!);
  }

  @override
  void dispose() {
    _velocityTrackers.clear();
    super.dispose();
  }

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties.add(EnumProperty<DragStartBehavior>('start behavior', DragStartBehavior.start));
  }

  @override
  String get debugDescription => 'draggable page drag';
}

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

  late _DraggablePageRecognizer _recognizer;

  @override
  void initState() {
    super.initState();
    _recognizer = _DraggablePageRecognizer(debugOwner: this)
      ..onStart = _handleDragStart
      ..onUpdate = _handleDragUpdate
      ..onEnd = _handleDragEnd
      ..onCancel = _handleDragCancel;
  }

  @override
  void dispose() {
    _recognizer.dispose();
    super.dispose();
  }

  void _handlePointerDown(PointerDownEvent event) {
    if (widget.isPopGestureEnabled())
      _recognizer.addPointer(event);
  }

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
        SizedBox.expand(
          child: Listener(
            behavior: HitTestBehavior.translucent,
            onPointerDown: _handlePointerDown))
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
