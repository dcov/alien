import 'package:elmer/elmer.dart';

import 'auth_model.dart';
import 'browse_model.dart';
import 'theming_model.dart';

// These are part of the model so we export them as well.
export 'auth_model.dart';
export 'browse_model.dart';
export 'theming_model.dart';

part 'app_model.g.dart';

abstract class App implements RootAuth, RootBrowse, RootTheming {

  factory App({
    bool initialized,
    Auth auth,
    Browse browse,
    Theming theming,
  }) = _$App;

  bool initialized;
}

