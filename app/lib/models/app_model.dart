import 'package:elmer/elmer.dart';
import 'package:meta/meta.dart';

import '../auth/auth_model.dart';
import '../browse/browse_model.dart';
import '../theming/theming_model.dart';

part 'app_model.g.dart';

abstract class App implements RootAuth, RootBrowse, RootTheming {

  factory App({
    @required String clientId,
    @required String redirectUri,
  }) {
    return _$App(
      initialized: false,
      auth: Auth(
        clientId: clientId,
        redirectUri: redirectUri
      ),
      theming: Theming()
    );
  }

  bool initialized;
}

