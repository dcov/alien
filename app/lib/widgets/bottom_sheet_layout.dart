import 'package:flutter/gestures.dart' show DragStartBehavior;
import 'package:flutter/material.dart';

typedef BottomSheetWidgetBuilder = Widget Function(
  BuildContext context,
  Animation<double> animation
);

class BottomSheetLayout extends StatefulWidget {

  BottomSheetLayout({
    Key key,
    @required this.body,
    @required this.sheetBuilder,
  }) : assert(body != null),
       assert(sheetBuilder != null),
       super(key: key);

  final Widget body;

  final BottomSheetWidgetBuilder sheetBuilder;

  @override
  _BottomSheetLayoutState createState() => _BottomSheetLayoutState();
}

class _BottomSheetLayoutState extends State<BottomSheetLayout> with TickerProviderStateMixin {

  _BottomSheetLayoutDelegate _delegate;

  @override
  void initState() {
    super.initState();
    _delegate = _BottomSheetLayoutDelegate(
      controller: AnimationController(
        duration: Duration(milliseconds: 300),
        value: 0.0,
        vsync: this
      )
    );
  }

  @override
  void dispose() {
    _delegate.controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return CustomMultiChildLayout(
      delegate: _delegate,
      children: <Widget>[
        LayoutId(
          id: _BottomSheetLayoutSlot.body,
          child: ValueListenableBuilder(
            valueListenable: _delegate.controller,
            builder: (_, double value, Widget child) {
              return IgnorePointer(
                ignoring: value != 0,
                child: DecoratedBox(
                  position: DecorationPosition.foreground,
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.25 * value)
                  ),
                  child: child
                ),
              );
            },
            child: widget.body
          )
        ),
        LayoutId(
          id: _BottomSheetLayoutSlot.sheet,
          child: widget.sheetBuilder(context, _delegate.controller),
        ),
        LayoutId(
          id: _BottomSheetLayoutSlot.handle,
          child: GestureDetector(
            onVerticalDragUpdate: _delegate.handleDragUpdate,
            onVerticalDragEnd: _delegate.handleDragEnd,
            behavior: HitTestBehavior.translucent,
            dragStartBehavior: DragStartBehavior.start
          ),
        ),
      ]
    );
  }
}

enum _BottomSheetLayoutSlot {
  body,
  sheet,
  handle
}

const double _kPeekHeight = 48.0;

class _BottomSheetLayoutDelegate extends MultiChildLayoutDelegate {

  _BottomSheetLayoutDelegate({ @required this.controller })
      : assert(controller != null),
        super(relayout: controller);

  final AnimationController controller;

  double _draggableAmount;

  void handleDragUpdate(DragUpdateDetails details) {
    controller.value -= details.primaryDelta / _draggableAmount;
  }

  void handleDragEnd(DragEndDetails details) {
    if (details.primaryVelocity.abs() >= 700) {
      controller.fling(velocity: -details.primaryVelocity / _draggableAmount);
    } else if (controller.value >= 0.5) {
      controller.fling(velocity: 1.0);
    } else {
      controller.fling(velocity: -1.0);
    }
  }

  @override
  void performLayout(Size size) {
    assert(hasChild(_BottomSheetLayoutSlot.body));
    assert(hasChild(_BottomSheetLayoutSlot.sheet));
    assert(hasChild(_BottomSheetLayoutSlot.handle));

    _placeChild(
      _BottomSheetLayoutSlot.body,
      BoxConstraints.tight(size),
      Offset.zero
    );

    final double height = size.height * 0.6;
    _draggableAmount = height - _kPeekHeight;
    final double amountDragged = _draggableAmount * controller.value;
    final double offsetY = size.height - _kPeekHeight - amountDragged;

    _placeChild(
      _BottomSheetLayoutSlot.sheet,
      BoxConstraints.tight(Size(size.width, height)),
      Offset(0.0, offsetY)
    );

    _placeChild(
      _BottomSheetLayoutSlot.handle,
      BoxConstraints.tight(Size(size.width, _kPeekHeight)),
      Offset(0.0, offsetY)
    );
  }

  void _placeChild(_BottomSheetLayoutSlot slot, BoxConstraints constraints, Offset offset) {
    layoutChild(slot, constraints);
    positionChild(slot, offset);
  }

  @override
  bool shouldRelayout(_BottomSheetLayoutDelegate oldDelegate) => true;
}

