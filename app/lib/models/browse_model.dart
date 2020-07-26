import 'package:elmer/elmer.dart';

import 'defaults_model.dart';
import 'home_model.dart';
import 'subscriptions_model.dart';

export 'defaults_model.dart';
export 'home_model.dart';
export 'subscriptions_model.dart';

part 'browse_model.g.dart';

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

