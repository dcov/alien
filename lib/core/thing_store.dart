import 'package:muex/muex.dart';

import '../reddit/types.dart';

import 'context.dart';
import 'comment.dart';
import 'post.dart';
import 'subreddit.dart';

part 'thing_store.g.dart';

class _StoredThing<T> {

  _StoredThing(this.thing);

  final T thing;

  int refCount = 1;
}

abstract class ThingStore implements Model {

  factory ThingStore() {
    return _$ThingStore();
  }

  Map<String, _StoredThing<Subreddit>> get subreddits;

  Map<String, _StoredThing<Post>> get posts;

  Map<String, _StoredThing<Comment>> get comments;
}

abstract class ThingStoreOwner {

  ThingStore get store;
}

class StorePosts implements Update {

  StorePosts({
    required this.posts,
    this.then,
  });

  final List<PostData> posts;

  final Then? then;

  @override
  Then update(ThingStoreOwner owner) {
    final store = owner.store;

    final newPosts = <PostData>[];

    for (final data in posts) {
      if (store.posts[data.id] == null) {
        newPosts.add(data);
      } else {
        final stored = store.posts[data.id]!;
        stored.refCount += 1;
        // TODO: Update the post data here
      }
    }

    if (newPosts.isEmpty) {
      return then ?? Then.done();
    }

    return Then(_GetPostsHaveBeenViewed(
      posts: newPosts,
      then: then,
    ));
  }
}

class _GetPostsHaveBeenViewed implements Effect {

  _GetPostsHaveBeenViewed({
    required this.posts,
    this.then,
  });

  final List<PostData> posts;

  final Then? then;

  @override
  Future<Then> effect(CoreContext context) async {
    final result = <String, bool>{};
    for (final data in posts) {
      result[data.id] = await context.getPostHasBeenViewed(data.id);
    }
    return Then(_StoreNewPosts(
      posts: posts,
      hasBeenViewed: result,
      then: then,
    ));
  }
}

class _StoreNewPosts implements Update {

  _StoreNewPosts({
    required this.posts,
    required this.hasBeenViewed,
    this.then,
  });

  final List<PostData> posts;

  final Map<String, bool> hasBeenViewed;

  final Then? then;

  @override
  Then update(ThingStoreOwner owner) {
    final store = owner.store;

    for (final data in posts) {
      store.posts[data.id] = _StoredThing(Post(
        data: data,
        hasBeenViewed: hasBeenViewed[data.id]!,
      ));
    }

    return then ?? Then.done();
  }
}

class UnstorePosts implements Update {

  UnstorePosts({
    required this.postIds,
  });

  final List<String> postIds;

  @override
  Then update(ThingStoreOwner owner) {
    _unstoreAll(postIds, owner.store.posts);
    return Then.done();
  }
}

class StoreSubreddits implements Update {

  StoreSubreddits({
    required this.subreddits,
  });

  final List<SubredditData> subreddits;

  @override
  Then update(ThingStoreOwner owner) {
    final store = owner.store;

    for (final data in subreddits) {
      store.subreddits.update(
        data.id,
        (_StoredThing<Subreddit> stored) {
          // TODO: update subreddit data
          stored.refCount += 1;
          return stored;
        },
        ifAbsent: () => _StoredThing(Subreddit(data: data)),
      );
    }

    return Then.done();
  }
}

class UnstoreSubreddits implements Update {

  UnstoreSubreddits({
    required this.subredditIds,
  });

  final List<String> subredditIds;

  @override
  Then update(ThingStoreOwner owner) {
    _unstoreAll(subredditIds, owner.store.subreddits);
    return Then.done();
  }
}

class StoreComments implements Update {

  StoreComments({
    required this.comments,
  });

  final List<CommentData> comments;

  @override
  Then update(ThingStoreOwner owner) {
    final store = owner.store;

    for (final data in comments) {
      store.comments.update(
        data.id,
        (_StoredThing<Comment> stored) {
          stored.refCount += 1;
          return stored;
        },
        ifAbsent: () => _StoredThing(Comment(data: data)),
      );
    }

    return Then.done();
  }
}

class UnstoreComments implements Update {

  UnstoreComments({
    required this.commentIds,
  });

  final List<String> commentIds;

  @override
  Then update(ThingStoreOwner owner) {
    _unstoreAll(commentIds, owner.store.comments);
    return Then.done();
  }
}

void _unstoreAll(List<String> ids, Map<String, _StoredThing> things) {
  for (final id in ids) {
    final stored = things[id]!;
    assert(stored.refCount > 0);
    stored.refCount -= 1;
    if (stored.refCount == 0) {
      things.remove(id);
    }
  }
}