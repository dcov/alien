part of 'subreddit_posts.dart';

class GetSubredditPosts extends Effect {

  const GetSubredditPosts({
    @required this.subredditPostsKey,
    @required this.status,
    @required this.subredditName,
    @required this.sort,
    @required this.page
  });

  final ModelKey subredditPostsKey;

  final ListingStatus status;

  final String subredditName;

  final SubredditSort sort;

  final Page page;
  
  @override
  Future<Event> perform(Repo repo) {
    return repo
      .get<RedditClient>()
      .asDevice()
      .getSubredditPosts(subredditName, sort, page)
      .then((ListingData<PostData> data) {
          return FinishSubredditPostsUpdate(
            subredditPostsKey: this.subredditPostsKey,
            status: this.status,
            data: data
          );
        });
  }
}
