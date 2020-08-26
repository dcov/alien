import 'package:elmer_flutter/elmer_flutter.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../logic/subscriptions.dart';
import '../models/app.dart';
import '../models/auth.dart';
import '../models/feed.dart';
import '../models/subreddit.dart';
import '../models/subscriptions.dart';
import '../widgets/routing.dart';
import '../widgets/widget_extensions.dart';

import 'feed_page.dart';
import 'subreddit_page.dart';

class AppPage extends EntryPage {

  AppPage({
    @required this.app,
    @required String name
  }) : super(name: name);

  final App app;

  static const pageName = 'app';

  @override
  Route createRoute(_) {
    return PageRouteBuilder(
      settings: this,
      pageBuilder: (BuildContext context, Animation<double> _, Animation<double> __) {
        return _AppPageView(app: app);
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
    return Column(
      children: <Widget>[
        Material(
          child: Padding(
            padding: EdgeInsets.only(top: context.mediaPadding.top),
            child: SizedBox(
              height: 48.0,
              child: Row(
                children: <Widget>[
                  _AuthHeader(auth: app.auth),
                ])))),
        Expanded(
          child: _AppBody(app: app)),
      ]);
  }
}

class _AuthHeader extends StatelessWidget {

  _AuthHeader({
    Key key,
    @required this.auth
  }) : super(key: key);

  final Auth auth;

  @override
  Widget build(BuildContext context) {
    return Connector(
      builder: (_) {
        return Row(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Text(auth.currentUser?.name ?? 'Sign in'),
            Icon(Icons.arrow_downward)
          ]);
      });
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

        final app = widget.app;
        mapValues(
          app.feeds,
          (Feed feed) => FeedTile(feed: feed),
          FeedPage.pageNameFrom);

        if (app.defaults != null) {
          assert(app.subscriptions == null);
          children.add(_SublistHeader(name: 'Defaults'));
          mapValues(
            app.defaults.subreddits,
            (Subreddit subreddit) => SubredditTile(subreddit: subreddit),
            SubredditPage.pageNameFrom);
        } else {
          assert(app.subscriptions != null);
          children.add(_SublistHeader(name: 'Subscriptions'));
          mapValues(
            app.subscriptions.subreddits,
            (Subreddit subreddit) => SubredditTile(subreddit: subreddit),
            SubredditPage.pageNameFrom);
        }

        return ListView(children: children);
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
    return ListTile(title: Text(name));
  }
}

