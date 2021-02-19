import 'package:muex/muex.dart';
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
    throw StateError('$data was not a CommentData or MoreData instance.');
}

// Flattens the [data] tree structure.
Iterable<ThingData> _flattenTree(Iterable<ThingData> data) sync* {
  for (final ThingData td in data) {
    yield td;
    if (td is CommentData)
      yield* _flattenTree(td.replies);
  }
}

class RefreshPostComments implements Update {

  RefreshPostComments({
    required this.comments,
    this.sortBy,
  });

  final PostComments comments;

  final CommentsSort? sortBy;

  @override
  Then update(AccountsOwner owner) {
    // If we're already in a refreshing state and we're not changing the sort value then we
    // shouldn't do anything.
    if (comments.refreshing &&
        (sortBy == null || sortBy == comments.sortBy)) {
      return Then.done();
    }

    /// Create a new marker to be used to represent this instantiation of the refresh flow.
    final refreshMarker = Object();

    comments
        ..refreshing = true
        ..latestRefreshMarker = refreshMarker;

    if (sortBy != null && sortBy != comments.sortBy) {
      comments..sortBy = sortBy!
              ..things.clear();
    }
    
    return Then(_GetPostComments(
      comments: comments,
      refreshMarker: refreshMarker,
      user: owner.accounts.currentUser));
  }
}

class _GetPostComments implements Effect {

  _GetPostComments({
    required this.comments,
    required this.refreshMarker,
    this.user
  });

  final PostComments comments;

  final Object refreshMarker;

  final User? user;

  @override
  Future<Then> effect(EffectContext context) {
    return context.clientFromUser(user)
      .getPostComments(
        comments.post.permalink,
        comments.sortBy)
      .then(
        (ListingData<ThingData> result) {
          return Then(_FinishRefreshing(
            comments: comments,
            result: result.things,
            refreshMarker: refreshMarker
          ));
        },
        onError: (_) {
          return Then(_GetPostCommentsFailed(
            comments: comments,
            refreshMarker: refreshMarker));
        });
  }
}

class _FinishRefreshing implements Update {

  _FinishRefreshing({
    required this.comments,
    required this.result,
    required this.refreshMarker
  });

  final PostComments comments;

  final Iterable<ThingData> result;

  final Object refreshMarker;

  @override
  Then update(_) {
    /// If the refreshMarker that corresponds to us is not the most recent marker, don't do anything.
    if (refreshMarker == comments.latestRefreshMarker) {
      comments
          ..refreshing = false
          ..things.clear()
          ..things.addAll(_flattenTree(result).map((data) => _mapThing(data, refreshMarker)));
    }

    return Then.done();
  }
}

class _GetPostCommentsFailed implements Update {

  _GetPostCommentsFailed({
    required this.comments,
    required this.refreshMarker
  });

  final PostComments comments;

  final Object refreshMarker;

  @override
  Then update(_) {
    if (refreshMarker == comments.latestRefreshMarker) {
      comments.refreshing = false;
    }
    return Then.done();
  }
}

class LoadMoreComments implements Update {

  LoadMoreComments({
    required this.comments,
    required this.more
  });

  final PostComments comments;

  final More more;

  @override
  Then update(AccountsOwner owner) {
    assert(more.refreshMarker == comments.latestRefreshMarker);
    assert(comments.things.contains(more));

    if (!more.isLoading) {
      more.isLoading = true;
      return Then(_GetMoreComments(
        comments: comments,
        more: more,
        user: owner.accounts.currentUser));
    }

    return Then.done();
  }
}

class _GetMoreComments implements Effect {

  _GetMoreComments({
    required this.comments,
    required this.more,
    this.user,
  });

  final PostComments comments;

  final More more;

  final User? user;

  @override
  Future<Then> effect(EffectContext context) {
    return context.clientFromUser(user)
      .getMoreComments(
        comments.post.fullId,
        more.id,
        more.thingIds)
      .then((ListingData<ThingData> result) {
          return Then(_InsertMoreComments(
            comments: comments,
            more: more,
            result: result.things
          ));
        },
        onError: (e) {
          return Then(_GetMoreCommentsFailed(
            more: more));
        });
  }
}

class _InsertMoreComments implements Update {

  _InsertMoreComments({
    required this.comments,
    required this.more,
    required this.result
  });

  final PostComments comments;

  final More more;

  final Iterable<ThingData> result ;

  @override
  Then update(_) {
    assert(more.isLoading);
    more.isLoading = false;

    if (more.refreshMarker == comments.latestRefreshMarker) {
      final things = _flattenTree(result).map((data) => _mapThing(data, more.refreshMarker));
      final insertIndex = comments.things.indexOf(more);
      comments.things
          ..removeAt(insertIndex)
          ..insertAll(insertIndex, things);
    }

    return Then.done();
  }
}

class _GetMoreCommentsFailed implements Update {

  _GetMoreCommentsFailed({
    required this.more
  });

  final More more;

  @override
  Then update(_) {
    more.isLoading = false;
    return Then.done();
  }
}
