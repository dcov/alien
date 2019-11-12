part of 'subreddit.dart';

class InitSubreddit extends Event {

  InitSubreddit({ @required this.subreddit })
    : assert(subreddit != null);

  final Subreddit subreddit;

  @override
  Event update(_) {
    subreddit.posts = SubredditPosts(
      subredditName: subreddit.name,
    );
    return UpdateSubredditPosts(
      subredditPosts: subreddit.posts,
      status: ListingStatus.loadingFirst
    );
  }
}

class DisposeSubreddit extends Event {

  DisposeSubreddit({ @required this.subreddit })
    : assert(subreddit != null);

  final Subreddit subreddit;

  @override
  void update(_) {
    subreddit.posts = null;
  }
}

