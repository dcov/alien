import 'package:flutter/material.dart';

import 'feed.dart';
import 'subreddit_links.dart';

class AllModelSideEffects {
  
  const AllModelSideEffects();

  SubredditLinksModel createSubredditLinksModel(String subredditName) {
    return SubredditLinksModel(subredditName);
  }
}

class AllModel extends FeedModel {

  AllModel([ AllModelSideEffects sideEffects = const AllModelSideEffects() ])
    : links = sideEffects.createSubredditLinksModel('all');

  @override
  String get feedName => 'All';

  @override
  IconData get iconData => Icons.dns;

  @override
  final SubredditLinksModel links;

  @override
  Color get primaryColor => Colors.green;
}