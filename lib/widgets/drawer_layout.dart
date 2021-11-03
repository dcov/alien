import 'package:flutter/material.dart';

class DrawerLayout extends StatefulWidget {

  DrawerLayout({
    Key? key,
    required this.drawer,
    required this.body,
  }) : super(key: key);

  final Widget drawer;

  final Widget body;

  @override
  DrawerLayoutState createState() => DrawerLayoutState();
}

class DrawerLayoutState extends State<DrawerLayout> with SingleTickerProviderStateMixin {

  late final AnimationController _controller;

  void toggleDrawer() {
    if (_controller.status == AnimationStatus.completed) {
      _controller.reverse();
    } else if (_controller.status == AnimationStatus.dismissed) {
      _controller.forward();
    }
  }

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: Duration(milliseconds: 250),
      value: 0.0,
      vsync: this,
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return CustomMultiChildLayout(
      delegate: _LayoutDelegate(
        position: _controller,
      ),
      children: <Widget>[
        LayoutId(
          id: _LayoutSlot.drawer,
          child: AnimatedBuilder(
            animation: _controller,
            builder: (BuildContext _, Widget? child) {
              return IgnorePointer(
                ignoring: _controller.status != AnimationStatus.completed,
                child: child,
              );
            },
            child: widget.drawer,
          ),
        ),
        LayoutId(
          id: _LayoutSlot.body,
          child: ValueListenableBuilder(
            valueListenable: _controller,
            child: widget.body,
            builder: (BuildContext _, double value, Widget? child) {
              return IgnorePointer(
                ignoring: _controller.status != AnimationStatus.dismissed,
                child: DecoratedBox(
                  position: DecorationPosition.foreground,
                  decoration: BoxDecoration(color: Colors.black.withOpacity(value / 2)),
                  child: child,
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}

enum _LayoutSlot {
  drawer,
  body,
}

class _LayoutDelegate extends MultiChildLayoutDelegate {

  _LayoutDelegate({
    required this.position,
  }) : super(relayout: position);

  final Animation<double> position;

  @override
  void performLayout(Size size) {
    assert(hasChild(_LayoutSlot.drawer));
    assert(hasChild(_LayoutSlot.body));

    final drawerWidth = layoutChild(
      _LayoutSlot.drawer,
      BoxConstraints.tightFor(
        width: 300,
        height: size.height,
      ),
    ).width;

    positionChild(
      _LayoutSlot.drawer,
      Offset(
        -36.0 * (1.0 - position.value),
        0.0,
      ),
    );

    layoutChild(
      _LayoutSlot.body,
      BoxConstraints.tight(size),
    );

    positionChild(
      _LayoutSlot.body,
      Offset(
        drawerWidth * position.value,
        0.0,
      ),
    );
  }

  @override
  bool shouldRelayout(_LayoutDelegate oldDelegate) {
    return this.position != oldDelegate.position;
  }
}
