import 'package:elmer/elmer.dart';
import 'package:meta/meta.dart';
import 'package:reddit/reddit.dart';

import '../effects.dart';
import '../models/accounts.dart';
import '../models/more.dart';
import '../models/post.dart';
import '../models/post_comments.dart';
import '../models/thing.dart';
import '../models/user.dart';

import 'comment.dart';
import 'thing.dart';
import 'user.dart';

PostComments commentsFromPost(Post post) {
  return PostComments(
    post: post,
    refreshing: false,
    sortBy: CommentsSort.best);
}

class RefreshPostComments extends Action {

  RefreshPostComments({
    @required this.comments
  }) : assert(comments != null);

  final PostComments comments;

  @override
  dynamic update(AccountsOwner owner) {
    if (comments.refreshing)
      return;

    comments.refreshing = true;
    
    return _GetPostComments(
      comments: comments,
      user: owner.accounts.currentUser);
  }
}

class _GetPostComments extends Effect {

  _GetPostComments({
    @required this.comments,
    this.user
  }) : assert(comments != null);

  final PostComments comments;

  final User user;

  @override
  dynamic perform(EffectContext context) {
    return context.clientFromUser(user)
      .getPostComments(
        comments.post.permalink,
        comments.sortBy)
      .then(
        (ListingData<ThingData> result) {
          return _FinishRefreshing(
            comments: comments,
            result: result.things
          );
        },
        onError: (_) {
          return _GetPostCommentsFailed();
        });
  }
}

class _FinishRefreshing extends Action {

  _FinishRefreshing({
    @required this.comments,
    @required this.result
  }) : assert(comments != null),
       assert(result != null);

  final PostComments comments;

  final Iterable<ThingData> result;

  @override
  dynamic update(_) {
    assert(comments.refreshing);
    comments
        ..refreshing = false
        ..things.clear()
        ..things.addAll(_flattenTree(result).map(_mapThing));
  }
}

class _GetPostCommentsFailed extends Action {

  _GetPostCommentsFailed();

  @override
  dynamic update(_) {
    // TODO: implement
  }
}

class LoadMoreComments extends Action {

  LoadMoreComments({
    @required this.comments,
    @required this.more
  }) : assert(comments != null),
       assert(more != null);

  final PostComments comments;

  final More more;

  @override
  dynamic update(AccountsOwner owner) {
    if (more.isLoading)
      return null;
    
    more.isLoading = true;
    return _GetMoreComments(
      comments: comments,
      more: more,
      user: owner.accounts.currentUser);
  }
}

class _GetMoreComments extends Effect {

  _GetMoreComments({
    @required this.comments,
    @required this.more,
    this.user,
  }) : assert(comments != null),
       assert(more != null);

  final PostComments comments;

  final More more;

  final User user;

  @override
  dynamic perform(EffectContext context) {
    return context.clientFromUser(user)
      .getMoreComments(
        comments.post.fullId,
        more.id,
        more.thingIds)
      .then<Action>((ListingData<ThingData> result) {
          return _InsertMoreComments(
            comments: comments,
            more: more,
            result: result.things
          );
        },
        onError: (e) {
          return _GetMoreCommentsFailed();
        });
  }
}

class _InsertMoreComments extends Action {

  _InsertMoreComments({
    @required this.comments,
    @required this.more,
    @required this.result
  }) : assert(comments != null),
       assert(more != null),
       assert(result != null);

  final PostComments comments;

  final More more;

  final Iterable<ThingData> result ;

  @override
  dynamic update(_) {
    assert(more.isLoading);
    more.isLoading = false;
    final int insertIndex = comments.things.indexOf(more);
    final Iterable<Thing> newThings = _flattenTree(result).map(_mapThing);
    comments.things.replaceRange(insertIndex, insertIndex + 1, newThings);
  }
}

class _GetMoreCommentsFailed extends Action {

  _GetMoreCommentsFailed();

  @override
  dynamic update(_) {
    // TODO: implement
  }
}

//// HELPER FUNCTIONS
// Maps [data] to a either a [Comment], or [More] object depending on its type.
Thing _mapThing(ThingData data) {
  if (data is CommentData)
    return commentFromData(data);
  else if (data is MoreData)
    return More(
      isLoading: false,
      count: data.count,
      depth: data.depth,
      thingIds: data.thingIds,
      id: data.id,
      kind: data.kind);
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

