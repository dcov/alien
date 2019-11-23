part of '../base.dart';

enum _ShellAreaTopBarSlot {
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

class ShellAreaTopBar extends StatefulWidget {

  ShellAreaTopBar({
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
  _ShellAreaTopBarState createState() => _ShellAreaTopBarState();
}

class _ShellAreaTopBarState extends State<ShellAreaTopBar> with TickerProviderStateMixin {

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
      child: Padding(
        padding: mediaPadding,
        child: Material(
          child: CustomMultiChildLayout(
            delegate: _ShellAreaTopBarLayout(
              hasReplacements ? kAlwaysCompleteAnimation : widget.animation
            ),
            children: <Widget>[
              if (widget.ternary != null)
                LayoutId(
                  id: _ShellAreaTopBarSlot.ternaryTitle,
                  child: _SecondaryTitle.inactive(
                    animation: ReverseAnimation(widget.animation),
                    title: widget.ternary.title
                  ),
                ),
              if (widget.secondary != null)
                ...<Widget>[
                  LayoutId(
                    id: _ShellAreaTopBarSlot.secondaryTitle,
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
                      id: _ShellAreaTopBarSlot.secondaryActions,
                      child: ActionsRow(
                        animation: ReverseAnimation(widget.animation),
                        children: widget.secondary.buildTopActions(context)
                      ),
                    ),
                ],
              if (widget.replacementSecondary != null)
                LayoutId(
                  id: _ShellAreaTopBarSlot.replacementSecondaryTitle,
                  child: _SecondaryTitle.inactive(
                    animation: widget.animation,
                    title: widget.replacementSecondary.title,
                  ),
                ),
              if (widget.secondary != null || widget.replacementSecondary != null)
                LayoutId(
                  id: _ShellAreaTopBarSlot.leading,
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
                id: _ShellAreaTopBarSlot.primaryTitle,
                child: _PrimaryTitle(
                  animation: widget.replacementPrimary != null
                      ? ReverseAnimation(widget.animation)
                      : widget.animation,
                  hasSecondary: widget.secondary != null,
                  title: widget.primary.title,
                )
              ),
              LayoutId(
                id: _ShellAreaTopBarSlot.primaryActions,
                child: ActionsRow(
                  animation: widget.replacementPrimary != null
                      ? ReverseAnimation(widget.animation)
                      : widget.animation,
                  children: widget.primary.buildTopActions(context),
                )
              ),
              if (widget.replacementPrimary != null)
                ...<Widget>[
                  LayoutId(
                    id: _ShellAreaTopBarSlot.replacementPrimaryTitle,
                    child: _PrimaryTitle(
                      animation: widget.animation,
                      hasSecondary: widget.replacementSecondary != null,
                      title: widget.replacementPrimary.title
                    )
                  ),
                  LayoutId(
                    id: _ShellAreaTopBarSlot.replacementPrimaryActions,
                    child: ActionsRow(
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

class _ShellAreaTopBarLayout extends MultiChildLayoutDelegate {

  _ShellAreaTopBarLayout(this.animation)
    : super(relayout: animation);

  final Animation<double> animation;

  void _placeTrailing(_ShellAreaTopBarSlot slot, Size size) {
    layoutChild(slot, BoxConstraints.tight(size));
    positionChild(slot, Offset(size.width * 2, 0.0));
  }

  @override
  void performLayout(Size size) {
    assert(hasChild(_ShellAreaTopBarSlot.primaryTitle));
    assert(hasChild(_ShellAreaTopBarSlot.primaryActions));

    final double progress = animation.value;
    final Size maxChildSize = Size((size.width / 3), size.height);

    layoutChild(
      _ShellAreaTopBarSlot.primaryTitle,
      BoxConstraints.loose(maxChildSize)
    );

    if (hasChild(_ShellAreaTopBarSlot.replacementPrimaryTitle)) {
      assert(hasChild(_ShellAreaTopBarSlot.replacementPrimaryActions));
      layoutChild(
        _ShellAreaTopBarSlot.replacementPrimaryTitle,
        BoxConstraints.loose(maxChildSize)
      );
      _placeTrailing(_ShellAreaTopBarSlot.replacementPrimaryActions, maxChildSize);
    }

    if (hasChild(_ShellAreaTopBarSlot.leading)) {
      final Size leadingSize = layoutChild(
        _ShellAreaTopBarSlot.leading,
        BoxConstraints.loose(maxChildSize)
      );

      positionChild(_ShellAreaTopBarSlot.leading, Offset.zero);

      final double maxSecondaryWidth = maxChildSize.width - leadingSize.width;

      if (hasChild(_ShellAreaTopBarSlot.secondaryTitle)) {
        layoutChild(
          _ShellAreaTopBarSlot.secondaryTitle,
          BoxConstraints.tight(Size(
            maxChildSize.width - (leadingSize.width * progress),
            maxChildSize.height
          ))
        );

        if (hasChild(_ShellAreaTopBarSlot.secondaryActions)) {
          _placeTrailing(_ShellAreaTopBarSlot.secondaryActions, maxChildSize);
        }

        if (hasChild(_ShellAreaTopBarSlot.ternaryTitle)) {
          positionChild(
            _ShellAreaTopBarSlot.secondaryTitle,
            Offset(
              leadingSize.width + (maxSecondaryWidth * (1.0 - progress)),
              0.0
            )
          );

          layoutChild(
            _ShellAreaTopBarSlot.ternaryTitle,
            BoxConstraints.tight(Size(
              maxSecondaryWidth,
              maxChildSize.height
            ))
          );

          positionChild(
            _ShellAreaTopBarSlot.ternaryTitle,
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
            _ShellAreaTopBarSlot.secondaryTitle,
            Offset(
              12.0 + ((leadingSize.width - 12.0) * secondaryTitleInterval.transform(progress)),
              0.0
            )
          );
        }
      }

      final double primaryOffsetX = maxChildSize.width * (1 + (1.0 - progress));
      // Center the title
      positionChild(_ShellAreaTopBarSlot.primaryTitle, Offset(primaryOffsetX, 0.0));

      if (hasChild(_ShellAreaTopBarSlot.replacementSecondaryTitle)) {
        assert(hasChild(_ShellAreaTopBarSlot.replacementSecondaryTitle));
        positionChild(
          _ShellAreaTopBarSlot.replacementPrimaryTitle,
          Offset(primaryOffsetX, 0.0)
        );

        layoutChild(
          _ShellAreaTopBarSlot.replacementSecondaryTitle,
          BoxConstraints.loose(Size(
            maxSecondaryWidth,
            maxChildSize.height
          ))
        );

        positionChild(
          _ShellAreaTopBarSlot.replacementSecondaryTitle,
          Offset(leadingSize.width, 0.0)
        );
      } else if (hasChild(_ShellAreaTopBarSlot.replacementPrimaryTitle)) {
        positionChild(
          _ShellAreaTopBarSlot.replacementPrimaryTitle,
          Offset.zero
        );
      }
    } else {
      // Align the title at start.
      positionChild(
        _ShellAreaTopBarSlot.primaryTitle,
        Offset.zero
      );

      if (hasChild(_ShellAreaTopBarSlot.replacementPrimaryTitle)) {
        positionChild(
          _ShellAreaTopBarSlot.replacementPrimaryTitle,
          Offset.zero
        );
      }
    }
    
    _placeTrailing(_ShellAreaTopBarSlot.primaryActions, maxChildSize);
  }

  @override
  bool shouldRelayout(_ShellAreaTopBarLayout oldDelegate) {
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

