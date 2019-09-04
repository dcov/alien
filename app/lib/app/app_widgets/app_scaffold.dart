part of '../app.dart';

const _kBaseBarHeight = 56.0;

typedef _OverlapBuilder = Widget Function(BuildContext, double value);

class AppScaffold extends StatefulWidget {

  AppScaffold({
    Key key,
    @required this.overlapped,
    @required this.topOverlapBuilder,
    @required this.bottomOverlapBuilder,
    @required this.draggableAmount
  }) : super(key: key);

  final Widget overlapped;

  final _OverlapBuilder topOverlapBuilder;

  final _OverlapBuilder bottomOverlapBuilder;

  final double draggableAmount;

  @override
  _AppScaffoldState createState() => _AppScaffoldState();
}

class _AppScaffoldState extends State<AppScaffold>
    with SingleTickerProviderStateMixin {

  AnimationController _controller;
  double _draggableExtent;

  void _handleDragUpdate(DragUpdateDetails details) {
    _controller.value += details.primaryDelta / _draggableExtent;
  }

  void _handleDragEnd(DragEndDetails details) {
    if (details.primaryVelocity.abs() > 700) {
      _controller.fling(velocity: details.primaryVelocity / _draggableExtent);
    } else if (_controller.value > 0.5) {
      _controller.fling(velocity: 1.0);
    } else {
      _controller.fling(velocity: -1.0);
    }
  }

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      value: 0.0
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Widget _buildLayout(BuildContext context, BoxConstraints constraints, double value) {
    final double topBarHeight = MediaQuery.of(context).padding.top + _kBaseBarHeight;
    final double bottomBarHeight = _kBaseBarHeight;
    _draggableExtent = constraints.maxHeight - topBarHeight - bottomBarHeight;
    final double bottomInset = bottomBarHeight + ((1.0 - value) * _draggableExtent);
    final double topInset = constraints.maxHeight - bottomBarHeight;
    return Stack(
      children: <Widget>[
        widget.overlapped,
        Positioned.fill(
          bottom: bottomInset,
          child: widget.topOverlapBuilder(context, value)
        ),
        Positioned.fill(
          top: topInset,
          child: widget.bottomOverlapBuilder(context, value),
        ),
        Positioned.fill(
          top: constraints.maxHeight - bottomInset - widget.draggableAmount,
          bottom: bottomInset,
          child: GestureDetector(
            behavior: HitTestBehavior.translucent,
            child: SizedBox.expand(),
            onVerticalDragUpdate: _handleDragUpdate,
            onVerticalDragEnd: _handleDragEnd,
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        return SizedBox.expand(
          child: ValueListenableBuilder(
            valueListenable: _controller,
            builder: (BuildContext context, double value, Widget _) {
              return _buildLayout(context, constraints, value);
            },
          )
        );
      },
    );
  }
}