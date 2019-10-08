part of 'subscriptions.dart';

class GetSubscriptions extends Effect {

  const GetSubscriptions({
    @required this.subscriptions,
    @required this.user,
  });

  final Subscriptions subscriptions;

  final User user;

  @override
  Future<Event> perform(AppContainer container) async {
    final RedditInteractor reddit = container.client.asUser(user.token);

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
        subscriptions: this.subscriptions,
        subreddits: subreddits
      );
    } catch (e) {
      return null;
    }
  }
}
