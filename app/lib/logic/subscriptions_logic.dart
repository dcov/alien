import 'package:elmer/elmer.dart';
import 'package:meta/meta.dart';
import 'package:reddit/reddit.dart';

import '../effects/effect_context.dart';
import '../models/auth_model.dart';
import '../models/subreddit_model.dart';
import '../models/subscriptions_model.dart';
import '../models/user_model.dart';
import '../utils/thing_utils.dart' as utils;

class RefreshSubscriptions implements Event {

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

class GetSubscriptions implements Effect {

  const GetSubscriptions({
    @required this.subscriptions,
    @required this.user,
  });

  final Subscriptions subscriptions;

  final User user;

  @override
  Future<Event> perform(EffectContext context) async {
    final RedditClient client = context.reddit.asUser(user.token);

    try {
      final List<SubredditData> result = List<SubredditData>();
      Pagination pagination = Pagination.maxLimit();

      do {
        final ListingData<SubredditData> listing = await client.getUserSubreddits(
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

class GetSubscriptionsSuccess implements Event {

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

class GetSubscriptionsFail implements Event {

  const GetSubscriptionsFail();

  /// TODO: Implement
  @override
  void update(_) { }
}

class ToggleSubscribed implements Event {

  ToggleSubscribed({ @required this.subreddit })
    : assert(subreddit != null);

  final Subreddit subreddit;

  @override
  Set<Message> update(RootAuth root) {
    final User user = root.auth.currentUser;
    assert(user != null);

    subreddit.userIsSubscriber = !subreddit.userIsSubscriber;

    if (subreddit.userIsSubscriber)
      return <Message>{
        RemoveSubscription(),
        PostUnsubscribe(
          subreddit: subreddit,
          user: user)
      };

    return <Message>{
      AddSubscription(),
      PostSubscribe(
        subreddit: subreddit,
        user: user)
    };
  }
}

class AddSubscription implements Event {

  @override
  void update(_) {
    // TODO: implement
  }
}

class PostSubscribe implements Effect {

  PostSubscribe({
    @required this.subreddit,
    @required this.user,
  });

  final Subreddit subreddit;

  final User user;

  @override
  dynamic perform(EffectContext context) async {
    try {
      await context.reddit
          .asUser(user.token)
          .postSubscribe(utils.makeFullId(subreddit));
    } catch (_) {
      // TODO: error handling
    }
  }
}

class RemoveSubscription implements Event {
  
  @override
  void update(_) {
    // TODO: implement
  }
}

class PostUnsubscribe implements Effect {

  PostUnsubscribe({
    @required this.subreddit,
    @required this.user,
  });

  final Subreddit subreddit;

  final User user;

  @override
  dynamic perform(EffectContext context) async {
    try {
      await context.reddit
          .asUser(user.token)
          .postUnsubscribe(utils.makeFullId(subreddit));
    } catch (_) {
      // TODO: error handling
    }
  }
}

