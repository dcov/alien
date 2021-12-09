import 'package:muex/muex.dart';

import '../reddit/endpoints.dart';
import '../reddit/types.dart';

import 'context.dart';
import 'accounts.dart';
import 'thing.dart';
import 'thing_store.dart';
import 'user.dart';

part 'post_comments.g.dart';

const kMoreCommentsIdPrefix = '+';

class TreeItem {
  TreeItem(this.id, this.depth);
  final String id;
  final int depth;
}

abstract class More implements Model, Thing {

  factory More({
    required MoreData data,
    required Object refreshMarker,
  }) {
    return _$More(
      kind: data.kind,
      id: data.id,
      count: data.count,
      depth: data.depth,
      isLoading: false,
      thingIds: data.thingIds,
      refreshMarker: refreshMarker,
    );
  }

  factory More.raw({
    required bool isLoading,
    required int count,
    required int depth,
    required Iterable<String> thingIds,
    required Object refreshMarker,
    required String id,
    required String kind,
  }) = _$More;

  int get count;

  int get depth;

  bool get isLoading;
  set isLoading(bool value);

  Iterable<String> get thingIds;

  /// The post comments refresh instance that led to this object being created.
  /// 
  /// This is used when loading the comments that correspond to a [More] instance (i.e. the [thingIds]).
  ///
  /// See the [PostComments] model for more info.
  Object get refreshMarker;
}

abstract class PostComments implements Model {

  factory PostComments({
    required String fullPostId,
    required String permalink,
  }) {
    return _$PostComments(
      fullPostId: fullPostId,
      permalink: permalink,
      sortBy: CommentsSort.best,
      refreshing: false,
    );
  }

  factory PostComments.raw({
    required String fullPostId,
    required String permalink,
    required bool refreshing,
    Object? latestRefreshMarker,
    required CommentsSort sortBy,
    List<TreeItem> items,
    Map<String, More> idToMore,
  }) = _$PostComments;

  String get fullPostId;

  String get permalink;

  bool get refreshing;
  set refreshing(bool value);

  /// Used when determining whether to refresh, and then whether to complete a refresh. This is needed because
  /// there are cases where multiple refresh actions are in progress (ex. if a user changes the sortBy value multiple
  /// times quickly), and this is used to ensure that only the latest refresh action completes succesfully.
  ///
  /// This is also used when loading the comments that correspond to a [More] model, so that if a refresh happens
  /// while loading those [More] comments, the loaded comments won't be inserted into the tree since the tree has
  /// changed and those comments might not correspond to it anymore.
  Object? get latestRefreshMarker;
  set latestRefreshMarker(Object? value);

  CommentsSort get sortBy;
  set sortBy(CommentsSort value);

  List<TreeItem> get items;

  Map<String, More> get idToMore;
}

class RefreshPostComments implements Update {

  RefreshPostComments({
    required this.comments,
    this.sortBy,
  });

  final PostComments comments;

  final CommentsSort? sortBy;

  @override
  Action update(AccountsOwner owner) {
    // If we're already in a refreshing state and we're not changing the sort value then we
    // shouldn't do anything.
    if (comments.refreshing &&
        (sortBy == null || sortBy == comments.sortBy)) {
      return None();
    }

    comments..refreshing = true
            ..latestRefreshMarker = Object()
            ..sortBy = sortBy ?? comments.sortBy
            ..idToMore.clear();

    final removedIds = comments.items
      .where((item) => item.id[0] != kMoreCommentsIdPrefix)
      .map((item) => item.id)
      .toList(growable: false);

    comments.items.clear();
    
    return Unchained({
      UnstoreComments(commentIds: removedIds),
      _GetPostComments(
        comments: comments,
        refreshMarker: comments.latestRefreshMarker!,
        user: owner.accounts.currentUser,
      ),
    });
  }
}

class _GetPostComments implements Effect {

  _GetPostComments({
    required this.comments,
    required this.refreshMarker,
    this.user,
  });

  final PostComments comments;

  final Object refreshMarker;

  final User? user;

  @override
  Future<Action> effect(CoreContext context) {
    return context.clientFromUser(user)
      .getPostComments(
        comments.permalink,
        comments.sortBy
      )
      .then(
        (ListingData<ThingData> result) {
          return _FinishRefreshing(
            comments: comments,
            result: result.things,
            refreshMarker: refreshMarker,
          );
        },
        onError: (_) {
          return _GetPostCommentsFailed(
            comments: comments,
            refreshMarker: refreshMarker,
          );
        },
      );
  }
}

