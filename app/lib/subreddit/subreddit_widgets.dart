import 'package:elmer_flutter/elmer_flutter.dart';
import 'package:flutter/material.dart';

import '../widgets/icons.dart';
import '../widgets/tile.dart';

import 'subreddit_model.dart';

class SubredditTile extends StatelessWidget {

  SubredditTile({
    Key key,
    @required this.subreddit,
    this.includeDepth = false,
  }) : super(key: key);

  final Subreddit subreddit;

  final bool includeDepth;

  @override
  Widget build(_) => Connector(
    builder: (BuildContext context, _) {
      return CustomTile(
        onTap: () { },
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

