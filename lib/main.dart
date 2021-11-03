import 'package:bitsdojo_window/bitsdojo_window.dart';
import 'package:flutter/services.dart';
import 'package:flutter/material.dart';
import 'package:muex_flutter/muex_flutter.dart';

import 'core/app.dart';
import 'core/context.dart';
import 'widgets/splash_screen.dart';
import 'widgets/theming.dart';

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
            final initialized = app.initialized;

            if (!initialized) {
              // TODO: use the native platform splash screen functionality instead
              return SplashScreen();
            }

            return MaterialApp(
              debugShowCheckedModeBanner: false,
              theme: ThemeData.dark(),
              builder: (_, Widget? child) {
                return Themer(
                  kind: ThemeKind.dark,
                  child: child!,
                );
              },
              home: Builder(
                builder: (BuildContext context) {
                  return Material(
                    color: Theming.of(context).canvasColor,
                    child: MainScreen()
                  );
                },
              ),
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
