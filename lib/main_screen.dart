import 'package:bitsdojo_window/bitsdojo_window.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:muex_flutter/muex_flutter.dart';

import 'core/app.dart';
import 'core/feed.dart';
import 'widgets/clickable.dart';
import 'widgets/column_tile.dart';
import 'widgets/drawer_layout.dart';
import 'widgets/icons.dart';
import 'widgets/page_router.dart';

import 'feed_page.dart';
import 'new_tab_dialog.dart';
import 'post_page.dart';
import 'subreddit_page.dart';

class MainScreen extends StatefulWidget {

  MainScreen({
    Key? key,
    required this.app,
  }) : super(key: key);

  final App app;

  @override
  _MainScreenState createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> with ConnectionCaptureStateMixin {

  late List<List<PageEntry>> _tabs;
  late List<PageEntry> _currentTab;

  late final NewTabDialog _newTabDialog;

  final _drawerLayoutKey = GlobalKey<DrawerLayoutState>();

  @override
  void initState() {
    super.initState();
    _newTabDialog = NewTabDialog(onNewTab: _handleNewTab);
  }

  @override
  void capture(StateSetter setState) {
    if (_newTabDialog.reset(widget.app, context)) {
      _tabs = <List<PageEntry>>[
        <PageEntry>[
          FeedPage(kind: FeedKind.popular)
        ]
      ];
      _currentTab = _tabs.first;
    }
  }

  void _handleTabSelected(int index) {
    assert(index >= 0 && index < _tabs.length);
    if (!identical(_tabs[index], _currentTab)) {
      setState(() {
        _currentTab = _tabs[index];
        _drawerLayoutKey.currentState!.toggleDrawer();
      });
    }
  }

  void _handleNewTab(PageEntry rootPage) {
    setState(() {
      _tabs.add(<PageEntry>[rootPage]);
      _currentTab = _tabs.last;
      _drawerLayoutKey.currentState!.toggleDrawer();
    });
  }

  void _handlePushPage(PageEntry page) {
    setState(() {
      _currentTab.add(page);
    });
  }

  void _handlePopPage(PageEntry page) {
    setState(() {
      assert(page == _currentTab.last);
      _currentTab.remove(page);
    });
  }

  @override
  Widget performBuild(BuildContext context) {
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
        drawer: _TabsDrawer(
          onTabSelected: _handleTabSelected,
          newTabDialog: _newTabDialog,
          tabs: _tabs,
        ),
        body: PageRouter(
          onPushPage: _handlePushPage,
          onPopPage: _handlePopPage,
          pages: _currentTab,
        ),
      )),
    ]);
  }
}

class _TabsDrawer extends StatelessWidget {

  _TabsDrawer({
    Key? key,
    required this.onTabSelected,
    required this.newTabDialog,
    required this.tabs,
  }) : super(key: key);

  final ValueChanged<int> onTabSelected;

  final NewTabDialog newTabDialog;

  final List<List<PageEntry>> tabs;

  @override
  Widget build(BuildContext context) {
    return Material(
      child: SizedBox(
        width: 200,
        child: ListView.builder(
          itemCount: tabs.length + 1,
          itemBuilder: (_, int i) {
            if (i == tabs.length) {
              return Clickable(
                onClick: () {
                  newTabDialog.show(context);
                },
                child: _IconTextTile(
                  icon: Icons.add,
                  title: 'New tab',
                ),
              );
            }
            
            final tab = tabs[i];
            return Clickable(
              onClick: () {
                onTabSelected(i);
              },
              child: ColumnTile(
                child: _PageTile(page: tab.first),
                children: tab.getRange(1, tab.length).map((PageEntry page) {
                  return _PageTile(page: page);
                }).toList(),
              ),
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
        page.feed.kind.icon,
        page.feed.kind.displayName,
      );
    } else if (page is PostPage) {
      return _PageTile._(
        key,
        Icons.comment,
        page.post.title,
      );
    } else if (page is SubredditPage) {
      return _PageTile._(
        key,
        CustomIcons.subreddit,
        page.subreddit.name,
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
          Icon(
            icon,
            color: Colors.grey,
          ),
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
