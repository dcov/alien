part of 'subreddit.dart';

class PushSubreddit extends PushTarget {

  const PushSubreddit({ @required this.subredditKey });

  final ModelKey subredditKey;

  @override
  Event update(Store store) {
    final Subreddit subreddit = store.get(this.subredditKey);
    if (push(store, subreddit)) {
      subreddit.posts = SubredditPosts(
        subredditName: subreddit.name,
      );
      return UpdateSubredditPosts(
        subredditPostsKey: subreddit.posts.key,
        status: ListingStatus.loadingFirst
      );
    }
    return null;
  }
}

class PopSubreddit extends PopTarget {

  const PopSubreddit({ @required this.subredditKey });

  final ModelKey subredditKey;

  @override
  void update(Store store) {
    final Subreddit subreddit = store.get(this.subredditKey);
    super.pop(store, subreddit);
    subreddit.posts = null;
  }
}
