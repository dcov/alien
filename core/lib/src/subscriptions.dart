import 'package:muex/muex.dart';
import 'package:reddit/reddit.dart';

import 'accounts.dart';
import 'context.dart';
import 'subreddit.dart';
import 'thing.dart';
import 'user.dart';

part 'subscriptions.g.dart';

abstract class Subscriptions implements Model {

  factory Subscriptions({
    required bool refreshing,
    List<Subreddit> things
  }) = _$Subscriptions;

  bool get refreshing;
  set refreshing(bool value);

  List<Subreddit> get things;
}

class RefreshSubscriptions implements Update {

  RefreshSubscriptions({
    required this.subscriptions
  });

  final Subscriptions subscriptions;

  @override
  Then update(AccountsOwner owner) {
    // If it's already refreshing we don't need to do anything.
    if (subscriptions.refreshing)
      return Then.done();

    subscriptions.refreshing = true;

    return Then(_GetSubscriptions(
      subscriptions: subscriptions,
      user: owner.accounts.currentUser));
  }
}

class _GetSubscriptions implements Effect {

  _GetSubscriptions({
    required this.subscriptions,
    required this.user
  });

  final Subscriptions subscriptions;

  final User? user;

  @override
  Future<Then> effect(CoreContext context) async {
    try {
      final  result = <SubredditData>[];
      Pagination pagination = Pagination.maxLimit();

      do {
        final listing = await context.clientFromUser(user)
            .getUserSubreddits(
                UserSubreddits.subscriber,
                pagination.nextPage!,
                false);
        result.addAll(listing.things);
        pagination = pagination.forward(listing);
      } while (pagination.nextPageExists);

      return Then(_FinishRefreshing(
        subscriptions: subscriptions,
        result: result));
    } catch (e) {
      return Then(_GetSubscriptionsFailed(subscriptions: subscriptions));
    }
  }
}

class _FinishRefreshing implements Update {

  _FinishRefreshing({
    required this.subscriptions,
    required this.result
  });

  final Subscriptions subscriptions;

  final List<SubredditData> result;

  @override
  Then update(_) {
    subscriptions
      ..refreshing = false
      ..things.clear()
      ..things.addAll(result.map(subredditFromData))
      ..things.sort((s1, s2) => s1.name.toLowerCase().compareTo(s2.name.toLowerCase()));

    return Then.done();
  }
}

class _GetSubscriptionsFailed implements Update {

  _GetSubscriptionsFailed({
    required this.subscriptions,
  });

  final Subscriptions subscriptions;

  @override
  Then update(_) {
    // TODO: implement better error handling
    subscriptions.refreshing = false;

    return Then.done();
  }
}

class ToggleSubscribed implements Update {

  ToggleSubscribed({
    required this.subreddit
  });

  final Subreddit subreddit;

  @override
  Then update(AccountsOwner owner) {
    assert(owner.accounts.currentUser != null,
        'Tried to toggle Subreddit subscription without a User.');

    final User user = owner.accounts.currentUser!;

    // Just flip their subscription state
    subreddit.userIsSubscriber = !subreddit.userIsSubscriber;
    if (subreddit.userIsSubscriber)
      return Then.all({
        RemoveSubscription(),
        PostUnsubscribe(
          subreddit: subreddit,
          user: user)
      });

    return Then.all({
      AddSubscription(),
      PostSubscribe(
        subreddit: subreddit,
        user: user)
    });
  }
}

class AddSubscription implements Update {

  AddSubscription();

  @override
  Then update(_) {
    // TODO: implement
    return Then.done();
  }
}

class PostSubscribe implements Effect {

  PostSubscribe({
    required this.subreddit,
    required this.user
  });

  final Subreddit subreddit;

  final User user;

  @override
  Future<Then> effect(CoreContext context) {
    return context.clientFromUser(user)
      .postSubscribe(subreddit.fullId)
      .then((_) => Then.done())
      .catchError((_) {
         // TODO: error handling
        return Then.done();
       });
  }
}

class RemoveSubscription implements Update {

  RemoveSubscription();

  @override
  Then update(_) {
    // TODO: Implement
    return Then.done();
  }
}

class PostUnsubscribe implements Effect {

  PostUnsubscribe({
    required this.subreddit,
    required this.user
  });

  final Subreddit subreddit;

  final User user;

  @override
  Future<Then> effect(CoreContext context) {
    return context.clientFromUser(user)
      .postUnsubscribe(subreddit.fullId)
      .then((_) => Then.done())
      .catchError((_) {
         // TODO: error handling
         return Then.done();
       });
  }
}
