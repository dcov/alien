import 'dart:async';

import 'package:alien_core/alien_core.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:muex_flutter/muex_flutter.dart';
import 'package:reddit/reddit.dart';

import 'depth_painter.dart';
import 'sliver_custom_paint.dart';
import 'widget_extensions.dart';

import 'comment_tile.dart';
import 'more_tile.dart';

class PostCommentsTreeSliver extends StatefulWidget {

  PostCommentsTreeSliver({
    Key? key,
    required this.comments
  }) : super(key: key);

  final PostComments comments;

  @override
  PostCommentsTreeSliverState createState() => PostCommentsTreeSliverState();
}

@visibleForTesting
class PostCommentsTreeSliverState extends State<PostCommentsTreeSliver> with ConnectionCaptureStateMixin {

  @visibleForTesting
  List<Thing> get visible => _visible!;
  List<Thing>? _visible;

  @visibleForTesting
  Set<String> get collapsed => _collapsed;
  final _collapsed = Set<String>();

  late CommentsSort _latestSortBy;

  @override
  void capture(StateSetter setState) {
    final comments = widget.comments;

    /// We place all of the state we depend on in variables so that we can track changes to it, regardless of whether
    /// we use them the first time or not.
    final things = comments.things;
    final latestSortBy = comments.sortBy;
    final refreshing = comments.refreshing;

    setState(() {
      if (_visible == null) {
        /// We're initializing our state for the first time
        _visible = List<Thing>.from(things);
        _latestSortBy = latestSortBy;
        return;
      }

      if (refreshing) {
        /// If we're refreshing due to a sortBy change, we'll clear the _visible list
        if (_latestSortBy != latestSortBy){
          _visible = const <Thing>[];
        }
        return;
      }
        
      _visible = List<Thing>.from(things);
      if (_latestSortBy != latestSortBy) {
        /// The completed refresh was due to a sort change so the currently collapsed items
        /// no longer apply.
        _collapsed.clear();
        _latestSortBy = latestSortBy;
        return;
      }

      if (_collapsed.isNotEmpty) {
        final noLongerCollapsed = Set<String>.from(_collapsed);
        for (var i = 0; i < _visible!.length; i++) {
          final thing = _visible![i];
          if (thing is Comment && _collapsed.contains(thing.id)) {
            _collapse(thing, i, setState);
            noLongerCollapsed.remove(thing.id);
          }
        }
        _collapsed.removeAll(noLongerCollapsed);
      }
    });
  }

  int _getThingDepth(Thing thing) {
    if (thing is Comment) {
      return thing.depth!;
    } else if (thing is More) {
      return thing.depth;
    } else {
      assert(false, '$thing was not instance of type Comment or More');
      return 0;
    }
  }

  void _collapse(Comment comment, int index, [StateSetter? setState]) {
    setState ??= this.setState;
    setState(() {
      for (var i = index + 1; i < _visible!.length;) {
        if (_getThingDepth(_visible![i]) <= comment.depth!) {
          break;
        }
        _visible!.removeAt(i);
      }
      _collapsed.add(comment.id);
    });
  }

  void _collapseToRoot(Comment comment, int index) {
    if (comment.depth == 0) {
      return;
    }

    late Comment rootComment;
    late int rootIndex;
    for (var i = index - 1; i >= 0; i--) {
      if (_getThingDepth(_visible![i]) == 0) {
        rootComment = _visible![i] as Comment;
        rootIndex = i;
        break;
      }
    }
    _collapse(rootComment, rootIndex);
  }

  void _uncollapse(Comment comment, int index) {
    assert(_collapsed.contains(comment.id));

    final mainThings = widget.comments.things;
    final mainIndex = mainThings.indexOf(comment);
    assert(mainIndex != -1);

    final uncollapsed = <Thing>[];
    for (var i = mainIndex + 1; i < mainThings.length; i++) {
      final thing = mainThings[i];
      if (_getThingDepth(thing) <= comment.depth!)
        break;

      uncollapsed.add(thing);
      if (_collapsed.contains(thing.id)) {
        for (; i < mainThings.length; i++) {
          if (_getThingDepth(mainThings[i + 1]) <= _getThingDepth(thing))
            break;
        }
      }
    }

    setState(() {
      _collapsed.remove(comment.id);
      _visible!.insertAll(index + 1, uncollapsed);
    });
  }

  Widget _buildItem(_, int index) {
    final thing = _visible![index];
    Widget child;
    if (thing is Comment) {
      child = CommentTile(
        comment: thing,
        includeDepthPadding: true,
        collapsed: _collapsed.contains(thing.id),
        onCollapse: () {
          _collapse(thing, index);
        },
        onCollapseToRoot: () {
          _collapseToRoot(thing, index);
        },
        onUncollapse: () {
          _uncollapse(thing, index);
        });
    } else {
      assert(thing is More);
      child = MoreTile(
        comments: widget.comments,
        more: thing as More);
    }
    
    return child;
  }

  @override
  Widget performBuild(BuildContext context) {
    return SliverPadding(
      padding: EdgeInsets.only(
        bottom: context.mediaPadding.bottom + 24.0),
      sliver: SliverCustomPaint(
        painter: DepthPainter(
          padding: 16.0,
          linePaint: Paint()..color = Colors.grey),
        sliver: SliverList(
          key: UniqueKey(),
          delegate: SliverChildBuilderDelegate(
            _buildItem,
            childCount: _visible!.length))));
  }
}

class PostCommentsRefreshSliver extends StatefulWidget {

  PostCommentsRefreshSliver({
    Key? key,
    required this.comments
  }) : super(key: key);

  final PostComments comments;

  @override
  _PostCommentsRefreshSliverState createState() => _PostCommentsRefreshSliverState();
}

class _PostCommentsRefreshSliverState extends State<PostCommentsRefreshSliver> {

  Completer<void>? _refreshCompleter;

  Future<void> _handleRefresh() {
    if (_refreshCompleter == null) {
      _refreshCompleter = Completer<void>();
      context.then(Then(RefreshPostComments(comments: widget.comments)));
    }
    return _refreshCompleter!.future;
  }

  void _checkShouldFinishRefresh(bool refreshing) {
    if (_refreshCompleter != null && !refreshing) {
      _refreshCompleter!.complete();
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
