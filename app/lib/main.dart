import 'package:elmer_flutter/elmer_flutter.dart';

import 'app/app.dart';
import 'authorization/authorization.dart';
import 'theming/theming.dart';

void main() {
  runLoop(
    rootModels: <Model>{
      AppState(),
      Authorization(

      ),
      Theming()
    },
    services: <Object>{

    },
    initialEvent: Init(),
    app: AlienApp()
  );
}
