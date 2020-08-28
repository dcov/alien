import 'package:elmer/elmer.dart';

import 'auth.dart';
import 'feed.dart';
import 'refreshable.dart';
import 'subreddit.dart';
import 'theming.dart';

part 'app.g.dart';

abstract class App extends Model implements AuthOwner, ThemingOwner {

  factory App({
    bool initialized,
    List<Feed> feeds,
    Refreshable<Subreddit> defaults,
    Refreshable<Subreddit> subscriptions,
    Auth auth,
    Theming theming,
  }) = _$App;

  bool initialized;

  List<Feed> get feeds;

  Refreshable<Subreddit> defaults;

  Refreshable<Subreddit> subscriptions;
}