class _FinishRefreshing implements Update {

  _FinishRefreshing({
    required this.comments,
    required this.result,
    required this.refreshMarker,
  });

  final PostComments comments;

  final Iterable<ThingData> result;

  final Object refreshMarker;

  @override
  Action update(_) {
    /// If the refreshMarker that corresponds to us is not the most recent
    // marker, don't do anything.
    if (refreshMarker == comments.latestRefreshMarker) {
      final newComments = _addToTree(comments, result);
      comments.refreshing = false;
      return StoreComments(comments: newComments);
    }

    return None();
  }
}

class _GetPostCommentsFailed implements Update {

  _GetPostCommentsFailed({
    required this.comments,
    required this.refreshMarker,
  });

  final PostComments comments;

  final Object refreshMarker;

  @override
  Action update(_) {
    if (refreshMarker == comments.latestRefreshMarker) {
      comments.refreshing = false;
      // TODO: Return a UI Effect here that notifies the user that this failed.
    }

    return None();
  }
}

class LoadMoreComments implements Update {

  LoadMoreComments({
    required this.comments,
    required this.more,
  });

  final PostComments comments;

  final More more;

  @override
  Action update(AccountsOwner owner) {
    // This should never happen if the UI is implemented correctly, but just in
    // case...
    if (more.refreshMarker != comments.latestRefreshMarker) {
      return None();
    }

    // This should also never happen if the UI is implemented correctly, but
    // just in case...
    if (!more.isLoading) {
      more.isLoading = true;
      return _GetMoreComments(
        comments: comments,
        more: more,
        user: owner.accounts.currentUser,
      );
    }

    return None();
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
  Future<Action> effect(CoreContext context) {
    return context.clientFromUser(user)
      .getMoreComments(
        comments.fullPostId,
        more.id,
        more.thingIds,
      )
      .then(
        (ListingData<ThingData> result) {
          return _InsertMoreComments(
            comments: comments,
            more: more,
            result: result.things,
          );
        },
        onError: (e) {
          return _GetMoreCommentsFailed(
            comments: comments,
            more: more,
          );
        },
      );
  }
}

class _InsertMoreComments implements Update {

  _InsertMoreComments({
    required this.comments,
    required this.more,
    required this.result,
  });

  final PostComments comments;

  final More more;

  final Iterable<ThingData> result;

  @override
  Action update(_) {
    assert(more.isLoading);
    more.isLoading = false;

    if (more.refreshMarker == comments.latestRefreshMarker) {
      late final int insertIndex;
      for (var i = 0; i < comments.items.length; i++) {
        if (comments.items[i].id == kMoreCommentsIdPrefix + more.id) {
          insertIndex = i;
          break;
        }
      }
      comments.items.removeAt(insertIndex);

      final newComments = _addToTree(
        comments,
        result,
        _InsertIndex(insertIndex),
      );

      return StoreComments(comments: newComments);
    }

    return None();
  }
}

class _GetMoreCommentsFailed implements Update {

  _GetMoreCommentsFailed({
    required this.comments,
    required this.more,
  });

  final PostComments comments;

  final More more;

  @override
  Action update(_) {
    more.isLoading = false;
    if (more.refreshMarker == comments.latestRefreshMarker) {
      // TODO: Return a UI Effect notifying the user that this failed.
    }
    return None();
  }
}

class _InsertIndex {
  _InsertIndex(this.value);
  int value;
}

List<CommentData> _addToTree(PostComments comments, Iterable<ThingData> newThings, [_InsertIndex? insertIndex, List<CommentData>? result]) {
  result = result ?? <CommentData>[];
  for (final thing in newThings) {
    if (thing is CommentData) {
      result.add(thing);
      if (insertIndex != null) {
        comments.items.insert(insertIndex.value, TreeItem(thing.id, thing.depth));
        insertIndex.value += 1;
      } else {
        comments.items.add(TreeItem(thing.id, thing.depth));
      }
      _addToTree(comments, thing.replies, insertIndex, result);
    } else if (thing is MoreData) {
      final id = kMoreCommentsIdPrefix + thing.id;
      if (insertIndex != null) {
        comments.items.insert(insertIndex.value, TreeItem(id, thing.depth));
      } else {
        comments.items.add(TreeItem(id, thing.depth));
      }
      comments.idToMore[id] = More(
        data: thing,
        refreshMarker: comments.latestRefreshMarker!,
      );
    } else {
      throw StateError('PostComments unexpectedly received something other than CommentData or MoreData.');
    }
  }
  return result;
}
