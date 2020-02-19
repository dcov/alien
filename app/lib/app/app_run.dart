import 'package:elmer_flutter/elmer_flutter.dart';

import '../effects/effect_context.dart';
import '../effects/effect_renderer.dart';

import 'app_config.dart' as Config;
import 'app_events.dart';
import 'app_model.dart';
import 'app_widgets.dart';

void run() => runLoop(,
  container: EffectContext(
    redditId: Config.kRedditId,
    redditRedirect: Config.kRedditRedirect,
  ),
  state: App(
    clientId: Config.kRedditId,
    redirectUri: Config.kRedditRedirect,
  ),
  init: Init(),
  app: EffectRenderer(child: Runner()),
);
