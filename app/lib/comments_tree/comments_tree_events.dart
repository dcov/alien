import 'package:elmer/elmer.dart';
import 'package:meta/meta.dart';
import 'package:reddit/reddit.dart';

import '../comment/comment_model.dart';
import '../thing/thing_model.dart';

import 'comments_tree_effects.dart';
import 'comments_tree_model.dart';

class LoadCommentsTree extends Event {

  const LoadCommentsTree({ @required this.commentsTree });

  final CommentsTree commentsTree;

  @override
  Effect update(_) {
    assert(commentsTree != null);
    if (commentsTree.isRefreshing)
      return null;

    commentsTree..isRefreshing = true
        ..things.clear();
    
    return GetPostComments(commentsTree: this.commentsTree);
  }
}

class GetPostCommentsSuccess extends Event {

  const GetPostCommentsSuccess({
    @required this.commentsTree,
    @required this.data
  });

  final CommentsTree commentsTree;

  final Iterable<ThingData> data;

  @override
  void update(_) {
    assert(commentsTree.isRefreshing);
    commentsTree..isRefreshing = false
        ..things.addAll(_expandTree(data).map(_mapThing));
  }
}

class GetPostCommentsFail extends Event {

  const GetPostCommentsFail();

  @override
  void update(_) { }
}

class LoadMoreComments extends Event {

  const LoadMoreComments({
    @required this.commentsTree,
    @required this.more,
  });

  final CommentsTree commentsTree;

  final More more;

  @override
  Effect update(_) {
    assert(commentsTree != null);
    assert(more != null);

    if (more.isLoading)
      return null;
    
    more.isLoading = true;
    return GetMoreComments(
      commentsTree: this.commentsTree,
      more: this.more,
    );
  }
}

class GetMoreCommentsSuccess extends Event {

  const GetMoreCommentsSuccess({
    @required this.commentsTree,
    @required this.more,
    @required this.data,
  });

  final CommentsTree commentsTree;

  final More more;

  final Iterable<ThingData> data;

  @override
  void update(_) {
    assert(more.isLoading);
    more.isLoading = false;
    final int insertIndex = commentsTree.things.indexOf(more);
    final Iterable<Thing> newThings = _expandTree(data).map(_mapThing);
    commentsTree.things.replaceRange(insertIndex, insertIndex + 1, newThings);
  }
}

class GetMoreCommentsFail extends Event {

  GetMoreCommentsFail();

  @override
  dynamic update(_) { }
}

// Helper functions

// Maps [data] to a either a [Comment], or [More] object depending on its type.
Thing _mapThing(ThingData data) {
  if (data is CommentData)
    return Comment.fromData(data);
  else if (data is MoreData)
    return More.fromData(data);
  
  return null;
}

// Flattens the [data] tree structure.
Iterable<ThingData> _expandTree(Iterable<ThingData> data) sync* {
  for (final ThingData td in data) {
    yield td;
    if (td is CommentData)
      yield* _expandTree(td.replies);
  }
}

