import 'package:elmer/elmer.dart';

import '../defaults/defaults_model.dart';
import '../home/home_model.dart';
import '../subscriptions/subscriptions_model.dart';

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

