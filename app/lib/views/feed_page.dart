import 'package:elmer_flutter/elmer_flutter.dart';
import 'package:flutter/material.dart';

import '../logic/feed.dart';
import '../models/feed.dart';
import '../widgets/routing.dart';

class FeedTile extends StatelessWidget {

  FeedTile({
    Key key,
    @required this.feed,
  }) : super(key: key);

  final Feed feed;

  void _pushPage(BuildContext context) {
    context.push(
      FeedPage.pageNameFrom(feed),
      (String pageName) => FeedPage(
        feed: feed,
        name: pageName));
  }

  @override
  Widget build(BuildContext context) {
    return ListTile(
      onTap: () => _pushPage(context));
  }
}

class FeedPage extends EntryPage {

  FeedPage({
    @required this.feed,
    @required String name,
  }) : super(name: name);

  final Feed feed;

  static String pageNameFrom(Feed feed) {
    return feed.name;
  }

  @override
  Route createRoute(BuildContext context) {
    return PageRouteBuilder(
      settings: this,
      pageBuilder: (BuildContext _, Animation<double> __, Animation<double> ___) {
        return _FeedPageView();
      });
  }
}

class _FeedPageView extends StatelessWidget {

  _FeedPageView({
    Key key
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SizedBox();
  }
}

