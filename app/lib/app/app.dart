import 'package:elmer/elmer.dart';
import 'package:elmer_flutter/elmer_flutter.dart';
import 'package:flutter/widgets.dart';
import 'package:reddit/reddit.dart';
import 'package:scraper/scraper.dart';

import '../auth/auth.dart';
import '../base/base.dart';
import '../routing/routing.dart';
import '../targets/targets.dart';
import '../theming/theming.dart';

part 'app_credentials.dart';
part 'app_effects.dart';
part 'app_events.dart';
part 'app_model.dart';
part 'app_widgets.dart';
part 'app.g.dart';

void run() => runLoop(
  container: Deps(
    client: RedditClient(Credentials.clientId),
    scraper: Scraper()
  ),
  state: App(
    clientId: Credentials.clientId,
    redirectUri: Credentials.redirectUri,
  ),
  init: Init(),
  app: Runner(),
);

