import 'package:flutter/material.dart';

import 'clickable.dart';

class ColumnTile extends StatefulWidget {

  ColumnTile({
    Key? key,
    required this.child,
    this.children = const <Widget>[],
  }) : super(key: key);

  final Widget child;

  final List<Widget> children;

  @override
  _ColumnTileState createState() => _ColumnTileState();
}

class _ColumnTileState extends State<ColumnTile> with SingleTickerProviderStateMixin {

  late final AnimationController _controller;
  late final Animation<double> _heightFactor;
  late final Animation<double> _iconTurns;

  bool _expanded = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(duration: const Duration(milliseconds: 250), vsync: this);
    _heightFactor = _controller.drive(CurveTween(curve: Curves.easeIn));
    _iconTurns = _controller.drive(Tween(begin: 0.0, end: 0.5).chain(CurveTween(curve: Curves.easeIn)));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _expandOrCollapse() {
    setState(() {
      _expanded = !_expanded;
      if (_expanded) {
        _controller.forward();
      } else {
        _controller.reverse().then((_) {
          if (!mounted)
            return;
          setState(() { });
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final closed = !_expanded && _controller.isDismissed;
    return AnimatedBuilder(
      animation: _controller,
      builder: (BuildContext context, Widget? child) {
        return Column(
          mainAxisSize: MainAxisSize.min,
          verticalDirection: VerticalDirection.up,
          children: <Widget>[
            if (child != null)
              ClipRect(
                child: Align(
                  heightFactor: _heightFactor.value,
                  child: child,
                ),
              ),
            Material(child: Row(children: <Widget>[
                Expanded(child: widget.child),
                if (child != null)
                  Clickable(
                    onClick: _expandOrCollapse,
                    child: Padding(
                      padding: EdgeInsets.symmetric(
                        vertical: 12.0,
                        horizontal: 16.0,
                      ),
                      child: RotationTransition(
                        turns: _iconTurns,
                        child: const Icon(Icons.expand_more),
                      ),
                    ),
                  ),
            ])),
          ],
        );
      },
      child: widget.children.isEmpty
        ? null
        : CustomPaint(
            painter: _ChildrenBackgroundPainter(),
            child: Padding(
              padding: EdgeInsets.only(left: 16.0),
              child: Offstage(
                offstage: closed,
                child: TickerMode(
                  enabled: closed,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      ...widget.children,
                      SizedBox(height: 12.0),
                    ],
                  ),
                ),
              ),
            ),
          ),
    );
  }
}

class _ChildrenBackgroundPainter extends CustomPainter {

  @override
  void paint(Canvas canvas, Size size) {
    canvas.drawLine(
      Offset(16.0, 0.0),
      Offset(16.0, size.height - 12.0),
      Paint()..color = Colors.grey,
    );
  }

  @override
  bool shouldRepaint(_ChildrenBackgroundPainter oldPainter) => false;
}
