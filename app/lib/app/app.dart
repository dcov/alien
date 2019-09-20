import 'package:elmer/elmer.dart';
import 'package:elmer_flutter/elmer_flutter.dart';
import 'package:flutter/material.dart';
import 'package:reddit/reddit.dart';
import 'package:scraper/scraper.dart';

import '../authorization/authorization.dart';
import '../browse/browse.dart';
import '../routing/routing.dart';
import '../scaffolding/scaffolding.dart';
import '../theming/theming.dart';

part 'app_credentials.dart';
part 'app_effects.dart';
part 'app_events.dart';
part 'app_model.dart';
part 'app_widgets.dart';
part 'app.g.dart';

void run() {
  runLoop(
    dependencies: <Object> {
      RedditClient(_Credentials.clientId),
      Scraper(),
    },
    rootModels: <Model> {
      AppState(),
      Authorization(
        clientId: _Credentials.clientId,
        redirectUri: _Credentials.redirectUri
      ),
      Routing(),
      Theming()
    },
    initialEvent: InitApp(),
    app: AlienApp()
  );
}
