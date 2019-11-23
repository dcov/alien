part of '../base.dart';

const double _kButtonSize = 48.0;

const double _kIconSize = 24.0;

const double _kBarHeight = 48.0;

const double _kPeekWidth = 24.0;

enum _ShellSlot {
  drawer,
  body,
  toggle,
  handle,
}

class Shell extends StatefulWidget {

  Shell({
    Key key,
    this.drawerController,
    this.bodyController,
    this.initialDrawerEntries = const <ShellAreaEntry>[],
    this.initialBodyEntries = const <ShellAreaEntry>[],
    this.onDrawerClose,
    this.onBodyPop,
  }) : assert(initialDrawerEntries != null),
       assert(initialBodyEntries != null),
       super(key: key);

  final ShellAreaController drawerController;

  final ShellAreaController bodyController;

  final List<ShellAreaEntry> initialDrawerEntries;

  final List<ShellAreaEntry> initialBodyEntries;

  final VoidCallback onDrawerClose;

  final VoidCallback onBodyPop;

  @override
  ShellState createState() => ShellState();
}

class ShellState extends State<Shell> with SingleTickerProviderStateMixin {

  final GlobalKey<ShellAreaState> _drawerKey = GlobalKey<ShellAreaState>();
  final GlobalKey<ShellAreaState> _bodyKey = GlobalKey<ShellAreaState>();
  AnimationController _controller;

  ShellAreaState get drawer => _drawerKey.currentState;

  ShellAreaState get body => _bodyKey.currentState;

  double get _draggableExtent => context.size.width - 24.0;

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

  void _toggle() {
    if (_controller.status == AnimationStatus.dismissed ||
        _controller.status == AnimationStatus.reverse) {
      _controller.forward();
    } else {
      _controller.reverse();
    }
  }

  void openDrawer() => _controller.forward();

  void closeDrawer() => _controller.reverse();

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 250),
      value: 0.0,
      vsync: this
    )..addStatusListener((AnimationStatus status) {
      if (status == AnimationStatus.dismissed && widget.onDrawerClose != null)
        widget.onDrawerClose();
    });
  }

  @override
  void dispose() {
    super.dispose();
    _controller.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final ColorTween overlayColorTween = ColorTween(
      begin: theme.canvasColor.withAlpha(0),
      end: theme.canvasColor.withAlpha(200),
    );
    return Material(
      child: CustomMultiChildLayout(
        delegate: _ShellLayout(_controller),
        children: <Widget>[
          LayoutId(
            id: _ShellSlot.drawer,
            child: IgnoreWhenAnimating(
              controller: _controller,
              until: 1.0,
              child: FadeTransition(
                opacity: _controller.drive(Tween(begin: 0.5, end: 1.0)),
                child: ShellArea(
                  key: _drawerKey,
                  controller: widget.drawerController,
                  initialEntries: widget.initialDrawerEntries,
                )
              )
            )
          ),
          LayoutId(
            id: _ShellSlot.body,
            child: IgnoreWhenAnimating(
              controller: _controller,
              until: 0.0,
              child: ValueListenableBuilder(
                valueListenable: _controller,
                builder: (_, double value, Widget child) {
                  return DecoratedBox(
                    position: DecorationPosition.foreground,
                    decoration: BoxDecoration(
                      color: overlayColorTween.transform(value),
                    ),
                    child: child
                  );
                },
                child: ShellArea(
                  key: _bodyKey,
                  controller: widget.bodyController,
                  initialEntries: widget.initialBodyEntries,
                ),
              )
            )
          ),
          LayoutId(
            id: _ShellSlot.toggle,
            child: Center(
              child: Pressable(
                onPress: _toggle,
                child: AnimatedIcon(
                  progress: _controller,
                  icon: AnimatedIcons.menu_close,
                  size: _kIconSize,
                ),
              )
            )
          ),
          LayoutId(
            id: _ShellSlot.handle,
            child: GestureDetector(
              behavior: HitTestBehavior.translucent,
              onHorizontalDragUpdate: _handleDragUpdate,
              onHorizontalDragEnd: _handleDragEnd,
            )
          ),
        ]
      )
    );
  }
}

class _ShellLayout extends MultiChildLayoutDelegate {

  _ShellLayout(this.animation) : super(relayout: animation);

  final Animation<double> animation;

  @override
  void performLayout(Size size) {
    assert(hasChild(_ShellSlot.drawer));
    assert(hasChild(_ShellSlot.body));
    assert(hasChild(_ShellSlot.toggle));
    assert(hasChild(_ShellSlot.handle));

    final double progress = animation.value;

    void _placeChild(_ShellSlot slot, double width, double offsetX) {
      layoutChild(slot, BoxConstraints.tight(Size(width, size.height)));
      positionChild(slot, Offset(offsetX, 0.0));
    }

    final double drawerWidth = size.width - _kPeekWidth;
    final double offsetX = drawerWidth * progress;

    _placeChild(_ShellSlot.drawer, drawerWidth, offsetX - drawerWidth);
    _placeChild(_ShellSlot.body, size.width, offsetX);
    _placeChild(_ShellSlot.handle, _kPeekWidth, offsetX);

    layoutChild(
      _ShellSlot.toggle,
      BoxConstraints.tight(Size(_kButtonSize, _kButtonSize))
    );

    positionChild(
      _ShellSlot.toggle,
      Offset(
        ((drawerWidth - _kButtonSize) / 2) * progress,
        size.height - _kButtonSize
      ),
    );
  }

  @override
  bool shouldRelayout(_ShellLayout oldDelegate) {
    return oldDelegate.animation != this.animation;
  }
}

