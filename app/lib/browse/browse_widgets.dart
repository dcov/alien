import 'package:elmer_flutter/elmer_flutter.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../home/home_widgets.dart';
import '../subscriptions/subscriptions_widgets.dart';

import 'browse_model.dart';

class BrowseTabView extends StatefulWidget {

  BrowseTabView({
    Key key,
    @required this.browse,
  }) : assert(browse != null),
       super(key: key);

  final Browse browse;

  @override
  _BrowseTabViewState createState() => _BrowseTabViewState();
}

class _BrowseTabViewState extends State<BrowseTabView> {

  final GlobalKey<NavigatorState> _navigatorKey = GlobalKey<NavigatorState>();

  @override
  Widget build(BuildContext context) {
    return CupertinoTabView(
      key: _navigatorKey,
      onGenerateRoute: (RouteSettings settings) {
        if (settings.name != "/")
          throw ArgumentError("BrowseTabController cannot generate a route for ${settings.name}");

        return CupertinoPageRoute(
          title: "Browse",
          builder: (BuildContext context) {
            return _BrowsePage(browse: widget.browse);
          });
      });
  }
}

class _BrowsePage extends StatelessWidget {

  _BrowsePage({
    Key key,
    @required this.browse
  }) : assert(browse != null),
       super(key: key);

  final Browse browse;

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      navigationBar: CupertinoNavigationBar(
        trailing: GestureDetector(
          onTap: () {},
          child: Icon(Icons.more_vert))),
      child: CustomScrollView(
        slivers: <Widget>[
          if (browse.home != null)
            HomeTile(home: browse.home),
        ]));
  }
}

