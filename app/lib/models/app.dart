import 'package:elmer/elmer.dart';

import 'auth.dart';
import 'defaults.dart';
import 'feed.dart';
import 'subscriptions.dart';
import 'theming.dart';

part 'app.g.dart';

abstract class App extends Model implements AuthOwner, DefaultsOwner, SubscriptionsOwner, ThemingOwner {

  factory App({
    bool initialized,
    List<Feed> feeds,
    Auth auth,
    Defaults defaults,
    Subscriptions subscriptions,
    Theming theming,
  }) = _$App;

  bool initialized;

  List<Feed> get feeds;
}

