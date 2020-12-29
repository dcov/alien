import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';

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

