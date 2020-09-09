import 'package:elmer_flutter/elmer_flutter.dart';
import 'package:flutter/material.dart';

import '../logic/thing.dart';
import '../models/subreddit.dart';
import '../widgets/icons.dart';
import '../widgets/tile.dart';
import '../widgets/routing.dart';

class SubredditTile extends StatelessWidget {

  SubredditTile({
    Key key,
    @required this.subreddit,
    this.includeDepth = false,
    this.pageNamePrefix = ''
  }) : super(key: key);

  final Subreddit subreddit;

  final bool includeDepth;

  final String pageNamePrefix;

  void _pushPage(BuildContext context) {
    context.push(
      SubredditPage.pageNameFrom(subreddit, pageNamePrefix),
      (String pageName) {
        return SubredditPage(
          subreddit: subreddit,
          name: pageName);
      });
  }

  @override
  Widget build(_) => Connector(
    builder: (BuildContext context) {
      return CustomTile(
        onTap: () => _pushPage(context),
        icon: Icon(
          CustomIcons.subreddit,
          color: Colors.blueGrey,
        ),
        title: Text(
          subreddit.name,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            fontSize: 14.0,
            fontWeight: FontWeight.w500),
        ),
      );
    },
  );
}

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

