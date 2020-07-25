import 'logic/init_logic.dart';
import 'views/app_runner.dart';

import 'config.dart' as config;
import 'effects.dart';

void main() {
  runLoopWithEffects(
    appId: config.kAppId,
    appRedirect: config.kAppRedirect,
    initial: InitApp(
      appId: config.kAppId,
      appRedirect: config.kAppRedirect),
    view: AppRunner());
}

