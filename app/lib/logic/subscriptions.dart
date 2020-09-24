import 'package:elmer/elmer.dart';
import 'package:meta/meta.dart';
import 'package:reddit/reddit.dart';

import '../effects.dart';
import '../models/accounts.dart';
import '../models/refreshable.dart';
import '../models/subreddit.dart';
import '../models/user.dart';

import 'subreddit.dart';
import 'thing.dart';
import 'user.dart';

class RefreshSubscriptions extends Action {

  RefreshSubscriptions({
    @required this.subscriptions
  }) : assert(subscriptions != null);

  final Refreshable<Subreddit> subscriptions;

  @override
  dynamic update(AccountsOwner owner) {
    // If it's already refreshing we don't need to do anything.
    if (subscriptions.refreshing)
      return;

    subscriptions.refreshing = true;

    return GetSubscriptions(
      subscriptions: subscriptions,
      user: owner.accounts.currentUser);
  }
}

class GetSubscriptions extends Effect {

  GetSubscriptions({
    @required this.subscriptions,
    @required this.user
  }) : assert(subscriptions != null),
       assert(user != null);

  final Refreshable<Subreddit> subscriptions;

  final User user;

  @override
  dynamic perform(EffectContext context) async {
    try {
      final List<SubredditData> result = List<SubredditData>();
      Pagination pagination = Pagination.maxLimit();

      do {
        final ListingData<SubredditData> listing = await context.clientFromUser(user).getUserSubreddits(
          UserSubreddits.subscriber,
          pagination.nextPage,
          false);
        result.addAll(listing.things);
        pagination = pagination.forward(listing);
      } while (pagination.nextPageExists);

      return GetSubscriptionsSuccess(
        subscriptions: subscriptions,
        result: result);
    } catch (e) {
      print(e);
      return GetSubscriptionsFailure(subscriptions: subscriptions);
    }
  }
}

class GetSubscriptionsSuccess extends Action {

  GetSubscriptionsSuccess({
    @required this.subscriptions,
    @required this.result
  }) : assert(subscriptions != null),
       assert(result != null);

  final Refreshable<Subreddit> subscriptions;

  final List<SubredditData> result;

  @override
  dynamic update(_) {
    subscriptions
      ..refreshing = false
      ..items.clear()
      ..items.addAll(result.map(subredditFromData))
      ..items.sort((s1, s2) => s1.name.compareTo(s2.name));
  }
}

class GetSubscriptionsFailure extends Action {

  GetSubscriptionsFailure({
    @required this.subscriptions,
  }) : assert(subscriptions != null);

  final Refreshable<Subreddit> subscriptions;

  @override
  dynamic update(_) {
    // TODO: implement better error handling
    subscriptions.refreshing = false;
  }
}

class ToggleSubscribed extends Action {

  ToggleSubscribed({
    @required this.subreddit
  }) : assert(subreddit != null);

  final Subreddit subreddit;

  @override
  dynamic update(AccountsOwner owner) {
    final User user = owner.accounts.currentUser;
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
  }) : assert(subreddit != null),
       assert(user != null);

  final Subreddit subreddit;

  final User user;

  @override
  dynamic perform(EffectContext context) async {
    return context.clientFromUser(user)
      .postSubscribe(subreddit.fullId)
      .catchError((_) {
         // TODO: error handling
       });
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
  }) : assert(subreddit != null),
       assert(user != null);

  final Subreddit subreddit;

  final User user;

  @override
  dynamic perform(EffectContext context) async {
    return context.clientFromUser(user)
      .postUnsubscribe(subreddit.fullId)
      .catchError((_) {
         // TODO: error handling
       });
  }
}

