part of '../main.dart';

class _MainLayout extends StatefulWidget {

  _MainLayout({
    Key key,
    @required this.frontDrop,
    @required this.rearChild,
    @required this.bottomBar,
    @required this.topBarHeight,
    @required this.bottomBarHeight,
  }) : super(key: key);

  final Widget frontDrop;

  final Widget rearChild;

  final Widget bottomBar;

  final double topBarHeight;

  final double bottomBarHeight;

  @override
  _MainLayoutState createState() => _MainLayoutState();
}

class _MainLayoutState extends State<_MainLayout>
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
      value: 0.0,
      vsync: this
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Widget _buildStack(BuildContext context, BoxConstraints constraints, double value) {
    final double topPadding = widget.topBarHeight;
    final double bottomPadding = widget.bottomBarHeight;
    _draggableExtent = (constraints.maxHeight - topPadding - bottomPadding);
    final double bottomInset = bottomPadding + ((1.0 - value) * _draggableExtent);
    return Stack(
      children: <Widget>[
        Padding(
          padding: EdgeInsets.only(
            top: topPadding - 24.0,
            bottom: bottomPadding
          ),
          child: widget.rearChild
        ),
        Positioned(
          left: 0.0,
          right: 0.0,
          top: 0.0,
          bottom: bottomInset,
          child: Material(
            shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.vertical(
                bottom: Radius.circular(24.0)
              )
            ),
            clipBehavior: Clip.antiAlias,
            elevation: 2.0,
            child: widget.frontDrop
          )
        ),
        Align(
          alignment: Alignment.bottomCenter,
          child: Material(
            shape: _OutwardBorder.top(24.0 * value),
            elevation: 2.0,
            color: const Color(0xFFE0E0E0),
            child: SizedBox(
              height: widget.bottomBarHeight,
              child: widget.bottomBar,
            )
          )
        ),
        Positioned(
          left: 0.0,
          right: 0.0,
          top: constraints.maxHeight - bottomInset - 24.0,
          bottom: bottomInset,
          child: GestureDetector(
            behavior: HitTestBehavior.translucent,
            child: SizedBox.expand(),
            onVerticalDragUpdate: _handleDragUpdate,
            onVerticalDragEnd: _handleDragEnd,
          ),
        )
      ],
    );
  }

  @override
  Widget build(BuildContext _) {
    return LayoutBuilder(
      builder: (BuildContext _, BoxConstraints constraints) {
        return SizedBox.expand(
          child: ValueListenableBuilder(
            valueListenable: _controller,
            builder: (BuildContext context, double value, Widget _) {
              return _buildStack(context, constraints, value);
            }
          )
        );
      }
    );
  }
}
