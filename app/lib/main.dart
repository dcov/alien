import 'package:elmer_flutter/elmer_flutter.dart';

import 'app/app.dart';
import 'theming/theming.dart';

void main() {
  runLoop(
    rootModels: {
      ThemingState()
    },
    app: AlienApp()
  );
}
