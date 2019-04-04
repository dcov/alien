import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/services.dart';
import 'package:flutter/rendering.dart';

import 'basic.dart';

typedef LatestIndicesCallback = void Function(int firstIndex, int lastIndex);

class SliverLatestChildBuilderDelegate extends SliverChildBuilderDelegate {

  SliverLatestChildBuilderDelegate(
    IndexedWidgetBuilder builder, {
    this.onLatestIndices,
    int childCount,
    bool addAutomaticKeepAlives = true,
    bool addRepaintBoundaries = true,
    bool addSemanticIndexes = true,
  }) : super(
    builder,
    childCount: childCount,
    addAutomaticKeepAlives: addAutomaticKeepAlives,
    addRepaintBoundaries: addRepaintBoundaries,
    addSemanticIndexes: addSemanticIndexes
  );

  final LatestIndicesCallback onLatestIndices;

  @override
  void didFinishLayout(int firstIndex, int lastIndex) {
    if (onLatestIndices != null)
      onLatestIndices(firstIndex, lastIndex);
  }
}

/// A copy of the [ListView.separated] constructor in SliverChildDelegate form.
class SliverSeparatedBuilderDelegate extends SliverChildBuilderDelegate {

  // Helper method to compute the semantic child count for the separated constructor.
  static int _computeSemanticChildCount(int itemCount) {
    return math.max(0, itemCount * 2 - 1);
  }

  SliverSeparatedBuilderDelegate({
    @required IndexedWidgetBuilder itemBuilder,
    @required IndexedWidgetBuilder separatorBuilder,
    @required int childCount,
    bool addAutomaticKeepAlives = true,
    bool addRepaintBoundaries = true,
    bool addSemanticIndexes = true
  }) : super(
      (BuildContext context, int index) {
        final int itemIndex = index ~/ 2;
        Widget widget;
        if (index.isEven) {
          widget = itemBuilder(context, itemIndex);
        } else {
          widget = separatorBuilder(context, itemIndex);
          assert(() {
            if (widget == null) {
              throw FlutterError('separatorBuilder cannot return null.');
            }
            return true;
          }());
        }
        return widget;
      },
      childCount: _computeSemanticChildCount(childCount),
      addAutomaticKeepAlives: addAutomaticKeepAlives,
      addRepaintBoundaries: addRepaintBoundaries,
      addSemanticIndexes: addSemanticIndexes,
      semanticIndexCallback: (Widget _, int index) {
        return index.isEven ? index ~/ 2 : null;
      }
    );
}

class SliverHeadingChildBuilderDelegate extends SliverChildBuilderDelegate {

  static int _defaultSemanticIndexCallback(Widget _, int localIndex) => localIndex;

  SliverHeadingChildBuilderDelegate({
    Widget heading,
    IndexedWidgetBuilder builder,
    int childCount,
    bool addAutomaticKeepAlives = true,
    bool addRepaintBoundaries = true,
    bool addSemanticIndexes = true,
    SemanticIndexCallback semanticIndexCallback = _defaultSemanticIndexCallback,
    int semanticIndexOffset = 0
  }) : super(
         (BuildContext context, int index) {
           if (index == 0)
             return heading;

           return builder(context, index - 1);
         },
         childCount: childCount == null ? null : childCount + 1,
         addAutomaticKeepAlives: addAutomaticKeepAlives,
         addRepaintBoundaries: addRepaintBoundaries,
         addSemanticIndexes: addSemanticIndexes,
         semanticIndexCallback: semanticIndexCallback,
         semanticIndexOffset: semanticIndexOffset
       );
}

class RenderProxySliver extends RenderSliver with RenderObjectWithChildMixin<RenderSliver> {

  RenderProxySliver({ RenderSliver child }) {
    this.child = child;
  }

  @override
  Rect get semanticBounds => child?.semanticBounds ?? super.semanticBounds;

  @override
  Rect get paintBounds => child?.paintBounds ?? super.paintBounds;

  @override
  double get centerOffsetAdjustment => child?.centerOffsetAdjustment ?? super.centerOffsetAdjustment;

  @override
  void setupParentData(RenderObject child) {
    if (child.parentData is! ParentData) {
      child.parentData = ParentData();
    }
  }

  @override
  void performLayout() {
    if (child != null) {
      child.layout(constraints, parentUsesSize: true);
      geometry = child.geometry;
    }
  }

  @override
  bool hitTestChildren(HitTestResult result, { double mainAxisPosition, double crossAxisPosition }) {
    return child?.hitTest(result, mainAxisPosition: mainAxisPosition, crossAxisPosition: crossAxisPosition) ?? false;
  }

  @override
  double childMainAxisPosition(RenderSliver child) {
    return 0.0;
  }

