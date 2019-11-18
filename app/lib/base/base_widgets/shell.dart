part of '../base.dart';

/// Configuration that [Shell] depends on.
///
/// It's inherited instead of passed directly to [Shell] so that a
/// non-parent [Widget] can configure it.
class ShellConfiguration extends InheritedWidget {

  ShellConfiguration({
    Key key,
    @required this.barHeight,
    @required this.barElevation,
    @required this.bottomLeading,
    Widget child,
  }) : super(key: key, child: child);

  final double barHeight;
  final double barElevation;
  final Widget bottomLeading;

  static ShellConfiguration of(BuildContext context) {
    return context.inheritFromWidgetOfExactType(ShellConfiguration);
  }

  @override
  bool updateShouldNotify(ShellConfiguration oldWidget) {
    return oldWidget.barHeight != this.barHeight ||
           oldWidget.barElevation != this.barElevation ||
           oldWidget.bottomLeading != this.bottomLeading;
  }
}

abstract class ShellEntry {

  String get title;

  List<Widget> buildTopActions(BuildContext context) => const <Widget>[];

  Widget buildBody(BuildContext context);

  List<Widget> buildBottomActions(BuildContext context) => const <Widget>[];
}

class Shell extends StatefulWidget {

  Shell({
    Key key,
    @required this.onPop,
  }) : super(key: key);

  final VoidCallback onPop;

  @override
  ShellState createState() => ShellState();
}

