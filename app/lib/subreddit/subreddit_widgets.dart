part of 'subreddit.dart';

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
        onTap: () => RouterKey.push(context, subreddit),
        depth: subreddit.depth,
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

class SubredditEntry extends RouterEntry {

  SubredditEntry({ @required this.subreddit });

  final Subreddit subreddit;

  @override
  Target get target => subreddit;

  @override
  String get title => subreddit.name;

  @override
  List<Widget> buildTopActions(BuildContext context) => <Widget>[
  ];

  @override
  Widget buildBody(BuildContext context) {
    return SubredditPostsScrollable(subredditPosts: subreddit.posts);
  }

  @override
  List<Widget> buildBottomActions(BuildContext context) => <Widget>[
  ];
}

