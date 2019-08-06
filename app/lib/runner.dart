import 'package:elmer_flutter/elmer_flutter.dart';

import 'main/main.dart';

void main() {
  runLoop(
    rootModels: {
      MainState()
    },
    app: AlienApp()
  );
}