class ShellState extends State<Shell>
    with TickerProviderStateMixin {

  /// The current stack of [ShellEntry]s.
  UnmodifiableListView<ShellEntry> get entries => UnmodifiableListView<ShellEntry>(_entries);

  Animation<double> get animation => _controller;

  final List<ShellEntry> _entries = <ShellEntry>[];
  List<ShellEntry> _replacements;
  AnimationController _controller;

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

  /// Adds [entry] to the end of the [entries] list, and starts a 'push'
  /// animation that animates [entry] in, and the now second-to-last
  /// [ShellEntry] out.
  ///
  /// It returns a [Future] that completes when the animation completes. It will
  /// never throw an error so it can be used safely with 'await'.
  Future<void> push(ShellEntry entry) async {
    assert(_controller?.isAnimating != true);
    setState(() {
      _entries.add(entry);
      _resetController();
    });
    try {
      await _controller.forward(from: 0.0).orCancel;
    } finally {
      // The animation completed, or the ticker was cancelled and we've caught
      // the error, we don't need to do anything else.
    }
  }

  /// Removes the last [ShellEntry] in [entries], which is the currently
  /// visible [ShellEntry], and starts a 'pop' animation that animates the
  /// last [ShellEntry] out, and the second to last [ShellEntry] in.
  ///
  /// It returns a [Future] that completes when the animation completes. It will
  /// never throw an error so it can be used safely with 'await'.
  Future<void> pop() async {
    assert(_controller?.isAnimating != true);
    setState(() {
      _resetController();
    });
    try {
      await _controller.reverse(from: 1.0).orCancel;
    } finally {
      setState(() {
        // Reset the controller to value 1.0 to enable the drag-to-pop gesture.
        _resetController(value: 1.0);
        _entries.removeLast();
      });
    }
  }

  /// Replaces the current list of [ShellEntry]s, [entries], with
  /// [replacements], and starts a 'replace' animation that animates the last,
  /// and second-to-last if it exists, [ShellEntry]s in [replacements] in,
  /// and animates the last, and second-to-last if it exists, [ShellEntry]s
  /// in the old [entries] out.
  ///
  /// It returns a [Future] that completes when the animation completes. It will
  /// never throw an error so it can be used safely with 'await'.
  Future<void> replace(List<ShellEntry> replacements) async {
    assert(_controller?.isAnimating != true);
    assert(replacements.isNotEmpty);
    setState(() {
      _replacements = replacements;
      _resetController();
    });
    try {
      await _controller.forward(from: 0.0).orCancel;
    } finally {
      setState(() {
        _entries..clear()
                ..addAll(_replacements);
        _replacements = null;
      });
    }
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

    final ShellConfiguration config = ShellConfiguration.of(context);
    final ShellEntry primary = _entries.last;
    final ShellEntry secondary = _entries.length > 1 ? _entries[_entries.length - 2] : null;
    final ShellEntry ternary = _entries.length > 2 ? _entries[_entries.length - 3] : null;

    ShellEntry replacementPrimary;
    ShellEntry replacementSecondary;
    if (_replacements != null) {
      replacementPrimary = _replacements.last;
      replacementSecondary = _replacements.length > 1 ? _replacements[_replacements.length - 2] : null;
    }

    return Stack(
      children: <Widget>[
        Column(
          children: <Widget>[
            _TopBar(
              onPop: widget.onPop,
              animation: _controller,
              height: config.barHeight,
              elevation: config.barElevation,
              primary: primary,
              secondary: secondary,
              // If we're rendering replacements, don't include the ternary entry.
              ternary: replacementPrimary != null ? null : ternary,
              replacementPrimary: replacementPrimary,
              replacementSecondary: replacementSecondary != secondary ? replacementSecondary : null,
            ),
            Expanded(
              child: _Body(
                animation: _controller,
                isReplace: replacementPrimary != null,
                primary: replacementPrimary ?? primary,
                secondary: replacementPrimary != null ? primary : secondary,
              )
            ),
            _BottomBar(
              animation: _controller,
              height: config.barHeight,
              elevation: config.barElevation,
              primary: replacementPrimary ?? primary,
              secondary: replacementPrimary != null ? primary : secondary,
              leading: config.bottomLeading,
            )
          ],
        ),
      ]
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
  replacementPrimaryTitle,
  replacementPrimaryActions,
  replacementSecondaryTitle,
}

class _TopBar extends StatefulWidget {

  _TopBar({
    Key key,
    this.animation,
    this.height,
    this.elevation,
    this.primary,
    this.secondary,
    this.ternary,
    this.replacementPrimary,
    this.replacementSecondary,
    this.onPop,
  }) : super(key: key);

  final Animation<double> animation;
  final double height;
  final double elevation;
  final ShellEntry primary;
  final ShellEntry secondary;
  final ShellEntry ternary;
  final ShellEntry replacementPrimary;
  final ShellEntry replacementSecondary;
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
    final EdgeInsets mediaPadding = MediaQuery.of(context).padding;
    final bool hasReplacements = widget.replacementPrimary != null;
    return SizedBox(
      height: widget.height + mediaPadding.top,
      child: Padding(
        padding: mediaPadding,
        child: Material(
          elevation: widget.elevation,
          child: CustomMultiChildLayout(
            delegate: _TopBarTransition(
              hasReplacements ? kAlwaysCompleteAnimation : widget.animation
            ),
            children: <Widget>[
              if (widget.ternary != null)
                LayoutId(
                  id: _TopBarSlot.ternaryTitle,
                  child: _SecondaryTitle.inactive(
                    animation: ReverseAnimation(widget.animation),
                    title: widget.ternary.title
                  ),
                ),
              if (widget.secondary != null)
                ...<Widget>[
                  LayoutId(
                    id: _TopBarSlot.secondaryTitle,
                    child: _SecondaryTitle(
                      animation: hasReplacements
                          ? ReverseAnimation(widget.animation)
                          : widget.animation,
                      pressableController: _pressableController,
                      title: widget.secondary.title,
                      onPop: widget.onPop,
                    )
                  ),
                  if (!hasReplacements)
                    LayoutId(
                      id: _TopBarSlot.secondaryActions,
                      child: _ActionsRow(
                        animation: ReverseAnimation(widget.animation),
                        children: widget.secondary.buildTopActions(context)
                      ),
                    ),
                ],
              if (widget.replacementSecondary != null)
                LayoutId(
                  id: _TopBarSlot.replacementSecondaryTitle,
                  child: _SecondaryTitle.inactive(
                    animation: widget.animation,
                    title: widget.replacementSecondary.title,
                  ),
                ),
              if (widget.secondary != null || widget.replacementSecondary != null)
                LayoutId(
                  id: _TopBarSlot.leading,
                  child: _Leading(
                    animation: widget.secondary != null
                        ? widget.replacementSecondary != null || widget.ternary != null
                            ? kAlwaysCompleteAnimation
                            : widget.animation
                        : widget.animation,
                    pressableController: _pressableController,
                    hasTernary: widget.ternary != null,
                    onPop: widget.onPop,
                  )
                ),
              LayoutId(
                id: _TopBarSlot.primaryTitle,
                child: _PrimaryTitle(
                  animation: widget.replacementPrimary != null
                      ? ReverseAnimation(widget.animation)
                      : widget.animation,
                  hasSecondary: widget.secondary != null,
                  title: widget.primary.title,
                )
              ),
              LayoutId(
                id: _TopBarSlot.primaryActions,
                child: _ActionsRow(
                  animation: widget.replacementPrimary != null
                      ? ReverseAnimation(widget.animation)
                      : widget.animation,
                  children: widget.primary.buildTopActions(context),
                )
              ),
              if (widget.replacementPrimary != null)
                ...<Widget>[
                  LayoutId(
                    id: _TopBarSlot.replacementPrimaryTitle,
                    child: _PrimaryTitle(
                      animation: widget.animation,
                      hasSecondary: widget.replacementSecondary != null,
                      title: widget.replacementPrimary.title
                    )
                  ),
                  LayoutId(
                    id: _TopBarSlot.replacementPrimaryActions,
                    child: _ActionsRow(
                      animation: widget.animation,
                      children: widget.replacementPrimary.buildTopActions(context)
                    ),
                  )
                ]
            ],
          ),
        )
      )
    );
  }
}

class _TopBarTransition extends MultiChildLayoutDelegate {

  _TopBarTransition(this.animation)
    : super(relayout: animation);

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

    layoutChild(
      _TopBarSlot.primaryTitle,
      BoxConstraints.loose(maxChildSize)
    );

    if (hasChild(_TopBarSlot.replacementPrimaryTitle)) {
      assert(hasChild(_TopBarSlot.replacementPrimaryActions));
      layoutChild(
        _TopBarSlot.replacementPrimaryTitle,
        BoxConstraints.loose(maxChildSize)
      );
      _placeTrailing(_TopBarSlot.replacementPrimaryActions, maxChildSize);
    }

    if (hasChild(_TopBarSlot.leading)) {
      final Size leadingSize = layoutChild(
        _TopBarSlot.leading,
        BoxConstraints.loose(maxChildSize)
      );

      positionChild(_TopBarSlot.leading, Offset.zero);

      final double maxSecondaryWidth = maxChildSize.width - leadingSize.width;

      if (hasChild(_TopBarSlot.secondaryTitle)) {
        layoutChild(
          _TopBarSlot.secondaryTitle,
          BoxConstraints.tight(Size(
            maxChildSize.width - (leadingSize.width * progress),
            maxChildSize.height
          ))
        );

        if (hasChild(_TopBarSlot.secondaryActions)) {
          _placeTrailing(_TopBarSlot.secondaryActions, maxChildSize);
        }

        if (hasChild(_TopBarSlot.ternaryTitle)) {
          positionChild(
            _TopBarSlot.secondaryTitle,
            Offset(
              leadingSize.width + (maxSecondaryWidth * (1.0 - progress)),
              0.0
            )
          );

          layoutChild(
            _TopBarSlot.ternaryTitle,
            BoxConstraints.tight(Size(
              maxSecondaryWidth,
              maxChildSize.height
            ))
          );

          positionChild(
            _TopBarSlot.ternaryTitle,
            Offset(
              leadingSize.width - (maxSecondaryWidth * progress),
              0.0
            )
          );
        } else {
          // Animate the position before the [_TopBarSlot.leading] fades in so
          // that they don't overlap.
          final Interval secondaryTitleInterval = const Interval(0.0, 0.5);
          positionChild(
            _TopBarSlot.secondaryTitle,
            Offset(
              12.0 + ((leadingSize.width - 12.0) * secondaryTitleInterval.transform(progress)),
              0.0
            )
          );
        }
      }

      final double primaryOffsetX = maxChildSize.width * (1 + (1.0 - progress));
      // Center the title
      positionChild(_TopBarSlot.primaryTitle, Offset(primaryOffsetX, 0.0));

      if (hasChild(_TopBarSlot.replacementSecondaryTitle)) {
        assert(hasChild(_TopBarSlot.replacementSecondaryTitle));
        positionChild(
          _TopBarSlot.replacementPrimaryTitle,
          Offset(primaryOffsetX, 0.0)
        );

        layoutChild(
          _TopBarSlot.replacementSecondaryTitle,
          BoxConstraints.loose(Size(
            maxSecondaryWidth,
            maxChildSize.height
          ))
        );

        positionChild(
          _TopBarSlot.replacementSecondaryTitle,
          Offset(leadingSize.width, 0.0)
        );
      } else if (hasChild(_TopBarSlot.replacementPrimaryTitle)) {
        positionChild(
          _TopBarSlot.replacementPrimaryTitle,
          Offset.zero
        );
      }
    } else {
      // Align the title at start.
      positionChild(
        _TopBarSlot.primaryTitle,
        Offset.zero
      );

      if (hasChild(_TopBarSlot.replacementPrimaryTitle)) {
        positionChild(
          _TopBarSlot.replacementPrimaryTitle,
          Offset.zero
        );
      }
    }
    
    _placeTrailing(_TopBarSlot.primaryActions, maxChildSize);
  }

  @override
  bool shouldRelayout(_TopBarTransition oldDelegate) {
    return oldDelegate.animation != this.animation;
  }
}

