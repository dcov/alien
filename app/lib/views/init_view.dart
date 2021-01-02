import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:mal_flutter/mal_flutter.dart';

import '../models/app.dart';
import '../widgets/routing.dart';
import '../widgets/scroll_configuration.dart';
import '../widgets/splash_screen.dart';

import 'app_page.dart';
import 'themer.dart';

/// The root view in the tree.
///
/// It handles the one-off configuration of the application, and the initial
/// phase between when the [App] state has yet to be initialized, in which it
/// renders a graphic, and after it's been initialized, in which it renders the
/// initialized [App] state and doesn't rebuild anymore.
class InitView extends StatelessWidget {

  InitView({ Key key })
    : super(key: key);

  @override
  Widget build(_) {
    /// Only allow portrait-up orientation. Certain [Widget]s will change this
    /// as needed, but the default is portrait-up.
    SystemChrome.setPreferredOrientations(const <DeviceOrientation>[
      DeviceOrientation.portraitUp,
    ]);

    return Connector(
      builder: (BuildContext context) {
        final App app = context.state;

        /// This check does two things: It checks whether the state has been
        /// initialized and returns a splash graphic if it hasn't, but more importantly
        /// it let's [Connector] know that the only value we depend on is
        /// the [app.initialized] value. This means we'll only rebuild once:
        /// when the [app.initialized] value is set to [true].
        if (!app.initialized)
          return SplashScreen();

        return MaterialApp(
          debugShowCheckedModeBanner: false,
          builder: (_, Widget child) {
            return Themer(
              theming: app.theming,
              child: child);
          },
          home: ScrollConfiguration(
            behavior: CustomScrollBehavior(),
            child: Material(
              child: Routing(
                initialPageName: AppPage.pageName,
                initialPageBuilder: (String name) {
                  return AppPage(app: app, name: name);
                }))));
      });
  }
}

