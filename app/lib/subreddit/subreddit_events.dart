part of 'subreddit.dart';

class PushSubreddit extends PushTarget {

  const PushSubreddit({ @required this.subreddit });

  final Subreddit subreddit;

  @override
  Event update(AppState state) {
    if (push(state.routing, subreddit)) {
      subreddit.posts = SubredditPosts(
        subredditName: subreddit.name,
      );
      return UpdateSubredditPosts(
        subredditPosts: subreddit.posts,
        status: ListingStatus.loadingFirst
      );
    }
    return null;
  }
}

class PopSubreddit extends PopTarget {

  const PopSubreddit({ @required this.subreddit });

  final Subreddit subreddit;

  @override
  void update(AppState state) {
    super.pop(state.routing, subreddit);
    // subreddit.posts = null;
  }
}
