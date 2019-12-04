part of 'subscriptions.dart';

class RefreshSubscriptions extends Event {

  const RefreshSubscriptions({
    @required this.subscriptions,
  });

  final Subscriptions subscriptions;

  @override
  dynamic update(RootAuth root) {
    // We're already refreshing, so we don't need to do anything.
    if (subscriptions.refreshing)
      return;

    subscriptions.refreshing = true;
    return GetSubscriptions(
      subscriptions: subscriptions,
      user: root.auth.currentUser
    );
  }
}

class GetSubscriptionsSuccess extends Event {

  const GetSubscriptionsSuccess({
    @required this.subscriptions,
    @required this.data,
  });

  final Subscriptions subscriptions;

  final List<SubredditData> data;

  @override
  void update(_) {
    subscriptions
      ..refreshing = false
      ..subreddits.clear()
      ..subreddits.addAll(
          data.map((SubredditData sd) => Subreddit.fromData(sd)))
      ..subreddits.sort(compareSubreddits);
  }
}

class GetSubscriptionsFail extends Event {

  const GetSubscriptionsFail();

  /// TODO: Implement
  @override
  void update(_) { }
}

class AddSubscriptionUpdate extends ProxyUpdate<AddSubscription> {

  AddSubscriptionUpdate();

  @override
  dynamic update(RootRouting root, AddSubscription event) {
    final Subscriptions subscriptions = root.routing.tree.singleWhere((t) => t is Subscriptions);
    subscriptions.subreddits.add(event.subreddit);
  }
}

class RemoveSubscriptionUpdate extends ProxyUpdate<RemoveSubscription> {

  RemoveSubscriptionUpdate();

  @override
  dynamic update(RootRouting root, RemoveSubscription event) {}
}

