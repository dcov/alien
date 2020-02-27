import 'package:elmer_flutter/elmer_flutter.dart';
import 'package:flutter/cupertino.dart';

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
    
  }
}

