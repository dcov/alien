import 'package:muex/muex.dart';

import '../reddit/endpoints.dart';
import '../reddit/types.dart';

import 'context.dart';
import 'accounts.dart';
import 'subreddit.dart';
import 'user.dart';

part 'defaults.g.dart';

abstract class Defaults implements Model {

  factory Defaults() {
    return _$Defaults(
      refreshing: false,
      things: const <Subreddit>[],
    );
  }

  bool get refreshing;
  set refreshing(bool value);

  List<Subreddit> get things;
}

class RefreshDefaults implements Update {

  RefreshDefaults({ required this.defaults });

  final Defaults defaults;

  @override
  Action update(AccountsOwner owner) {
    if (defaults.refreshing) {
      return None();
    }
    
    defaults..refreshing = true
            ..things.clear();

    return GetDefaults(
      defaults: defaults,
      user: owner.accounts.currentUser,
    );
  }
}

class GetDefaults implements Effect {

  GetDefaults({
    required this.defaults,
    this.user
  });

  final Defaults defaults;

  final User? user;

  @override
  Future<Action> effect(CoreContext context) {
    return context.clientFromUser(user)
      .getSubredditsWhere(
          Subreddits.defaults,
          Page(limit: Page.kMaxLimit))
      .then(
        (ListingData<SubredditData> result) {
          return GetDefaultsSuccess(
            defaults: defaults,
            result: result.things,
          );
        },
        onError: (e) {
          return GetDefaultsFailure(defaults: defaults);
        },
      );
  }
}

class GetDefaultsSuccess implements Update {

  GetDefaultsSuccess({
    required this.defaults,
    required this.result
  });

  final Defaults defaults;

  final Iterable<SubredditData> result;

  @override
  Action update(_) {
    // Ensure we're still expecting this.
    if (defaults.refreshing) {
      defaults
        ..refreshing = false
        ..things.addAll(result.map((data) => Subreddit(data: data)))
        ..things.sort((s1, s2) {
            return s1.name.toLowerCase().compareTo(s2.name.toLowerCase());
          });
    }

    return None();
  }
}

class GetDefaultsFailure implements Update {

  GetDefaultsFailure({
    required this.defaults
  });

  final Defaults defaults;

  @override
  Action update(_) {
    // TODO: better handle this error case
    defaults.refreshing = false;
    return None();
  }
}
