part of 'post.dart';

class PostPage extends StatefulWidget {

  PostPage({
    Key key,
    @required this.post
  }) : super(key: key);

  final Post post;

  @override
  _PostPageState createState() => _PostPageState();
}

class _PostPageState extends State<PostPage> {

  @override
  Widget build(_) => Connector(
    builder: (BuildContext context, EventDispatch dispatch) {
      final Post post = widget.post;
      return Stack(
        children: <Widget>[
          Padding(
            padding: EdgeInsets.only(
              top: MediaQuery.of(context).padding.top + 56.0),
            child: CommentsTreeScrollable(commentsTree: post.comments),
          ),
          Material(
            elevation: 1.0,
            child: Padding(
              padding: MediaQuery.of(context).padding,
              child: SizedBox(
                height: 56.0,
                child: NavigationToolbar(
                  leading: IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: Icon(Icons.close),
                  ),
                  middle: Text(
                    post.title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ),
            ),
          ),
        ],
      );
    }
  );
}

class PostTile extends StatelessWidget {

  PostTile({
    Key key,
    @required this.post,
    this.includeSubredditName = true,
  }) : super(key: key);

  final Post post;

  final bool includeSubredditName;
  
  @override
  Widget build(_) => Connector(
    builder: (BuildContext context, EventDispatch dispatch) {
      return DecoratedBox(
        decoration: BoxDecoration(
          border: Border(
            bottom: Divider.createBorderSide(context)
          )
        ),
        child: InkWell(
          onTap: () => PushNotification.notify(context, PushPost(post: post)),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text(post.title),
                      Padding(
                        padding: const EdgeInsets.only(top: 4.0),
                        child: Wrap(
                          crossAxisAlignment: WrapCrossAlignment.center,
                          children: <Widget>[
                            if (includeSubredditName)
                              Text('r/${post.subredditName}'),
                            Text('u/${post.authorName}'),
                            Text(formatElapsedUtc(post.createdAtUtc)),
                          ]
                        )
                      ),
                      Wrap(
                        crossAxisAlignment: WrapCrossAlignment.center,
                        children: <Widget>[
                          Text(
                            '${formatCount(post.score)} points',
                            style: TextStyle(
                              color: post.voteDir == VoteDir.up ? Colors.deepOrange :
                                     post.voteDir == VoteDir.down ? Colors.indigoAccent :
                                     Colors.grey
                            )
                          ),
                          Text('${formatCount(post.commentCount)} comments')
                        ],
                      )
                    ]
                  )
                ),
                if (post.media != null) 
                  Padding(
                    padding: const EdgeInsets.only(left: 8.0),
                    child: Material(
                      child: InkWell(
                        child: ClipPath(
                          clipper: ShapeBorderClipper(
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(4.0)
                            )
                          ),
                          child: SizedBox(
                            width: 70,
                            height: 60,
                            child: MediaThumbnail(
                              media: post.media,
                            )
                          )
                        )
                      )
                    )
                  )
              ],
            ),
          )
        )
      );
    },
  );
}
