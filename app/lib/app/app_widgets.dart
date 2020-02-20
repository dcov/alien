import 'package:elmer_flutter/elmer_flutter.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../theming/theming_widgets.dart';
import '../widgets/bottom_sheet_layout.dart';
import '../widgets/scroll_configuration.dart';

import 'app_model.dart';

/// The root widget in the tree.
///
/// It handles the one-off configuration of the application, and the initial
/// phase between when the [App] state has yet to be initialized, in which it
/// renders a graphic, and after it's been initialized, in which it renders the
/// initialized [App] state and doesn't rebuild anymore.
class Runner extends StatelessWidget {

  Runner({ Key key }) : super(key: key);

  @override
  Widget build(_) {
    /// Only allow portrait-up orientation. Certain [Widget]s will change this
    /// as needed, but the default is portrait-up.
    SystemChrome.setPreferredOrientations(const <DeviceOrientation>[
      DeviceOrientation.portraitUp,
    ]);

    return Tracker(
      builder: (BuildContext context) {
        final App app = context.state;

        /// This check does two things: It checks whether the state has been
        /// initialized and returns [_Splash] if it hasn't, but more importantly
        /// it let's [Connector] know that the only value we depend on is
        /// the [app.initialized] value. This means we'll only rebuild once -
        /// when the [app.initialized] value is set to [true].
        if (!app.initialized)
          return _Splash();

        return MaterialApp(
          debugShowCheckedModeBanner: false,
          builder: (_, Widget child) {
            return Themer(
              theming: app.theming,
              child: child,
            );
          },
          home: ScrollConfiguration(
            behavior: CustomScrollBehavior(),
            child: _Main(app: app)
          )
        );
      }
    );
  }
}

class _Splash extends StatelessWidget {

  const _Splash({ Key key }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const SizedBox();
  }
}

/// The main [Widget] in the tree which essentially wires up all of the 
/// top-level components of the app.
class _Main extends StatefulWidget {

  _Main({
    Key key,
    this.app,
  }) : super(key: key);

  final App app;

  @override
  _MainState createState() => _MainState();
}

class _MainState extends State<_Main> {

  @override
  Widget build(_) {
    return Material(
      child: BottomSheetLayout(
        body: Scaffold(
          appBar: AppBar(title: Text('Alien'))
        ),
        sheetBuilder: (_, __) {
          return Material(
            elevation: 4.0,
            color: Colors.grey,
            child: SizedBox.expand()
          );
        }
      )
    );
  }
}

