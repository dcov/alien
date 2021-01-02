import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:mal_flutter/mal_flutter.dart';

import '../models/app.dart';
import '../models/feed.dart';
import '../models/subreddit.dart';
import '../widgets/draggable_page_route.dart';
import '../widgets/pressable.dart';
import '../widgets/routing.dart';

import 'accounts_bottom_sheet.dart';
import 'feed_page.dart';
import 'settings_page.dart';
import 'subreddit_page.dart';

class _AccountHeader extends StatelessWidget {

  _AccountHeader({
    Key key,
    @required this.app
  }) : assert(app != null),
       super(key: key);

  final App app;

  @override
  Widget build(_) {
    return Connector(
      builder: (BuildContext context) {
        return Pressable(
          onPress: () => showAccountsBottomSheet(
            context: context,
            accounts: app.accounts),
          child: Padding(
            padding: EdgeInsets.all(12.0),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                Text(
                  app.accounts.currentUser?.name ?? 'Sign in',
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: 14.0,
                    fontWeight: FontWeight.w500)),
                Icon(
                  Icons.arrow_drop_down,
                  color: Colors.black)
              ])));
      });
  }
}

class _SublistHeader extends StatelessWidget {

  _SublistHeader({
    Key key,
    @required this.name
  }) : super(key: key);

  final String name;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(color: Colors.grey.shade200),
      child: Padding(
        padding: const EdgeInsets.symmetric(
          vertical: 12.0,
          horizontal: 16.0),
        child: Text(
          name,
          style: TextStyle(
            color: Colors.grey.shade700,
            letterSpacing: 1.0,
            fontSize: 10.0,
            fontWeight: FontWeight.w700))));
  }
}

class _AppBody extends StatefulWidget {

  _AppBody({
    Key key,
    @required this.app,
  }) : super(key: key);

  final App app;

  @override
  _AppBodyState createState() => _AppBodyState();
}

class _AppBodyState extends State<_AppBody> {

  final _entries = Map<String, List<RoutingEntry>>();

  void _updateEntries() {
    // Clear the entries map
    _entries.clear();

    String parentName;
    List<RoutingEntry> childEntries;
    for (final entry in context.routingEntries) {
      if (entry.depth == 0) {
        assert(entry.page.name == AppPage.pageName);
        continue;
      }

      if (entry.depth == 1) {
        parentName = entry.page.name;
        childEntries = List<RoutingEntry>();
        _entries[parentName] = childEntries;
      } else {
        childEntries ??= List<RoutingEntry>();
        childEntries.add(entry);
      }
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _updateEntries();
  }

  Widget _mapEntryToTile(RoutingEntry entry) {
    // TODO: implement
    return const SizedBox();
  }

  @override
  Widget build(BuildContext context) {
    return Connector(
      builder: (BuildContext context) {
        final app = widget.app;
        final children = List<Widget>();
        void mapValues<T>(List<T> values, Widget mapToWidget(T value), String mapToPageName(T value)) {
          for (final value in values) {
            children.add(mapToWidget(value));
            final pageName = Routing.joinPageNames([AppPage.pageName, mapToPageName(value)]);
            final childEntries = _entries[pageName];
            if (childEntries != null) {
              for (final entry in childEntries) {
                children.add(_mapEntryToTile(entry));
              }
            }
          }
        }

        children.add(_SublistHeader(name: 'FEEDS'));
        mapValues(
          app.feeds,
          (Feed feed) => FeedTile(feed: feed),
          feedPageNameFrom);

        if (app.defaults != null) {
          assert(app.subscriptions == null);
          children.add(_SublistHeader(name: 'DEFAULTS'));
          mapValues(
            app.defaults.items,
            (Subreddit subreddit) => SubredditTile(subreddit: subreddit),
            subredditPageNameFrom);
        } else {
          assert(app.subscriptions != null);
          children.add(_SublistHeader(name: 'SUBSCRIPTIONS'));
          mapValues(
            app.subscriptions.items,
            (Subreddit subreddit) => SubredditTile(subreddit: subreddit),
            subredditPageNameFrom);
        }

        return SliverList(delegate: SliverChildListDelegate(children));
      });
  }
}

class _AppPageView extends StatelessWidget {

  _AppPageView({
    Key key,
    @required this.app
  }) : super(key: key);

  final App app;

  @override
  Widget build(BuildContext context) {
    return CustomScrollView(
      slivers: <Widget>[
        SliverAppBar(
          toolbarHeight: 48.0,
          elevation: 1.0,
          pinned: true,
          backgroundColor: Theme.of(context).canvasColor,
          centerTitle: true,
          title: _AccountHeader(app: app),
          actions: <Widget>[
            PressableIcon(
              onPress: () => showSettingsPage(context: context),
              icon: Icons.settings,
              iconColor: Colors.black,
              padding: EdgeInsets.symmetric(horizontal: 16.0))
          ]),
        _AppBody(app: app),
      ]);
  }
}

class AppPage extends EntryPage {

  AppPage({
    @required this.app,
    @required String name
  }) : super(name: name);

  final App app;

  static const pageName = 'app';

  @override
  Route createRoute(_) {
    return DraggablePageRoute(
      settings: this,
      builder: (BuildContext context) {
        return _AppPageView(app: app);
      });
  }
}
