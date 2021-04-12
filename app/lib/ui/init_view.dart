import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:muex_flutter/muex_flutter.dart';

import '../model/app.dart';
import '../ui/app_route.dart';
import '../ui/themer.dart';
import '../ui/scroll_configuration.dart';
import '../ui/routing.dart';
import '../ui/splash_screen.dart';
import '../ui/theming.dart';

/// The root view in the tree.
///
/// It handles the one-off configuration of the application, and the initial
/// phase between when the [App] state has yet to be initialized, in which it
/// renders a graphic, and after it's been initialized, in which it renders the
/// initialized [App] state and doesn't rebuild anymore.
class InitView extends StatefulWidget {

  InitView({ Key? key })
    : super(key: key);

  @override
  _InitViewState createState() => _InitViewState();
}

class _InitViewState extends State<InitView> {

  late final appRoute = AppRoute(app: context.state as App);

  @override
  Widget build(_) {
    /// Only allow portrait-up orientation. Certain [Widget]s will change this
    /// as needed, but the default is portrait-up.
    SystemChrome.setPreferredOrientations(const <DeviceOrientation>[
      DeviceOrientation.portraitUp,
    ]);

    return Connector(
      builder: (BuildContext context) {
        final app = context.state as App;
        final initialized = app.initialized;
        final theme = app.theme;

        if (!initialized) {
          // TODO: use the native platform splash screen functionality instead
          return SplashScreen();
        }

        return MaterialApp(
          debugShowCheckedModeBanner: false,
          theme: ThemeData.dark(),
          builder: (_, Widget? child) {
            return Themer(
              theme: theme,
              child: child!);
          },
          home: ScrollConfiguration(
            behavior: CustomScrollBehavior(),
            child: Builder(
              builder: (BuildContext context) {
                return Material(
                  color: Theming.of(context).canvasColor,
                  child: Routing(root: appRoute));
              })));
      });
  }
}
