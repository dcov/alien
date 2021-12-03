import 'package:flutter/material.dart';
import 'package:muex_flutter/muex_flutter.dart';

import 'core/comment.dart';
import 'core/post.dart';
import 'core/post_comments.dart';
import 'core/thing.dart';
import 'core/thing_store.dart';
import 'reddit/types.dart';
import 'widgets/clickable.dart';
import 'widgets/depth_painter.dart';
import 'widgets/formatting.dart';
import 'widgets/page_stack.dart';
import 'widgets/sliver_custom_paint.dart';
import 'widgets/widget_extensions.dart';

import 'snudown_view.dart';
import 'sort_views.dart';
import 'votable_views.dart';

class PostPage extends PageStackEntry {

  PostPage({
    required ValueKey<String> key,
    required this.post
  }) : super(key: key);

  final Post post;
  late final PostComments _comments;

  @override
  void initState(BuildContext context) {
    _comments = PostComments(
      permalink: post.permalink,
      fullPostId: post.fullId,
    );
    context.then(Then.all({
      MarkPostAsViewed(post: post),
      RefreshPostComments(comments: _comments),
    }));
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      verticalDirection: VerticalDirection.up,
      children: <Widget>[
        Expanded(child: Material(
          child: _CommentsTreeView(comments: _comments),
        )),
        Material(
          elevation: 2.0,
          child: SizedBox(
            height: 56.0,
            child: NavigationToolbar(
              centerMiddle: false,
              leading: CloseButton(),
              middle: Text(
                post.title,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 16.0,
                  fontWeight: FontWeight.w600,
                ),
              ),
              trailing: Connector(builder: (BuildContext context) {
                return Row(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: <Widget>[
                    SortButton(
                      onSortChanged: (CommentsSort newSort) {
                        context.then(Then(RefreshPostComments(comments: _comments, sortBy: newSort)));
                      },
                      sortArgs: CommentsSort.values,
                      currentSort: _comments.sortBy,
                    ),
                  ]
                );
              }),
            ),
          ),
        ),
      ]
    );
  }
}

class _CommentsTreeView extends StatefulWidget {

  _CommentsTreeView({
    Key? key,
    required this.comments,
  }) : super(key: key);

  final PostComments comments;

  @override
  _CommentsTreeViewState createState() => _CommentsTreeViewState();
}

class _CommentsTreeViewState extends State<_CommentsTreeView> with ConnectionCaptureStateMixin {

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
      child = _CommentTile(
        comment: thing,
        collapsed: _collapsed.contains(thing.id),
        onCollapse: () {
          _collapse(thing, index);
        },
        onCollapseToRoot: () {
          _collapseToRoot(thing, index);
        },
        onUncollapse: () {
          _uncollapse(thing, index);
        },
      );
    } else {
      assert(thing is More);
      child = _MoreTile(
        comments: widget.comments,
        more: thing as More,
      );
    }
    
    return child;
  }

  @override
  Widget performBuild(BuildContext context) {
    return CustomScrollView(
      slivers: <Widget>[
        SliverPadding(
          padding: EdgeInsets.only(
            bottom: context.mediaPadding.bottom + 24.0),
          sliver: SliverCustomPaint(
            painter: DepthPainter(
              padding: 16.0,
              linePaint: Paint()..color = Colors.grey,
            ),
            sliver: SliverList(
              key: UniqueKey(),
              delegate: SliverChildBuilderDelegate(
                _buildItem,
                childCount: _visible!.length,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _CommentTile extends StatelessWidget {

  _CommentTile({
    Key? key,
    required this.comment,
    required this.collapsed,
    required this.onCollapse,
    required this.onCollapseToRoot,
    required this.onUncollapse,
  }) : super(key: key);

  final Comment comment;

  final bool collapsed;

  final VoidCallback onCollapse;

  final VoidCallback onCollapseToRoot;

  final VoidCallback onUncollapse;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(left: (comment.depth! * 16.0) + 1),
      child: Clickable(
        onClick: () { },
        child: Material(child: Padding(
          padding: EdgeInsets.symmetric(
            vertical: 8.0,
            horizontal: 16.0,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Wrap(
                spacing: 4.0,
                crossAxisAlignment: WrapCrossAlignment.center,
                children: <Widget>[
                  Text(
                    'u/${comment.authorName}',
                    style: TextStyle(
                      fontSize: 12.0,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Text(
                    'Commented ${formatElapsedUtc(comment.createdAtUtc)}',
                    style: TextStyle(
                      fontSize: 12.0,
                      fontWeight: FontWeight.w400,
                      color: Colors.grey,
                    ),
                  ),
                  if (comment.editedAtUtc != null)
                    Text(
                      '- Edited ${formatElapsedUtc(comment.editedAtUtc!)}',
                      style: TextStyle(
                        fontSize: 12.0,
                        fontWeight: FontWeight.w400,
                        color: Colors.grey,
                      ),
                    ),
                ],
              ),
              Padding(
                padding: EdgeInsets.only(top: 4.0),
                child: SnudownView(snudown: comment.body),
              ),
              Padding(
                padding: EdgeInsets.only(top: 4.0),
                child: Row(children: <Widget>[
                  VoteButton(
                    votable: comment,
                    voteDir: VoteDir.up,
                  ),
                  ScoreText(votable: comment),
                  VoteButton(
                    votable: comment,
                    voteDir: VoteDir.down,
                  ),
                ]),
              ),
            ],
          ),
        )),
      ),
    );
  }
}

class _MoreTile extends StatelessWidget {

  _MoreTile({
    Key? key,
    required this.comments,
    required this.more,
  }) : super(key: key);

  final PostComments comments;

  final More more;

  @override
  Widget build(_) => Connector(builder: (BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(left: (more.depth * 16.0) + 1),
      child: Clickable(
        onClick: () => context.then(Then(LoadMoreComments(more: more, comments: comments))),
        child: Material(child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
          child: Text(
            more.isLoading ? 'Loading...' : 'Load ${more.count} comments',
            style: TextStyle(
              fontSize: 14.0,
              fontWeight: FontWeight.w500,
            ),
          ),
        )),
      ),
    );
  });
}
