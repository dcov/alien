import 'package:elmer/elmer.dart';
import 'package:meta/meta.dart';
import 'package:reddit/reddit.dart';

import '../effects.dart';
import '../models/comment.dart';
import '../models/comments_tree.dart';

import 'comment.dart';

part 'comments_tree.msg.dart';

@action loadCommentsTree(_, { @required CommentsTree commentsTree }) {
  if (commentsTree.isRefreshing)
    return null;

  commentsTree..isRefreshing = true
      ..things.clear();
  
  return GetPostComments(commentsTree: commentsTree);
}

@effect getPostComments(EffectContext context, { @required CommentsTree commentsTree }) {
  return context.reddit
    .asDevice()
    .getPostComments(
      commentsTree.permalink,
      commentsTree.sort)
    .then(
      (ListingData<ThingData> result) {
        return GetPostCommentsSuccess(
          commentsTree: commentsTree,
          result: result.things
        );
      },
      onError: (_) {
        return GetPostCommentsFail();
      });
}

@action getPostCommentsSuccess(_, { @required CommentsTree commentsTree, @required Iterable<ThingData> result }) {
  assert(commentsTree.isRefreshing);
  commentsTree..isRefreshing = false
      ..things.addAll(_flattenTree(result).map(_mapThing));
}

@action getPostCommentsFail(_) {
}

@action loadMoreComments(_, { @required CommentsTree commentsTree, @required More more }) {
  if (more.isLoading)
    return null;
  
  more.isLoading = true;
  return GetMoreComments(
    commentsTree: commentsTree,
    more: more,
  );
}

@effect getMoreComments(EffectContext context, { @required CommentsTree commentsTree, @required More more }) {
  return context.reddit
    .asDevice()
    .getMoreComments(
      commentsTree.fullPostId,
      more.id,
      more.thingIds)
    .then((ListingData<ThingData> result) {
        return GetMoreCommentsSuccess(
          commentsTree: commentsTree,
          more: more,
          result: result.things
        );
      },
      onError: (e) {
        return GetPostCommentsFail();
      });
}

@action getMoreCommentsSuccess(_, { @required CommentsTree commentsTree, @required More more, @required Iterable<ThingData> result }) {
  assert(more.isLoading);
  more.isLoading = false;
  final int insertIndex = commentsTree.things.indexOf(more);
  final Iterable<Thing> newThings = _flattenTree(result).map(_mapThing);
  commentsTree.things.replaceRange(insertIndex, insertIndex + 1, newThings);
}

@action getMoreCommentsFail(_) {
}

//// HELPER FUNCTIONS
// Maps [data] to a either a [Comment], or [More] object depending on its type.
Thing _mapThing(ThingData data) {
  if (data is CommentData)
    return data.toModel();
  else if (data is MoreData)
    return data.toModel();
  else
    // TODO: Figure out a better way to handle this
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

extension _MoreDataExtensions on MoreData {

  More toModel() {
    return More(
      isLoading: false,
      count: this.count,
      depth: this.depth,
      thingIds: this.thingIds,
      id: this.id,
      kind: this.kind);
  }
}

