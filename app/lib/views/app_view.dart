import 'package:flutter/widgets.dart';

import '../models/app.dart';
import '../widgets/routing.dart';

import 'app_route.dart';

class AppView extends StatelessWidget {

  AppView({
    Key key,
    @required this.app
  }) : super(key: key);

  final App app;

  @override
  Widget build(BuildContext context) {
    return Routing(
      initialRouteName: 'app',
      initialRouteBuilder: (BuildContext context, RouteSettings settings) {
      });
  }
}

