import 'package:flutter/material.dart';

import 'feed.dart';
import 'subreddit_links.dart';

class PopularModelSideEffects {
  
  const PopularModelSideEffects();

  SubredditLinksModel createSubredditLinksModel(String subredditName) => SubredditLinksModel(subredditName);
}

class PopularModel extends FeedModel {

  PopularModel([ PopularModelSideEffects sideEffects = const PopularModelSideEffects() ])
    : links = sideEffects.createSubredditLinksModel('popular');

  @override
  String get feedName => 'Popular';

  @override
  IconData get iconData => Icons.trending_up;

  @override
  final SubredditLinksModel links;

  @override
  Color get primaryColor => Colors.blue;
}