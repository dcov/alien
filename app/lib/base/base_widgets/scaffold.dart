part of '../base.dart';

/// Configuration that [CustomScaffold] depends on.
///
/// It's inherited instead of passed directly to [CustomScaffold] so that a
/// non-parent [Widget] can configure it.
class CustomScaffoldConfiguration extends InheritedWidget {

  CustomScaffoldConfiguration({
    Key key,
    @required this.barHeight,
    @required this.barElevation,
    @required this.bottomLeading,
    Widget child,
  }) : super(key: key, child: child);

  final double barHeight;
  final double barElevation;
  final Widget bottomLeading;

  static CustomScaffoldConfiguration of(BuildContext context) {
    return context.inheritFromWidgetOfExactType(CustomScaffoldConfiguration);
  }

  @override
  bool updateShouldNotify(CustomScaffoldConfiguration oldWidget) {
    return oldWidget.barHeight != this.barHeight ||
           oldWidget.barElevation != this.barElevation ||
           oldWidget.bottomLeading != this.bottomLeading;
  }
}

abstract class ScaffoldEntry {

  String get title;

  List<Widget> buildTopActions(BuildContext context) => const <Widget>[];

  Widget buildBody(BuildContext context);

  List<Widget> buildBottomActions(BuildContext context) => const <Widget>[];
}

class CustomScaffold extends StatefulWidget {

  CustomScaffold({
    Key key,
    @required this.onPop,
  }) : super(key: key);

  final VoidCallback onPop;

  @override
  CustomScaffoldState createState() => CustomScaffoldState();
}

enum _Transition {
  push,
  pop,
  replace
}

class CustomScaffoldState extends State<CustomScaffold>
    with TickerProviderStateMixin {

  /// The current stack of [ScaffoldEntry]s.
  UnmodifiableListView<ScaffoldEntry> get entries => UnmodifiableListView<ScaffoldEntry>(_entries);

  final List<ScaffoldEntry> _entries = <ScaffoldEntry>[];
  AnimationController _controller;
  _Transition _transition;

  /// Resets the [_controller] to a new [AnimationController], and disposes
  /// of the old [_controller] if it existed.
  ///
  /// This is called every time a call to [push], [pop], or [replace] happens
  /// to ensure that we've had a chance to render the new state at least once
  /// before we start animating.
  void _resetController({ double value: 0.0 }) {
    _controller?.dispose();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 300),
      value: value,
      vsync: this
    );
  }

  Future<void> push(ScaffoldEntry entry) {
    assert(_controller?.isAnimating != true);
    setState(() {
      _transition = _Transition.push;
      _entries.add(entry);
      _resetController();
    });
    return _controller.forward(from: 0.0).orCancel;
  }

  Future<void> pop() {
    assert(_controller?.isAnimating != true);
    setState(() {
      _transition = _Transition.pop;
      _resetController();
    });
    return _controller.reverse(from: 1.0).orCancel.then((_) {
      setState(() {
        // Reset the controller to value 1.0 to enable the drag-to-pop gesture.
        _resetController(value: 1.0);
        _entries.removeLast();
      });
    });
  }

  Future<void> replace(List<ScaffoldEntry> entries) {
    assert(_controller?.isAnimating != true);
    assert(entries.isNotEmpty);
    setState(() {
      _transition = _Transition.replace;
      _entries.add(entries.last);
      _resetController();
    });
    return _controller.forward(from: 0.0).orCancel.then((_) {
      setState(() {
        _entries.replaceRange(0, _entries.length, entries);
      });
    });
  }
  
  @override
  void dispose() {
    super.dispose();
    _controller?.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_entries.isEmpty) {
      return const SizedBox.expand();
    }

    final CustomScaffoldConfiguration config = CustomScaffoldConfiguration.of(context);
    final ScaffoldEntry primary = _entries.last;
    final ScaffoldEntry secondary = _entries.length > 1 ? _entries[_entries.length - 2] : null;
    final ScaffoldEntry ternary = _entries.length > 2 ? _entries[_entries.length - 3] : null;
    final Animation<double> animation = (_transition == _Transition.pop)? ReverseAnimation(_controller) : _controller;

    return Stack(
      children: <Widget>[
        Column(
          children: <Widget>[
            _TopBar(
              onPop: widget.onPop,
              animation: animation,
              transition: _transition,
              height: config.barHeight,
              elevation: config.barElevation,
              primary: primary,
              secondary: secondary,
              ternary: ternary,
            ),
            Expanded(
              child: _Body(
                animation: animation,
                transition: _transition,
                primary: primary,
                secondary: secondary,
              )
            ),
            _BottomBar(
              animation: animation,
              transition: _transition,
              height: config.barHeight,
              elevation: config.barElevation,
              primary: primary,
              secondary: secondary,
              leading: config.bottomLeading,
            )
          ],
        ),
      ]
    );
  }
}

