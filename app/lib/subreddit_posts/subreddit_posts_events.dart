part of 'subreddit_posts.dart';

class UpdateSubredditPosts extends UpdateListing {

  const UpdateSubredditPosts({
    @required this.subredditPosts,
    @required this.status
  });

  final SubredditPosts subredditPosts;

  final ListingStatus status;

  @override
  Effect update(_) {
    return ifNotNull(
      super.updateStatus(subredditPosts, this.status),
      (Page page) {
        return GetSubredditPosts(
          subredditPosts: this.subredditPosts,
          status: this.status,
          page: page
        );
      }
    );
  }
}

class FinishSubredditPostsUpdate extends FinishListingUpdate {

  FinishSubredditPostsUpdate({
    @required this.subredditPosts,
    @required this.status,
    @required this.data,
  });

  final SubredditPosts subredditPosts;
  final ListingStatus status;
  final ListingData data;

  @override
  void update(_) {
    super.endUpdate(
      subredditPosts,
      status,
      data,
      (data) => Post.fromData(data)
    );
  }
}
