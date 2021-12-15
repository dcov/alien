import 'package:bitsdojo_window/bitsdojo_window.dart';
import 'package:flutter/material.dart';
import 'package:muex_flutter/muex_flutter.dart';

import 'core/app.dart';
import 'core/completion.dart';
import 'core/subreddit.dart';
import 'core/thing_store.dart';
import 'widgets/clickable.dart';
import 'widgets/color_swatch.dart';
import 'widgets/constants.dart';
import 'widgets/icons.dart';
import 'widgets/page_stack.dart';

class AppScreen extends StatefulWidget {

  AppScreen({
    Key? key,
    required this.app,
    required this.pageStackController,
    required this.revealController,
  }) : super(key: key);

  final App app;

  final PageStackController pageStackController;

  final AnimationController revealController;

  static AnimationController createRevealController(TickerProvider vsync, [double? value]) {
    return AnimationController(
      duration: const Duration(milliseconds: 200),
      value: value ?? 1.0,
      vsync: vsync,
    );
  }

  @override
  _AppScreenState createState() => _AppScreenState();
}

class _AppScreenState extends State<AppScreen> {

  void _handleMenuButtonClick() {
    switch (widget.revealController.status) {
      case AnimationStatus.forward:
      case AnimationStatus.completed:
        widget.revealController.reverse();
        break;
      case AnimationStatus.reverse:
      case AnimationStatus.dismissed:
        widget.revealController.forward();
        break;
    }
  }

  void _handlePageStackChange() {
    switch (widget.revealController.status) {
      case AnimationStatus.dismissed:
        if (widget.pageStackController.stack.isEmpty) {
          widget.revealController.forward();
          setState(() { });
        }
        break;
      case AnimationStatus.completed:
        if (widget.pageStackController.stack.isNotEmpty) {
          widget.revealController.reverse();
          setState(() { });
        }
        break;
      default:
        break;
    }
  }

  @override
  void initState() {
    super.initState();
    widget.pageStackController.addListener(_handlePageStackChange);
  }

  @override
  void didUpdateWidget(AppScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.pageStackController != oldWidget.pageStackController) {
      oldWidget.pageStackController.removeListener(_handlePageStackChange);
      widget.pageStackController.addListener(_handlePageStackChange);
    }
  }

  @override
  void dispose() {
    widget.pageStackController.removeListener(_handlePageStackChange);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final swatch = AlienColorSwatch.of(context);
    return Stack(children: <Widget>[
      IgnorePointer(child: ValueListenableBuilder(
        valueListenable: widget.revealController,
        builder: (BuildContext context, double value, Widget? child) {
          return DecoratedBox(
            decoration: BoxDecoration(
              color: Colors.black54.withOpacity(value),
            ),
            child: const SizedBox.expand(),
          );
        },
      )),
      LayoutBuilder(builder: (BuildContext context, BoxConstraints constraints) {
        const appBarWidth = 400.0;
        const appBarRadius = 16.0;
        final appBarRect = Rect.fromLTWH(
          (constraints.maxWidth - appBarWidth) / 2,
          kAppBarVerticalPadding,
          appBarWidth,
          kAppBarHeight,
        );
        return ClipRRect(
          clipper: _OvalRevealClipper(
            beginRect: appBarRect,
            beginRadius: appBarRadius,
            animation: widget.revealController,
          ),
          child: DecoratedBox(
            decoration: BoxDecoration(color: swatch.surface),
            child: Stack(children: <Widget>[
              ValueListenableBuilder(
                valueListenable: widget.revealController,
                builder: (BuildContext context, double value, Widget? child) {
                  return IgnorePointer(
                    ignoring: value != 1.0,
                    child: child,
                  );
                },
                child: _AppBody(
                  app: widget.app,
                  pageStackController: widget.pageStackController,
                ),
              ),
              _AppBar(
                rect: appBarRect,
                radius: appBarRadius,
                menuButtonAnimation: widget.pageStackController.stack.isNotEmpty ? widget.revealController : null,
                onMenuClick: _handleMenuButtonClick,
              ),
            ]),
          ),
        );
      }),
    ]);
  }
}

class _AppBar extends StatelessWidget {

  _AppBar({
    Key? key,
    required this.rect,
    required this.radius,
    required this.onMenuClick,
    this.menuButtonAnimation,
  }) : super(key: key);

  final Rect rect;

  final double radius;

  final VoidCallback onMenuClick;

