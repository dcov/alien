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
    bool initialized,
    List<Feed> feeds,
    Refreshable<Subreddit> defaults,
    Refreshable<Subreddit> subscriptions,
    Accounts accounts,
    Auth auth,
    Theming theming,
  }) = _$App;

  bool initialized;

  List<Feed> get feeds;

  Refreshable<Subreddit> defaults;

  Refreshable<Subreddit> subscriptions;
}

