import 'package:elmer_flutter/elmer_flutter.dart';

import '../effects/effect_context.dart';
import '../effects/effect_renderer.dart';

import 'app_config.dart' as config;
import 'app_events.dart';
import 'app_model.dart';
import 'app_widgets.dart';

void run() => runLoop(
  container: EffectContext(
    redditId: config.kRedditId,
    redditRedirect: config.kRedditRedirect,
  ),
  state: App(
    clientId: config.kRedditId,
    redirectUri: config.kRedditRedirect,
  ),
  init: Init(),
  app: EffectRenderer(child: Runner()),
);
