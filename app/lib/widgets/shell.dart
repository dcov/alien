import 'dart:collection';

import 'package:flutter/material.dart';

import 'pressable.dart';

const double _kButtonSize = 48.0;

const double _kIconSize = 24.0;

const double _kBarHeight = 48.0;

const double _kPeekWidth = 24.0;

enum _ShellSlot {
  drawer,
  body,
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

class ShellState extends State<Shell> with TickerProviderStateMixin {

  final GlobalKey<ShellAreaState> _drawerKey = GlobalKey<ShellAreaState>();
  final GlobalKey<ShellAreaState> _bodyKey = GlobalKey<ShellAreaState>();
  AnimationController _layoutController;
  AnimationController _peekController;

  ShellAreaState get drawer => _drawerKey.currentState;

  ShellAreaState get body => _bodyKey.currentState;

  void openDrawer() => _layoutController.forward();

  void closeDrawer() => _layoutController.reverse();

  Future<void> expandDrawer() => _peekController.forward();

  Future<void> shrinkDrawer() => _peekController.reverse();

  double get _draggableExtent => context.size.width - 24.0;

  void _handleDragUpdate(DragUpdateDetails details) {
    _layoutController.value += details.primaryDelta / _draggableExtent;
  }

  void _handleDragEnd(DragEndDetails details) {
    if (details.primaryVelocity.abs() > 700) {
      _layoutController.fling(velocity: details.primaryVelocity / _draggableExtent);
    } else if (_layoutController.value > 0.5) {
      _layoutController.fling(velocity: 1.0);
    } else {
      _layoutController.fling(velocity: -1.0);
    }
  }

  void _toggle() {
    if (_layoutController.status == AnimationStatus.dismissed ||
        _layoutController.status == AnimationStatus.reverse) {
      _layoutController.forward();
    } else {
      _layoutController.reverse();
    }
  }

  @override
  void initState() {
    super.initState();
    _layoutController = AnimationController(
      duration: const Duration(milliseconds: 250),
      value: 0.0,
      vsync: this
    )..addStatusListener((AnimationStatus status) {
      if (status == AnimationStatus.dismissed && widget.onDrawerClose != null)
        widget.onDrawerClose();
    });

    _peekController = AnimationController(
      duration: const Duration(milliseconds: 200),
      value: 0.0,
      vsync: this,
    );
  }

