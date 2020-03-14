import 'package:elmer/elmer.dart';

import '../defaults/defaults_model.dart';
import '../home/home_model.dart';
import '../subscriptions/subscriptions_model.dart';

part 'browse_model.g.dart';

abstract class Browse implements Model {

  factory Browse.signedIn() {
    return _$Browse(
      home: Home(),
      subscriptions: Subscriptions(),
    );
  }

  factory Browse.signedOut() {
    return _$Browse(
      defaults: Defaults());
  }

  Home get home;

  Defaults get defaults;

  Subscriptions get subscriptions;
}

