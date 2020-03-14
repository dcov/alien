import 'package:flutter/material.dart';

import '../subreddit/subreddit_widgets.dart';

import 'defaults_model.dart';

class DefaultsSliver extends StatelessWidget {

  DefaultsSliver({
    Key key,
    @required this.defaults,
  }) : super(key: key);

  final Defaults defaults;

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
          subreddit: defaults.subreddits[index]);
      },
      childCount: defaults.subreddits.length);
  }

  @override
  Widget build(BuildContext context) {
    return SliverList(
      delegate: defaults.refreshing
          ? _createRefreshingDelegate()
          : _createBuilderDelegate());
  }
}

