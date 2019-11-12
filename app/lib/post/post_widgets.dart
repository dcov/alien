part of 'post.dart';

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
      return Pressable(
        onPress: () {},
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
      );
    },
  );
}

class PostEntry extends RouterEntry {

  PostEntry({ @required this.post });

  final Post post;

  @override
  RoutingTarget get target => post;

  @override
  String get title => post.title;

  @override
  Widget buildBody(BuildContext context) {
    return CommentsTreeScrollable(commentsTree: post.comments);
  }
}

