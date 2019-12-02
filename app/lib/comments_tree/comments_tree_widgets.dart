part of 'comments_tree.dart';

class CommentsTreeScrollable extends StatefulWidget {

  CommentsTreeScrollable({
    Key key,
    @required this.commentsTree,
  }) : super(key: key);

  final CommentsTree commentsTree;

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
    builder: (BuildContext context, EventDispatch dispatch) {
      final CommentsTree commentsTree = widget.commentsTree;
      return PaddedScrollView(
        controller: _controller,
        slivers: <Widget>[
          SliverList(
            delegate: SliverChildBuilderDelegate(
              (_, int index) {
                final Thing thing = commentsTree.things[index];
                if (thing is Comment) {
                  return CommentTile(
                    comment: thing,
                    includeDepthPadding: true,
                  );
                } else if (thing is More) {
                  return MoreTile(
                    commentsTree: commentsTree,
                    more: thing,
                  );
                }
                
                return const SizedBox();
              },
              childCount: commentsTree.things.length
            ),
          )
        ],
      );
    },
  );
}
