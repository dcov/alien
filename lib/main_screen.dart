import 'package:bitsdojo_window/bitsdojo_window.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import 'core/feed.dart';
import 'widgets/change_notifier_controller.dart';
import 'widgets/clickable.dart';
import 'widgets/column_tile.dart';
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
          builder: (_, __) {
            return ListView.builder(
              itemCount: stacks.length + 1,
              itemBuilder: (_, int i) {
                if (i == stacks.length) {
                  return Clickable(
                    child: _IconTextTile(
                      icon: Icons.add,
                      title: 'New tab',
                    ),
                  );
                }
                
                final stack = stacks[i];
                return Clickable(
                  onClick: () { },
                  child: ColumnTile(
                    child: _PageTile(page: stack.first),
                    children: stack.getRange(1, stack.length).map((PageEntry page) {
                      return _PageTile(page: page);
                    }).toList(),
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }
}

class _PageTile extends StatelessWidget {

  factory _PageTile({
    Key? key,
    required PageEntry page,
  }) {
    if (page is FeedPage) {
      return _PageTile._(
        key,
        () {
          switch (page.feed.kind) {
            case FeedKind.home:
              return Icons.home;
            case FeedKind.popular:
              return Icons.trending_up;
            case FeedKind.all:
              return Icons.all_inclusive;
          }
        }(),
        page.feed.kind.displayName,
      );
    }

    if (page is PostPage) {
      return _PageTile._(
        key,
        Icons.comment,
        page.post.title,
      );
    }

    throw UnimplementedError('_PageTile for ${page.runtimeType} has not been implemented yet.');
  }

  _PageTile._(Key? key, this.icon, this.title) : super(key: key);
  
  final IconData icon;

  final String title;

  @override
  Widget build(BuildContext context) {
    return _IconTextTile(
      icon: icon,
      title: title,
    );
  }
}

class _IconTextTile extends StatelessWidget {

  _IconTextTile({
    Key? key,
    required this.icon,
    required this.title,
  }) : super(key: key);

  final IconData icon;

  final String title;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(
        vertical: 12.0,
        horizontal: 16.0,
      ),
      child: Row(
        children: <Widget>[
          Icon(icon),
          Expanded(child: Padding(
            padding: EdgeInsets.only(left: 16.0),
            child: Text(
              title,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          )),
        ]
      ),
    );
  }
}
