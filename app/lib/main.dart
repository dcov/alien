import 'logic/init.dart';
import 'views/init_view.dart';

import 'config.dart' as config;
import 'effects.dart';

void main() {
  runLoopWithEffects(
    appId: config.kAppId,
    appRedirect: config.kAppRedirect,
    initial: InitApp(
      appId: config.kAppId,
      appRedirect: config.kAppRedirect),
    view: InitView());
}