class _TopBar extends StatefulWidget {

  _TopBar({
    Key key,
    this.animation,
    this.transition,
    this.height,
    this.elevation,
    this.primary,
    this.secondary,
    this.ternary,
    this.onPop,
  }) : super(key: key);

  final Animation<double> animation;
  final _Transition transition;
  final double height;
  final double elevation;
  final ScaffoldEntry primary;
  final ScaffoldEntry secondary;
  final ScaffoldEntry ternary;
  final VoidCallback onPop;

  @override
  _TopBarState createState() => _TopBarState();
}

class _TopBarState extends State<_TopBar> with TickerProviderStateMixin {

  AnimationController _pressableController;

  @override
  void initState() {
    super.initState();
    _pressableController = Pressable.createController(vsync: this);
  }

  @override
  void reassemble() {
    super.reassemble();
    _pressableController?.dispose();
    _pressableController = Pressable.createController(vsync: this);
  }

  @override
  void dispose() {
    super.dispose();
    _pressableController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final TextStyleTween textStyle = TextStyleTween(
      begin: TextStyle(
        fontSize: 14.0,
        fontWeight: FontWeight.w300
      ),
      end: TextStyle(
        fontSize: 16.0,
        fontWeight: FontWeight.bold
      )
    );
    final EdgeInsets mediaPadding = MediaQuery.of(context).padding;
    return SizedBox(
      height: widget.height + mediaPadding.top,
      child: Padding(
        padding: mediaPadding,
        child: Material(
          elevation: widget.elevation,
          child: CustomMultiChildLayout(
            delegate: _TopBarTransition(widget.animation),
            children: <Widget>[
              if (widget.ternary != null)
                LayoutId(
                  id: _TopBarSlot.ternaryTitle,
                  child: _AnimatedTitle(
                    animation: const AlwaysStoppedAnimation(0.0),
                    textStyle: textStyle,
                    title: widget.ternary.title,
                  )
                ),
              if (widget.secondary != null)
                ...<Widget>[
                  LayoutId(
                    id: _TopBarSlot.secondaryTitle,
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: Pressable(
                        onPress: widget.onPop,
                        onLongPress: () {},
                        controller: _pressableController,
                        alignment: Alignment.centerLeft,
                        child: _AnimatedTitle(
                          animation: ReverseAnimation(widget.animation),
                          textStyle: textStyle,
                          title: widget.secondary.title,
                        )
                      )
                    ),
                  ),
                  LayoutId(
                    id: _TopBarSlot.secondaryActions,
                    child: FadeTransition(
                      opacity: ReverseAnimation(widget.animation),
                      child: _ActionsRow(children: widget.secondary.buildTopActions(context)),
                    )
                  ),
                ],
              LayoutId(
                id: _TopBarSlot.primaryTitle,
                child: Center(
                  child: _AnimatedTitle(
                    animation: widget.animation,
                    textStyle: textStyle,
                    title: widget.primary.title,
                  )
                ),
              ),
              LayoutId(
                id: _TopBarSlot.primaryActions,
                child: Align(
                  alignment: Alignment.centerRight,
                  child: FadeTransition(
                    opacity: widget.animation,
                    child: _ActionsRow(children: widget.primary.buildTopActions(context)),
                  )
                )
              ),
              if (widget.secondary != null)
                LayoutId(
                  id: _TopBarSlot.leading,
                  child: Align(
                    widthFactor: 1.0,
                    alignment: Alignment.centerLeft,
                    child: Pressable(
                      onPress: widget.onPop,
                      onLongPress: () {},
                      controller: _pressableController,
                      alignment: Alignment.centerRight,
                      child: Icon(
                        Icons.keyboard_arrow_left,
                        size: 24.0
                      ),
                    )
                  )
                )
            ],
          ),
        )
      )
    );
  }
}

