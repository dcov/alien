import 'package:elmer_flutter/elmer_flutter.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../browse/browse_widgets.dart';
import '../theming/theming_widgets.dart';
import '../widgets/bottom_navigation.dart';
import '../widgets/bottom_sheet_layout.dart';
import '../widgets/page.dart';
import '../widgets/scroll_configuration.dart';

import 'app_model.dart';

/// The root widget in the tree.
///
/// It handles the one-off configuration of the application, and the initial
/// phase between when the [App] state has yet to be initialized, in which it
/// renders a graphic, and after it's been initialized, in which it renders the
/// initialized [App] state and doesn't rebuild anymore.
class Runner extends StatelessWidget {

  Runner({ Key key })
    : super(key: key);

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
        /// it let's [Tracker] know that the only value we depend on is
        /// the [app.initialized] value. This means we'll only rebuild once -
        /// when the [app.initialized] value is set to [true].
        if (!app.initialized)
          return _Splash();

        return CupertinoApp(
          debugShowCheckedModeBanner: false,
          builder: (_, Widget child) {
            return Themer(
              theming: app.theming,
              child: child);
          },
          home: ScrollConfiguration(
            behavior: CustomScrollBehavior(),
            child: _Scaffold(app: app)));
      });
  }
}

class _Splash extends StatelessWidget {

  const _Splash({ Key key })
    : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const SizedBox();
  }
}

/// The main [Widget] in the tree which essentially wires up all of the 
/// top-level components of the app.
class _Scaffold extends StatefulWidget {

  _Scaffold({
    Key key,
    this.app,
  }) : super(key: key);

  final App app;

  @override
  _ScaffoldState createState() => _ScaffoldState();
}

class _ScaffoldState extends State<_Scaffold> {

  List<GlobalKey> _tabKeys;
  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
    resetKeys();
  }

  void resetKeys() {
    _tabKeys = List.generate(4, (_) => GlobalKey());
  }

  Widget _buildTabNavigator(GlobalKey key, PageFactory onGenerateRoute) {
    return PageNavigator(
      key: key,
      onGeneratePage: (RouteSettings settings) {
        if (settings.name == "/") {
          return onGenerateRoute(settings);
        }
        throw ArgumentError("");
      });
  }

  Widget _buildTabView() {
    switch (_currentIndex) {
      case 0:
        return _buildTabNavigator(
          _tabKeys[0],
          (RouteSettings settings) {
            return BrowsePage(
              settings: settings,
              browse: widget.app.browse);
          });
      case 1:
        return _buildTabNavigator(
          _tabKeys[1],
          (RouteSettings settings) {
            return null;
          });
      case 2:
        return _buildTabNavigator(
          _tabKeys[2],
          (RouteSettings settings) {
            return null;
          });
      case 3:
        return _buildTabNavigator(
          _tabKeys[3],
          (RouteSettings settings) {
            return null;
          });
    }
    throw StateError("The current tab index in the app scaffold is not valid, index is $_currentIndex");
  }

  @override
  Widget build(_) {
    return BottomSheetLayout(
      body: AnimatedSwitcher(
        duration: const Duration(milliseconds: 250),
        child: _buildTabView()),
      sheetBuilder: (_, __) {
        return Stack(
          children: <Widget>[
            BottomNavigation(
              currentIndex: _currentIndex,
              items: <BottomNavigationBarItem>[
                BottomNavigationBarItem(
                  icon: Icon(Icons.home)),
                BottomNavigationBarItem(
                  icon: Icon(Icons.search)),
                BottomNavigationBarItem(
                  icon: Icon(Icons.mail)),
                BottomNavigationBarItem(
                  icon: Icon(Icons.person)),
              ],
              onTap: (int index) {
                setState(() {
                  _currentIndex = index;
                });
              }),
          ]);
      });
  }
}