  @override
  void dispose() {
    super.dispose();
    _layoutController.dispose();
    _peekController.dispose();
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
        delegate: _ShellLayout(
          layout: _layoutController,
          peek: _peekController,
        ),
        children: <Widget>[
          LayoutId(
            id: _ShellSlot.drawer,
            child: _IgnoreWhenAnimating(
              controller: _layoutController,
              until: 1.0,
              child: FadeTransition(
                opacity: _layoutController.drive(Tween(begin: 0.5, end: 1.0)),
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
            child: _IgnoreWhenAnimating(
              controller: _layoutController,
              until: 0.0,
              child: ValueListenableBuilder(
                valueListenable: _layoutController,
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
                  bottomLeading: SizedBox(
                    width: _kButtonSize,
                    height: _kButtonSize,
                    child: Center(
                      child: Pressable(
                        onPress: _toggle,
                        child: Icon(Icons.menu),
                      )
                    )
                  )
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

  _ShellLayout({
    @required this.layout,
    @required this.peek
  }) : super(
    // We use an [AnimationMean] so that we listen to both [layout], and [peek].
    relayout: AnimationMean(left: layout, right: peek),
  );

  final Animation<double> layout;
  final Animation<double> peek;

  @override
  void performLayout(Size size) {
    assert(hasChild(_ShellSlot.drawer));
    assert(hasChild(_ShellSlot.body));
    assert(hasChild(_ShellSlot.handle));

    void _placeChild({
      @required _ShellSlot slot,
      @required double width,
      @required double offsetX,
    }) {
      layoutChild(slot, BoxConstraints.tight(Size(width, size.height)));
      positionChild(slot, Offset(offsetX, 0.0));
    }

    final double drawerWidth = size.width - (_kPeekWidth * (1.0 - peek.value));
    final double offsetX = drawerWidth * layout.value;

    _placeChild(
      slot: _ShellSlot.drawer,
      width: drawerWidth,
      offsetX: offsetX - drawerWidth
    );

    _placeChild(
      slot: _ShellSlot.body,
      width: size.width,
      offsetX: offsetX
    );
    
    _placeChild(
      slot: _ShellSlot.handle,
      width: _kPeekWidth,
      offsetX: offsetX
    );
  }

  @override
  bool shouldRelayout(_ShellLayout oldDelegate) {
    return oldDelegate.layout != this.layout ||
           oldDelegate.peek != this.peek;
  }
}

/// The shim between [ShellArea] and [ShellAreaEntry]s.
///
/// The [ShellArea] in scope can be modified by calling [push] or [pop] with
/// an [Object] that is either already a [ShellAreaEntry], or can be mapped to
/// a [ShellAreaEntry].
///
/// The default behavior, which is implemented by [ShellAreaState], only
/// accepts [ShellAreaEntry]s as values for either [push] or [pop].
abstract class ShellAreaController {

  /// Pushes a [ShellAreaEntry] mapping of [value] onto the [ShellArea] in
  /// scope.
  void push(covariant Object value);

  /// Pops a [ShellAreaEntry] mapping of [value] from the [ShellArea] in scope.
  /// If [value] isn't given, or it's null, the last [ShellAreaEntry] will be
  /// popped from the [ShellArea] stack.
  void pop([covariant Object value]);
}

class _ShellAreaControllerScope extends InheritedWidget {

  _ShellAreaControllerScope({
    Key key,
    @required this.controller,
    Widget child
  }) : assert(controller != null),
       super(key: key, child: child);

  final ShellAreaController controller;

  @override
  bool updateShouldNotify(_ShellAreaControllerScope oldWidget) {
    return oldWidget.controller != this.controller;
  }
}

extension ShellAreaControllerExtensions on BuildContext {

  ShellAreaController get _controller {
    final _ShellAreaControllerScope scope = dependOnInheritedWidgetOfExactType();
    assert(scope != null);
    return scope.controller;
  }

  void push(Object value) => _controller.push(value);

  void pop([Object value]) => _controller.pop(value);
}

abstract class ShellAreaEntry {

  String get title;

  List<Widget> buildTopActions(BuildContext context) => const <Widget>[];

  Widget buildBody(BuildContext context);

  List<Widget> buildBottomActions(BuildContext context) => const <Widget>[];
}

class ShellAreaPadding extends InheritedWidget {

  ShellAreaPadding({
    Key key,
    @required this.bodyPadding,
    Widget child,
  }) : assert(bodyPadding != null),
       super(key: key, child: child);

  final EdgeInsets bodyPadding;

  @override
  bool updateShouldNotify(ShellAreaPadding oldWidget) {
    return oldWidget.bodyPadding != this.bodyPadding;
  }
}

extension ShellAreaPaddingExtensions on BuildContext {

  ShellAreaPadding get areaPadding {
    final ShellAreaPadding padding = dependOnInheritedWidgetOfExactType();
    assert(padding != null);
    return padding;
  }

  EdgeInsets get bodyAreaPadding => areaPadding.bodyPadding;
}

class ShellArea extends StatefulWidget {

  ShellArea({
    Key key,
    this.controller,
    this.initialEntries = const <ShellAreaEntry>[],
    this.bottomLeading,
  }) : super(key: key);

  final ShellAreaController controller;

  final List<ShellAreaEntry> initialEntries;

  final Widget bottomLeading;

  @override
  ShellAreaState createState() => ShellAreaState();
}

class ShellAreaState extends State<ShellArea>
    with TickerProviderStateMixin
    implements ShellAreaController {

  /// The current stack of [ShellAreaEntry]s.
  UnmodifiableListView<ShellAreaEntry> get entries => UnmodifiableListView<ShellAreaEntry>(_entries);

  Animation<double> get animation => _controller;

  List<ShellAreaEntry> _entries;
  List<ShellAreaEntry> _replacements;
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
  /// [ShellAreaEntry] out.
  ///
  /// It returns a [Future] that completes when the animation completes. It will
  /// never throw an error so it can be used safely with 'await'.
  @override
  Future<void> push(ShellAreaEntry entry) async {
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

  /// Removes the last [ShellAreaEntry] in [entries], which is the currently
  /// visible [ShellAreaEntry], and starts a 'pop' animation that animates the
  /// last [ShellAreaEntry] out, and the second to last [ShellAreaEntry] in.
  ///
  /// It returns a [Future] that completes when the animation completes. It will
  /// never throw an error so it can be used safely with 'await'.
  @override
  Future<void> pop([ShellAreaEntry entry]) async {
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

  /// Replaces the current list of [ShellAreaEntry]s, [entries], with
  /// [replacements], and starts a 'replace' animation that animates the last,
  /// and second-to-last if it exists, [ShellAreaEntry]s in [replacements] in,
  /// and animates the last, and second-to-last if it exists, [ShellAreaEntry]s
  /// in the old [entries] out.
  ///
  /// It returns a [Future] that completes when the animation completes. It will
  /// never throw an error so it can be used safely with 'await'.
  Future<void> replace(List<ShellAreaEntry> replacements) async {
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
  void initState() {
    super.initState();
    _entries = List<ShellAreaEntry>();
    _entries.addAll(widget.initialEntries);
    _resetController(value: 1.0);
  }
  
  @override
  void dispose() {
    super.dispose();
    _controller?.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_entries.isEmpty)
      return const SizedBox();

    final ShellAreaEntry primary = _entries.last;
    final ShellAreaEntry secondary = _entries.length > 1 ? _entries[_entries.length - 2] : null;
    final ShellAreaEntry ternary = _entries.length > 2 ? _entries[_entries.length - 3] : null;

    ShellAreaEntry replacementPrimary;
    ShellAreaEntry replacementSecondary;
    if (_replacements != null) {
      replacementPrimary = _replacements.last;
      replacementSecondary = _replacements.length > 1 ? _replacements[_replacements.length - 2] : null;
    }

    final EdgeInsets mediaPadding = MediaQuery.of(context).padding;

    return _ShellAreaControllerScope(
      controller: widget.controller ?? this,
      child: ShellAreaPadding(
        bodyPadding: EdgeInsets.only(
          top: _kBarHeight + mediaPadding.top,
          bottom: _kBarHeight + mediaPadding.bottom,
        ),
        child: Stack(
          children: <Widget>[
            _Body(
              animation: _controller,
              isReplace: replacementPrimary != null,
              primary: replacementPrimary ?? primary,
              secondary: replacementPrimary != null ? primary : secondary,
            ),
            _TopBar(
              onPop: widget.controller?.pop ?? pop,
              animation: _controller,
              primary: primary,
              secondary: secondary,
              // If we're rendering replacements, don't include the ternary entry.
              ternary: replacementPrimary != null ? null : ternary,
              replacementPrimary: replacementPrimary,
              replacementSecondary: replacementSecondary != secondary ? replacementSecondary : null,
            ),
            Align(
              alignment: Alignment.bottomCenter,
              child: _BottomBar(
                animation: _controller,
                primary: replacementPrimary ?? primary,
                secondary: replacementPrimary != null ? primary : secondary,
                leading: widget.bottomLeading,
              )
            )
          ]
        )
      )
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
    this.primary,
    this.secondary,
    this.ternary,
    this.replacementPrimary,
    this.replacementSecondary,
    this.onPop,
  }) : super(key: key);

  final Animation<double> animation;
  final ShellAreaEntry primary;
  final ShellAreaEntry secondary;
  final ShellAreaEntry ternary;
  final ShellAreaEntry replacementPrimary;
  final ShellAreaEntry replacementSecondary;
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
      height: _kBarHeight + mediaPadding.top,
      child: Material(
        child: Padding(
          padding: mediaPadding,
          child: CustomMultiChildLayout(
            delegate: _TopBarLayout(
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
                        hasLeading: true,
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
                  hasLeading :true,
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
                      hasLeading: true,
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

class _TopBarLayout extends MultiChildLayoutDelegate {

  _TopBarLayout(this.animation)
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
  bool shouldRelayout(_TopBarLayout oldDelegate) {
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
                size: _kIconSize,
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
  final ShellAreaEntry primary;
  final ShellAreaEntry secondary;

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
    @required this.leading,
    @required this.primary,
    @required this.secondary
  }) : super(key: key);

  final Animation<double> animation;
  final Widget leading;
  final ShellAreaEntry primary;
  final ShellAreaEntry secondary;
  
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: _kBarHeight,
      child: Material(
        child: Row(
          children: <Widget>[
            if (leading != null)
              leading,
            Expanded(
              child: Stack(
                children: <Widget>[
                  if (secondary != null)
                    _ActionsRow(
                      animation: ReverseAnimation(animation),
                      hasLeading: leading != null,
                      children: secondary.buildBottomActions(context)
                    ),
                  _ActionsRow(
                    animation: animation,
                    hasLeading: leading != null,
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
    @required this.hasLeading,
    @required this.children,
  }) : super(key: key);

  final Animation<double> animation;

  final bool hasLeading;

  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: hasLeading ? Alignment.centerRight : Alignment.center,
      child: FadeTransition(
        opacity: animation,
        child: Row(
          mainAxisSize: hasLeading ? MainAxisSize.min : MainAxisSize.max,
          mainAxisAlignment: MainAxisAlignment.spaceAround,
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
    @required this.until,
    @required this.child
  }) : super(
    key: key,
    listenable: _IsAnimatingNotifier(controller, until)
  );

  final double until;

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

  _IsAnimatingNotifier(this.controller, this.until)
    : super(controller.isAnimating);

  final AnimationController controller;
  final double until;

  void _handleStatusChange(_) {
    value = controller.isAnimating || controller.value != until;
  }

  @override
  void addListener(VoidCallback listener) {
    super.addListener(listener);
    controller.addStatusListener(_handleStatusChange);
  }

  @override
  void removeListener(VoidCallback listener) {
    super.removeListener(listener);
    controller.removeStatusListener(_handleStatusChange);
  }
}

