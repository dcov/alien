import 'package:elmer/elmer.dart';

import 'auth.dart';
import 'subscriptions.dart';
import 'theming.dart';

part 'app.g.dart';

abstract class App extends Model implements AuthOwner, SubscriptionsOwner, ThemingOwner {

  factory App({
    bool initialized,
    Auth auth,
    Subscriptions subscriptions,
    Theming theming,
  }) = _$App;

  bool initialized;
}

