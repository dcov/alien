import 'package:elmer_flutter/elmer_flutter.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../logic/subscriptions.dart';
import '../models/app.dart';
import '../models/auth.dart';
import '../models/subscriptions.dart';
import '../widgets/routing.dart';
import '../widgets/widget_extensions.dart';

class AppPage extends EntryPage {

  AppPage({
    @required this.app,
    @required String name
  }) : super(name: name);

  final App app;

  @override
  Route createRoute(_) {
    return PageRouteBuilder(
      settings: this,
      pageBuilder: (BuildContext context, Animation<double> _, Animation<double> __) {
        return _AppPageView(app: app);
      });
  }
}

class _AppPageView extends StatelessWidget {

  _AppPageView({
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
        _AppPageBody(app: app),
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

class _AppPageBody extends StatelessWidget {

  _AppPageBody({
    Key key,
    @required this.app,
  }) : super(key: key);

  final App app;

  @override
  Widget build(BuildContext context) {
    final entries = context.routingData.entries;
    final slivers = List<Widget>();
    if (app.auth.currentUser != null) {
      slivers.add(_HomeTile());
    }

    return CustomScrollView(
      slivers: <Widget>[
        if (app.auth.currentUser != null)
          ...[
            SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.all(16.0),
                child: Text('Subscriptions'))),
            SliverList(
              delegate: SliverChildBuilderDelegate(
                (BuildContext context, int index) {
                },
              childCount: app.subscriptions.subreddits.length))
          ]
        else
          ...[
          ]
      ]);
  }
}

class _HomeTile extends StatelessWidget {

  _HomeTile({ Key key })
    : super(key: key);

  @override
  Widget build(BuildContext context) {
  }
}

