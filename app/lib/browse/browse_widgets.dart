import 'package:elmer_flutter/elmer_flutter.dart';
import 'package:flutter/widgets.dart';

import 'browse_model.dart';

class BrowseTabController extends StatefulWidget {

  BrowseTabController({
    Key key,
  }) : super(key: key);

  @override
  _BrowseTabControllerState createState() => _BrowseTabControllerState();
}

class _BrowseTabControllerState extends State<BrowseTabController> {

  final GlobalKey<NavigatorState> _navigatorKey = GlobalKey<NavigatorState>();

  @override
  Widget build(BuildContext context) {
    return Navigator(
      key: _navigatorKey,
      );
  }
}

class _BrowseView extends StatelessWidget {

  @override
  Widget build(BuildContext context) {
  }
}