  @override
  double childCrossAxisPosition(RenderSliver child) {
    return 0.0;
  }

  @override
  double childScrollOffset(RenderSliver child) {
    return 0.0;
  }

  @override
  void applyPaintTransform(RenderObject child, Matrix4 transform) { }

  @override
  void paint(PaintingContext context, Offset offset) {
    if (child != null) {
      context.paintChild(child, offset);
    }
  }
}

class SliverCustomPaint extends SingleChildRenderObjectWidget {

  SliverCustomPaint({ Key key, Widget sliver, this.painter })
    : super(key: key, child: sliver);

  final CustomPainter painter;

  @override
  RenderSliverCustomPaint createRenderObject(BuildContext context) {
    return RenderSliverCustomPaint(painter: painter);
  }

  @override
  void updateRenderObject(BuildContext context, RenderSliverCustomPaint renderObject) {
    renderObject..painter = painter;
  }
}

class RenderSliverCustomPaint extends RenderProxySliver {

  RenderSliverCustomPaint({
    CustomPainter painter,
    RenderSliver child
  }) : this._painter = painter,
       super(child: child);

  CustomPainter get painter => _painter;
  CustomPainter _painter;
  set painter(CustomPainter value) {
    if (_painter == value)
      return;

    _painter = value;
    markNeedsPaint();
  }

  Size getSizeRelativeToAxis() {
    double mainAxisExtent = geometry.paintExtent;
    double crossAxisExtent = constraints.crossAxisExtent;
    switch (constraints.axis) {
      case Axis.horizontal:
        return Size(mainAxisExtent, crossAxisExtent);
      case Axis.vertical:
        return Size(crossAxisExtent, mainAxisExtent);
    }
    return null;
  }

  @override
  void paint(PaintingContext context, Offset offset) {
    if (_painter != null) {
      final Canvas canvas = context.canvas;
      canvas.save();
      if (offset != Offset.zero)
        canvas.translate(offset.dx, offset.dy);
      painter.paint(canvas, getSizeRelativeToAxis());
      canvas.restore();
    }
    super.paint(context, offset);
  }
}

class Indicator extends StatelessWidget {

  static Widget builder(
    BuildContext context,
    IndicatorStatus status,
    double extentPulled,
    double triggerExtent,
    double indicatorExtent
  ) {
    return Indicator(
      status: status,
      extentPulled: extentPulled,
      triggerExtent: triggerExtent,
      indicatorExtent: indicatorExtent,
    );
  }

  static Widget emptyBuilder(
    BuildContext context,
    IndicatorStatus status,
    double extentPulled,
    double triggerExtent,
    double indicatorExtent
  ) {
    return const EmptyBox();
  }

  Indicator({
    Key key,
    @required this.status,
    @required this.extentPulled,
    @required this.triggerExtent,
    @required this.indicatorExtent
  }) : super(key: key);

  final IndicatorStatus status;
  final double extentPulled;
  final double triggerExtent;
  final double indicatorExtent;

  @override
  Widget build(BuildContext context) {
    const Curve opacityCurve = Interval(0.4, 0.8, curve: Curves.easeInOut);
    return Align(
      alignment: Alignment.bottomCenter,
      child: Padding(
        padding: const EdgeInsets.only(bottom: 16.0),
        child: status == IndicatorStatus.dragging
            ? Opacity(
                opacity: opacityCurve.transform(
                  math.min(extentPulled/ triggerExtent, 1.0)
                ),
                child: const Icon(
                  Icons.arrow_downward,
                  color: Colors.grey,
                  size: 24.0,
                )
              )
            : const EmptyBox()
      ),
    );
  }
}

/// The current state of the refresh control.
///
/// Passed into the [IndicatorBuilder] builder function so
/// users can show different UI in different modes.
enum IndicatorStatus {
  /// Initial state, when not being overscrolled into, or after the overscroll
  /// is canceled or after done and the sliver retracted away.
  inactive,

  /// While being overscrolled but not far enough yet to trigger the refresh.
  dragging,

  /// Dragged far enough that the onRefresh callback will run and the dragged
  /// displacement is not yet at the final refresh resting state.
  armed,

  /// While the task is running.
  running,

  /// While the indicator is animating away after running.
  done,
}

typedef IndicatorBuilder = Widget Function(
    BuildContext context,
    IndicatorStatus status,
    double extentPulled,
    double triggerExtent,
    double indicatorExtent
);

typedef TaskCallback = Future<void> Function();

const _kDefaultTriggerExtent = 100.0;
const _kDefaultIndicatorExtent = 60.0;

class SliverIndicator extends StatefulWidget {

