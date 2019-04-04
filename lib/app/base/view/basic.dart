import 'package:meta/meta.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

class EmptyBox extends SizedBox {

  @literal
  const EmptyBox({ Key key })
    : super(key: key, width: 0.0, height: 0.0);
}

class SizeNotifier extends SingleChildRenderObjectWidget {
  
  SizeNotifier({
    Key key,
    @required this.onSize,
    Widget child,
  }) : super(key: key, child: child);

  final ValueChanged<Size> onSize;

  @override
  _RenderSizeNotifier createRenderObject(BuildContext context) {
    return _RenderSizeNotifier(onSize);
  }

  @override
  void updateRenderObject(BuildContext context, _RenderSizeNotifier renderObject) {
    renderObject._onSize = this.onSize;
  }
}

class _RenderSizeNotifier extends RenderProxyBox {

  _RenderSizeNotifier(this._onSize, [ RenderBox child ]) : super(child);

  ValueChanged<Size> _onSize;

  @override
  void performLayout() {
    super.performLayout();
    _onSize(size);
  }
}