  final Animation<double>? menuButtonAnimation;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Positioned.fromRect(
      rect: rect,
      child: SizedBox.expand(child: ClipRRect(
        borderRadius: BorderRadius.circular(radius),
        child: DecoratedBox(
          decoration: BoxDecoration(color: Colors.black38),
          child: Row(children: <Widget>[
            Clickable(
              onClick: menuButtonAnimation != null ? onMenuClick : null,
              child: DecoratedBox(
                decoration: BoxDecoration(
                  border: Border(right: BorderSide(
                    width: 0.1,
                    color: Colors.grey,
                  )),
                ),
                child: SizedBox.square(
                  dimension: rect.height,
                  child: Center(child: AnimatedIcon(
                    icon: AnimatedIcons.menu_close,
                    progress: menuButtonAnimation ?? kAlwaysCompleteAnimation,
                    color: menuButtonAnimation != null ? theme.iconTheme.color : theme.disabledColor,
                  )),
                ),
              ),
            ),
            Expanded(child: TextField(
              decoration: null,
              onChanged: (String value) {
              },
            )),
          ]),
        ),
      )),
    );
  }
}

class _AppBody extends StatelessWidget {

  _AppBody({
    Key? key,
    required this.app,
    required this.pageStackController,
  }) : super(key: key);

  final App app;

  final PageStackController pageStackController;

  List<Subreddit> _collectSubreddits() {
    final allIds = <String>{
      ...app.defaults.ids,
      ...app.subscriptions.subscribers.keys,
    };
    final subreddits = allIds.map((id) => app.store.idToSubreddit(id)).toList();
    subreddits.sort((s1, s2) => s1.name.toLowerCase().compareTo(s2.name.toLowerCase()));
    return subreddits;
  }

  @override
  Widget build(BuildContext context) {
    final swatch = AlienColorSwatch.of(context);
    final pageStack = pageStackController.stack;
    return Padding(
      padding: EdgeInsets.only(top: 72.0),
      child: DecoratedBox(
        decoration: BoxDecoration(
          border: Border(top: BorderSide(
            width: 0.1,
            color: swatch.divider,
          )),
        ),
        child: Connector(builder: (BuildContext context) {
          final subreddits = _collectSubreddits();
          return CustomScrollView(slivers: <Widget>[
            SliverList(delegate: SliverChildListDelegate(
              pageStack.map((PageStackEntry page) {
                return ListTile();
              }).toList(),
            )),
            SliverList(delegate: SliverChildBuilderDelegate(
              (BuildContext context, int index) => _SubredditTile(
                subreddit: subreddits[index],
                pageStackController: pageStackController,
              ),
              childCount: subreddits.length,
            )),
          ]);
        }),
      ),
    );
  }
}

class _SubredditTile extends StatelessWidget {

  _SubredditTile({
    Key? key,
    required this.subreddit,
    required this.pageStackController,
  }) : super(key: key);

  final Subreddit subreddit;

  final PageStackController pageStackController;

  @override
  Widget build(BuildContext context) {
    final swatch = AlienColorSwatch.of(context);
    return Clickable(
      onClick: () {
        pageStackController.push(context, subreddit);
      },
      child: SizedBox(
        height: 48.0,
        child: Row(children: <Widget>[
          const Padding(
            padding: EdgeInsets.symmetric(
              horizontal: 16.0,
            ),
            child: Icon(
              AlienIcons.subreddit,
              size: 24.0,
            ),
          ),
          Expanded(child: Text(
            subreddit.name,
            style: TextStyle(
              color: swatch.text,
              fontSize: 16.0,
              fontWeight: FontWeight.w500,
            ),
          )),
        ]),
      ),
    );
  }
}

class _OvalRevealClipper extends CustomClipper<RRect> {

  _OvalRevealClipper({
    required this.beginRect,
    required this.beginRadius,
    required this.animation,
  }) : super(reclip: animation);

  final Rect beginRect;

  final double beginRadius;

  final Animation<double> animation;

  @override
  RRect getClip(Size size) {
    return RRect.fromLTRBR(
      beginRect.left * (1.0 - animation.value),
      beginRect.top * (1.0 - animation.value),
      beginRect.right + ((size.width - beginRect.right) * animation.value),
      beginRect.bottom + ((size.height - beginRect.bottom) * animation.value),
      Radius.circular(beginRadius * (1.0 - animation.value)),
    );
  }

  @override
  bool shouldReclip(_OvalRevealClipper oldClipper) {
    return this.beginRect != oldClipper.beginRect ||
           this.beginRadius != oldClipper.beginRadius ||
           this.animation != oldClipper.animation;
  }
}
