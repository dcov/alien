import 'package:muex/muex.dart';

import 'accounts.dart';
import 'auth.dart';
import 'feed.dart';
import 'refreshable.dart';
import 'subreddit.dart';

part 'app.g.dart';

enum AppTheme {
  dark
}

abstract class App implements Model, AccountsOwner, AuthOwner {

  factory App({
    required bool initialized,
    required AppTheme theme,
    List<Feed> feeds,
    Refreshable<Subreddit> defaults,
    Refreshable<Subreddit> subscriptions,
    required Accounts accounts,
    required Auth auth,
  }) = _$App;

  bool get initialized;
  set initialized(bool value);

  AppTheme get theme;
  set theme(AppTheme value);

  List<Feed> get feeds;

  Refreshable<Subreddit>? get defaults;
  set defaults(Refreshable<Subreddit>? value);

  Refreshable<Subreddit>? get subscriptions;
  set subscriptions(Refreshable<Subreddit>? value);
}
