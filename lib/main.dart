import 'package:bitsdojo_window/bitsdojo_window.dart';
import 'package:flutter/material.dart';
import 'package:muex_flutter/muex_flutter.dart';

import 'core/app.dart';
import 'core/context.dart';
import 'widgets/splash_screen.dart';

import 'main_screen.dart';
import 'reddit_credentials.dart';

void main() {
  const runInScriptMode = bool.hasEnvironment('script_mode');
  runLoop(
    initial: InitApp(
      appId: Credentials.appId,
      appRedirect: Credentials.appRedirect,
      isInScriptMode: runInScriptMode,
    ),
    container: CoreContext(
      appId: Credentials.appId,
      appRedirect: Credentials.appRedirect,
      scriptId: runInScriptMode ? Credentials.scriptId : null,
      scriptSecret: Credentials.scriptSecret,
      scriptUsername: Credentials.scriptUsername,
      scriptPassword: Credentials.scriptPassword,
    ),
    view: Builder(
      builder: (BuildContext _) {
        return Connector(
          builder: (BuildContext context) {
            final app = context.state as App;

            if (!app.initialized) {
              // TODO: use the native platform splash screen functionality instead
              return SplashScreen();
            }

            return MaterialApp(
              debugShowCheckedModeBanner: false,
              theme: ThemeData.dark(),
              home: Material(child: MainScreen(app: app)),
            );
          },
        );
      }
    ),
  );

  doWhenWindowReady(() {
    appWindow.minSize = Size(800, 800);
    appWindow.show();
  });
}
