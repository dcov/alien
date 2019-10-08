part of 'subreddit.dart';

class SubredditPage extends StatefulWidget {

  SubredditPage({
    Key key,
    @required this.subreddit,
  }) : super(key: key);

  final Subreddit subreddit;

  @override
  _SubredditPageState createState() => _SubredditPageState();
}

class _SubredditPageState extends State<SubredditPage> {

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(_) => Connector(
    builder: (BuildContext context, EventDispatch dispatch) {
      final Subreddit subreddit = widget.subreddit;
      final EdgeInsets mediaPadding = MediaQuery.of(context).padding;
      return Column(
        children: <Widget>[
          Padding(
            padding: mediaPadding,
            child: Material(
              elevation: 1.0,
              child: SizedBox(
                height: 56.0,
                child: NavigationToolbar(
                  leading: IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: Icon(Icons.close, color: Colors.black,),
                  ),
                  middle: Text(
                    subreddit.name,
                    style: TextStyle(
                      color: Colors.black
                    ),
                  ),
                )
              ),
            )
          ),
          Expanded(
            child: SubredditPostsScrollable(
              subredditPosts: subreddit.posts,
              topPadding: 16.0,
            ),
          )
        ]
      );
    },
  );
}

class SubredditTile extends StatelessWidget {

  SubredditTile({
    Key key,
    @required this.subreddit,
    this.includeDepth = false,
  }) : super(key: key);

  final Subreddit subreddit;

  final bool includeDepth;

  @override
  Widget build(BuildContext context) => Connector(
    builder: (BuildContext context, EventDispatch dispatch) {
      return CustomTile(
        onTap: () => PushNotification.notify(context, PushSubreddit(subreddit: subreddit)),
        padding: EdgeInsets.only(
          left: 16.0 * (1 + (includeDepth ? subreddit.depth : 0)),
          top: 16.0,
          right: 16.0,
          bottom: 16.0
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
