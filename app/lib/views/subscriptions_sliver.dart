import 'package:elmer_flutter/elmer_flutter.dart';
import 'package:flutter/material.dart';

import '../models/subscriptions.dart';

import 'subreddit_tile.dart';

class SubscriptionsSliver extends StatelessWidget {

  SubscriptionsSliver({
    Key key,
    @required this.subscriptions
  }) : super(key: key);

  final Subscriptions subscriptions;

  SliverChildDelegate _createRefreshingDelegate() {
    return SliverChildListDelegate(
      <Widget>[
        CircularProgressIndicator()
      ]);
  }

  SliverChildDelegate _createBuilderDelegate() {
    return SliverChildBuilderDelegate(
      (BuildContext context, int index) {
        return SubredditTile(
          subreddit: subscriptions.subreddits[index]);
      },
      childCount: subscriptions.subreddits.length);
  }

  @override
  Widget build(_) {
    return Connector(
      builder: (_) {
        return SliverList(
          delegate: subscriptions.refreshing
              ? _createRefreshingDelegate()
              : _createBuilderDelegate());
      });
  }
}

