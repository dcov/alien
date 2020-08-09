import 'package:elmer_flutter/elmer_flutter.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../models/app.dart';

/// The main [Widget] in the tree which essentially wires up all of the 
/// top-level components of the app.
class AppController extends StatefulWidget {

  AppController({
    Key key,
    @required this.app,
  }) : super(key: key);

  final App app;

  @override
  _AppControllerState createState() => _AppControllerState();
}

class _AppControllerState extends State<AppController> {

  final _navigatorKey = GlobalKey<NavigatorState>();

  @override
  void initState() {
    super.initState();

    _navigatorKey.currentState.
  }

  @override
  Widget build(BuildContext context) {
    return Navigator(
      key: _navigatorKey
      );
  }
}

