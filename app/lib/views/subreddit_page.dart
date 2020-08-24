import 'package:elmer_flutter/elmer_flutter.dart';
import 'package:flutter/material.dart';

import '../logic/thing.dart';
import '../models/subreddit.dart';
import '../widgets/routing.dart';

class SubredditPage extends EntryPage {

  SubredditPage({
    @required this.subreddit,
    @required String name,
  }) : super(name: name);

  final Subreddit subreddit;

  static String pageNameFrom(Subreddit subreddit, [String prefix = '']) {
    return prefix + subreddit.fullId;
  }

  @override
  Route createRoute(BuildContext context) {
    return PageRouteBuilder(
      settings: this);
  }
}

