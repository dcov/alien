import 'dart:async';

import 'package:elmer_flutter/elmer_flutter.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../logic/post_comments.dart';
import '../models/comment.dart';
import '../models/more.dart';
import '../models/post_comments.dart';
import '../models/thing.dart';

import 'comment_tile.dart';
import 'more_tile.dart';

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
      builder: (_) {
        return SliverList(
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
            childCount: comments.things.length));
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

  void _checkShouldFinishRefresh() {
    if (_refreshCompleter != null && !widget.comments.refreshing) {
      _refreshCompleter.complete();
      _refreshCompleter = null;
    }
  }

  @override
  Widget build(_) {
    return Connector(
      builder: (_) {
        _checkShouldFinishRefresh();
        return CupertinoSliverRefreshControl(onRefresh: _handleRefresh);
      });
  }
}

