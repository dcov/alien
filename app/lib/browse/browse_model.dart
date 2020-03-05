import 'package:elmer/elmer.dart';

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

  factory Browse.signedOut() = _$Browse;

  Home get home;

  Subscriptions get subscriptions;
}

