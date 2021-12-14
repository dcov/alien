import 'package:bitsdojo_window/bitsdojo_window.dart';
import 'package:flutter/material.dart';
import 'package:muex_flutter/muex_flutter.dart';

import 'core/app.dart';
import 'core/completion.dart';
import 'core/subreddit.dart';
import 'core/thing_store.dart';
import 'widgets/clickable.dart';
import 'widgets/color_swatch.dart';
import 'widgets/icons.dart';
import 'widgets/page_stack.dart';

class AppScreen extends StatefulWidget {

  AppScreen({
    Key? key,
    required this.app,
    required this.pageStackController,
  }) : super(key: key);

  final App app;

  final PageStackController pageStackController;

  @override
  _AppScreenState createState() => _AppScreenState();
}

class _AppScreenState extends State<AppScreen> with TickerProviderStateMixin {

  late AnimationController _revealController;
  late List<PageStackEntry> _pageStack;

  AnimationController _createRevealController() {
    return AnimationController(
      duration: const Duration(milliseconds: 200),
      value: 1.0,
      vsync: this,
    );
  }

  void _handleMenuButtonClick() {
    switch (_revealController.status) {
      case AnimationStatus.forward:
      case AnimationStatus.completed:
        _revealController.reverse();
        break;
      case AnimationStatus.reverse:
      case AnimationStatus.dismissed:
        _revealController.forward();
        break;
    }
  }

  void _handlePageStackChange() {
    setState(() {
      _pageStack = widget.pageStackController.stack;
      switch (_revealController.status) {
        case AnimationStatus.dismissed:
          if (_pageStack.isEmpty) {
            _revealController.forward();
          }
          break;
        case AnimationStatus.completed:
          if (_pageStack.isNotEmpty) {
            _revealController.reverse();
          }
          break;
        default:
          break;
      }
    });
  }

  @override
  void initState() {
    super.initState();
    _revealController = _createRevealController();
    _pageStack = widget.pageStackController.stack;
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
  void reassemble() {
    _revealController.dispose();
    super.reassemble();
    _revealController = _createRevealController();
  }

  @override
  void dispose() {
    _revealController.dispose();
    widget.pageStackController.removeListener(_handlePageStackChange);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(children: <Widget>[
      ValueListenableBuilder(
        valueListenable: _revealController,
        builder: (BuildContext context, double value, Widget? child) {
          // We return a RawGestureDetector instead of the typical GestureDetector because we don't
          // actually want to receive input events, and instead only want to block the elements
          // behind us from receiving them by toggling the [HitTestBehavior].
          return RawGestureDetector(
            behavior: value != 0.0 ? HitTestBehavior.opaque : HitTestBehavior.translucent,
            child: DecoratedBox(
              decoration: BoxDecoration(
                color: Colors.black54.withOpacity(value),
              ),
              child: const SizedBox.expand(),
            ),
          );
        },
      ),
      LayoutBuilder(builder: (BuildContext context, BoxConstraints constraints) {
        const appBarWidth = 400.0;
        const appBarRadius = 16.0;
        final appBarRect = Rect.fromLTWH(
          (constraints.maxWidth - appBarWidth) / 2,
          16.0,
          appBarWidth,
          40.0,
        );
        return ClipRRect(
          clipper: _OvalRevealClipper(
            beginRect: appBarRect,
            beginRadius: appBarRadius,
            animation: _revealController,
          ),
          child: Stack(children: <Widget>[
            _AppBody(
              app: widget.app,
              pageStack: _pageStack,
            ),
            _AppBar(
              rect: appBarRect,
              radius: appBarRadius,
              menuButtonAnimation: _pageStack.isNotEmpty ? _revealController : null,
              onMenuClick: _handleMenuButtonClick,
            ),
          ]),
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
      child: SizedBox.expand(child: DecoratedBox(
        decoration: ShapeDecoration(
          color: Colors.black38,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(radius),
          ),
        ),
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
                  progress: menuButtonAnimation ?? kAlwaysDismissedAnimation,
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
      )),
    );
  }
}

class _AppBody extends StatelessWidget {

  _AppBody({
    Key? key,
    required this.app,
    required this.pageStack,
  }) : super(key: key);

  final App app;

  final List<PageStackEntry> pageStack;

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
    return DecoratedBox(
      decoration: BoxDecoration(color: swatch.mainSurface),
      child: Padding(
        padding: EdgeInsets.only(top: 72.0),
        child: Connector(builder: (BuildContext context) {
          final subreddits = _collectSubreddits();
          return CustomScrollView(slivers: <Widget>[
            SliverList(delegate: SliverChildListDelegate(
              pageStack.map((PageStackEntry page) {
                return ListTile();
              }).toList(),
            )),
            SliverToBoxAdapter(child: Divider(color: swatch.altSurface)),
            SliverList(delegate: SliverChildBuilderDelegate(
              (BuildContext context, int index) => _SubredditTile(subreddit: subreddits[index]),
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
  }) : super(key: key);

  final Subreddit subreddit;

  @override
  Widget build(BuildContext context) {
    return Material(child: ListTile(
      tileColor: AlienColorSwatch.of(context).mainSurface,
      leading: const Icon(AlienIcons.subreddit),
      title: Text(subreddit.name),
    ));
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
