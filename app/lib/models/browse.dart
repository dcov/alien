import 'package:elmer/elmer.dart';

import 'defaults.dart';
import 'home.dart';
import 'subscriptions.dart';

export 'defaults.dart';
export 'home.dart';
export 'subscriptions.dart';

part 'browse.mdl.dart';

@model
mixin $Browse {

  $Home get home;

  $Defaults get defaults;

  $Subscriptions get subscriptions;
}

mixin BrowseOwner {

  $Browse browse;
}

