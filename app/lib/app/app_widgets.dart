import 'package:elmer_flutter/elmer_flutter.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../browse/browse_widgets.dart';
import '../theming/theming_widgets.dart';
import '../user/user_model.dart';
import '../user/user_widgets.dart';
import '../widgets/animated_offstage.dart';
import '../widgets/bottom_navigation.dart';
import '../widgets/bottom_sheet_layout.dart';
import '../widgets/page.dart';
import '../widgets/scroll_configuration.dart';
import '../widgets/widget_extensions.dart';

import 'app_model.dart';

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

class _ScaffoldState extends State<_Scaffold>
    with TrackerStateMixin {

  int _currentIndex = 0;

  User _currentUser;

  @override
  void track(StateSetter setState) {
    setState(() {
      _currentUser = widget.app.auth.currentUser;
    });
  }

  Widget _buildTabView(int index) {
    final Widget navigator = PageNavigator(
      // We use a [ValueKey] for the navigator with the current [User] as a 
      // value so that when it changes, the navigation stack resets.
      key: ValueKey(_currentUser),
      onGeneratePage: (RouteSettings settings) {
        if (settings.name == "/") {
          switch (index) {
            case 0:
              return BrowsePage(
                settings: settings,
                browse: widget.app.browse);
            case 1:
              return UserPage(
                settings: settings,
                user: widget.app.auth.currentUser);
          }
        }
        throw ArgumentError("");
      });

    return AnimatedOffstage(
      offstage: index != _currentIndex,
      child: navigator);
  }

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = context.theme;
    return Material(
      child: BottomSheetLayout(
        body: Stack(
          fit: StackFit.expand,
          children: List.generate(2, _buildTabView)),
        sheetBuilder: (_, __) {
          return DecoratedBox(
            decoration: BoxDecoration(
              color: theme.canvasColor,
              border: Border.all(
                width: 0.0,
                color: Color(0x4C000000)),
              borderRadius: BorderRadius.vertical(
                top: Radius.circular(16.0))),
            child: Stack(
              children: <Widget>[
                BottomNavigation(
                    activeColor: theme.accentColor,
                    inactiveColor: theme.tabBarTheme.labelColor,
                    currentIndex: _currentIndex,
                    items: <BottomNavigationBarItem>[
                      BottomNavigationBarItem(
                        icon: Icon(Icons.home)),
                      BottomNavigationBarItem(
                        icon: Icon(Icons.person)),
                    ],
                    onTap: (int index) {
                      setState(() {
                        _currentIndex = index;
                      });
                    }),
              ]));
        }));
  }
}

