import 'dart:async';

import 'package:flutter/material.dart';

class CustomScaffoldConfiguration extends InheritedWidget {

  CustomScaffoldConfiguration({
    Key key,
    @required this.barHeight,
    @required this.barElevation,
    @required this.bottomLeading,
  }) : super(key: key);

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

  Widget buildTopContent(BuildContext context);

  Widget buildTopActions(BuildContext context);

  Widget buildBody(BuildContext context);

  Widget buildBottomActions(BuildContext context);
}

class CustomScaffold extends StatefulWidget {

  CustomScaffold({ Key key }) : super(key: key);

  @override
  CustomScaffoldState createState() => CustomScaffoldState();
}

enum _Transition {
  pushPop,
  replace
}

class CustomScaffoldState extends State<CustomScaffold>
    with SingleTickerProviderStateMixin {

  final List<ScaffoldEntry> _entries = <ScaffoldEntry>[];
  AnimationController _controller;
  _Transition _transition;

  void _resetController({ double value: 0.0 }) {
    _controller?.dispose();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 300),
      value: value,
      vsync: this
    );
  }

  Future<void> push(ScaffoldEntry entry) {
    assert(!_controller.isAnimating);
    setState(() {
      _transition = _Transition.pushPop;
      _entries.add(entry);
      _resetController();
    });
    return _controller.forward(from: 0.0);
  }

  Future<void> pop() {
    assert(!_controller.isAnimating);
    setState(() {
      _transition = _Transition.pushPop;
      _resetController();
    });
    return _controller.reverse(from: 1.0).then((_) {
      setState(() {
        // Reset the controller to value 1.0 to enable the drag-to-pop gesture.
        _resetController(value: 1.0);
        _entries.removeLast();
      });
    });
  }

  Future<void> replace(List<ScaffoldEntry> entries, { int begin: 0 }) {
    assert(!_controller.isAnimating);
    assert(entries.isNotEmpty);
    setState(() {
      _transition = _Transition.replace;
      _entries.add(entries.last);
      _resetController();
    });
    return _controller.forward(from: 0.0).then((_) {
      setState(() {
        _entries.replaceRange(begin, _entries.length, entries);
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
    final ScaffoldEntry last = _entries.last;
    final ScaffoldEntry secondToLast = _entries.length > 2 ? _entries[_entries.length - 2] : null;
    final ScaffoldEntry thirdTolast = _entries.length > 3 ? _entries[_entries.length - 3] : null;

    return Stack(
      children: <Widget>[
        Column(
          children: <Widget>[
            _TopBar(
              controller: _controller,
              transition: _transition,
              height: config.barHeight,
              elevation: config.barElevation,
              first: last,
              second: secondToLast,
              third: thirdTolast,
            ),
            _Body(
              controller: _controller,
              transition: _transition,
              top: last,
              bottom: secondToLast,
            ),
            _BottomBar(
              controller: _controller,
              transition: _transition,
              height: config.barHeight,
              elevation: config.barElevation,
              top: last,
              bottom: secondToLast,
            )
          ],
        ),

      ]
    );
  }
}

class _TopBar extends StatelessWidget {

  _TopBar({
    Key key,
    this.controller,
    this.transition,
    this.height,
    this.elevation,
    this.first,
    this.second,
    this.third
  }) : super(key: key);

  final AnimationController controller;
  final _Transition transition;
  final double height;
  final double elevation;
  final ScaffoldEntry first;
  final ScaffoldEntry second;
  final ScaffoldEntry third;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: height,
      child: Material(
        elevation: elevation,
        child: CustomMultiChildLayout(
          delegate: _TopBarTransition(controller),
          children: <Widget>[
            if (third != null)
              LayoutId(
                id: _TopBarSlot.thirdTitle,
                child: _AnimatedTitle(
                  animation: const AlwaysStoppedAnimation(0.0),
                  title: third.title,
                )
              ),
            if (second != null)
              ...<Widget>[
                LayoutId(
                  id: _TopBarSlot.secondTitle,
                  child: _AnimatedTitle(
                    animation: ReverseAnimation(controller),
                    title: second.title,
                  ),
                ),
                LayoutId(
                  id: _TopBarSlot.secondActions,
                  child: FadeTransition(
                    opacity: ReverseAnimation(controller),
                    child: second.buildTopActions(context),
                  )
                ),
              ],
            LayoutId(
              id: _TopBarSlot.firstTitle,
              child: _AnimatedTitle(
                animation: controller,
                title: first.title,
              ),
            ),
            LayoutId(
              id: _TopBarSlot.firstActions,
              child: FadeTransition(
                opacity: controller,
                child: first.buildTopActions(context),
              )
            ),
            if (second != null)
              LayoutId(
                id: _TopBarSlot.leading,
                child: Icon(Icons.arrow_back_ios),
              )
          ],
        ),
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
  firstTitle,
  firstActions,
  secondTitle,
  secondActions,
  thirdTitle,
}

class _TopBarTransition extends MultiChildLayoutDelegate {

  _TopBarTransition(this.animation) : super(relayout: animation);

  final Animation<double> animation;

  @override
  void performLayout(Size size) {
    assert(hasChild(_TopBarSlot.firstTitle));
    assert(hasChild(_TopBarSlot.firstActions));

    final Size maxChildSize = Size((size.width / 3), size.height);
    if (hasChild(_TopBarSlot.leading)) {
      final Size leadingSize = layoutChild(
          _TopBarSlot.leading,
          BoxConstraints.loose(maxChildSize));
      
      final Size secondTitleSize = layoutChild(
        _TopBarSlot.secondTitle,
        BoxConstraints.loose(maxChildSize)
      );
    }
  }

  @override
  bool shouldRelayout(_TopBarTransition oldDelegate) {
    return oldDelegate.animation != this.animation;
  }
}

class _Body extends StatelessWidget {

  _Body({
    Key key,
    this.controller,
    this.transition,
    this.top,
    this.bottom,
  }) : super(key: key);

  final AnimationController controller;
  final _Transition transition;
  final ScaffoldEntry top;
  final ScaffoldEntry bottom;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: <Widget>[
        if (bottom != null)
          ValueListenableBuilder(
            valueListenable: controller,
            builder: (BuildContext context, double value, Widget child) {
              Widget result = Opacity(
                opacity: 1.0 - value,
                child: child,
              );

              if (transition == _Transition.pushPop) {
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
            child: bottom.buildBody(context),
          ),
        ValueListenableBuilder(
          valueListenable: controller,
          builder: (BuildContext context, double value, Widget child) {
            Widget result = Opacity(
              opacity: value,
              child: child,
            );

            if (transition == _Transition.pushPop) {
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
          child: top.buildBody(context),
        ),
      ],
    );
  }
}

class _BottomBar extends StatelessWidget {

  _BottomBar({
    Key key,
    this.controller,
    this.transition,
    this.height,
    this.elevation,
    this.leading,
    this.top,
    this.bottom
  }) : super(key: key);

  final AnimationController controller;
  final _Transition transition;
  final double height;
  final double elevation;
  final Widget leading;
  final ScaffoldEntry top;
  final ScaffoldEntry bottom;
  
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: height,
      child: Material(
        elevation: elevation,
        child: CustomMultiChildLayout(
          delegate: _BottomBarTransition(controller),
          children: <Widget>[
            if (bottom != null)
              LayoutId(
                id: _BottomBarSlot.bottom,
                child: bottom.buildBottomActions(context)
              ),
            LayoutId(
              id: _BottomBarSlot.top,
              child: top.buildBottomActions(context)
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
  bottom,
  top,
}

class _BottomBarTransition extends MultiChildLayoutDelegate {

  _BottomBarTransition(this.animation)
    : super(relayout: animation);

  final Animation<double> animation;

  @override
  void performLayout(Size size) {
    assert(hasChild(_BottomBarSlot.leading));
    assert(hasChild(_BottomBarSlot.top));
    final Size leadingSize = layoutChild(_BottomBarSlot.leading, BoxConstraints.loose(size));
    positionChild(_BottomBarSlot.leading, Offset.zero);

    final double progress = animation.value;

    final Size topSize = layoutChild(
      _BottomBarSlot.top,
      BoxConstraints.loose(Size(
        size.width - leadingSize.width,
        size.height,
      )));
    positionChild(
      _BottomBarSlot.top,
      Offset(
        (-topSize.width * progress)
          + ((size.width - topSize.width) * (1.0 - progress)),
        0.0
      ));
    
    if (hasChild(_BottomBarSlot.bottom)) {
      final Size bottomSize = layoutChild(
        _BottomBarSlot.bottom,
        BoxConstraints.loose(Size(
          size.width - leadingSize.width,
          size.height
        )));
      positionChild(
        _BottomBarSlot.bottom,
        Offset(
          (-bottomSize.width * (1.0 - progress))
            + ((size.width - bottomSize.width) * progress),
          0.0
        ));
    }
  }

  @override
  bool shouldRelayout(_BottomBarTransition oldDelegate) {
    return oldDelegate.animation != this.animation;
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
  void addListener(listener) {
    super.addListener(listener);
    _controller.addStatusListener(_handleStatusChange);
  }

  @override
  void removeListener(listener) {
    super.removeListener(listener);
    _controller.removeStatusListener(_handleStatusChange);
  }
}
