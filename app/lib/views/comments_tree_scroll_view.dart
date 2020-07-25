import 'package:elmer_flutter/elmer_flutter.dart';
import 'package:flutter/material.dart';

import '../logic/comments_tree_logic.dart';
import '../models/comment_model.dart';
import '../models/comments_tree_model.dart';
import '../widgets/padded_scroll_view.dart';

import 'comment_tile.dart';

class CommentsTreeScrollView extends StatefulWidget {

  CommentsTreeScrollView({
    Key key,
    @required this.commentsTree,
  }) : super(key: key);

  final CommentsTree commentsTree;

  @override
  _CommentsTreeScrollViewState createState() => _CommentsTreeScrollViewState();
}

class _CommentsTreeScrollViewState extends State<CommentsTreeScrollView> {

  ScrollController _controller;

  @override
  void initState() {
    super.initState();
    _controller = ScrollController();
  }

  @override
  Widget build(_) => Connector(
    builder: (BuildContext context) {
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
                  return _MoreTile(
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

class _MoreTile extends StatelessWidget {

  _MoreTile({
    Key key,
    @required this.commentsTree,
    @required this.more
  }) : super(key: key);

  final CommentsTree commentsTree;

  final More more;

  @override
  Widget build(_) => Connector(
    builder: (BuildContext context) {
      return Padding(
        padding: EdgeInsets.only(left: 16.0 * more.depth),
        child: Material(
          child: InkWell(
            onTap: !more.isLoading
              ? () => context.dispatch(LoadMoreComments(
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

