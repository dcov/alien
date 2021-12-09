import 'package:flutter/material.dart';
import 'package:muex/muex.dart';
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
    context.then(Unchained({
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
                        context.then(RefreshPostComments(comments: _comments, sortBy: newSort));
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

  List<TreeItem>? _visible;
  final _collapsed = Set<String>();
  late CommentsSort _latestSortBy;

  @override
  void capture(StateSetter setState) {
    final comments = widget.comments;

    /// We place all of the state we depend on in variables so that we can track changes to it, regardless of whether
    /// we use them the first time or not.
    final items = comments.items;
    final latestSortBy = comments.sortBy;
    final refreshing = comments.refreshing;

    setState(() {
      if (_visible == null) {
        /// We're initializing our state for the first time
        _visible = List.from(items);
        _latestSortBy = latestSortBy;
        return;
      }

      if (refreshing) {
        /// If we're refreshing due to a sortBy change, we'll clear the _visible list
        if (_latestSortBy != latestSortBy) {
          _visible = const <TreeItem>[];
        }
        return;
      }
        
      _visible = List.from(items);
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
          final item = _visible![i];
          if (_collapsed.contains(item.id)) {
            _collapse(item, i, setState);
            noLongerCollapsed.remove(item.id);
          }
        }
        _collapsed.removeAll(noLongerCollapsed);
      }
    });
  }

  void _collapse(TreeItem item, int index, [StateSetter? setState]) {
    setState ??= this.setState;
    setState(() {
      for (var i = index + 1; i < _visible!.length;) {
        if (_visible![i].depth <= item.depth) {
          break;
        }
        _visible!.removeAt(i);
      }
      _collapsed.add(item.id);
    });
  }

  void _collapseToRoot(TreeItem item, int index) {
    if (item.depth == 0) {
      return;
    }

    late TreeItem rootItem;
    late int rootIndex;
    for (var i = index - 1; i >= 0; i--) {
      if (_visible![i].depth == 0) {
        rootItem = _visible![i];
        rootIndex = i;
        break;
      }
    }
    _collapse(rootItem, rootIndex);
  }

  void _uncollapse(TreeItem from, int index) {
    assert(_collapsed.contains(from.id));

    final mainItems = widget.comments.items;
    final mainIndex = mainItems.indexOf(from);
    assert(mainIndex != -1);

    final uncollapsed = <TreeItem>[];
    for (var i = mainIndex + 1; i < mainItems.length; i++) {
      final item = mainItems[i];
      if (item.depth <= from.depth)
        break;

      uncollapsed.add(item);
      if (_collapsed.contains(item.id)) {
        for (; i < mainItems.length; i++) {
          if (mainItems[i + 1].depth <= item.depth)
            break;
        }
      }
    }

    setState(() {
      _collapsed.remove(from.id);
      _visible!.insertAll(index + 1, uncollapsed);
    });
  }

  Widget _buildItem(BuildContext context, int index) {
    final item = _visible![index];
    if (item.id[0] == kMoreCommentsIdPrefix) {
      return _MoreTile(
        comments: widget.comments,
        more: widget.comments.idToMore[item.id]!,
      );
    } else {
      return _CommentTile(
        comment: (context.state as ThingStoreOwner).store.idToComment(item.id),
        collapsed: _collapsed.contains(item.id),
        onCollapse: () => _collapse(item, index),
        onCollapseToRoot: () => _collapseToRoot(item, index),
        onUncollapse: () => _uncollapse(item, index),
      );
    }
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
        onClick: () => context.then(LoadMoreComments(more: more, comments: comments)),
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
