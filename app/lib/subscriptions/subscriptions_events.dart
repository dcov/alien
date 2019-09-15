part of 'subscriptions.dart';

class RefreshSubscriptions extends Event {

  const RefreshSubscriptions({
    @required this.subscriptionsKey,
  });

  final ModelKey subscriptionsKey;

  @override
  Effect update(Store store) {
    final Subscriptions subscriptions = store.get(this.subscriptionsKey);
    // We're already refreshing, so we don't need to do anything.
    if (subscriptions.refreshing)
      return null;

    subscriptions.refreshing = true;
    return GetSubscriptions(
      subscriptionsKey: this.subscriptionsKey,
      userToken: utils.getUserToken(store)
    );
  }
}

class UpdateSubscriptions extends Event {

  const UpdateSubscriptions({
    @required this.subscriptionsKey,
    @required this.subreddits,
  });

  final ModelKey subscriptionsKey;

  final List<SubredditData> subreddits;

  @override
  void update(Store store) {
    store.get<Subscriptions>(this.subscriptionsKey)
      ..refreshing = false
      ..subreddits.clear()
      ..subreddits.addAll(
        this.subreddits.map((data) => Subreddit.fromData(data)));
  }
}
