import 'package:elmer/elmer.dart';
import 'package:elmer_flutter/elmer_flutter.dart';
import 'package:flutter/material.dart';

import '../comment/comment_model.dart';
import '../comment/comment_widgets.dart';
import '../thing/thing_model.dart';

import '../widgets/padded_scroll_view.dart';

import 'comments_tree_events.dart';
import 'comments_tree_model.dart';

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

