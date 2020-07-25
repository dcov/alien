import 'package:elmer_flutter/elmer_flutter.dart';

import 'effects/effect_context.dart';
import 'logic/init_logic.dart';
import 'views/app_view.dart';

import 'config.dart' as config;

void main() {
  runLoop(
    initial: InitApp(
      appId: config.kAppId,
      appRedirect: config.kAppRedirect),
    container: EffectContext(
      appId: config.kAppId,
      appRedirect: config.kAppRedirect),
    view: AppRunner());
}

