import 'package:elmer/elmer.dart';
import 'package:meta/meta.dart';
import 'package:reddit/reddit.dart';

import '../effects.dart';
import '../models/auth.dart';
import '../models/subreddit.dart';
import '../models/subscriptions.dart';
import '../models/user.dart';

import 'subreddit.dart' show SubredditDataExtensions;
import 'thing.dart' show ThingExtensions;

class RefreshSubscriptions extends Action {

  RefreshSubscriptions();

  @override
  dynamic update(Object owner) {
    assert(owner is AuthOwner);
    assert(owner is SubscriptionsOwner);

    final auth = (owner as AuthOwner).auth;
    final subscriptions = (owner as SubscriptionsOwner).subscriptions;
    // If it's already refreshing we don't need to do anything.
    if (subscriptions.refreshing)
      return;

    subscriptions.refreshing = true;
    return GetSubscriptions(
      subscriptions: subscriptions,
      user: auth.currentUser
    );
  }
}

class GetSubscriptions extends Effect {

  GetSubscriptions({
    @required this.user
  });

  final User user;

  @override
  dynamic perform(EffectContext context) async {
    final RedditClient client = context.reddit.asUser(user.token);

    try {
      final List<SubredditData> result = List<SubredditData>();
      Pagination pagination = Pagination.maxLimit();

      do {
        final ListingData<SubredditData> listing = await client.getUserSubreddits(
          UserSubreddits.subscriber,
          pagination.nextPage,
          false);
        result.addAll(listing.things);
        pagination = pagination.forward(listing);
      } while (pagination.nextPageExists);

      return GetSubscriptionsSuccess(
        result: result);
    } catch (e) {
      print(e);
      return GetSubscriptionsFailure();
    }
  }
}

class GetSubscriptionsSuccess extends Action {

  GetSubscriptionsSuccess({
    @required this.result
  });

  final List<SubredditData> result;

  @override
  dynamic update(SubscriptionsOwner owner) {
    owner.subscriptions
      ..refreshing = false
      ..subreddits.clear()
      ..subreddits.addAll(
          result.map((SubredditData data) => data.toModel()))
      ..subreddits.sort((s1, s2) => s1.name.compareTo(s2.name));
  }
}

class GetSubscriptionsFailure extends Action {

  GetSubscriptionsFailure();

  @override
  dynamic update(_) {
    // TODO: implement
  }
}

class ToggleSubscribed extends Action {

  ToggleSubscribed({
    @required this.subreddit
  });

  final Subreddit subreddit;

  @override
  dynamic update(AuthOwner owner) {
    final User user = owner.auth.currentUser;
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

class AddSubscription extends Action {

  AddSubscription();

  @override
  dynamic update(_) {
    // TODO: implement
  }
}

class PostSubscribe extends Effect {

  PostSubscribe({
    @required this.subreddit,
    @required this.user
  });

  final Subreddit subreddit;

  final User user;

  @override
  dynamic perform(EffectContext context) async {
    try {
      await context.reddit
          .asUser(user.token)
          .postSubscribe(subreddit.fullId);
    } catch (_) {
      // TODO: error handling
    }
  }
}

class RemoveSubscription extends Action {

  RemoveSubscription();

  @override
  dynamic update(_) {
   // TODO: Implement
  }
}

class PostUnsubscribe extends Effect {

  PostUnsubscribe({
    @required this.subreddit,
    @required this.user
  });

  final Subreddit subreddit;

  final User user;

  @override
  dynamic perform(EffectContext context) async {
    try {
      await context.reddit
          .asUser(user.token)
          .postUnsubscribe(subreddit.fullId);
    } catch (_) {
      // TODO: error handling
    }
  }
}

