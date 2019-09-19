part of 'comments_tree.dart';

class CommentsTreeScrollable extends StatefulWidget {

  CommentsTreeScrollable({
    Key key,
    @required this.commentsTreeKey,
  }) : super(key: key);

  final ModelKey commentsTreeKey;

  @override
  _CommentsTreeScrollableState createState() => _CommentsTreeScrollableState();
}

class _CommentsTreeScrollableState extends State<CommentsTreeScrollable> {

  ScrollController _controller;

  @override
  void initState() {
    super.initState();
    _controller = ScrollController();
  }

  @override
  Widget build(_) => Connector(
    builder: (BuildContext context, Store store, EventDispatch dispatch) {
      final CommentsTree tree = store.get(widget.commentsTreeKey);
      return CustomScrollView(
        controller: _controller,
        slivers: <Widget>[
          SliverList(
            delegate: SliverChildBuilderDelegate(
              (_, int index) {
                final Thing thing = tree.things[index];
                if (thing is Comment)
                  return CommentTile(commentKey: thing.key);
                else if (thing is More)
                  return MoreTile(
                    commentsTreeKey: tree.key,
                    moreKey: thing.key,
                  );
                
                return const SizedBox();
              }
            ),
          )
        ],
      );
    },
  );
}
