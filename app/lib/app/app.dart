import 'package:elmer/elmer.dart';
import 'package:elmer_flutter/elmer_flutter.dart';
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:reddit/reddit.dart';
import 'package:scraper/scraper.dart';

import '../auth/auth.dart';
import '../base/base.dart';
import '../routing/routing.dart';
import '../targets/targets.dart';
import '../theming/theming.dart';

part 'app_config.dart';
part 'app_effects.dart';
part 'app_events.dart';
part 'app_model.dart';
part 'app_widgets.dart';
part 'app.g.dart';

void run() => runLoop(
  container: Deps(
    client: RedditClient(Config.kRedditId),
    hive: Hive..init(Config.kHivePath),
    scraper: Scraper()
  ),
  state: App(
    clientId: Config.kRedditId,
    redirectUri: Config.kRedditRedirect,
  ),
  init: Init(),
  app: Runner(),
);

