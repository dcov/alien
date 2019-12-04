part of 'subscriptions.dart';

class GetSubscriptions extends Effect {

  const GetSubscriptions({
    @required this.subscriptions,
    @required this.user,
  });

  final Subscriptions subscriptions;

  final User user;

  @override
  Future<Event> perform(EffectContext context) async {
    final RedditInteractor reddit = context.client.asUser(user.token);

    try {
      final List<SubredditData> result = List<SubredditData>();
      Pagination pagination = Pagination.maxLimit();

      do {
        final ListingData<SubredditData> listing = await reddit.getUserSubreddits(
          UserSubreddits.subscriber,
          pagination.nextPage,
          false
        );
        result.addAll(listing.things);
        pagination = pagination.forward(listing);
      } while(pagination.nextPageExists);

      return GetSubscriptionsSuccess(
        subscriptions: this.subscriptions,
        data: result
      );
    } catch (e) {
      print(e);
      return GetSubscriptionsFail();
    }
  }
}

