import 'package:muex/muex.dart';
import 'package:reddit/reddit.dart';

import 'context.dart';
import 'accounts.dart';
import 'subreddit.dart';
import 'user.dart';

part 'defaults.g.dart';

abstract class Defaults implements Model {

  factory Defaults({
    required bool refreshing,
    List<Subreddit> things
  }) = _$Defaults;

  bool get refreshing;
  set refreshing(bool value);

  List<Subreddit> get things;
}

class RefreshDefaults implements Update {

  RefreshDefaults({
    required this.defaults
  });

  final Defaults defaults;

  @override
  Then update(AccountsOwner owner) {
    if (defaults.refreshing)
      return Then.done();
    
    defaults..refreshing = true
            ..things.clear();

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

  final Defaults defaults;

  final User? user;

  @override
  Future<Then> effect(CoreContext context) {
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

  final Defaults defaults;

  final Iterable<SubredditData> result;

  @override
  Then update(_) {
    // Ensure we're still expecting this.
    if (defaults.refreshing) {
      defaults
        ..refreshing = false
        ..things.addAll(result.map(subredditFromData))
        ..things.sort((s1, s2) {
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

  final Defaults defaults;

  @override
  Then update(_) {
    // TODO: better handle this error case
    defaults.refreshing = false;

    return Then.done();
  }
}
