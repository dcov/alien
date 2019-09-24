part of 'subreddit.dart';

class SubredditTile extends StatelessWidget {

  SubredditTile({
    Key key,
    @required this.subredditKey,
    this.includeDepth = false,
  }) : super(key: key);

  final ModelKey subredditKey;

  final bool includeDepth;

  @override
  Widget build(BuildContext context) => Connector(
    builder: (BuildContext context, Store store, EventDispatch dispatch) {
      final Subreddit subreddit = store.get(this.subredditKey);
      return CustomTile(
        onTap: () {
          dispatch(PushSubreddit(subredditKey: this.subredditKey));
          PushNotification.notify(context);
        },
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

class SubredditPage extends StatefulWidget {

  SubredditPage({
    Key key,
    @required this.subredditKey
  }) : super(key: key);

  final ModelKey subredditKey;

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
    builder: (BuildContext context, Store store, EventDispatch dispatch) {
      final Subreddit subreddit = store.get(widget.subredditKey);
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
                    onPressed: () => dispatch(PopSubreddit(subredditKey: subreddit.key)),
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
              subredditPostsKey: subreddit.posts.key,
              topPadding: 16.0,
            ),
          )
        ]
      );
    },
  );
}
