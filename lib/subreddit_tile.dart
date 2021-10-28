import 'package:flutter/material.dart';
import 'package:muex_flutter/muex_flutter.dart';

import 'core/subreddit.dart';
import 'widgets/icons.dart';
import 'widgets/tile.dart';

import 'subreddit_route.dart';

class SubredditTile extends StatelessWidget {

  SubredditTile({
    Key? key,
    required this.subreddit,
    required this.pathPrefix
  }) : super(key: key);

  final Subreddit subreddit;

  final String pathPrefix;

  @override
  Widget build(_) => Connector(
    builder: (BuildContext context) {
      return CustomTile(
        onTap: () {
          SubredditRoute.goTo(
            context,
            subreddit,
            pathPrefix);
        },
        icon: Icon(
          CustomIcons.subreddit,
          color: Colors.blueGrey),
        title: Text(
          subreddit.name,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            fontSize: 14.0,
            fontWeight: FontWeight.w500)));
    });
}
