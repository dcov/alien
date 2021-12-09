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

  Map<String, _StoredThing<Comment>> get comments;

  Map<String, _StoredThing<Post>> get posts;

  Map<String, _StoredThing<Subreddit>> get subreddits;
}

abstract class ThingStoreOwner {

  ThingStore get store;
}

class StoreComments implements Update {

  StoreComments({
    required this.comments,
  });

  final List<CommentData> comments;

  @override
  Action update(ThingStoreOwner owner) {
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

    return None();
  }
}

class UnstoreComments implements Update {

  UnstoreComments({
    required this.commentIds,
  });

  final List<String> commentIds;

  @override
  Action update(ThingStoreOwner owner) {
    _unstoreAll(commentIds, owner.store.comments);
    return None();
  }
}

class StorePosts implements Update {

  StorePosts({ required this.posts });

  final List<PostData> posts;

  @override
  Action update(ThingStoreOwner owner) {
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
      return None();
    }

    return Effect((CoreContext context) async {
      final hasBeenViewed = <String, bool>{};
      for (final data in posts) {
        hasBeenViewed[data.id] = await context.getPostHasBeenViewed(data.id);
      }
      return Update((_) {
        for (final data in posts) {
          store.posts[data.id] = _StoredThing(Post(
            data: data,
            hasBeenViewed: hasBeenViewed[data.id]!,
          ));
        }
        return None();
      });
    });
  }
}

class UnstorePosts implements Update {

  UnstorePosts({
    required this.postIds,
  });

  final List<String> postIds;

  @override
  Action update(ThingStoreOwner owner) {
    _unstoreAll(postIds, owner.store.posts);
    return None();
  }
}

class StoreSubreddits implements Update {

  StoreSubreddits({
    required this.subreddits,
  });

  final List<SubredditData> subreddits;

  @override
  Action update(ThingStoreOwner owner) {
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

    return None();
  }
}

class UnstoreSubreddits implements Update {

  UnstoreSubreddits({
    required this.subredditIds,
  });

  final List<String> subredditIds;

  @override
  Action update(ThingStoreOwner owner) {
    _unstoreAll(subredditIds, owner.store.subreddits);
    return None();
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

extension ThingStoreExtension on ThingStore {

  Comment idToComment(String id) {
    return this.comments[id]!.thing;
  }

  Post idToPost(String id) {
    return this.posts[id]!.thing;
  }

  Subreddit idToSubreddit(String id) {
    return this.subreddits[id]!.thing;
  }
}
