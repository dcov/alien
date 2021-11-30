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

class DrawerLayoutState extends State<DrawerLayout> with TickerProviderStateMixin {

  late AnimationController _controller;

  void _initController([double value = 0.0]) {
    _controller = AnimationController(
      duration: Duration(milliseconds: 100),
      value: value,
      vsync: this,
    );
  }

  void toggleDrawer() {
    if (_controller.status == AnimationStatus.completed) {
      _controller.reverse();
    } else if (_controller.status == AnimationStatus.dismissed) {
      _controller.forward();
    }
  }

  bool isOpen() {
    return _controller.status == AnimationStatus.completed;
  }

  @override
  void initState() {
    super.initState();
    _initController();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  void reassemble() {
    super.reassemble();
    final value = _controller.value;
    _controller.dispose();
    _initController(value);
  }

  @override
  Widget build(BuildContext context) {
    return CustomMultiChildLayout(
      delegate: _LayoutDelegate(animation: _controller),
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
          child: AnimatedBuilder(
            animation: _controller,
            builder: (BuildContext _, Widget? child) {
              return IgnorePointer(
                ignoring: _controller.isAnimating,
                child: child,
              );
            },
            child: widget.body,
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
    required this.animation,
  }) : super(relayout: animation);

  final Animation<double> animation;

  @override
  void performLayout(Size size) {
    assert(hasChild(_LayoutSlot.drawer));
    assert(hasChild(_LayoutSlot.body));

    final drawerWidth = layoutChild(
      _LayoutSlot.drawer,
      BoxConstraints.tightFor(
        height: size.height,
      ),
    ).width;

    positionChild(
      _LayoutSlot.drawer,
      Offset.zero,
    );

    layoutChild(
      _LayoutSlot.body,
      BoxConstraints.tight(Size(
        size.width - (drawerWidth * animation.value),
        size.height,
      )),
    );

    positionChild(
      _LayoutSlot.body,
      Offset(
        drawerWidth * animation.value,
        0.0,
      ),
    );
  }

  @override
  bool shouldRelayout(_LayoutDelegate oldDelegate) {
    return this.animation != oldDelegate.animation;
  }
}
