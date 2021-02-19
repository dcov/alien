import 'package:muex/muex.dart';
import 'package:reddit/reddit.dart';

import '../effects.dart';
import '../models/accounts.dart';
import '../models/refreshable.dart';
import '../models/subreddit.dart';
import '../models/user.dart';

import 'subreddit.dart';
import 'user.dart';

class RefreshDefaults implements Update {

  RefreshDefaults({
    required this.defaults
  });

  final Refreshable<Subreddit> defaults;

  @override
  Then update(AccountsOwner owner) {
    if (defaults.refreshing)
      return Then.done();
    
    defaults..refreshing = true
            ..items.clear();

    return Then(GetDefaults(
      defaults: defaults,
      user: owner.accounts.currentUser));
  }
}

class GetDefaults implements Effect {

  GetDefaults({
    required this.defaults,
    this.user
  });

  final Refreshable<Subreddit> defaults;

  final User? user;

  @override
  Future<Then> effect(EffectContext context) {
    return context.clientFromUser(user)
      .getSubredditsWhere(
          Subreddits.defaults,
          Page(limit: Page.kMaxLimit))
      .then(
          (ListingData<SubredditData> result) {
            return Then(GetDefaultsSuccess(
              defaults: defaults,
              result: result.things));
          },
          onError: (e) {
            return Then(GetDefaultsFailure(
              defaults: defaults));
          });
  }
}

class GetDefaultsSuccess implements Update {

  GetDefaultsSuccess({
    required this.defaults,
    required this.result
  });

  final Refreshable<Subreddit> defaults;

  final Iterable<SubredditData> result;

  @override
  Then update(_) {
    // Ensure we're still expecting this.
    if (defaults.refreshing) {
      defaults
        ..refreshing = false
        ..items.addAll(result.map(subredditFromData))
        ..items.sort((s1, s2) {
            return s1.name.toLowerCase().compareTo(s2.name.toLowerCase());
          });
    }

    return Then.done();
  }
}

class GetDefaultsFailure implements Update {

  GetDefaultsFailure({
    required this.defaults
  });

  final Refreshable<Subreddit> defaults;

  @override
  Then update(_) {
    // TODO: better handle this error case
    defaults.refreshing = false;

    return Then.done();
  }
}
