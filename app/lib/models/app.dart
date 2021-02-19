import 'package:muex/muex.dart';

import 'accounts.dart';
import 'auth.dart';
import 'feed.dart';
import 'refreshable.dart';
import 'subreddit.dart';
import 'theming.dart';

part 'app.g.dart';

abstract class App implements Model, AccountsOwner, AuthOwner, ThemingOwner {

  factory App({
    required bool initialized,
    List<Feed> feeds,
    Refreshable<Subreddit> defaults,
    Refreshable<Subreddit> subscriptions,
    required Accounts accounts,
    required Auth auth,
    required Theming theming,
  }) = _$App;

  bool get initialized;
  set initialized(bool value);

  List<Feed> get feeds;

  Refreshable<Subreddit>? get defaults;
  set defaults(Refreshable<Subreddit>? value);

  Refreshable<Subreddit>? get subscriptions;
  set subscriptions(Refreshable<Subreddit>? value);
}
