import 'package:elmer_flutter/elmer_flutter.dart';
import 'package:flutter/material.dart';

import '../models/subreddit.dart';
import '../widgets/icons.dart';
import '../widgets/routing.dart';
import '../widgets/tile.dart';

import 'subreddit_page.dart';

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
        ),
      );
    },
  );
}

