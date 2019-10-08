part of 'more.dart';

class MoreTile extends StatelessWidget {

  const MoreTile({
    Key key,
    @required this.commentsTree,
    @required this.more
  }) : super(key: key);

  final CommentsTree commentsTree;

  final More more;

  @override
  Widget build(_) => Connector(
    builder: (BuildContext _, EventDispatch dispatch) {
      return Padding(
        padding: EdgeInsets.only(left: 16.0 * more.depth),
        child: Material(
          child: InkWell(
            onTap: !more.isLoading
              ? () => dispatch(LoadMoreComments(
                    commentsTree: commentsTree, more: more))
              : null,
            child: Padding(
              padding: EdgeInsets.all(16.0),
              child: !more.isLoading
                ? Text('Load ${more.count} comments')
                : Text('Loading...'),
            )
          ),
        ),
      );
    },
  );
}
