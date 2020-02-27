import 'package:elmer_flutter/elmer_flutter.dart';
import 'package:flutter/widgets.dart';

import 'browse_model.dart';

class BrowseTabView extends StatefulWidget {

  BrowseTabView({
    Key key,
  }) : super(key: key);



  @override
  _BrowseTabViewState createState() => _BrowseTabViewState();
}

class _BrowseTabViewState extends State<BrowseTabView> {

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

