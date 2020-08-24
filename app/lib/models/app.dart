import 'package:elmer/elmer.dart';

import 'auth.dart';
import 'feed.dart';
import 'subscriptions.dart';
import 'theming.dart';

part 'app.g.dart';

abstract class App extends Model implements AuthOwner, SubscriptionsOwner, ThemingOwner {

  factory App({
    bool initialized,
    List<Feed> feeds,
    Auth auth,
    Subscriptions subscriptions,
    Theming theming,
  }) = _$App;

  bool initialized;

  List<Feed> get feeds;
}

