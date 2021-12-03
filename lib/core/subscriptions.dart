import 'package:muex/muex.dart';

import '../reddit/endpoints.dart';
import '../reddit/types.dart';
import '../reddit/utils.dart';

import 'accounts.dart';
import 'context.dart';
import 'thing_store.dart';
import 'user.dart';

part 'subscriptions.g.dart';

abstract class Subscriptions implements Model {

  factory Subscriptions() {
    return _$Subscriptions(refreshing: false);
  }

  bool get refreshing;
  set refreshing(bool value);

  Map<String, List<User>> get subscribers;
}

abstract class SubscriptionsOwner {

  Subscriptions get subscriptions;
}

class RefreshSubscriptions implements Update {

  const RefreshSubscriptions();

  @override
  Then update(Object owner) {
    assert(owner is AccountsOwner);
    assert(owner is SubscriptionsOwner);
    final accounts = (owner as AccountsOwner).accounts;

    final subscriptions = (owner as SubscriptionsOwner).subscriptions;

    subscriptions.refreshing = true;
    final removedIds = subscriptions.subscribers.keys.toList(growable: false);
    subscriptions.subscribers.clear();

    return Then.all({
      if (removedIds.isNotEmpty)
        UnstoreSubreddits(subredditIds: removedIds),
      if (accounts.users.isNotEmpty)
        _GetSubscriptions(accounts.users),
    });
  }
}

class _GetSubscriptions implements Effect {

  _GetSubscriptions(this.users);

  final List<User> users;

  @override
  Future<Then> effect(CoreContext context) async {
    final result = <MapEntry<User, List<SubredditData>>>[];
    for (final user in users) {
      final userResult = <SubredditData>[];
      var pagination = Pagination.maxLimit();
      do {
        try {
          final listing = await context.clientFromUser(user)
            .getUserSubreddits(
              UserSubreddits.subscriber,
              pagination.nextPage!,
              false
            );
          userResult.addAll(listing.things);
          pagination = pagination.forward(listing);
        } catch (_) {
          return Then(const _RefreshFailed());
        }
      } while (pagination.nextPageExists);

      result.add(MapEntry(user, userResult));
    }

    return Then(_FinishRefreshing(result));
  }
}

class _FinishRefreshing implements Update {

  _FinishRefreshing(this.result);

  final List<MapEntry<User, List<SubredditData>>> result;

  @override
  Then update(SubscriptionsOwner owner) {
    final subscriptions = owner.subscriptions;
    assert(subscriptions.refreshing);

    final subreddits = <SubredditData>[];

    for (final entry in result) {
      final user = entry.key;
      final subscribed = entry.value;
      for (final sub in subscribed) {
        subscriptions.subscribers.update(
          sub.id,
          (List<User> list) {
            list.add(user);
            return list;
          },
          ifAbsent: () {
            subreddits.add(sub);
            return <User>[user];
          }
        );
      }
    }

    subscriptions.refreshing = false;

    return Then(StoreSubreddits(subreddits: subreddits));
  }
}

class _RefreshFailed implements Update {

  const _RefreshFailed();

  @override
  Then update(SubscriptionsOwner owner) {
    owner.subscriptions.refreshing = false;
    return Then.done();
  }
}
