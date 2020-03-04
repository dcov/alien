import 'package:elmer/elmer.dart';

import '../home/home_model.dart';
import '../subscriptions/subscriptions_model.dart';

part 'browse_model.g.dart';

abstract class Browse implements Model {

  Home home;

  Subscriptions subscriptions;
}