class _AnimatedTitle extends AnimatedWidget {

  _AnimatedTitle({
    Key key,
    Animation<double> animation,
    this.textStyle,
    this.title,
  }) : super(key: key, listenable: animation);

  @override
  Animation<double> get listenable => super.listenable;

  final TextStyleTween textStyle;

  final String title;

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      style: textStyle.evaluate(listenable),
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
    );
  }
}

enum _TopBarSlot {
  leading,
  primaryTitle,
  primaryActions,
  secondaryTitle,
  secondaryActions,
  ternaryTitle,
}

class _TopBarTransition extends MultiChildLayoutDelegate {

  _TopBarTransition(this.animation) : super(relayout: animation);

  final Animation<double> animation;

  void _placeTrailing(_TopBarSlot slot, Size size) {
    layoutChild(slot, BoxConstraints.tight(size));
    positionChild(slot, Offset(size.width * 2, 0.0));
  }

  @override
  void performLayout(Size size) {
    assert(hasChild(_TopBarSlot.primaryTitle));
    assert(hasChild(_TopBarSlot.primaryActions));

    final double progress = animation.value;
    final Size maxChildSize = Size((size.width / 3), size.height);

    if (hasChild(_TopBarSlot.leading)) {
      assert(hasChild(_TopBarSlot.secondaryTitle));

      final Size leadingSize = layoutChild(
        _TopBarSlot.leading,
        BoxConstraints.loose(maxChildSize));

      positionChild(_TopBarSlot.leading, Offset.zero);

      layoutChild(
        _TopBarSlot.secondaryTitle,
        BoxConstraints.tight(Size(
          maxChildSize.width - (leadingSize.width * progress),
          maxChildSize.height
        )));
      
      final double maxSecondaryWidth = maxChildSize.width - leadingSize.width;
      positionChild(
        _TopBarSlot.secondaryTitle,
        Offset(
          leadingSize.width + (maxSecondaryWidth * (1.0 - progress)),
          0.0
        ));
      
      _placeTrailing(_TopBarSlot.secondaryActions, maxChildSize);
      
      if (hasChild(_TopBarSlot.ternaryTitle)) {
        layoutChild(
          _TopBarSlot.ternaryTitle,
          BoxConstraints.tight(Size(
            maxSecondaryWidth,
            maxChildSize.height
          )));

        positionChild(
          _TopBarSlot.ternaryTitle,
          Offset(
            leadingSize.width - (maxSecondaryWidth * progress),
            0.0
          ));
      }
    }

    layoutChild(
      _TopBarSlot.primaryTitle,
      BoxConstraints.tight(maxChildSize));

    if (hasChild(_TopBarSlot.leading)) {
      // Center the title
      positionChild(
        _TopBarSlot.primaryTitle,
        Offset(
          maxChildSize.width * (1 + (1.0 - progress)),
          0.0
        ));
    } else {
      // Align the title at start.
      positionChild(
        _TopBarSlot.primaryTitle,
        Offset.zero
      );
    }
    
    _placeTrailing(_TopBarSlot.primaryActions, maxChildSize);
  }

  @override
  bool shouldRelayout(_TopBarTransition oldDelegate) {
    return oldDelegate.animation != this.animation;
  }
}

class _Body extends StatelessWidget {

  _Body({
    Key key,
    this.animation,
    this.transition,
    this.primary,
    this.secondary,
  }) : super(key: key);

  final Animation<double> animation;
  final _Transition transition;
  final ScaffoldEntry primary;
  final ScaffoldEntry secondary;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: <Widget>[
        if (secondary != null)
          ValueListenableBuilder(
            valueListenable: animation,
            builder: (BuildContext context, double value, Widget child) {
              Widget result = Opacity(
                opacity: 1.0 - value,
                child: child,
              );

              if (transition == _Transition.push || transition == _Transition.pop) {
                result = Align(
                  alignment: AlignmentDirectional.centerStart,
                  child: Align(
                    alignment: AlignmentDirectional.centerEnd,
                    widthFactor: 1.0 - (value / 2),
                    child: result,
                  ),
                );
              }

              return result;
            },
            child: secondary.buildBody(context),
          ),
        ValueListenableBuilder(
          valueListenable: animation,
          builder: (BuildContext context, double value, Widget child) {
            Widget result = Opacity(
              opacity: value,
              child: child,
            );

            if (transition == _Transition.push || transition == _Transition.pop) {
              result = Align(
                alignment: AlignmentDirectional.centerEnd,
                child: Align(
                  alignment: AlignmentDirectional.centerStart,
                  widthFactor: value,
                  child: result,
                ),
              );
            }

            return result;
          },
          child: primary.buildBody(context),
        ),
      ],
    );
  }
}