  /// Calls [onTriggered] whenever the sliver is pulled past the 
  /// [triggerExtent], and disappears as soon as the user finishes
  /// dragging.
  /// 
  /// For an indicator that persists for an indeterminate amout of time
  /// once triggered, use [SliverIndicator.indicate].
  SliverIndicator({
    Key key,
    this.triggerExtent = _kDefaultTriggerExtent,
    this.triggerFeedback = true,
    @required this.builder,
    VoidCallback onTriggered
  })  : this.onTriggered = onTriggered,
        this.indicatorExtent = 0.0,
        super(key: key);

  final double triggerExtent;
  final double indicatorExtent;
  final bool triggerFeedback;
  final IndicatorBuilder builder;

  final dynamic onTriggered;


  @override
  _SliverIndicatorState createState() => _SliverIndicatorState();
}

const _kInactiveResetOverscrollRatio = 0.1;

class _SliverIndicatorState extends State<SliverIndicator> {

  IndicatorStatus status;

  Future<void> task;

  double currentExtent = 0.0;

  bool sliverShouldIncludeIndicatorExtent = false;

  @override
  void initState() {
    super.initState();
    status = IndicatorStatus.inactive;
  }

  void trigger() {
    if (widget.onTriggered != null) {

      if (widget.triggerFeedback) HapticFeedback.mediumImpact();
      // Call the callback after this frame finished since the function is
      // user supplied and we're always here in the middle of the sliver's
      // performLayout.
      SchedulerBinding.instance.addPostFrameCallback((Duration timestamp) {
        final result = widget.onTriggered();

        if (result is Future) {
          task = result..then((_) {
            if (mounted) {
              setState(() => task = null);

            // Trigger one more transition because by this time, BoxConstraint's
            // maxHeight might already be resting at 0 in which case no
            // calls to [transitionNextStatus] will occur anymore and the
            // state may be stuck in a non-inactive state.
              status = transitionNextStatus();
            }
          });
        }
        setState(() => sliverShouldIncludeIndicatorExtent = true);
      });
    }
  }

  IndicatorStatus transitionNextStatus() {
    IndicatorStatus nextStatus;

    void goToDone() {
      nextStatus = IndicatorStatus.done;
      // Either schedule the RenderSliver to re-layout on the next frame
      // when not currently in a frame or schedule it on the next frame.
      if (SchedulerBinding.instance.schedulerPhase == SchedulerPhase.idle) {
        setState(() => sliverShouldIncludeIndicatorExtent = false);
      } else {
        SchedulerBinding.instance.addPostFrameCallback((Duration timestamp){
          setState(() => sliverShouldIncludeIndicatorExtent = false);
        });
      }
    }

    switch (status) {
      case IndicatorStatus.inactive:
        if (currentExtent <= 0) {
          return IndicatorStatus.inactive;
        } else {
          nextStatus = IndicatorStatus.dragging;
        }
        continue drag;
      drag:
      case IndicatorStatus.dragging:
        if (currentExtent == 0) {
          return IndicatorStatus.inactive;
        } else if (currentExtent < widget.triggerExtent) {
          return IndicatorStatus.dragging;
        } else {
          trigger();
          return IndicatorStatus.armed;
        }
        
        // Don't continue here. We can never possibly call onRefresh and
        // progress to the next state in one [computeNextState] call.
        break;
      case IndicatorStatus.armed:
        if (task == null) {
          goToDone();
          continue done;
        } else {
          nextStatus = IndicatorStatus.running;
        }

        continue running;
      running:
      case IndicatorStatus.running:
        if (task != null) {
          return IndicatorStatus.running;
        } else {
          goToDone();
        }
        continue done;
      done:
      case IndicatorStatus.done:
        // Let the transition back to inactive trigger before strictly going
        // to 0.0 since the last bit of the animation can take some time and
        // can feel sluggish if not going all the way back to 0.0 prevented
        // a subsequent pull-to-refresh from starting.
        if (currentExtent >
            widget.triggerExtent * _kInactiveResetOverscrollRatio) {
          return IndicatorStatus.done;
        } else {
          nextStatus = IndicatorStatus.inactive;
        }
        break;
    }

    return nextStatus;
  }

  @override
  Widget build(BuildContext context) =>
    _Indicator(
      layoutExtent: widget.indicatorExtent,
      includeLayoutExtent: sliverShouldIncludeIndicatorExtent,
      child: LayoutBuilder(
        builder: (BuildContext context, BoxConstraints constraints) {
          currentExtent = constraints.maxHeight;
          status = transitionNextStatus();
          return widget.builder != null && status != IndicatorStatus.inactive
            ? widget.builder(
                context,
                status,
                currentExtent,
                widget.triggerExtent,
                widget.indicatorExtent,
              )
            : Container();
        }
      ),
    );
}


class _Indicator extends SingleChildRenderObjectWidget {

