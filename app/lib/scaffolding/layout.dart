part of 'scaffolding.dart';

typedef _LayoutWidgetBuilder = Widget Function(
  BuildContext context,
  Animation<double> animation
);

class _Layout extends StatefulWidget {

  _Layout({
    Key key,
    @required this.canDrag,
    @required this.overlappedBuilder,
    @required this.overlapBuilder
  }) : super(key: key);

  final bool canDrag;

  final _LayoutWidgetBuilder overlappedBuilder;

  final _LayoutWidgetBuilder overlapBuilder;

  @override
  _LayoutState createState() => _LayoutState();
}

class _LayoutState extends State<_Layout>
    with SingleTickerProviderStateMixin {

  AnimationController _controller;
  double _draggableExtent;

  bool get overlapIsVisible => _controller.value == 1.0;

  void showOverlap() {
    _controller.fling(velocity: 1.0);
  }

  void hideOverlap() {
    _controller.fling(velocity: -1.0);
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

  Widget _buildLayout(
      BuildContext context,
      BoxConstraints constraints,
      double value,
      Widget overlapped,
      Widget overlap) {
    final double topBarHeight = MediaQuery.of(context).padding.top + 56.0;
    _draggableExtent = constraints.maxHeight - topBarHeight;
    final double bottomInset = (1.0 - value) * _draggableExtent;
    return Stack(
      children: <Widget>[
        overlapped,
        Positioned.fill(
          bottom: bottomInset,
          child: Material(
            type: MaterialType.canvas,
            elevation: 1.0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.vertical(
                bottom: Radius.circular(24.0)
              )
            ),
            clipBehavior: Clip.antiAlias,
            child: overlap
          )
        ),
        Positioned.fill(
          top: constraints.maxHeight + ((1.0 - value) * 24.0),
          child: Material(
            elevation: 1.0 - value,
            color: const Color(0xFFF0F0F0),
            shape: _OutwardBorder(24.0),
          ),
        ),
        if (widget.canDrag)
          Positioned.fill(
            top: constraints.maxHeight - bottomInset - 36.0,
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
    final Widget overlapped = widget.overlappedBuilder(context, _controller);
    final Widget overlap = widget.overlapBuilder(context, _controller);

    // We always give it a new UniqueKey, otherwise it doesn't rebuild on
    // certain occasions which causes problems down the build pipeline.
    return LayoutBuilder(
      key: UniqueKey(),
      builder: (BuildContext context, BoxConstraints constraints) {
        return ValueListenableBuilder(
            valueListenable: _controller,
            builder: (BuildContext context, double value, Widget _) {
              return _buildLayout(context, constraints, value, overlapped, overlap);
            },
        );
      },
    );
  }
}

class _OutwardBorder extends ShapeBorder {

  static const double _radiansPerDegree = math.pi / 180;
  static const double _ninetyDegreesInRadians = 90 * _radiansPerDegree;
  static const double _oneHundredEightyDegreesInRadians = 180 * _radiansPerDegree;

  const _OutwardBorder(this.radius);

  final double radius;

  @override
  EdgeInsetsGeometry get dimensions => EdgeInsets.zero;

  @override
  ShapeBorder scale(double t) => _OutwardBorder(radius * t);

  Path _getPath(Rect rect) {
    final double diameter = radius * 2;
    return Path()
      ..arcTo(
          Rect.fromLTWH(0, -diameter, diameter, diameter),
          _oneHundredEightyDegreesInRadians,
          -_ninetyDegreesInRadians,
          false)
      ..lineTo(rect.width - radius, 0)
      ..arcTo(
          Rect.fromLTWH(rect.width - diameter, -diameter, diameter, diameter),
          _ninetyDegreesInRadians,
          -_ninetyDegreesInRadians,
          false)
      ..lineTo(rect.width, rect.height)
      ..lineTo(0, rect.height)
      ..lineTo(0, -radius);
  }

  @override
  Path getInnerPath(Rect rect, {TextDirection textDirection}) {
    return _getPath(rect);
  }

  @override
  Path getOuterPath(Rect rect, {TextDirection textDirection}) {
    return _getPath(rect);
  }

  @override
  void paint(Canvas canvas, Rect rect, {TextDirection textDirection}) { }
}
