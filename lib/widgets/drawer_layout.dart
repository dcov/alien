import 'package:flutter/widgets.dart';

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
    } else if (_controller.status != AnimationStatus.dismissed) {
      _controller.forward();
    }
  }

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: Duration(milliseconds: 250),
      value: 1.0,
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
          child: widget.drawer,
        ),
        LayoutId(
          id: _LayoutSlot.body,
          child: widget.body,
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
      BoxConstraints(
        minWidth: 0.0,
        maxWidth: size.width,
        minHeight: size.height,
        maxHeight: size.height,
      ),
    ).width;

    positionChild(
      _LayoutSlot.drawer,
      Offset(
        -drawerWidth * (1.0 - position.value),
        0.0,
      ),
    );

    layoutChild(
      _LayoutSlot.body,
      BoxConstraints.tightFor(
        width: drawerWidth > size.width / 3
          ? size.width
          : size.width - (drawerWidth * position.value),
        height: size.height,
      ),
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
