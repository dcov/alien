import 'package:elmer/elmer.dart';
import 'package:meta/meta.dart';
import 'package:reddit/reddit.dart';

import '../effects/effect_context.dart';
import '../models/comment_model.dart';
import '../models/comments_tree_model.dart';

class LoadCommentsTree implements Event {

  LoadCommentsTree({
    @required this.commentsTree
  });

  final CommentsTree commentsTree;

  @override
  Effect update(_) {
    if (commentsTree.isRefreshing)
      return null;

    commentsTree..isRefreshing = true
        ..things.clear();
    
    return GetPostComments(commentsTree: this.commentsTree);
  }
}

class GetPostComments implements Effect {

  GetPostComments({
    @required this.commentsTree
  });

  final CommentsTree commentsTree;

  @override
  Future<Event> perform(EffectContext context) {
    return context.reddit
        .asDevice()
        .getPostComments(
          commentsTree.permalink,
          commentsTree.sort)
        .then(
          (ListingData<ThingData> data) {
            return GetPostCommentsSuccess(
              commentsTree: this.commentsTree,
              data: data.things
            );
          },
          onError: (_) {
            return GetPostCommentsFail();
          });
  }
}

class GetPostCommentsSuccess implements Event {

  GetPostCommentsSuccess({
    @required this.commentsTree,
    @required this.data
  });

  final CommentsTree commentsTree;

  final Iterable<ThingData> data;

  @override
  void update(_) {
    assert(commentsTree.isRefreshing);
    commentsTree..isRefreshing = false
        ..things.addAll(_flattenTree(data).map(_mapThing));
  }
}

class GetPostCommentsFail implements Event {

  GetPostCommentsFail();

  @override
  void update(_) { }
}

class LoadMoreComments implements Event {

  LoadMoreComments({
    @required this.commentsTree,
    @required this.more,
  });

  final CommentsTree commentsTree;

  final More more;

  @override
  Effect update(_) {
    if (more.isLoading)
      return null;
    
    more.isLoading = true;
    return GetMoreComments(
      commentsTree: this.commentsTree,
      more: this.more,
    );
  }
}

class GetMoreComments implements Effect {

  GetMoreComments({
    @required this.commentsTree,
    @required this.more,
  });

  final CommentsTree commentsTree;

  final More more;

  @override
  Future<Event> perform(EffectContext context) {
    return context.reddit
        .asDevice()
        .getMoreComments(
          commentsTree.fullPostId,
          more.id,
          more.thingIds)
        .then(
          (ListingData<ThingData> data) {
            return GetMoreCommentsSuccess(
              commentsTree: this.commentsTree,
              more: this.more,
              data: data.things
            );
          },
          onError: (e) {
            return GetPostCommentsFail();
          });
  }
}

class GetMoreCommentsSuccess implements Event {

  GetMoreCommentsSuccess({
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
    final Iterable<Thing> newThings = _flattenTree(data).map(_mapThing);
    commentsTree.things.replaceRange(insertIndex, insertIndex + 1, newThings);
  }
}

class GetMoreCommentsFail implements Event {

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
Iterable<ThingData> _flattenTree(Iterable<ThingData> data) sync* {
  for (final ThingData td in data) {
    yield td;
    if (td is CommentData)
      yield* _flattenTree(td.replies);
  }
}

