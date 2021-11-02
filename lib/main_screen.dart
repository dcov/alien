import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import 'core/feed.dart';
import 'widgets/change_notifier_controller.dart';
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
    return DrawerLayout(
      drawer: SizedBox(
        width: 250,
        child: _StacksDrawer(
          stacks: _stacks,
          stackChangedNotifier: _stackNotifier,
        )
      ),
      body: PageRouter(
        stack: _currentStack,
        stackNotifier: _stackNotifier,
      ),
    );
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
      color: Colors.grey.shade800,
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
      children: stack.map((entry) => _PageEntryTile(entry: entry)).toList(),
    );
  }
}

class _PageEntryTile extends StatelessWidget {

  _PageEntryTile({
    Key? key,
    required this.entry,
  }) : super(key: key);

  final PageEntry entry;

  @override
  Widget build(BuildContext context) {
    if (entry is FeedPage) {
      final feed = (entry as FeedPage).feed;
      return _DrawerTile(
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
        title: feed.kind.displayName,
      );
    } else if (entry is PostPage) {
      final post = (entry as PostPage).post;
      return _DrawerTile(
        icon: Icons.comment,
        title: post.title,
      );
    }

    throw StateError('$entry is an invalid or unimplemented type.');
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
