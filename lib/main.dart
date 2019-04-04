import 'package:flutter/widgets.dart';

import 'package:alien/app/app.dart';


import 'credentials.dart' as credentials;

void main() {
  runApp(
    App(model: AppModel(
      credentials.kClientId,
      credentials.kRedirect,
    ))
  );
}