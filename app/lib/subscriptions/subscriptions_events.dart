import 'package:elmer/elmer.dart';
import 'package:meta/meta.dart';
import 'package:reddit/reddit.dart';

import '../auth/auth_model.dart';
import '../subreddit/subreddit_events.dart';
import '../subreddit/subreddit_model.dart';

import 'subscriptions_effects.dart';
import 'subscriptions_model.dart';

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
      ..subreddits.sort((s1, s2) => s1.name.compareTo(s2.name));
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
  dynamic update(_, AddSubscription event) {
    // TODO: Implement
  }
}

class RemoveSubscriptionUpdate extends ProxyUpdate<RemoveSubscription> {

  RemoveSubscriptionUpdate();

  @override
  dynamic update(_, RemoveSubscription event) {
    // TODO: Implement
  }
}

