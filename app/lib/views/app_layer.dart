import 'package:flutter/material.dart';
import 'package:muex_flutter/muex_flutter.dart';

import '../models/app.dart';
import '../models/subreddit.dart';
import '../widgets/pressable.dart';
import '../widgets/shell.dart';

import 'subreddit_route.dart';

class AppLayer extends ShellRoot {

  AppLayer({
    required this.app
  });

  final App app;

  @override
  Widget buildLayer(BuildContext context, Map<String, ShellNode> nodes) {
    return Connector(
      builder: (BuildContext context) {
        final children = <Widget>[];
        final defaults = app.defaults;
        final subscriptions = app.subscriptions;
        if (defaults != null) {
          children.add(_SublistHeader(name: 'DEFAULTS'));
          children.addAll(
            defaults.items.map((Subreddit subreddit) {
              return SubredditTile(
                subreddit: subreddit,
                routePath: subredditRoutePathFrom('defaults:', subreddit));
            }));
        } else {
          assert(subscriptions != null);
          children.add(_SublistHeader(name: 'SUBSCRIPTIONS'));
          children.addAll(
            subscriptions!.items.map((Subreddit subreddit) {
              return SubredditTile(
                subreddit: subreddit,
                routePath: subredditRoutePathFrom('subscriptions:', subreddit));
            }));
        }
        return CustomScrollView(
          slivers: <Widget>[
            SliverAppBar(
              toolbarHeight: 48.0,
              backgroundColor: Theme.of(context).canvasColor,
              leading: PressableIcon(
                icon: Icons.settings,
                iconColor: Colors.grey)),
            SliverList(
              delegate: SliverChildListDelegate(children))
          ]);
      });
  }
}

class _SublistHeader extends StatelessWidget {

  _SublistHeader({
    Key? key,
    required this.name
  }) : super(key: key);

  final String name;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(color: Colors.grey.shade200),
      child: SizedBox(
        height: 30.0,
        child: Align(
          alignment: AlignmentDirectional.centerStart,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Text(
              name,
              style: TextStyle(
                color: Colors.grey.shade700,
                letterSpacing: 1.0,
                fontSize: 10.0,
                fontWeight: FontWeight.w700))))));
  }
}