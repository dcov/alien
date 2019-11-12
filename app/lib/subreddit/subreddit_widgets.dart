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
    builder: (BuildContext context, EventDispatch dispatch) {
      return CustomTile(
        onTap: () => RouterKey.push(context, subreddit),
        padding: EdgeInsets.only(
          left: 12.0 * (1 + (includeDepth ? subreddit.depth : 0)),
          top: 12.0,
          right: 12.0,
          bottom: 12.0
        ),
        icon: Icon(
          CustomIcons.subreddit,
          color: Colors.blueGrey,
        ),
        title: Text(subreddit.name),
      );
    },
  );
}

class SubredditEntry extends RouterEntry {

  SubredditEntry({ @required this.subreddit });

  final Subreddit subreddit;

  @override
  RoutingTarget get target => subreddit;

  @override
  String get title => subreddit.name;

  @override
  Widget buildBody(BuildContext context) {
    return SubredditPostsScrollable(subredditPosts: subreddit.posts);
  }
}

