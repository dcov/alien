import 'dart:async';

import 'package:elmer_flutter/elmer_flutter.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../logic/post_comments.dart';
import '../models/comment.dart';
import '../models/more.dart';
import '../models/post_comments.dart';
import '../widgets/sliver_custom_paint.dart';
import '../widgets/widget_extensions.dart';

import 'comment_tile.dart';
import 'more_tile.dart';

class _CommentsTreePainter extends CustomPainter {
  
  _CommentsTreePainter({
    @required this.depth,
    @required this.spacing,
    @required this.linePaint
  }) : assert(depth != null),
       assert(spacing != null);

  final int depth;

  final double spacing;

  final Paint linePaint;

  @override
  void paint(Canvas canvas, Size size) {
    for (int i = 1; i <= depth; i++) {
      final dx = spacing * i;
      canvas.drawLine(
        Offset(dx, 0.0),
        Offset(dx, size.height),
        linePaint);
    }
  }

  @override
  bool shouldRepaint(_CommentsTreePainter oldPainter) {
    return depth != oldPainter.depth ||
           spacing != oldPainter.spacing ||
           linePaint != oldPainter.linePaint;
  }
}

class PostCommentsTreeSliver extends StatelessWidget {

  PostCommentsTreeSliver({
    Key key,
    @required this.comments
  }) : assert(comments != null),
       super(key: key);

  final PostComments comments;

  @override
  Widget build(_) {
    return Connector(
      builder: (BuildContext context) {
        return SliverPadding(
          padding: EdgeInsets.only(bottom: context.mediaPadding.bottom + 24.0),
          sliver: SliverCustomPaint(
            painter: _CommentsTreePainter(
              depth: 10,
              spacing: 16.0,
              linePaint: Paint()..color = Colors.grey),
            sliver: SliverList(
              key: UniqueKey(),
              delegate: SliverChildBuilderDelegate(
                (_, int index) {
                  final thing = comments.things[index];
                  if (thing is Comment) {
                    return CommentTile(
                      comment: thing,
                      includeDepthPadding: true);
                  } else if (thing is More) {
                    return MoreTile(
                      comments: comments,
                      more: thing);
                  }
                  
                  return const SizedBox();
                },
                childCount: comments.things.length))));
      });
  }
}

class PostCommentsRefreshSliver extends StatefulWidget {

  PostCommentsRefreshSliver({
    Key key,
    @required this.comments
  }) : assert(comments != null),
       super(key: key);

  final PostComments comments;

  @override
  _PostCommentsRefreshSliverState createState() => _PostCommentsRefreshSliverState();
}

class _PostCommentsRefreshSliverState extends State<PostCommentsRefreshSliver> {

  Completer<void> _refreshCompleter;

  Future<void> _handleRefresh() {
    if (_refreshCompleter == null) {
      _refreshCompleter = Completer<void>();
      context.dispatch(RefreshPostComments(comments: widget.comments));
    }
    return _refreshCompleter.future;
  }

  void _checkShouldFinishRefresh(bool refreshing) {
    if (_refreshCompleter != null && !refreshing) {
      _refreshCompleter.complete();
      _refreshCompleter = null;
    }
  }

  @override
  Widget build(_) {
    return Connector(
      builder: (_) {
        /// Check if we were waiting on a refresh and if that refresh is done
        ///
        /// This also lets [Connector] know that we're depending on the [widget.comments.refreshing] value, so that 
        /// we can rebuild when it changes.
        _checkShouldFinishRefresh(widget.comments.refreshing);
        return CupertinoSliverRefreshControl(onRefresh: _handleRefresh);
      });
  }
}

