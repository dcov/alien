import 'package:elmer/elmer.dart';
import 'package:meta/meta.dart';
import 'package:reddit/reddit.dart';

import '../effects.dart';
import '../models/accounts.dart';
import '../models/comments_tree.dart';
import '../models/thing.dart';
import '../models/user.dart';

import 'comment.dart';
import 'user.dart';

class LoadCommentsTree extends Action {

  LoadCommentsTree({
    @required this.commentsTree
  });

  final CommentsTree commentsTree;

  @override
  dynamic update(AccountsOwner owner) {
    if (commentsTree.isRefreshing)
      return null;

    commentsTree
        ..isRefreshing = true
        ..things.clear();
    
    return GetPostComments(
      commentsTree: commentsTree,
      user: owner.accounts.currentUser);
  }
}

class GetPostComments extends Effect {

  GetPostComments({
    @required this.commentsTree,
    this.user
  });

  final CommentsTree commentsTree;

  final User user;

  @override
  dynamic perform(EffectContext context) {
    return context.clientFromUser(user)
      .getPostComments(
        commentsTree.permalink,
        commentsTree.sortBy)
      .then(
        (ListingData<ThingData> result) {
          return GetPostCommentsSuccess(
            commentsTree: commentsTree,
            result: result.things
          );
        },
        onError: (_) {
          return GetPostCommentsFailure();
        });
  }
}

class GetPostCommentsSuccess extends Action {

  GetPostCommentsSuccess({
    @required this.commentsTree,
    @required this.result
  });

  final CommentsTree commentsTree;

  final Iterable<ThingData> result;

  @override
  dynamic update(_) {
    assert(commentsTree.isRefreshing);
    commentsTree..isRefreshing = false
        ..things.addAll(_flattenTree(result).map(_mapThing));
  }
}

class GetPostCommentsFailure extends Action {

  GetPostCommentsFailure();

  @override
  dynamic update(_) {
    // TODO: implement
  }
}

class LoadMoreComments extends Action {

  LoadMoreComments({
    @required this.commentsTree,
    @required this.more
  });

  final CommentsTree commentsTree;

  final More more;

  @override
  dynamic update(AccountsOwner owner) {
    if (more.isLoading)
      return null;
    
    more.isLoading = true;
    return GetMoreComments(
      commentsTree: commentsTree,
      more: more,
      user: owner.accounts.currentUser
    );
  }
}

class GetMoreComments extends Effect {

  GetMoreComments({
    @required this.commentsTree,
    @required this.more,
    this.user
  });

  final CommentsTree commentsTree;

  final More more;

  final User user;

  @override
  dynamic perform(EffectContext context) {
    return context.clientFromUser(user)
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
          return GetMoreCommentsFailure();
        });
  }
}

class GetMoreCommentsSuccess extends Action {

  GetMoreCommentsSuccess({
    @required this.commentsTree,
    @required this.more,
    @required this.result
  });

  final CommentsTree commentsTree;

  final More more;

  final Iterable<ThingData> result ;

  @override
  dynamic update(_) {
    assert(more.isLoading);
    more.isLoading = false;
    final int insertIndex = commentsTree.things.indexOf(more);
    final Iterable<Thing> newThings = _flattenTree(result).map(_mapThing);
    commentsTree.things.replaceRange(insertIndex, insertIndex + 1, newThings);
  }
}

class GetMoreCommentsFailure extends Action {

  GetMoreCommentsFailure();

  @override
  dynamic update(_) {
    // TODO: implement
  }
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

