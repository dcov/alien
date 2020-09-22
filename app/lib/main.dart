import 'logic/init.dart';
import 'views/init_view.dart';

import 'config.dart';
import 'effects.dart';

void main() {
  runLoopWithEffects(
    appId: Credentials.appId,
    appRedirect: Credentials.appRedirect,
    initial: InitApp(
      appId: Credentials.appId,
      appRedirect: Credentials.appRedirect),
    view: InitView());
}