class _Leading extends StatelessWidget {

  _Leading({
    Key key,
    @required this.animation,
    @required this.pressableController,
    @required this.hasTernary,
    @required this.onPop,
  }) : super(key: key);

  final Animation<double> animation;
  final AnimationController pressableController;
  final bool hasTernary;
  final VoidCallback onPop;

  @override
  Widget build(BuildContext context) {
    return Align(
      widthFactor: 1.0,
      alignment: Alignment.centerLeft,
      child: Tooltip(
        message: 'Go back',
        child: Pressable(
          onPress: onPop,
          controller: pressableController,
          alignment: Alignment.centerRight,
          child: FadeTransition(
            opacity: hasTernary
                ? kAlwaysCompleteAnimation
                : CurvedAnimation(
                    parent: animation,
                    curve: Interval(0.5, 1.0)
                  ),
            child: Material(
              child: Icon(
                Icons.keyboard_arrow_left,
                size: 24.0
              )
            )
          ),
        )
      )
    );
  }
}

class _SecondaryTitle extends StatelessWidget {

  _SecondaryTitle({
    Key key,
    @required this.animation,
    @required this.pressableController,
    @required this.title,
    @required this.onPop,
  }) : assert(animation != null),
       assert(pressableController != null),
       assert(title != null),
       assert(onPop != null),
       super(key: key);

