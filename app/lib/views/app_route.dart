import 'package:elmer_flutter/elmer_flutter.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../models/app.dart';
import '../widgets/routing.dart';
import '../widgets/widget_extensions.dart';

class AppRoute extends EntryRoute {

  AppRoute({
    @required this.app,
    @required RouteSettings settings
  }) : super(settings: settings);

  final App app;

  @override
  Widget buildPage(BuildContext context, _, __) {
    return _AppPage(app: app);
  }
}

class _AppPage extends StatelessWidget {

  _AppPage({
    Key key,
    @required this.app
  }) : super(key: key);

  final App app;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        Material(
          child: Padding(
            padding: EdgeInsets.only(top: context.mediaPadding.top),
            child: SizedBox(
              height: 48.0,
              child: Row(
                children: <Widget>[
                  _AuthHeader(auth: app.auth),
                ])))),
        _AppBody(app: app),
      ]);
  }
}

class _AuthHeader extends StatelessWidget {

  _AuthHeader({
    Key key,
    @required this.auth
  }) : super(key: key);

  final Auth auth;

  @override
  Widget build(BuildContext context) {
    return Connector(
      builder: (_) {
        return Row(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Text(auth.currentUser?.name ?? 'Sign in'),
            Icon(Icons.arrow_downward)
          ]);
      });
  }
}

class _AppBody extends StatelessWidget {

  _AppBody({
    Key key,
    @required this.app,
  }) : super(key: key);

  final App app;

  @override
  Widget build(BuildContext context) {
    final entryNames = context.routingData.entryNames;
    return CustomScrollView(
      slivers: <Widget>[
      ]);
  }
}