class _BottomBar extends StatelessWidget {

  _BottomBar({
    Key key,
    this.animation,
    this.transition,
    this.height,
    this.elevation,
    this.leading,
    this.primary,
    this.secondary
  }) : super(key: key);

  final Animation<double> animation;
  final _Transition transition;
  final double height;
  final double elevation;
  final Widget leading;
  final ScaffoldEntry primary;
  final ScaffoldEntry secondary;
  
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: height,
      child: Material(
        elevation: elevation,
        child: CustomMultiChildLayout(
          delegate: _BottomBarTransition(animation),
          children: <Widget>[
            if (secondary != null)
              LayoutId(
                id: _BottomBarSlot.secondary,
                child: _ActionsRow(children: secondary.buildBottomActions(context)),
              ),
            LayoutId(
              id: _BottomBarSlot.primary,
              child: _ActionsRow(children: primary.buildBottomActions(context)),
            ),
            LayoutId(
              id: _BottomBarSlot.leading,
              child: leading,
            ),
          ]
        )
      )
    );
  }
}

enum _BottomBarSlot {
  leading,
  primary,
  secondary,
}

class _BottomBarTransition extends MultiChildLayoutDelegate {

  _BottomBarTransition(this.animation)
    : super(relayout: animation);

  final Animation<double> animation;

  @override
  void performLayout(Size size) {
    assert(hasChild(_BottomBarSlot.leading));
    assert(hasChild(_BottomBarSlot.primary));

    final Size leadingSize = layoutChild(_BottomBarSlot.leading, BoxConstraints.loose(size));
    positionChild(_BottomBarSlot.leading, Offset.zero);

    final Size trailingSize = Size(size.width - leadingSize.width, size.height);
    layoutChild(
      _BottomBarSlot.primary,
      BoxConstraints.tight(trailingSize)
    );

    final double progress = animation.value;
    if (hasChild(_BottomBarSlot.secondary)) {
      final Size secondarySize = layoutChild(
        _BottomBarSlot.secondary,
        BoxConstraints.tight(trailingSize)
      );

      positionChild(
        _BottomBarSlot.secondary,
        Offset(
          leadingSize.width - (trailingSize.width * progress),
          0.0
        )
      );

      positionChild(
        _BottomBarSlot.primary,
        Offset(
          size.width - (trailingSize.width * progress),
          0.0
        )
      );
    } else {
      positionChild(
        _BottomBarSlot.primary,
        Offset(
          leadingSize.width,
          0.0,
        )
      );
    }
  }

  @override
  bool shouldRelayout(_BottomBarTransition oldDelegate) {
    return oldDelegate.animation != this.animation;
  }
}

class _ActionsRow extends StatelessWidget {

  _ActionsRow({
    Key key,
    @required this.children,
  }) : super(key: key);

  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: children
    );
  }
}

class _IgnoreWhenAnimating extends AnimatedWidget {

  _IgnoreWhenAnimating({
    Key key,
    @required AnimationController controller,
    @required this.child
  }) : super(key: key, listenable: _IsAnimatingNotifier(controller));

  final Widget child;

  @override
  _IsAnimatingNotifier get listenable => super.listenable;

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      ignoring: listenable.value,
      child: child,
    );
  }
}

class _IsAnimatingNotifier extends ValueNotifier<bool> {

  _IsAnimatingNotifier(this._controller) : super(_controller.isAnimating);

  final AnimationController _controller;

  void _handleStatusChange(_) {
    value = _controller.isAnimating;
  }

  @override
  void addListener(VoidCallback listener) {
    super.addListener(listener);
    _controller.addStatusListener(_handleStatusChange);
  }

  @override
  void removeListener(VoidCallback listener) {
    super.removeListener(listener);
    _controller.removeStatusListener(_handleStatusChange);
  }
}

