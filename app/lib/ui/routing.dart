import 'package:flutter/cupertino.dart';

import '../utils/path_router.dart';

mixin _Route {

  void initState(BuildContext context) { }

  void didChangeDependencies(BuildContext context) { }

  void dispose(BuildContext context) { }

  Widget build(BuildContext context);
}

abstract class RootRoute with _Route { }

abstract class ChildRoute extends PathRoute with _Route { }

final _kPrimaryTween = Tween<Offset>(begin: Offset(1.0, 0.0), end: Offset.zero);

final _kSecondaryTween = Tween<Offset>(begin: Offset.zero, end: Offset(-(1.0/3.0), 0.0));

class _RoutePage extends Page {

  _RoutePage({
    required this.route
  });

  final _Route route;

  Widget _buildPage(BuildContext context, Animation<double> primaryAnimation, Animation<double> secondaryAnimation) {
    return SlideTransition(
      position: primaryAnimation.drive(_kPrimaryTween),
      child: SlideTransition(
        position: secondaryAnimation.drive(_kSecondaryTween),
        child: route.build(context)));
  }

  @override
  Route createRoute(BuildContext context) {
    return PageRouteBuilder(
      settings: this,
      pageBuilder: _buildPage);
  }
}

class Routing extends StatefulWidget {

  Routing({
    Key? key,
    required this.root
  }) : super(key: key);

  final RootRoute root;

  @override
  _RoutingState createState() => _RoutingState();
}

class _RoutingState extends State<Routing> {

  @override
  Widget build(BuildContext context) {
    return Navigator(
      pages: <Page>[
      ]);
  }
}
