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
    sortBy: CommentsSort.best,
    refreshing: false);
}

// Maps [data] to a either a [Comment], or [More] object depending on its type.
Thing _mapThing(ThingData data, Object refreshMarker) {
  if (data is CommentData)
    return commentFromData(data);
  else if (data is MoreData)
    return More(
      isLoading: false,
      count: data.count,
      depth: data.depth,
      thingIds: data.thingIds,
      refreshMarker: refreshMarker,
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

class RefreshPostComments extends Action {

  RefreshPostComments({
    @required this.comments,
    this.sortBy,
  }) : assert(comments != null);

  final PostComments comments;

  final CommentsSort sortBy;

  @override
  dynamic update(AccountsOwner owner) {
    if (comments.refreshing &&
        (sortBy == null || sortBy == comments.sortBy)) {
      return;
    }

    /// Create a new marker to be used to represent this instantiation of the refresh flow.
    final refreshMarker = Object();

    comments..refreshing = true
            ..latestRefreshMarker = refreshMarker;

    if (sortBy != null && sortBy != comments.sortBy) {
      comments..sortBy = sortBy
              ..things.clear();
    }
    
    return _GetPostComments(
      comments: comments,
      refreshMarker: refreshMarker,
      user: owner.accounts.currentUser);
  }
}

class _GetPostComments extends Effect {

  _GetPostComments({
    @required this.comments,
    @required this.refreshMarker,
    this.user
  }) : assert(comments != null),
       assert(refreshMarker != null);

  final PostComments comments;

  final Object refreshMarker;

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
            result: result.things,
            refreshMarker: refreshMarker
          );
        },
        onError: (_) {
          return _GetPostCommentsFailed(
            comments: comments,
            refreshMarker: refreshMarker);
        });
  }
}

class _FinishRefreshing extends Action {

  _FinishRefreshing({
    @required this.comments,
    @required this.result,
    @required this.refreshMarker
  }) : assert(comments != null),
       assert(result != null),
       assert(refreshMarker != null);

  final PostComments comments;

  final Iterable<ThingData> result;

  final Object refreshMarker;

  @override
  dynamic update(_) {
    /// If the refreshMarker that corresponds to us is not the most recent marker, don't do anything.
    if (refreshMarker != comments.latestRefreshMarker) 
      return;

    comments
        ..refreshing = false
        ..things.clear()
        ..things.addAll(_flattenTree(result).map((data) => _mapThing(data, refreshMarker)));
  }
}

class _GetPostCommentsFailed extends Action {

  _GetPostCommentsFailed({
    @required this.comments,
    @required this.refreshMarker
  }) : assert(comments != null),
       assert(refreshMarker != null);

  final PostComments comments;

  final Object refreshMarker;

  @override
  dynamic update(_) {
    if (refreshMarker == comments.latestRefreshMarker)
      comments.refreshing = false;
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
    assert(more.refreshMarker == comments.latestRefreshMarker);
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
          return _GetMoreCommentsFailed(
            more: more);
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

    if (more.refreshMarker != comments.latestRefreshMarker)
      return;

    final int insertIndex = comments.things.indexOf(more);
    final Iterable<Thing> newThings = _flattenTree(result).map((data) => _mapThing(data, more.refreshMarker));
    comments.things.replaceRange(insertIndex, insertIndex + 1, newThings);
  }
}

class _GetMoreCommentsFailed extends Action {

  _GetMoreCommentsFailed({
    @required this.more
  }) : assert(more != null);

  final More more;

  @override
  dynamic update(_) {
    more.isLoading = false;
  }
}

