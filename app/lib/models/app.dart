import 'package:elmer/elmer.dart';

import 'auth.dart';
import 'browse.dart';
import 'theming.dart';

// These are part of the model so we export them as well.
export 'auth.dart';
export 'browse.dart';
export 'theming.dart';

part 'app.mdl.dart';

@model
mixin $App implements AuthOwner, BrowseOwner, ThemingOwner {

  bool initialized;
}

