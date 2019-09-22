part of 'subreddit_posts.dart';

class UpdateSubredditPosts extends UpdateListing {

  const UpdateSubredditPosts({
    @required this.subredditPostsKey,
    @required this.status
  });

  final ModelKey subredditPostsKey;

  final ListingStatus status;

  @override
  Effect update(Store store) {
    final SubredditPosts sp = store.get(this.subredditPostsKey);
    return ifNotNull(
      super.updateStatus(sp, this.status),
      (Page page) {
        return GetSubredditPosts(
          subredditPostsKey: this.subredditPostsKey,
          status: this.status,
          subredditName: sp.subredditName,
          sort: sp.sort,
          page: page
        );
      }
    );
  }
}

class FinishSubredditPostsUpdate extends FinishListingUpdate {

  FinishSubredditPostsUpdate({
    @required this.subredditPostsKey,
    @required this.status,
    @required this.data,
  });

  final ModelKey subredditPostsKey;
  final ListingStatus status;
  final ListingData data;

  @override
  void update(Store store) {
    ifNotNull(store.get<SubredditPosts>(this.subredditPostsKey),
      (SubredditPosts sp) {
        super.endUpdate(
          sp,
          status,
          data,
          (data) => Post.fromData(data)
        );
      }
    );
  }
}
