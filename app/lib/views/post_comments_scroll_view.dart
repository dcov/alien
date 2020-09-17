import 'dart:async';
import 'dart:math' as math;

import 'package:elmer_flutter/elmer_flutter.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../logic/post_comments.dart';
import '../models/comment.dart';
import '../models/more.dart';
import '../models/post_comments.dart';
import '../models/thing.dart';
import '../widgets/widget_extensions.dart';

import 'comment_tile.dart';
import 'more_tile.dart';

class PostCommentsScrollView extends StatefulWidget {

  PostCommentsScrollView({
    Key key,
    @required this.comments,
  }) : super(key: key);

  final PostComments comments;

  @override
  _PostCommentsScrollViewState createState() => _PostCommentsScrollViewState();
}

class _PostCommentsScrollViewState extends State<PostCommentsScrollView> {

  ScrollController _controller;

  @override
  void initState() {
    super.initState();
    _controller = ScrollController();
  }

  Completer<void> _refreshCompleter;

  Future<void> _handleRefresh() {
    if (_refreshCompleter == null) {
      _refreshCompleter = Completer<void>();
      context.dispatch(RefreshPostComments(comments: widget.comments));
    }
    return _refreshCompleter.future;
  }

  void _checkShouldFinishRefresh(PostComments comments) {
    if (_refreshCompleter != null && !comments.refreshing) {
      _refreshCompleter.complete();
      _refreshCompleter = null;
    }
  }

  @override
  Widget build(_) => Connector(
    builder: (BuildContext context) {
      final comments = widget.comments;
      _checkShouldFinishRefresh(comments);
      return CustomScrollView(
        controller: _controller,
        slivers: <Widget>[
          CupertinoSliverRefreshControl(
            onRefresh: _handleRefresh),
          SliverList(
            delegate: SliverChildBuilderDelegate(
              (_, int index) {
                final Thing thing = comments.things[index];
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
              childCount: comments.things.length)),
          SliverToBoxAdapter(
            child: SizedBox(
              height: math.max(context.mediaPadding.bottom * 2, 48)))
        ]);
    });
}

