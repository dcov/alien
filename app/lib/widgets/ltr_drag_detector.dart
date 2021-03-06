import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/widgets.dart';

class LTRDragDetector extends StatefulWidget {

  LTRDragDetector({
    Key? key,
    required this.onDragStart,
    required this.onDragUpdate,
    required this.onDragEnd,
    required this.onDragCancel,
    this.child
  }) : super(key: key);

  final GestureDragStartCallback onDragStart;

  final GestureDragUpdateCallback onDragUpdate;

  final GestureDragEndCallback onDragEnd;

  final GestureDragCancelCallback onDragCancel;

  final Widget? child;

  @override
  _LTRDragDetectorState createState() => _LTRDragDetectorState();
}

class _LTRDragDetectorState extends State<LTRDragDetector> {

  late _LTRDragRecognizer _recognizer;

  @override
  void initState() {
    super.initState();
    _recognizer = _LTRDragRecognizer(debugOwner: this)
        ..onStart = widget.onDragStart
        ..onUpdate = widget.onDragUpdate
        ..onEnd = widget.onDragEnd
        ..onCancel = widget.onDragCancel;
  }

  @override
  void didUpdateWidget(LTRDragDetector oldWidget) {
    super.didUpdateWidget(oldWidget);
    _recognizer
        ..onStart = widget.onDragStart
        ..onUpdate = widget.onDragUpdate
        ..onEnd = widget.onDragEnd
        ..onCancel = widget.onDragCancel;
  }

  @override
  void dispose() {
    _recognizer.dispose();
    super.dispose();
  }
  
  @override
  Widget build(BuildContext context) {
    return Listener(
      behavior: HitTestBehavior.translucent,
      onPointerDown: _recognizer.addPointer,
      child: widget.child);
  }
}

enum _DragState {
  ready,
  possible,
  accepted
}

class _LTRDragRecognizer extends OneSequenceGestureRecognizer {

  _LTRDragRecognizer({
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
  String get debugDescription => 'ltr drag detector';
}
