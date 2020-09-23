import 'package:elmer/elmer.dart';
import 'package:meta/meta.dart';
import 'package:reddit/reddit.dart';

import '../effects.dart';
import '../models/accounts.dart';
import '../models/refreshable.dart';
import '../models/subreddit.dart';
import '../models/user.dart';

import 'subreddit.dart';
import 'user.dart';

class RefreshDefaults extends Action {

  RefreshDefaults({
    @required this.defaults
  });

  final Refreshable<Subreddit> defaults;

  @override
  dynamic update(AccountsOwner owner) {
    if (defaults.refreshing)
      return null;
    
    defaults..refreshing = true
            ..items.clear();

    return GetDefaults(
      defaults: defaults,
      user: owner.accounts.currentUser);
  }
}

class GetDefaults extends Effect {

  GetDefaults({
    @required this.defaults,
    this.user
  });

  final Refreshable<Subreddit> defaults;

  final User user;

  @override
  dynamic perform(EffectContext context) {
    return context.clientFromUser(user)
      .getSubreddits(
          Subreddits.defaults,
          Page(limit: Page.kMaxLimit))
      .then(
          (ListingData<SubredditData> result) {
            return GetDefaultsSuccess(
              defaults: defaults,
              result: result.things);
          },
          onError: (e) {
            return GetDefaultsFailure(
              defaults: defaults);
          });
  }
}

class GetDefaultsSuccess extends Action {

  GetDefaultsSuccess({
    @required this.defaults,
    @required this.result
  });

  final Refreshable<Subreddit> defaults;

  final Iterable<SubredditData> result;

  @override
  dynamic update(_) {
    // Ensure we're still expecting this.
    if (!defaults.refreshing)
      return;

    defaults
      ..refreshing = false
      ..items.addAll(result.map((SubredditData data) => data.toModel()))
      ..items.sort((s1, s2) {
          return s1.name.toLowerCase().compareTo(s2.name.toLowerCase());
        });
  }
}

class GetDefaultsFailure extends Action {

  GetDefaultsFailure({
    @required this.defaults
  });

  final Refreshable<Subreddit> defaults;

  @override
  dynamic update(_) {
    // TODO: better handle this error case
    defaults.refreshing = false;
  }
}