  _SecondaryTitle.inactive({
    Key key,
    @required this.animation,
    @required this.title
  }) : pressableController = null,
       onPop = null,
       assert(title != null),
       super(key: key);

  final Animation<double> animation;
  final AnimationController pressableController;
  final String title;
  final VoidCallback onPop;

  @override
  Widget build(BuildContext context) {
    Widget result = _AnimatedTitle(
      animation: onPop != null ? animation : kAlwaysCompleteAnimation,
      textStyle: TextStyleTween(
        begin: TextStyle(
          fontSize: 14.0,
          fontWeight: FontWeight.w700,
        ),
        end: TextStyle(
          fontSize: 14.0,
          fontWeight: FontWeight.w300
        )
      ),
      title: title,
    );

    if (onPop != null) {
      result = Tooltip(
        message: 'Go back',
        child: Pressable(
          onPress: onPop,
          controller: pressableController,
          alignment: Alignment.centerLeft,
          child: result
        )
      );
    } else {
      result = FadeTransition(
        opacity: animation,
        child: result,
      );
    }

    return Align(
      alignment: Alignment.centerLeft,
      child: result
    );
  }
}

class _AnimatedTitle extends AnimatedWidget {

  _AnimatedTitle({
    Key key,
    @required Animation<double> animation,
    @required this.textStyle,
    @required this.title,
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

class _PrimaryTitle extends StatelessWidget {

  _PrimaryTitle({
    Key key,
    @required this.animation,
    @required this.hasSecondary,
    @required this.title,
  }) : super(key: key);

  final Animation<double> animation;
  final bool hasSecondary;
  final String title;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 12.0),
      child: Align(
        alignment: hasSecondary ? Alignment.center : Alignment.centerLeft,
        child: FadeTransition(
          opacity: animation,
          child: Text(
            title,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontSize: 14.0,
              fontWeight: FontWeight.w700
            )
          )
        )
      )
    );
  }
}

class _Body extends StatelessWidget {

  _Body({
    Key key,
    @required this.animation,
    @required this.isReplace,
    @required this.primary,
    @required this.secondary,
  }) : super(key: key);

  final Animation<double> animation;
  final bool isReplace;
  final ShellEntry primary;
  final ShellEntry secondary;

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

              if (!isReplace) {
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

            if (!isReplace) {
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
    @required this.animation,
    @required this.height,
    @required this.elevation,
    @required this.leading,
    @required this.primary,
    @required this.secondary
  }) : super(key: key);

  final Animation<double> animation;
  final double height;
  final double elevation;
  final Widget leading;
  final ShellEntry primary;
  final ShellEntry secondary;
  
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: height,
      child: Material(
        elevation: elevation,
        child: Row(
          children: <Widget>[
            leading,
            Expanded(
              child: Stack(
                children: <Widget>[
                  if (secondary != null)
                    _ActionsRow(
                      animation: ReverseAnimation(animation),
                      children: secondary.buildBottomActions(context)
                    ),
                  _ActionsRow(
                    animation: animation,
                    children: primary.buildBottomActions(context)
                  ),
                ]
              )
            )
          ]
        )
      )
    );
  }
}

class _ActionsRow extends StatelessWidget {

  _ActionsRow({
    Key key,
    @required this.animation,
    @required this.children,
  }) : super(key: key);

  final Animation<double> animation;

  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerRight,
      child: FadeTransition(
        opacity: animation,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: children
        )
      )
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

