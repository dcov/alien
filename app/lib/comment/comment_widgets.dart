part of 'comment.dart';

class CommentTile extends StatelessWidget {

  CommentTile({
    Key key,
    @required this.commentKey,
    @required this.includeDepthPadding
  }) : super(key: key);

  final ModelKey commentKey;

  final bool includeDepthPadding;

  @override
  Widget build(_) => Connector(
    builder: (BuildContext context, Store store, EventDispatch dispatch) {
      final Comment comment = store.get(this.commentKey);
      Widget result = Material(
        child: Padding(
          padding: includeDepthPadding
            ? paddingWithLeftDepth(16.0, comment.depth)
            : const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Row(children: <Widget>[
                  Text(
                    comment.authorName,
                    style: TextStyle(
                      color: comment.isSubmitter ? Colors.blue : null
                    )
                  ),
                  Text(formatElapsedUtc(comment.createdAtUtc)),
                  Text(formatCount(comment.score)),
              ]),
              Padding(
                padding: const EdgeInsets.only(top: 4.0),
                child: DefaultTextStyle(
                  style: Theme.of(context).textTheme.body1,
                  child: SnudownBody(
                    snudownKey: comment.body.key,
                    scrollable: false,
                  ),
                )
              )
            ]
          )
        )
      );

      return result;
    }
  );
}
