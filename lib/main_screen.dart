import 'package:bitsdojo_window/bitsdojo_window.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import 'core/feed.dart';
import 'widgets/change_notifier_controller.dart';
import 'widgets/clickable.dart';
import 'widgets/tile.dart';
import 'widgets/drawer_layout.dart';
import 'widgets/page_router.dart';

import 'feed_page.dart';
import 'post_page.dart';

class MainScreen extends StatefulWidget {

  MainScreen({
    Key? key,
  }) : super(key: key);

  @override
  _MainScreenState createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {

  late final List<List<PageEntry>> _stacks;
  late List<PageEntry> _currentStack;
  final _stackNotifier = ChangeNotifierController();

  final _drawerLayoutKey = GlobalKey<DrawerLayoutState>();

  @override
  void initState() {
    super.initState();
    _stacks = <List<PageEntry>>[
      <PageEntry>[
        FeedPage(kind: FeedKind.popular)
      ]
    ];
    _currentStack = _stacks.first;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final windowButtonColors = WindowButtonColors(iconNormal: theme.iconTheme.color);
    return Column(children: <Widget>[
      WindowTitleBarBox(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                Clickable(
                  opaque: false,
                  onClick: () { },
                  child: ConstrainedBox(
                    constraints: BoxConstraints.tight(appWindow.titleBarButtonSize),
                    child: Icon(
                      Icons.person_rounded,
                      size: 16.0,
                    ),
                  ),
                ),
                Clickable(
                  opaque: true,
                  onClick: () => _drawerLayoutKey.currentState!.toggleDrawer(),
                  child: ConstrainedBox(
                    constraints: BoxConstraints.tight(appWindow.titleBarButtonSize),
                    child: Icon(
                      Icons.menu,
                      size: 16.0,
                    ),
                  ),
                ),
              ],
            ),
            Expanded(
              child: MoveWindow(),
            ),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                MinimizeWindowButton(colors: windowButtonColors),
                MaximizeWindowButton(colors: windowButtonColors),
                CloseWindowButton(
                  colors: WindowButtonColors(
                    mouseOver: const Color(0xFFD32F2F),
                    iconNormal: windowButtonColors.iconNormal,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
      Expanded(child: DrawerLayout(
        key: _drawerLayoutKey,
        drawer: _StacksDrawer(
          stacks: _stacks,
          stackChangedNotifier: _stackNotifier,
        ),
        body: PageRouter(
          stack: _currentStack,
          stackNotifier: _stackNotifier,
        ),
      )),
    ]);
  }
}

class _StacksDrawer extends StatelessWidget {

  _StacksDrawer({
    Key? key,
    required this.stacks,
    required this.stackChangedNotifier,
  }) : super(key: key);

  final List<List<PageEntry>> stacks;

  final ChangeNotifier stackChangedNotifier;

  @override
  Widget build(BuildContext context) {
    return Material(
      child: SizedBox(
        width: 200,
        child: AnimatedBuilder(
          animation: stackChangedNotifier,
          builder: (BuildContext _, Widget? __) {
            return ListView.builder(
              itemCount: stacks.length + 1,
              itemBuilder: (_, int i) {
                if (i == stacks.length) {
                  return _NewTabTile();
                }
                
                return _StackTile(stack: stacks[i]);
              },
            );
          },
        ),
      ),
    );
  }
}

class _StackTile extends StatelessWidget {

  _StackTile({
    Key? key,
    required this.stack,
  }) : super(key: key);

  final List<PageEntry> stack;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: stack.map((page) => _PageEntryTile(page: page)).toList(),
    );
  }
}

class _PageEntryTile extends StatelessWidget {

  _PageEntryTile({
    Key? key,
    required PageEntry page,
  }) : this.details = _PageDetails.from(page),
       super(key: key);

  final _PageDetails details;

  @override
  Widget build(BuildContext context) {
    return _DrawerTile(
      icon: details.icon,
      title: details.title,
    );
  }
}

class _NewTabTile extends StatelessWidget {

  _NewTabTile({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return _DrawerTile(
      icon: Icons.add,
      title: "New Tab",
    );
  }
}

class _DrawerTile extends StatelessWidget {

  _DrawerTile({
    Key? key,
    required this.icon,
    required this.title,
  }) : super(key: key);

  final IconData icon;

  final String title;

  @override
  Widget build(BuildContext context) {
    return CustomTile(
      icon: Icon(icon),
      title: Text(title, maxLines: 1),
    );
  }
}

class _PageDetails {

  factory _PageDetails.from(PageEntry page) {
    if (page is FeedPage) {
      final feed = page.feed;
      return _PageDetails._(
        title: feed.kind.displayName,
        icon: () {
          switch (feed.kind) {
            case FeedKind.home:
              return Icons.home;
            case FeedKind.popular:
              return Icons.trending_up;
            case FeedKind.all:
              return Icons.all_inclusive;
          }
        }(),
      );
    } else if (page is PostPage) {
      final post = page.post;
      return _PageDetails._(
        title: post.title,
        icon: Icons.comment,
      );
    }

    throw UnimplementedError();
  }

  _PageDetails._({
    required this.title,
    required this.icon,
  });

  final String title;

  final IconData icon;
}
