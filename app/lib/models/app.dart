import 'package:elmer/elmer.dart';

import 'auth.dart';
import 'browse.dart';
import 'theming.dart';

// These are part of the model so we export them as well.
export 'auth.dart';
export 'browse.dart';
export 'theming.dart';

part 'app.g.dart';

abstract class App implements RootAuth, RootBrowse, RootTheming {

  factory App({
    bool initialized,
    Auth auth,
    Browse browse,
    Theming theming,
  }) = _$App;

  bool initialized;
}

