part of 'subreddit_posts.dart';

class GetSubredditPosts extends Effect {

  const GetSubredditPosts({
    @required this.subredditPosts,
    @required this.status,
    @required this.page
  });

  final SubredditPosts subredditPosts;

  final ListingStatus status;

  final Page page;
  
  @override
  Future<Event> perform(EffectContext context) {
    return context.client
      .asDevice()
      .getSubredditPosts(
        subredditPosts.subredditName, subredditPosts.sort, page)
      .then((ListingData<PostData> data) {
          return FinishSubredditPostsUpdate(
            subredditPosts: this.subredditPosts,
            status: this.status,
            data: data
          );
        });
  }
}
