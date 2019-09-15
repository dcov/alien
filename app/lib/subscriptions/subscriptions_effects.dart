part of 'subscriptions.dart';

class GetSubscriptions extends Effect {

  const GetSubscriptions({
    @required this.subscriptionsKey,
    @required this.userToken,
  });

  final ModelKey subscriptionsKey;

  final String userToken;

  @override
  Future<Event> perform(Repository repository) async {
    final RedditInteractor reddit = repository
        .get<RedditClient>()
        .asUser(this.userToken);

    try {

      final List<SubredditData> subreddits = List<SubredditData>();
      Pagination pagination = Pagination.maxLimit();

      do {
        final ListingData<SubredditData> listing = await reddit.getUserSubreddits(
          UserSubreddits.subscriber,
          pagination.nextPage,
          false
        );
        subreddits.addAll(listing.things);
        pagination.forward(listing);
      } while(pagination.nextPageExists);

      return UpdateSubscriptions(
        subscriptionsKey: this.subscriptionsKey,
        subreddits: subreddits
      );
    } catch (e) {
      return null;
    }
  }
}
