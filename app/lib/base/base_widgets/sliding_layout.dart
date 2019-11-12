part of '../base.dart';

class SlidingLayout extends StatefulWidget {

  SlidingLayout({
    Key key,
    @required this.drawer,
    @required this.child
  }) : assert(drawer != null),
       assert(child != null),
       super(key: key);

  final Widget drawer;

  final Widget child;

  @override
  SlidingLayoutState createState() => SlidingLayoutState();
}

class SlidingLayoutState extends State<SlidingLayout>
    with SingleTickerProviderStateMixin {

  AnimationController _controller;

  double _draggableExtent;

  bool get isOpen => _controller.status == AnimationStatus.completed;

  void open() {
    _controller.forward();
  }

  void close() {
    _controller.reverse();
  }

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
      duration: const Duration(
        milliseconds: 250,
      ),
      value: 0.0,
      vsync: this
    );
  }

  @override
  void dispose() {
    super.dispose();
    _controller.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (_, BoxConstraints constraints) {
        _draggableExtent = constraints.maxWidth - 24.0;
        return ValueListenableBuilder(
          valueListenable: _controller,
          builder: (_, double value, __) {
            return Stack(
              children: <Widget>[
                Positioned.fill(
                  left: -24.0 * (1.0 - value),
                  right: 48.0 - (24.0 * value),
                  child: widget.drawer,
                ),
                Positioned.fill(
                  left: _draggableExtent * value,
                  right: -_draggableExtent * value,
                  child: Material(
                    child: widget.child,
                  )
                ),
                Positioned.fill(
                  left: _draggableExtent * value,
                  right: constraints.maxWidth - 24.0 - (_draggableExtent * value),
                  child: GestureDetector(
                    behavior: HitTestBehavior.translucent,
                    onHorizontalDragUpdate: _handleDragUpdate,
                    onHorizontalDragEnd: _handleDragEnd,
                    child: const SizedBox(),
                  ),
                )
              ],
            );
          }
        );
      }
    );
  }
}

