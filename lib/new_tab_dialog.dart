import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:muex_flutter/muex_flutter.dart';

import 'core/app.dart';
import 'core/defaults.dart';
import 'core/feed.dart';
import 'core/subscriptions.dart';
import 'core/user.dart';
import 'widgets/icons.dart';
import 'widgets/clickable.dart';
import 'widgets/page_router.dart';

import 'feed_page.dart';
import 'subreddit_page.dart';

class NewTabDialog {

  NewTabDialog({ required this.onNewTab });

  final ValueChanged<PageEntry> onNewTab;

  late List<FeedKind> _feeds;
  late Defaults? _defaults;
  late Subscriptions? _subscriptions;

  User? _currentUser;
  bool _initialized = false;

  bool reset(App app, BuildContext context) {
    if (app.accounts.currentUser != _currentUser || !_initialized) {
      _currentUser = app.accounts.currentUser;
      _initialized = true;
      if (_currentUser != null) {
        _feeds = const <FeedKind>[ FeedKind.home, FeedKind.popular, FeedKind.all ];
        _defaults = null;
        _subscriptions = Subscriptions();

        SchedulerBinding.instance!.addPostFrameCallback((_) {
          context.then(Then.all({
            RefreshSubscriptions(subscriptions: _subscriptions!),
          }));
        });
      } else {
        _feeds = const <FeedKind>[ FeedKind.popular, FeedKind.all ];
        _defaults = Defaults();
        _subscriptions = null;

        SchedulerBinding.instance!.addPostFrameCallback((_) {
          context.then(Then.all({
            RefreshDefaults(defaults: _defaults!),
          }));
        });
      }

      return true;
    }

    return false;
  }

  void show(BuildContext context) async {
    final result = await showDialog<PageEntry>(
      context: context,
      useRootNavigator: true,
      builder: (BuildContext context) {

        void pop(PageEntry page) {
          Navigator
            .of(context, rootNavigator: true)
            .pop(page);
        }

        return Padding(
          padding: EdgeInsets.all(48.0),
          child: Material(child: Column(
            verticalDirection: VerticalDirection.up,
            children: <Widget>[
              Expanded(child: CustomScrollView(slivers: <Widget>[
                _HeaderSliver(text: 'FEEDS'),
                SliverList(delegate: SliverChildBuilderDelegate(
                  (BuildContext _, int index) {
                    final kind = _feeds[index];
                    return _Tile(
                      onClick: () => pop(FeedPage(kind: kind)),
                      icon: kind.icon,
                      title: kind.displayName,
                    );
                  },
                  childCount: _feeds.length,
                )),
                if (_defaults != null) ...[
                  _HeaderSliver(text: 'SUBSCRIPTIONS'),
                  SliverList(delegate: SliverChildBuilderDelegate(
                    (BuildContext _, int index) {
                      final subreddit = _defaults!.things[index];
                      return _Tile(
                        onClick: () => pop(SubredditPage(subreddit: subreddit)),
                        icon: CustomIcons.subreddit,
                        iconColor: Colors.grey,
                        title: subreddit.name,
                      );
                    },
                    childCount: _defaults!.things.length,
                  )),
                ],
              ])),
              DecoratedBox(
                decoration: BoxDecoration(border: Border(
                  bottom: BorderSide(
                    width: 0.1,
                    color: Colors.grey,
                  ),
                )),
                child: SizedBox(
                  height: 56.0,
                  child: NavigationToolbar(
                    centerMiddle: false,
                    leading: Clickable(
                      onClick: () => Navigator.of(context, rootNavigator: true).pop(null),
                      child: Padding(
                        padding: EdgeInsets.all(16.0),
                        child: Icon(Icons.close),
                      ),
                    ),
                    middle: Text('New tab'),
                  ),
                ),
              ),
            ]),
          ),
        );
      },
    );

    if (result != null) {
      onNewTab(result);
    }
  }
}

class _HeaderSliver extends StatelessWidget {

  _HeaderSliver({
    Key? key,
    required this.text,
  }) : super(key: key);

  final String text;

  @override
  Widget build(BuildContext context) {
    return SliverToBoxAdapter(child: Padding(
      padding: const EdgeInsets.symmetric(vertical: 12.0, horizontal: 16.0),
      child: Text(
        text,
        style: const TextStyle(
          fontSize: 12.0,
          fontWeight: FontWeight.w600,
          color: Colors.grey,
        ),
      ),
    ));
  }
}

class _Tile extends StatelessWidget {

  _Tile({
    Key? key,
    required this.onClick,
    required this.icon,
    this.iconColor,
    required this.title,
  }) : super(key: key);

  final VoidCallback onClick;

  final IconData icon;

  final Color? iconColor;

  final String title;

  @override
  Widget build(BuildContext context) {
    return Clickable(
      onClick: onClick,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12.0, horizontal: 16.0),
        child: Row(children: <Widget>[
          Icon(
            icon,
            color: iconColor
          ),
          Padding(
            padding: EdgeInsets.only(left: 16.0),
            child: Text(title),
          ),
        ]),
      ),
    );
  }
}