  _Indicator({
    Key key,
    this.layoutExtent,
    this.includeLayoutExtent,
    Widget child
  })  : super(key: key, child: child);

  final double layoutExtent;
  final bool includeLayoutExtent;

  @override
  _RenderIndicator createRenderObject(BuildContext context) =>
    _RenderIndicator(
      layoutExtent: layoutExtent,
      includeLayoutExtent: includeLayoutExtent,
    );

  @override
  void updateRenderObject(BuildContext context, _RenderIndicator renderObject) =>
    renderObject
      ..layoutExtent = layoutExtent
      ..includeLayoutExtent = includeLayoutExtent;
}

class _RenderIndicator extends RenderSliver with RenderObjectWithChildMixin<RenderBox> {

  _RenderIndicator({
    double layoutExtent,
    bool includeLayoutExtent,
    RenderBox child,
  })  : this._layoutExtent = layoutExtent,
        this._includeLayoutExtent = includeLayoutExtent {
    this.child = child;
  }


  double _layoutExtent;
  double get layoutExtent => _layoutExtent;
  set layoutExtent(double newValue) {
    if (newValue != _layoutExtent) {
      _layoutExtent = newValue;
      markNeedsLayout();
    }
  }

  bool _includeLayoutExtent;
  bool get includeLayoutExtent => _includeLayoutExtent;
  set includeLayoutExtent(bool newValue) {
    if (newValue != _includeLayoutExtent) {
      _includeLayoutExtent = newValue;
      markNeedsLayout();
    }
  }

  // This keeps track of the previously applied scroll offsets to the scrollable
  // so that when [refreshIndicatorLayoutExtent] or [hasLayoutExtent] changes,
  // the appropriate delta can be applied to keep everything in the same place
  // visually.
  double layoutExtentOffsetCompensation = 0.0;

  @override
  void performLayout() {
    // Only pulling to refresh from the top is currently supported.
    assert(constraints.axisDirection == AxisDirection.down);
    assert(constraints.growthDirection == GrowthDirection.forward);

    // The new layout extent this sliver should now have.
    final double layoutExtent =
        (_includeLayoutExtent ? 1.0 : 0.0) * _layoutExtent;
    // If the new layoutExtent instructive changed, the SliverGeometry's
    // layoutExtent will take that value (on the next performLayout run). Shift
    // the scroll offset first so it doesn't make the scroll position suddenly jump.
    if (layoutExtent != layoutExtentOffsetCompensation) {
      geometry = new SliverGeometry(
        scrollOffsetCorrection: layoutExtent - layoutExtentOffsetCompensation,
      );
      layoutExtentOffsetCompensation = layoutExtent;
      // Return so we don't have to do temporary accounting and adjusting the
      // child's constraints accounting for this one transient frame using a
      // combination of existing layout extent, new layout extent change and
      // the overlap.
      return;
    }

    final bool active = constraints.overlap < 0.0 || layoutExtent > 0.0;
    final double overscrolledExtent =
        constraints.overlap < 0.0 ? constraints.overlap.abs() : 0.0;
    // Layout the child giving it the space of the currently dragged overscroll
    // which may or may not include a sliver layout extent space that it will
    // keep after the user lets go during the refresh process.
    child.layout(
      constraints.asBoxConstraints(
        maxExtent: layoutExtent
            // Plus only the overscrolled portion immediately preceding this
            // sliver.
            + overscrolledExtent,
      ),
      parentUsesSize: true,
    );
    if (active) {
      geometry = new SliverGeometry(
        scrollExtent: layoutExtent,
        paintOrigin: -overscrolledExtent - constraints.scrollOffset,
        paintExtent: math.max(
          // Check child size (which can come from overscroll) because
          // layoutExtent may be zero. Check layoutExtent also since even
          // with a layoutExtent, the indicator builder may decide to not
          // build anything.
          math.max(child.size.height, layoutExtent) - constraints.scrollOffset,
          0.0,
        ),
        maxPaintExtent: math.max(
          math.max(child.size.height, layoutExtent) - constraints.scrollOffset,
          0.0,
        ),
        layoutExtent: math.max(layoutExtent - constraints.scrollOffset, 0.0),
      );
    } else {
      // If we never started overscrolling, return no geometry.
      geometry = SliverGeometry.zero;
    }
  }

  @override
  void paint(PaintingContext paintContext, Offset offset) {
    if (constraints.overlap < 0.0 ||
        constraints.scrollOffset + child.size.height > 0) {
      paintContext.paintChild(child, offset);
    }
  }

  // Nothing special done here because this sliver always paints its child
  // exactly between paintOrigin and paintExtent.
  @override
  void applyPaintTransform(RenderObject child, Matrix4 transform) {}
}