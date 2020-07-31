import 'package:elmer/elmer.dart';

import 'defaults.dart';
import 'home.dart';
import 'subscriptions.dart';

export 'defaults.dart';
export 'home.dart';
export 'subscriptions.dart';

part 'browse.g.dart';

abstract class Browse implements Model {

  factory Browse({
    Home home,
    Defaults defaults,
    Subscriptions subscriptions
  }) = _$Browse;

  Home get home;

  Defaults get defaults;

  Subscriptions get subscriptions;
}

@abs
abstract class RootBrowse implements Model {

  Browse browse;
}

